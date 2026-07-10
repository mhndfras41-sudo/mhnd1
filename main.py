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

# --- نظام الويب للبقاء اونلاين ---
app = Flask('')
@app.route('/')
def home():
    return "Bot is Alive and Running!"

def run_web_server():
    app.run(host='0.0.0.0', port=8000)

def keep_alive():
    t = threading.Thread(target=run_web_server)
    t.start()

# --- إعدادات البوت ---
intents = discord.Intents.default()
intents.message_content = True
intents.members = True
bot = commands.Bot(command_prefix="!", intents=intents)

# --- متغيرات النظام ---
verify_message_id = None
verify_role_ids = []
ticket_staff_role_id = None
ticket_category_id = None
mm_staff_role_id = None
mm_category_id = None
ratings_channel_id = None
tax_channel_id = None

_rate_cooldowns = {}

# --- وظائف مساعدة ---
def parse_amount(text: str):
    # تنظيف النص من الفواصل والمسافات
    text = text.strip().lower().replace(",", "")
    if not re.match(r"^\d{1,12}(\.\d{1,4})?[mk]?$", text):
        return None
    
    # تحديد القيمة (m = مليون، k = ألف)
    multiplier = 1
    if text.endswith('m'):
        multiplier = 1_000_000
    elif text.endswith('k'):
        multiplier = 1_000
        
    value = float(text.replace('m', '').replace('k', '')) * multiplier
    return value

def format_amount(value: float) -> str:
    return f"{int(value):,}" if value == int(value) else f"{value:,.2f}"

def get_active_ticket(guild, user):
    user_name = user.name.lower().replace(" ", "-")
    for channel in guild.text_channels:
        if channel.name.startswith(('ticket-', 'mm-')):
            if user_name in channel.name:
                return channel
    return None

# --- لوحات الأزرار (Views) ---

# لوحة إغلاق التكت
class CloseTicketView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    @discord.ui.button(label="🔒 إغلاق التذكرة", style=discord.ButtonStyle.danger, custom_id="close_ticket")
    async def close_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.response.send_message("سيتم حذف التذكرة بعد 5 ثواني...", ephemeral=True)
        await asyncio.sleep(5)
        await interaction.channel.delete()

# لوحة التكت العام
class TicketPanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    @discord.ui.button(label="🎫 فتح تذكرة دعم", style=discord.ButtonStyle.success, custom_id="open_ticket")
    async def open_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        if get_active_ticket(interaction.guild, interaction.user):
            return await interaction.response.send_message("❌ لديك تذكرة مفتوحة بالفعل!", ephemeral=True)
        
        overwrites = {
            interaction.guild.default_role: discord.PermissionOverwrite(view_channel=False),
            interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True),
            interaction.guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True)
        }
        if ticket_staff_role_id:
            overwrites[interaction.guild.get_role(ticket_staff_role_id)] = discord.PermissionOverwrite(view_channel=True, send_messages=True)
            
        channel = await interaction.guild.create_text_channel(
            name=f"ticket-{interaction.user.name}",
            category=interaction.guild.get_channel(ticket_category_id),
            overwrites=overwrites
        )
        await channel.send(f"<@&{ticket_staff_role_id}>", embed=discord.Embed(title="تذكرة دعم جديدة", description=f"أهلاً بك يا {interaction.user.mention}، سيتم الرد عليك."), view=CloseTicketView())
        await interaction.response.send_message(f"✅ تم فتح التذكرة: {channel.mention}", ephemeral=True)

# لوحة تكت الوسيط
class MM_Ticket_View(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)

    @discord.ui.button(label="🤝 طلب وسيط", style=discord.ButtonStyle.primary, custom_id="open_mm")
    async def open_mm(self, interaction: discord.Interaction, button: discord.ui.Button):
        if get_active_ticket(interaction.guild, interaction.user):
            return await interaction.response.send_message("❌ لديك تذكرة مفتوحة بالفعل!", ephemeral=True)
        
        overwrites = {
            interaction.guild.default_role: discord.PermissionOverwrite(view_channel=False),
            interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True),
            interaction.guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True)
        }
        if mm_staff_role_id:
            overwrites[interaction.guild.get_role(mm_staff_role_id)] = discord.PermissionOverwrite(view_channel=True, send_messages=True)
            
        channel = await interaction.guild.create_text_channel(
            name=f"mm-{interaction.user.name}",
            category=interaction.guild.get_channel(mm_category_id),
            overwrites=overwrites
        )
        await channel.send(f"<@&{mm_staff_role_id}>", embed=discord.Embed(title="طلب وسيط", description=f"{interaction.user.mention} يحتاج وسيط للتبادل."), view=CloseTicketView())
        await interaction.response.send_message(f"✅ تم فتح تذكرة الوسيط: {channel.mention}", ephemeral=True)

