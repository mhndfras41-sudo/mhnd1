import asyncio
import discord
from discord.ext import commands
from discord import app_commands
import os
import threading
from flask import Flask
import random
import time
import math
import re

# --- 24/7 keep-alive web server ---
app = Flask('')

@app.route('/')
def home():
    return "Bot is Alive!"

def run_web_server():
    app.run(host='0.0.0.0', port=8000)

def keep_alive():
    t = threading.Thread(target=run_web_server)
    t.start()

# --- Bot setup ---
intents = discord.Intents.default()
intents.message_content = True
intents.members = True
bot = commands.Bot(command_prefix="!", intents=intents)

# --- Configuration (in-memory) ---
verify_message_id = None
verify_role_ids = []
ticket_staff_role_id = None
ticket_category_id = None
rating_channel_id = None
tax_channel_id = None

# --- Locks & Cooldowns ---
_verify_lock = asyncio.Lock()
_ad_cooldowns = {}
_rating_cooldowns = {}
_last_tax_reply = {}
TAX_COOLDOWN_SECONDS = 5
AD_COOLDOWN_DURATION = 7200
RATING_COOLDOWN = 86400  # 24 ساعة كول داون للتقييم

# --- Utility Functions ---
_AMOUNT_RE = re.compile(r"^\d{1,12}(\.\d{1,4})?[mk]?$")
MAX_TAX_AMOUNT = 1_000_000_000_000

def parse_amount(text: str):
    text = text.strip().lower().replace(",", "")
    if not text or not _AMOUNT_RE.match(text):
        return None
    multiplier = 1
    if text.endswith('m'): multiplier = 1_000_000; text = text[:-1]
    elif text.endswith('k'): multiplier = 1_000; text = text[:-1]
    try:
        value = float(text)
    except ValueError:
        return None
    result = value * multiplier
    if result <= 0 or result > MAX_TAX_AMOUNT:
        return None
    return result

def format_amount(value: float) -> str:
    if value == int(value):
        return f"{int(value):,}"
    return f"{value:,.2f}"

# --- UI Components ---

class AdModal(discord.ui.Modal):
    def __init__(self, target_channel_id: int, channel_name: str):
        super().__init__(title=f"انشر إعلان في قسم: {channel_name}")
        self.target_channel_id = target_channel_id
        self.item = discord.ui.TextInput(label="المنتج", placeholder="مثال: حساب ببجي", required=True)
        self.price = discord.ui.TextInput(label="السعر", placeholder="مثال: 50 ريال", required=True)
        self.details = discord.ui.TextInput(label="تفاصيل إضافية", style=discord.TextStyle.paragraph, required=False)
        self.add_item(self.item)
        self.add_item(self.price)
        self.add_item(self.details)

    async def on_submit(self, interaction: discord.Interaction):
        embed = discord.Embed(title="📦 إعلان جديد", color=discord.Color.green())
        embed.add_field(name="المنتج", value=self.item.value, inline=False)
        embed.add_field(name="السعر", value=self.price.value, inline=False)
        if self.details.value:
            embed.add_field(name="التفاصيل", value=self.details.value, inline=False)
        embed.set_footer(text=f"البائع: {interaction.user}")
        
        target = interaction.guild.get_channel(self.target_channel_id)
        if target:
            await target.send(embed=embed)
        _ad_cooldowns[interaction.user.id] = time.time()
        await interaction.response.send_message("✅ تم نشر إعلانك بنجاح", ephemeral=True)

class CloseTicketView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
    
    @discord.ui.button(label="🔒 إغلاق التذكرة", style=discord.ButtonStyle.danger, custom_id="close_ticket")
    async def close_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message("سيتم حذف الروم خلال 5 ثواني...", ephemeral=False)
        await asyncio.sleep(5)
        await interaction.channel.delete()

class TicketPanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
        
    async def process_ticket_creation(self, interaction: discord.Interaction, ticket_type: str):
        guild = interaction.guild
        existing = discord.utils.get(guild.text_channels, name=f"ticket-{interaction.user.name}".lower())
        if existing:
            await interaction.response.send_message("⚠️ لديك تذكرة مفتوحة، جاري حذفها لفتح تذكرة جديدة...", ephemeral=True)
            await existing.delete()
            
        overwrites = {
            guild.default_role: discord.PermissionOverwrite(view_channel=False),
            interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True),
            guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True)
        }
        if ticket_staff_role_id:
            staff_role = guild.get_role(ticket_staff_role_id)
            if staff_role: overwrites[staff_role] = discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True)
        
        category = guild.get_channel(ticket_category_id)
        channel = await guild.create_text_channel(name=f"ticket-{interaction.user.name}", category=category, overwrites=overwrites)
        
        embed = discord.Embed(title=f"🎫 تذكرة {ticket_type}", description=f"أهلاً {interaction.user.mention}، سيقوم المختص بالرد عليك قريباً.", color=discord.Color.blue())
        mention = f"<@&{ticket_staff_role_id}>" if ticket_staff_role_id else ""
        await channel.send(content=mention, embed=embed, view=CloseTicketView())
        
        if not interaction.response.is_done():
            await interaction.response.send_message(f"✅ تم إنشاء تذكرتك: {channel.mention}", ephemeral=True)

    @discord.ui.button(label="🎫 تذكرة دعم", style=discord.ButtonStyle.primary, custom_id="support_ticket")
    async def support_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        await self.process_ticket_creation(interaction, "الدعم الفني")

    @discord.ui.button(label="🤝 تذكرة وسيط", style=discord.ButtonStyle.success, custom_id="middleman_ticket")
    async def middleman_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        await self.process_ticket_creation(interaction, "الوساطة")

class ChannelSelect(discord.ui.Select):
    def __init__(self):
        options = [
            discord.SelectOption(label="روم الحسابات", value="1524578445894615060", emoji="👤"),
            discord.SelectOption(label="روم ديسكورد", value="1524578492262383787", emoji="💬"),
            discord.SelectOption(label="روم التصاميم", value="1524578533467488286", emoji="🎨"),
            discord.SelectOption(label="روم الالعاب", value="1524578615788830780", emoji="🎮"),
            discord.SelectOption(label="روم طلبات", value="1525211150986383522", emoji="📥"),
            discord.SelectOption(label="روم اخرى", value="1524578574273745057", emoji="⚙️"),
        ]
        super().__init__(placeholder="اختر القسم...", options=options)

    async def callback(self, interaction: discord.Interaction):
        await interaction.response.send_modal(AdModal(target_channel_id=int(self.values[0]), channel_name=self.values[0]))

class TradePanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
        self.add_item(ChannelSelect())

# --- Commands ---

@bot.tree.command(name="calculate_tax", description="حساب ضريبة البروبوت + ضريبة الوسيط (25%)")
async def calculate_tax(interaction: discord.Interaction, amount: float):
    probot_total = math.ceil((amount * 20) / 19)
    probot_fee = probot_total - amount
    broker_fee = amount * 0.25
    total_needed = probot_total + broker_fee
    
    embed = discord.Embed(title="💰 حاسبة الضرائب الشاملة", color=discord.Color.gold())
    embed.add_field(name="المبلغ الأساسي", value=format_amount(amount), inline=True)
    embed.add_field(name="ضريبة البروبوت (5.26%)", value=format_amount(probot_fee), inline=True)
    embed.add_field(name="ضريبة الوسيط (25%)", value=format_amount(broker_fee), inline=True)
    embed.add_field(name="المبلغ الإجمالي للتحويل", value=format_amount(total_needed), inline=False)
    await interaction.response.send_message(embed=embed)

@bot.tree.command(name="setup_verify", description="نشر لوحة التحقق")
@app_commands.checks.has_permissions(administrator=True)
async def setup_verify(interaction: discord.Interaction, role1: discord.Role, role2: discord.Role=None, role3: discord.Role=None):
    global verify_message_id, verify_role_ids
    roles = [r for r in [role1, role2, role3] if r is not None]
    verify_role_ids = [r.id for r in roles]
    roles_text = "\n".join([r.mention for r in roles])
    embed = discord.Embed(title="✅ تحقق من هويتك", description=f"اضغط على الإيموجي ✅ للتحقق والحصول على رتبة:\n{roles_text}", color=discord.Color.gold())
    await interaction.response.send_message(embed=embed)
    msg = await interaction.original_response()
    await msg.add_reaction("✅")
    verify_message_id = msg.id

@bot.tree.command(name="setup_rating", description="تحديد الروم المخصص للتقييمات")
@app_commands.checks.has_permissions(administrator=True)
async def setup_rating(interaction: discord.Interaction, channel: discord.TextChannel):
    global rating_channel_id
    rating_channel_id = channel.id
    await interaction.response.send_message(f"✅ تم تحديد {channel.mention} ليكون روم التقييمات.", ephemeral=True)

