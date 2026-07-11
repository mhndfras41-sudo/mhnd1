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

# --- Web Server ---
app = Flask('')
@app.route('/')
def home():
    return "Bot is Alive!"

def run_web_server():
    app.run(host='0.0.0.0', port=8000)

def keep_alive():
    t = threading.Thread(target=run_web_server)
    t.start()

# --- Bot Setup ---
intents = discord.Intents.default()
intents.message_content = True
intents.members = True
bot = commands.Bot(command_prefix="!", intents=intents)

# --- Variables ---
verify_message_id = None
verify_role_ids = []
ticket_staff_role_id = None
ticket_category_id = None
rating_channel_id = None
tax_channel_id = None

# --- Cooldowns ---
_ad_cooldowns = {}
_rating_cooldowns = {}
_last_tax_reply = {}
_verify_lock = asyncio.Lock()

# --- Helpers ---
_AMOUNT_RE = re.compile(r"^\d{1,12}(\.\d{1,4})?[mk]?$")

def parse_amount(text: str):
    text = text.strip().lower().replace(",", "")
    if not text or not _AMOUNT_RE.match(text): return None
    multiplier = 1
    if text.endswith('m'): multiplier = 1_000_000; text = text[:-1]
    elif text.endswith('k'): multiplier = 1_000; text = text[:-1]
    try: value = float(text)
    except ValueError: return None
    return value * multiplier

def format_amount(value: float) -> str:
    return f"{value:,.2f}"

# --- Views ---

class CloseTicketView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
    @discord.ui.button(label="🔒 إغلاق التذكرة", style=discord.ButtonStyle.danger, custom_id="close_ticket")
    async def close_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        await interaction.channel.delete()

class TicketPanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
    async def create_t(self, interaction, t_type):
        guild = interaction.guild
        existing = discord.utils.get(guild.text_channels, name=f"ticket-{interaction.user.name}".lower())
        if existing: await existing.delete()
        overwrites = {guild.default_role: discord.PermissionOverwrite(view_channel=False), interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True), guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True)}
        if ticket_staff_role_id: overwrites[guild.get_role(ticket_staff_role_id)] = discord.PermissionOverwrite(view_channel=True, send_messages=True)
        ch = await guild.create_text_channel(name=f"ticket-{interaction.user.name}", category=guild.get_channel(ticket_category_id), overwrites=overwrites)
        await ch.send(f"<@&{ticket_staff_role_id}>", embed=discord.Embed(title=f"تذكرة {t_type}", description="جاري المساعدة..", color=discord.Color.blue()), view=CloseTicketView())
        await interaction.response.send_message(f"✅ تم فتح التذكرة: {ch.mention}", ephemeral=True)
    @discord.ui.button(label="🎫 تذكرة دعم", style=discord.ButtonStyle.primary, custom_id="sup")
    async def sup(self, interaction, button): await self.create_t(interaction, "دعم")
    @discord.ui.button(label="🤝 تذكرة وسيط", style=discord.ButtonStyle.success, custom_id="mid")
    async def mid(self, interaction, button): await self.create_t(interaction, "وسيط")

class AdModal(discord.ui.Modal):
    def __init__(self, ch_id):
        super().__init__(title="إضافة إعلان")
        self.ch_id = ch_id
        self.item = discord.ui.TextInput(label="المنتج", required=True)
        self.price = discord.ui.TextInput(label="السعر", required=True)
        self.add_item(self.item)
        self.add_item(self.price)
    async def on_submit(self, interaction):
        await interaction.guild.get_channel(self.ch_id).send(embed=discord.Embed(title="📦 إعلان جديد", description=f"المنتج: {self.item.value}\nالسعر: {self.price.value}").set_footer(text=f"بواسطة {interaction.user}"))
        await interaction.response.send_message("✅ تم النشر", ephemeral=True)

class ChannelSelect(discord.ui.Select):
    def __init__(self):
        options = [
            discord.SelectOption(label="روم الحسابات", value="1524578445894615060"),
            discord.SelectOption(label="روم ديسكورد", value="1524578492262383787"),
            discord.SelectOption(label="روم التصاميم", value="1524578533467488286"),
            discord.SelectOption(label="روم الالعاب", value="1524578615788830780"),
            discord.SelectOption(label="روم طلبات", value="1525211150986383522"),
            discord.SelectOption(label="روم اخرى", value="1524578574273745057"),
        ]
        super().__init__(placeholder="اختر القسم...", options=options)
    async def callback(self, interaction): await interaction.response.send_modal(AdModal(int(self.values[0])))

class TradePanelView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
        self.add_item(ChannelSelect())