# لوحة الإعلانات (Modal)
class AdModal(discord.ui.Modal):
    def __init__(self, target_channel_id: int, channel_name: str):
        super().__init__(title=f"نشر إعلان في: {channel_name}")
        self.target_channel_id = target_channel_id
        
        self.item = discord.ui.TextInput(label="المنتج", placeholder="مثال: حساب ببجي", required=True)
        self.price = discord.ui.TextInput(label="السعر", placeholder="مثال: 50", required=True)
        self.details = discord.ui.TextInput(label="التفاصيل", style=discord.TextStyle.paragraph, placeholder="اكتب تفاصيل إضافية...", required=False)
        
        self.add_item(self.item)
        self.add_item(self.price)
        self.add_item(self.details)
        
    async def on_submit(self, interaction: discord.Interaction):
        embed = discord.Embed(title="📦 إعلان جديد", color=discord.Color.green())
        embed.add_field(name="المنتج", value=self.item.value, inline=False)
        embed.add_field(name="السعر", value=self.price.value, inline=False)
        embed.add_field(name="التفاصيل", value=self.details.value or "لا يوجد", inline=False)
        embed.set_footer(text=f"تم النشر بواسطة: {interaction.user.name}")
        
        channel = interaction.guild.get_channel(self.target_channel_id)
        if channel:
            await channel.send(embed=embed)
            await interaction.response.send_message("✅ تم نشر إعلانك بنجاح.", ephemeral=True)
        else:
            await interaction.response.send_message("❌ خطأ: لم أتمكن من العثور على الروم.", ephemeral=True)

# قائمة الرومات المتاحة للإعلان
class ChannelSelect(discord.ui.Select):
    def __init__(self):
        options = [
            discord.SelectOption(label="روم الحسابات", value="1524578445894615060", emoji="👤"),
            discord.SelectOption(label="روم ديسكورد", value="1524578492262383787", emoji="💬"),
            discord.SelectOption(label="روم التصاميم", value="1524578533467488286", emoji="🎨"),
            discord.SelectOption(label="روم الألعاب", value="1524578615788830780", emoji="🎮"),
            discord.SelectOption(label="روم الطلبات", value="1525211150986383522", emoji="📥"),
            discord.SelectOption(label="روم أخرى", value="1524578574273745057", emoji="⚙️"),
        ]
        super().__init__(placeholder="اختر القسم لنشر إعلانك...", options=options)
        
    async def callback(self, interaction: discord.Interaction):
        await interaction.response.send_modal(AdModal(int(self.values[0]), self.values[0]))

class TradePanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
        self.add_item(ChannelSelect())

# --- الأوامر الأساسية ---

@bot.tree.command(name="setup_trade", description="إعداد لوحة التجارة")
@app_commands.checks.has_permissions(administrator=True)
async def setup_trade(interaction: discord.Interaction):
    await interaction.response.send_message("🛒 تم إعداد لوحة التجارة بنجاح.", view=TradePanelView())

@bot.tree.command(name="setup_verify", description="إعداد نظام التحقق")
@app_commands.checks.has_permissions(administrator=True)
async def setup_verify(interaction: discord.Interaction, role: discord.Role):
    global verify_message_id, verify_role_ids
    verify_role_ids = [role.id]
    await interaction.response.send_message(f"✅ تم تفعيل نظام التحقق برتبة: {role.mention}")
    msg = await interaction.original_response()
    await msg.add_reaction("✅")
    verify_message_id = msg.id

@bot.tree.command(name="setup_ticket", description="إعداد لوحة التذاكر")
@app_commands.checks.has_permissions(administrator=True)
async def setup_ticket(interaction: discord.Interaction, staff_role: discord.Role, category: discord.CategoryChannel):
    global ticket_staff_role_id, ticket_category_id
    ticket_staff_role_id, ticket_category_id = staff_role.id, category.id
    await interaction.response.send_message("🎫 تم إعداد نظام التذاكر.", view=TicketPanelView())

