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
    port = int(os.environ.get("PORT", 8000))
    app.run(host='0.0.0.0', port=port)

def keep_alive():
    t = threading.Thread(target=run_web_server)
    t.start()

# --- Bot setup ---
intents = discord.Intents.default()
intents.message_content = True
intents.members = True
bot = commands.Bot(command_prefix="!", intents=intents)

# --- Verification configuration (in-memory) ---
verify_message_id = None
verify_role_ids = []

# --- Ticket configuration (in-memory) ---
ticket_staff_role_id = None
ticket_category_id = None
ticket_counter = 0

# --- Verification lock ---
_verify_lock = asyncio.Lock()

# --- Tax configuration (in-memory) ---
tax_channel_id = None
TAX_RATE = 0.05
TAX_RATE_WASIT = 0.25

_AMOUNT_RE = re.compile(r"^\d{1,12}(\.\d{1,4})?[mk]?$")
MAX_TAX_AMOUNT = 1_000_000_000_000

_last_tax_reply = {}
TAX_COOLDOWN_SECONDS = 5

_ad_cooldowns = {}
AD_COOLDOWN_DURATION = 7200

# --- Rating configuration (in-memory) ---
rating_channel_id = None

# --- Middleman (وسيط) ticket configuration (in-memory) ---
ticket_wasit_staff_role_id = None
ticket_wasit_category_id = None

def parse_amount(text: str):
    text = text.strip().lower().replace(",", "")
    if not text or not _AMOUNT_RE.match(text):
        return None
    multiplier = 1
    if text.endswith('m'):
        multiplier = 1_000_000
        text = text[:-1]
    elif text.endswith('k'):
        multiplier = 1_000
        text = text[:-1]
    try:
        value = float(text)
    except ValueError:
        return None
    if not (value == value) or value in (float('inf'), float('-inf')):
        return None
    result = value * multiplier
    if result <= 0 or result > MAX_TAX_AMOUNT:
        return None
    return result

def format_amount(value: float) -> str:
    if value == int(value):
        return f"{int(value):,}"
    return f"{value:,.2f}"

def compute_total_with_tax(amount: float, rate: float):
    total = math.floor(amount / (1 - rate) + 1)
    tax = total - amount
    return total, tax

# --- Ad posting modal ---
class AdModal(discord.ui.Modal):
    def __init__(self, target_channel_id: int, channel_name: str):
        super().__init__(title=f"انشر إعلان في قسم: {channel_name}")
        self.target_channel_id = target_channel_id
        
        self.item = discord.ui.TextInput(label="اسم المنتج / الحساب", placeholder="مثال: حساب ببجي، 5000 روبكس...", required=True, max_length=100)
        self.price = discord.ui.TextInput(label="السعر", placeholder="مثال: 50 ريال", required=True, max_length=50)
        self.details = discord.ui.TextInput(label="تفاصيل إضافية", style=discord.TextStyle.paragraph, placeholder="وصف المنتج، طريقة التسليم، إلخ...", required=False, max_length=500)
        
        self.add_item(self.item)
        self.add_item(self.price)
        self.add_item(self.details)

    async def on_submit(self, interaction: discord.Interaction):
        embed = discord.Embed(title="📦 إعلان جديد", color=discord.Color.green())
        embed.add_field(name="المنتج", value=self.item.value, inline=False)
        embed.add_field(name="السعر", value=self.price.value, inline=False)
        if self.details.value:
            embed.add_field(name="التفاصيل", value=self.details.value, inline=False)
        embed.set_author(name=interaction.user.display_name, icon_url=interaction.user.display_avatar.url)
        embed.set_footer(text=f"البائع: {interaction.user}")
        
        view = ContactButton(interaction.user.id)
        target_channel = interaction.guild.get_channel(self.target_channel_id) or interaction.channel
        await target_channel.send(embed=embed, view=view)
        
        _ad_cooldowns[interaction.user.id] = time.time()
        await interaction.response.send_message(f"✅ تم نشر إعلانك بنجاح في {target_channel.mention}", ephemeral=True)