# --- Commands ---

@bot.tree.command(name="calculate_tax", description="حساب الضرائب (بروبوت + وسيط 25%)")
async def calculate_tax(interaction: discord.Interaction, amount: float):
    probot_total = math.ceil((amount * 20) / 19)
    broker_fee = amount * 0.25
    total = probot_total + broker_fee
    embed = discord.Embed(title="💰 حاسبة الضرائب", color=discord.Color.gold())
    embed.add_field(name="المبلغ", value=format_amount(amount), inline=True)
    embed.add_field(name="ضريبة البروبوت", value=format_amount(probot_total - amount), inline=True)
    embed.add_field(name="ضريبة الوسيط (25%)", value=format_amount(broker_fee), inline=True)
    embed.add_field(name="الإجمالي للتحويل", value=format_amount(total), inline=False)
    await interaction.response.send_message(embed=embed)

@bot.tree.command(name="setup_verify", description="نظام التحقق")
async def setup_verify(interaction, r1: discord.Role, r2: discord.Role=None):
    global verify_message_id, verify_role_ids
    verify_role_ids = [r.id for r in [r1, r2] if r]
    msg = await interaction.channel.send(embed=discord.Embed(title="✅ تحقق", description="اضغط ✅ لتحصل على الرتبة"))
    await msg.add_reaction("✅")
    verify_message_id = msg.id
    await interaction.response.send_message("تم الإعداد", ephemeral=True)

@bot.tree.command(name="setup_rating", description="إعداد التقييم")
async def setup_rating(interaction, channel: discord.TextChannel):
    global rating_channel_id
    rating_channel_id = channel.id
    await interaction.response.send_message("تم تحديد الروم", ephemeral=True)

@bot.tree.command(name="rate", description="تقييم وسيط")
async def rate(interaction, user: discord.Member, stars: int, comment: str):
    if not rating_channel_id: return await interaction.response.send_message("لم يتم إعداد الروم", ephemeral=True)
    ch = interaction.guild.get_channel(rating_channel_id)
    await ch.send(embed=discord.Embed(title="⭐ تقييم جديد", description=f"الوسيط: {user.mention}\nالتقييم: {'⭐'*stars}\nالتعليق: {comment}"))
    await interaction.response.send_message("تم التقييم", ephemeral=True)

@bot.tree.command(name="setup_ticket", description="إعداد التذاكر")
async def setup_ticket(interaction, role: discord.Role, cat: discord.CategoryChannel):
    global ticket_staff_role_id, ticket_category_id
    ticket_staff_role_id = role.id
    ticket_category_id = cat.id
    await interaction.channel.send(embed=discord.Embed(title="🎫 التذاكر", description="اختر زر"), view=TicketPanelView())
    await interaction.response.send_message("تم الإعداد", ephemeral=True)

@bot.tree.command(name="setup_trade", description="إعداد السوق")
async def setup_trade(interaction):
    await interaction.channel.send(embed=discord.Embed(title="🛒 سوق التجارة"), view=TradePanelView())
    await interaction.response.send_message("تم الإعداد", ephemeral=True)

@bot.tree.command(name="set_tax_channel", description="تفعيل حساب الضريبة التلقائي")
async def set_tax_channel(interaction, channel: discord.TextChannel):
    global tax_channel_id
    tax_channel_id = channel.id
    await interaction.response.send_message("تم", ephemeral=True)

# --- Events ---

@bot.event
async def on_message(message):
    if message.author.bot: return
    if tax_channel_id and message.channel.id == tax_channel_id:
        amount = parse_amount(message.content)
        if amount:
            p_total = math.ceil((amount * 20) / 19)
            broker = amount * 0.25
            await message.reply(embed=discord.Embed(title="💰 الحسبة", description=f"المبلغ: {format_amount(amount)}\nضريبة البروبوت: {format_amount(p_total-amount)}\nضريبة الوسيط (25%): {format_amount(broker)}\n**الإجمالي: {format_amount(p_total + broker)}**"))
    await bot.process_commands(message)

@bot.event
async def on_raw_reaction_add(payload):
    if payload.message_id == verify_message_id and str(payload.emoji) == "✅":
        g = bot.get_guild(payload.guild_id)
        r = g.get_role(random.choice(verify_role_ids))
        await payload.member.add_roles(r)

@bot.event
async def on_ready():
    bot.add_view(TicketPanelView())
    bot.add_view(CloseTicketView())
    bot.add_view(TradePanelView())
    await bot.tree.sync()
    print("Bot is ready")

bot.run(os.environ["DISCORD_TOKEN"])
                       