@bot.tree.command(name="setup_ticket_mediator", description="إعداد لوحة الوسيط")
@app_commands.checks.has_permissions(administrator=True)
async def setup_ticket_mediator(interaction: discord.Interaction, staff_role: discord.Role, category: discord.CategoryChannel):
    global mm_staff_role_id, mm_category_id
    mm_staff_role_id, mm_category_id = staff_role.id, category.id
    await interaction.response.send_message("🤝 تم إعداد نظام الوسيط.", view=MM_Ticket_View())

@bot.tree.command(name="set_tax_channel", description="تحديد روم الضرائب")
@app_commands.checks.has_permissions(administrator=True)
async def set_tax_channel(interaction: discord.Interaction, channel: discord.TextChannel):
    global tax_channel_id
    tax_channel_id = channel.id
    await interaction.response.send_message(f"📉 تم تحديد {channel.mention} كروم الضرائب.")

@bot.tree.command(name="set_ratings_channel", description="تحديد روم التقييمات")
@app_commands.checks.has_permissions(administrator=True)
async def set_ratings_channel(interaction: discord.Interaction, channel: discord.TextChannel):
    global ratings_channel_id
    ratings_channel_id = channel.id
    await interaction.response.send_message(f"⭐ تم تحديد {channel.mention} كروم للتقييمات.")

@bot.tree.command(name="rate", description="تقييم عضو (مرة كل ساعة)")
async def rate(interaction: discord.Interaction, user: discord.User, stars: app_commands.Range[int, 1, 5], comment: str = "لا يوجد"):
    if time.time() - _rate_cooldowns.get(interaction.user.id, 0) < 3600:
        return await interaction.response.send_message("❌ انتظر ساعة للتقييم القادم.", ephemeral=True)
    
    _rate_cooldowns[interaction.user.id] = time.time()
    if not ratings_channel_id:
        return await interaction.response.send_message("❌ لم يتم تحديد روم التقييمات.", ephemeral=True)
        
    channel = interaction.guild.get_channel(ratings_channel_id)
    await channel.send(f"⭐ تقييم لـ {user.mention}\nالتقييم: {'⭐'*stars}\nالتعليق: {comment}\nالمقيم: {interaction.user.mention}")
    await interaction.response.send_message(f"✅ تم إرسال تقييمك لـ {user.mention}.", ephemeral=True)

# --- الأحداث (Events) ---

@bot.event
async def on_message(message: discord.Message):
    if message.author.bot:
        return
        
    # نظام الضرائب
    if tax_channel_id and message.channel.id == tax_channel_id:
        val = parse_amount(message.content)
        if val:
            # ضريبة بروبوت (5%)
            std_total = math.ceil(val / 0.95)
            # ضريبة وسيط (15%)
            mm_total = math.ceil(val / 0.85)
            
            embed = discord.Embed(title="🧾 حاسبة الضرائب", color=discord.Color.gold())
            embed.add_field(name="المبلغ المطلوب", value=format_amount(val), inline=False)
            embed.add_field(name="ضريبة بروبوت (5%)", value=f"الإجمالي: {format_amount(std_total)}", inline=True)
            embed.add_field(name="ضريبة وسيط (15%)", value=f"الإجمالي: {format_amount(mm_total)}", inline=True)
            await message.reply(embed=embed)
            
    await bot.process_commands(message)

@bot.event
async def on_raw_reaction_add(payload):
    if payload.message_id == verify_message_id and str(payload.emoji) == "✅" and not payload.member.bot:
        role = payload.member.guild.get_role(verify_role_ids[0])
        await payload.member.add_roles(role)

@bot.event
async def on_ready():
    # إضافة اللوحات للذاكرة عند التشغيل
    bot.add_view(TicketPanelView())
    bot.add_view(MM_Ticket_View())
    bot.add_view(CloseTicketView())
    bot.add_view(TradePanelView())
    
    await bot.tree.sync()
    print("البوت يعمل بكامل طاقته الآن!")

keep_alive()
bot.run(os.environ.get("DISCORD_TOKEN"))
                      