class ContactButton(discord.ui.View):
    def __init__(self, seller_id: int):
        super().__init__(timeout=None)
        self.add_item(discord.ui.Button(label="تواصل مع البائع", style=discord.ButtonStyle.link, url=f"https://discord.com/users/{seller_id}"))

class ChannelSelect(discord.ui.Select):
    def __init__(self):
        options = [
            discord.SelectOption(label="روم الحسابات", description="نشر الإعلانات الخاصة بالحسابات", value="1524578445894615060", emoji="👤"),
            discord.SelectOption(label="روم ديسكورد", description="نشر الإعلانات الخاصة بسيرفرات أو خدمات ديسكورد", value="1524578492262383787", emoji="💬"),
            discord.SelectOption(label="روم التصاميم", description="نشر الإعلانات الخاصة بالتصاميم والغرافيكس", value="1524578533467488286", emoji="🎨"),
            discord.SelectOption(label="روم الالعاب", description="نشر الإعلانات الخاصة بالألعاب وحساباتها", value="1524578615788830780", emoji="🎮"),
            discord.SelectOption(label="روم طلبات", description="نشر الطلبات والخدمات المطلوبة", value="1525211150986383522", emoji="📥"),
            discord.SelectOption(label="روم اخرى", description="نشر الإعلانات المتنوعة الأخرى", value="1524578574273745057", emoji="⚙️"),
        ]
        super().__init__(placeholder="اختر القسم الذي تريد نشر إعلانك فيه...", min_values=1, max_values=1, options=options, custom_id="select_ad_channel")

    async def callback(self, interaction: discord.Interaction):
        user_id = interaction.user.id
        current_time = time.time()
        
        if user_id in _ad_cooldowns:
            time_passed = current_time - _ad_cooldowns[user_id]
            if time_passed < AD_COOLDOWN_DURATION:
                time_left = AD_COOLDOWN_DURATION - time_passed
                hours = int(time_left // 3600)
                minutes = int((time_left % 3600) // 60)
                time_msg = f"{hours} ساعة و " if hours > 0 else ""
                time_msg += f"{minutes} دقيقة"
                await interaction.response.send_message(f"❌ عذراً، يجب عليك الانتظار **{time_msg}** قبل نشر إعلان آخر لمنع السبام!", ephemeral=True)
                return
                
        chosen_channel_id = int(self.values[0])
        chosen_label = [o.label for o in self.options if o.value == self.values[0]][0]
        await interaction.response.send_modal(AdModal(target_channel_id=chosen_channel_id, channel_name=chosen_label))

class TradePanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
        self.add_item(ChannelSelect())

# --- Ticket system ---
class CloseTicketView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
        
    @discord.ui.button(label="🔒 إغلاق التذكرة", style=discord.ButtonStyle.danger, custom_id="close_ticket")
    async def close_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message("سيتم إغلاق التذكرة خلال 5 ثواني...", ephemeral=False)
        await interaction.channel.send("🔒 تم إغلاق التذكرة، جاري حذف الروم...")
        await asyncio.sleep(5)
        await interaction.channel.delete()

class WasitTicketPanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    @discord.ui.button(label="🤝 طلب وسيط", style=discord.ButtonStyle.success, custom_id="open_ticket_wasit")
    async def open_ticket_wasit(self, interaction: discord.Interaction, button: discord.ui.Button):
        guild = interaction.guild

        existing = discord.utils.get(guild.text_channels, name=f"wasit-{interaction.user.name}".lower())
        if existing:
            await interaction.response.send_message(f"⚠️ لديك تكت وسيط مفتوح بالفعل: {existing.mention}. أغلقه أولاً قبل فتح تكت جديد.", ephemeral=True)
            return

        overwrites = {
            guild.default_role: discord.PermissionOverwrite(view_channel=False),
            interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True),
            guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True)
        }
        if ticket_wasit_staff_role_id:
            staff_role = guild.get_role(ticket_wasit_staff_role_id)
            if staff_role:
                overwrites[staff_role] = discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True)

        category = guild.get_channel(ticket_wasit_category_id) if ticket_wasit_category_id else None
        channel = await guild.create_text_channel(name=f"wasit-{interaction.user.name}", category=category, overwrites=overwrites, reason=f"طلب وسيط جديد من {interaction.user}")

        embed = discord.Embed(title="🤝 طلب وسيط", description=f"أهلاً {interaction.user.mention}، وضّح تفاصيل الصفقة (الطرف الثاني، المبلغ، المنتج/الخدمة) وسيتم تعيين وسيط موثوق للإشراف على الصفقة قريباً.", color=discord.Color.teal())
        mention = f"<@&{ticket_wasit_staff_role_id}>" if ticket_wasit_staff_role_id else ""
        await channel.send(content=mention, embed=embed, view=CloseTicketView())

        if not interaction.response.is_done():
            await interaction.response.send_message(f"✅ تم إنشاء تكت الوسيط: {channel.mention}", ephemeral=True)

class TicketPanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
        
    @discord.ui.button(label="🎫 فتح تذكرة", style=discord.ButtonStyle.success, custom_id="open_ticket")
    async def open_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        global ticket_counter
        guild = interaction.guild
        
        existing = discord.utils.get(guild.text_channels, name=f"ticket-{interaction.user.name}".lower())
        if existing:
            await interaction.response.send_message("⚠️ لديك تذكرة قديمة، جاري حذفها لفتح تذكرة جديدة...", ephemeral=True)
            await existing.delete(reason="User opened a new ticket, deleting old one.")
            
        ticket_counter += 1
        overwrites = {
            guild.default_role: discord.PermissionOverwrite(view_channel=False),
            interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True),
            guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True)
        }
        if ticket_staff_role_id:
            staff_role = guild.get_role(ticket_staff_role_id)
            if staff_role:
                overwrites[staff_role] = discord.PermissionOverwrite(view_channel=True, send_messages=True, read_message_history=True)
                
        category = guild.get_channel(ticket_category_id) if ticket_category_id else None
        channel = await guild.create_text_channel(name=f"ticket-{interaction.user.name}", category=category, overwrites=overwrites, reason=f"تذكرة جديدة من {interaction.user}")
        
        embed = discord.Embed(title="🎫 تذكرة دعم جديدة", description=f"أهلاً {interaction.user.mention}، اشرح مشكلتك أو استفسارك وسيقوم أحد المسؤولين بالرد عليك قريباً.", color=discord.Color.blue())
        mention = f"<@&{ticket_staff_role_id}>" if ticket_staff_role_id else ""
        await channel.send(content=mention, embed=embed, view=CloseTicketView())
        
        if not interaction.response.is_done():
            await interaction.response.send_message(f"✅ تم إنشاء تذكرتك: {channel.mention}", ephemeral=True)

# --- Slash commands ---
@bot.tree.command(name="setup_trade", description="نشر لوحة نشر الإعلانات")
@app_commands.checks.has_permissions(administrator=True)
async def setup_trade(interaction: discord.Interaction):
    embed = discord.Embed(title="🛒 سوق التجارة", description="اختر القسم المناسب من القائمة أدناه لنشر إعلانك فيه.", color=discord.Color.blurple())
    await interaction.response.send_message(embed=embed, view=TradePanelView())

@bot.tree.command(name="setup_verify", description="نشر رسالة التحقق التي تمنح رتبة عشوائية عند الضغط على ✅")
@app_commands.checks.has_permissions(administrator=True)
async def setup_verify(interaction: discord.Interaction, role1: discord.Role, role2: discord.Role=None, role3: discord.Role=None, role4: discord.Role=None, role5: discord.Role=None):
    global verify_message_id, verify_role_ids
    roles = [r for r in [role1, role2, role3, role4, role5] if r is not None]
    verify_role_ids = [r.id for r in roles]
    
    roles_list = "\n".join(f"• {r.mention}" for r in roles)
    embed = discord.Embed(title="✅ إثبات الهوية", description=f"اضغط على الإيموجي ✅ أدناه لإثبات نفسك، وستحصل تلقائياً على رتبة عشوائية من الرتب التالية:\n\n{roles_list}", color=discord.Color.gold())
    await interaction.response.send_message(embed=embed)
    msg = await interaction.original_response()
    await msg.add_reaction("✅")
    verify_message_id = msg.id