@bot.tree.command(name="rate", description="تقييم وسيط (من 1 إلى 5)")
async def rate(interaction: discord.Interaction, user: discord.Member, stars: int, comment: str):
    if not rating_channel_id:
        await interaction.response.send_message("❌ لم يتم تحديد روم التقييم من قبل الإدارة.", ephemeral=True)
        return
    if not (1 <= stars <= 5):
        await interaction.response.send_message("❌ التقييم يجب أن يكون بين 1 و 5.", ephemeral=True)
        return
        
    last_rate = _rating_cooldowns.get(interaction.user.id, 0)
    if time.time() - last_rate < RATING_COOLDOWN:
        await interaction.response.send_message("❌ لا يمكنك التقييم الآن، يرجى الانتظار 24 ساعة.", ephemeral=True)
        return

    channel = interaction.guild.get_channel(rating_channel_id)
    if not channel:
        await interaction.response.send_message("❌ روم التقييم غير موجود.", ephemeral=True)
        return

    embed = discord.Embed(title="⭐ تقييم جديد", color=discord.Color.yellow())
    embed.add_field(name="الوسيط", value=user.mention, inline=True)
    embed.add_field(name="التقييم", value="⭐" * stars, inline=True)
    embed.add_field(name="التعليق", value=comment, inline=False)
    embed.set_footer(text=f"العميل: {interaction.user}")
    
    await channel.send(embed=embed)
    _rating_cooldowns[interaction.user.id] = time.time()
    await interaction.response.send_message("✅ تم إرسال تقييمك بنجاح!", ephemeral=True)

@bot.tree.command(name="setup_ticket", description="نشر لوحة التذاكر")
@app_commands.checks.has_permissions(administrator=True)
async def setup_ticket(interaction: discord.Interaction, staff_role: discord.Role=None, category: discord.CategoryChannel=None):
    global ticket_staff_role_id, ticket_category_id
    if staff_role: ticket_staff_role_id = staff_role.id
    if category: ticket_category_id = category.id
    embed = discord.Embed(title="🎫 تذاكر السيرفر", description="اختر نوع التذكرة:", color=discord.Color.blue())
    await interaction.response.send_message(embed=embed, view=TicketPanelView())

@bot.tree.command(name="setup_trade", description="نشر لوحة نشر الإعلانات")
@app_commands.checks.has_permissions(administrator=True)
async def setup_trade(interaction: discord.Interaction):
    embed = discord.Embed(title="🛒 سوق التجارة", description="اختر القسم المناسب من القائمة أدناه لنشر إعلانك فيه.", color=discord.Color.blurple())
    await interaction.response.send_message(embed=embed, view=TradePanelView())

@bot.tree.command(name="set_tax_channel", description="تحديد روم الضريبة التلقائي")
@app_commands.checks.has_permissions(administrator=True)
async def set_tax_channel(interaction: discord.Interaction, channel: discord.TextChannel=None):
    global tax_channel_id
    channel = channel or interaction.channel
    tax_channel_id = channel.id
    await interaction.response.send_message(f"✅ تم تفعيل حساب الضريبة في {channel.mention}.", ephemeral=True)

# --- Events ---

@bot.event
async def on_raw_reaction_add(payload):
    if payload.message_id != verify_message_id or str(payload.emoji) != "✅" or payload.member.bot: return
    if not verify_role_ids: return
    guild = bot.get_guild(payload.guild_id)
    if not guild: return
    async with _verify_lock:
        member = guild.get_member(payload.user_id)
        if member:
            chosen_role_id = random.choice(verify_role_ids)
            role = guild.get_role(chosen_role_id)
            if role: await member.add_roles(role)

@bot.event
async def on_message(message: discord.Message):
    if message.author.bot: return
    if tax_channel_id and message.channel.id == tax_channel_id:
        amount = parse_amount(message.content)
        if amount is not None:
            now = time.monotonic()
            last = _last_tax_reply.get(message.author.id, 0)
            if now - last >= TAX_COOLDOWN_SECONDS:
                _last_tax_reply[message.author.id] = now
                total_to_send = math.floor((amount * 20) / 19 + 1)
                tax = total_to_send - amount
                embed = discord.Embed(title="🧾 حساب ضريبة البروبوت", description="حوّل المبلغ الإجمالي أدناه.", color=discord.Color.orange())
                embed.add_field(name="المبلغ الصافي", value=format_amount(amount), inline=True)
                embed.add_field(name="الضريبة (5%)", value=format_amount(tax), inline=True)
                embed.add_field(name="💰 المبلغ الإجمالي", value=format_amount(total_to_send), inline=False)
                await message.reply(embed=embed)
    await bot.process_commands(message)

@bot.event
async def on_ready():
    bot.add_view(TicketPanelView())
    bot.add_view(CloseTicketView())
    bot.add_view(TradePanelView())
    await bot.tree.sync()
    print(f"Logged in as {bot.user} - Online!")

def main():
    token = os.environ.get("DISCORD_TOKEN")
    if not token:
        raise RuntimeError("DISCORD_TOKEN environment variable is not set.")
    keep_alive()
    bot.run(token)

if __name__ == "__main__":
    main()
        