@bot.tree.command(name="setup_ticket", description="نشر لوحة فتح التذاكر للتواصل مع الإدارة")
@app_commands.checks.has_permissions(administrator=True)
async def setup_ticket(interaction: discord.Interaction, staff_role: discord.Role=None, category: discord.CategoryChannel=None):
    global ticket_staff_role_id, ticket_category_id
    if staff_role: ticket_staff_role_id = staff_role.id
    if category: ticket_category_id = category.id
    
    embed = discord.Embed(title="🎫 التواصل مع الإدارة", description="إذا عندك موضوع أو استفسار تبي تكلم الإدارة فيه بشكل خاص، اضغط الزر أدناه وسيتم فتح روم خاص بينك وبين الإدارة.", color=discord.Color.blue())
    await interaction.response.send_message(embed=embed, view=TicketPanelView())

@bot.tree.command(name="set_tax_channel", description="تحديد الروم اللي يحسب فيه البوت ضريبة المبالغ تلقائياً")
@app_commands.checks.has_permissions(administrator=True)
async def set_tax_channel(interaction: discord.Interaction, channel: discord.TextChannel=None):
    global tax_channel_id
    channel = channel or interaction.channel
    tax_channel_id = channel.id
    await interaction.response.send_message(f"✅ تم تفعيل حساب الضريبة (5%) في {channel.mention}.", ephemeral=True)

@bot.tree.command(name="setup_ticket_wasit", description="نشر لوحة طلب وسيط موثوق للإشراف على صفقات التجارة")
@app_commands.checks.has_permissions(administrator=True)
async def setup_ticket_wasit(interaction: discord.Interaction, staff_role: discord.Role=None, category: discord.CategoryChannel=None):
    global ticket_wasit_staff_role_id, ticket_wasit_category_id
    if staff_role: ticket_wasit_staff_role_id = staff_role.id
    if category: ticket_wasit_category_id = category.id

    embed = discord.Embed(title="🤝 طلب وسيط للصفقات", description="إذا تسوي صفقة بيع أو شراء وتبي وسيط موثوق يضمن حقوق الطرفين، اضغط الزر أدناه وسيتم فتح تكت خاص بالصفقة.", color=discord.Color.teal())
    await interaction.response.send_message(embed=embed, view=WasitTicketPanelView())

@bot.tree.command(name="set_rating_channel", description="تحديد الروم اللي يتم فيه نشر تقييمات الأعضاء")
@app_commands.checks.has_permissions(administrator=True)
async def set_rating_channel(interaction: discord.Interaction, channel: discord.TextChannel=None):
    global rating_channel_id
    channel = channel or interaction.channel
    rating_channel_id = channel.id
    await interaction.response.send_message(f"✅ تم تحديد روم التقييمات: {channel.mention}", ephemeral=True)

@bot.tree.command(name="تقييم", description="قيّم عضو من 1 إلى 5 نجوم")
@app_commands.describe(member="العضو الذي تريد تقييمه", stars="عدد النجوم من 1 إلى 5", reason="سبب التقييم")
@app_commands.choices(stars=[
    app_commands.Choice(name="⭐ (1)", value=1),
    app_commands.Choice(name="⭐⭐ (2)", value=2),
    app_commands.Choice(name="⭐⭐⭐ (3)", value=3),
    app_commands.Choice(name="⭐⭐⭐⭐ (4)", value=4),
    app_commands.Choice(name="⭐⭐⭐⭐⭐ (5)", value=5),
])
async def rate_member(interaction: discord.Interaction, member: discord.Member, stars: app_commands.Choice[int], reason: str):
    if member.id == interaction.user.id:
        await interaction.response.send_message("❌ لا يمكنك تقييم نفسك.", ephemeral=True)
        return
    if member.bot:
        await interaction.response.send_message("❌ لا يمكنك تقييم بوت.", ephemeral=True)
        return

    stars_value = stars.value
    stars_display = "⭐" * stars_value + "☆" * (5 - stars_value)

    embed = discord.Embed(title="⭐ تقييم جديد", color=discord.Color.gold())
    embed.add_field(name="الشخص المُقيِّم", value=interaction.user.mention, inline=True)
    embed.add_field(name="الشخص المُقيَّم", value=member.mention, inline=True)
    embed.add_field(name="التقييم", value=f"{stars_display} ({stars_value}/5)", inline=False)
    embed.add_field(name="السبب", value=reason, inline=False)
    embed.set_footer(text=f"بواسطة {interaction.user}", icon_url=interaction.user.display_avatar.url)

    target_channel = interaction.guild.get_channel(rating_channel_id) if rating_channel_id else None
    target_channel = target_channel or interaction.channel

    await target_channel.send(embed=embed)
    await interaction.response.send_message(f"✅ تم نشر تقييمك في {target_channel.mention}", ephemeral=True)

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
                total_normal, tax_normal = compute_total_with_tax(amount, TAX_RATE)
                total_wasit, tax_wasit = compute_total_with_tax(amount, TAX_RATE_WASIT)
                embed = discord.Embed(title="🧾 حساب الضريبة", description="حوّل المبلغ الإجمالي أدناه حسب نوع الصفقة ليصل كاملاً للطرف الثاني.", color=discord.Color.orange())
                embed.add_field(name="المبلغ الصافي", value=format_amount(amount), inline=False)
                embed.add_field(name="ضريبة عادية (5%)", value=format_amount(tax_normal), inline=True)
                embed.add_field(name="💰 الإجمالي (عادي)", value=format_amount(total_normal), inline=True)
                embed.add_field(name="ضريبة وسيط (25%)", value=format_amount(tax_wasit), inline=True)
                embed.add_field(name="💰 الإجمالي (وسيط)", value=format_amount(total_wasit), inline=True)
                await message.reply(embed=embed)
    await bot.process_commands(message)

@bot.event
async def on_raw_reaction_add(payload: discord.RawReactionActionEvent):
    if payload.message_id != verify_message_id or str(payload.emoji) != "✅" or payload.member.bot: return
    if not verify_role_ids: return
    guild = bot.get_guild(payload.guild_id)
    if not guild: return
    
    async with _verify_lock:
        member = guild.get_member(payload.member.id) or payload.member
        if {r.id for r in member.roles}.intersection(verify_role_ids): return
        chosen_role_id = random.choice(verify_role_ids)
        role = guild.get_role(chosen_role_id)
        if role: await member.add_roles(role)

@setup_trade.error
@setup_verify.error
@setup_ticket.error
@set_tax_channel.error
@setup_ticket_wasit.error
@set_rating_channel.error
async def admin_command_error(interaction: discord.Interaction, error: app_commands.AppCommandError):
    if isinstance(error, app_commands.MissingPermissions):
        await interaction.response.send_message("يجب أن تكون أدمن لاستخدام هذا الأمر.", ephemeral=True)
    else: raise error

@bot.event
async def on_ready():
    bot.add_view(TradePanelView())
    bot.add_view(TicketPanelView())
    bot.add_view(WasitTicketPanelView())
    bot.add_view(CloseTicketView())
    synced = await bot.tree.sync()
    print(f"Logged in as {bot.user} - Online inside Discord!", flush=True)

def main():
    token = os.environ.get("DISCORD_TOKEN")
    if not token:
        raise RuntimeError("DISCORD_TOKEN environment variable is not set.")
    keep_alive()
    bot.run(token)

if __name__ == "__main__":
    main()
    
