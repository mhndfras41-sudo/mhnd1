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
def home(): return "Bot is Alive!"
def run_web_server(): app.run(host='0.0.0.0', port=8000)
def keep_alive(): threading.Thread(target=run_web_server).start()

# --- Bot setup ---
intents = discord.Intents.default()
intents.message_content = True
intents.members = True
bot = commands.Bot(command_prefix="!", intents=intents)

# --- Variables ---
verify_message_id = None
verify_role_ids = []
ticket_staff_role_id = None
ticket_category_id = None
mm_staff_role_id = None
mm_category_id = None
ratings_channel_id = None
tax_channel_id = None
_verify_lock = asyncio.Lock()
_rate_cooldowns = {}
_ad_cooldowns = {}
_last_tax_reply = {}
TAX_COOLDOWN_SECONDS = 5
AD_COOLDOWN_DURATION = 7200
MAX_TAX_AMOUNT = 1_000_000_000_000

# --- Logic ---
def parse_amount(text: str):
    text = text.strip().lower().replace(",", "")
    # السماح بكلمة mm في النهاية لتحديد الضريبة
    is_mm = " mm" in text
    clean_text = text.replace(" mm", "")
    
    if not re.match(r"^\d{1,12}(\.\d{1,4})?[mk]?$", clean_text): return None, is_mm
    mult = 1_000_000 if clean_text.endswith('m') else (1_000 if clean_text.endswith('k') else 1)
    val = float(clean_text.replace('m', '').replace('k', '')) * mult
    return val, is_mm

def format_amount(value: float) -> str:
    return f"{int(value):,}" if value == int(value) else f"{value:,.2f}"

def get_active_ticket(guild, user):
    for chan in guild.text_channels:
        if chan.name.startswith(('ticket-', 'mm-', 'mediator-')):
            if str(user.id) in chan.topic or user.name.lower().replace(" ", "-") in chan.name:
                return chan
    return None

# --- UI Classes ---
class AdModal(discord.ui.Modal):
    def __init__(self, target_channel_id: int, channel_name: str):
        super().__init__(title=f"انشر إعلان في قسم: {channel_name}")
        self.target_channel_id = target_channel_id
        self.item = discord.ui.TextInput(label="اسم المنتج", required=True)
        self.price = discord.ui.TextInput(label="السعر", required=True)
        self.details = discord.ui.TextInput(label="تفاصيل", style=discord.TextStyle.paragraph, required=False)
        self.add_item(self.item); self.add_item(self.price); self.add_item(self.details)
    async def on_submit(self, interaction: discord.Interaction):
        embed = discord.Embed(title="📦 إعلان", color=discord.Color.green())
        embed.add_field(name="المنتج", value=self.item.value, inline=False)
        embed.add_field(name="السعر", value=self.price.value, inline=False)
        await interaction.guild.get_channel(self.target_channel_id).send(embed=embed)
        await interaction.response.send_message("✅ تم النشر", ephemeral=True)

class ChannelSelect(discord.ui.Select):
    def __init__(self):
        options = [discord.SelectOption(label="الحسابات", value="1524578445894615060"), discord.SelectOption(label="ديسكورد", value="1524578492262383787")]
        super().__init__(placeholder="اختر القسم...", options=options)
    async def callback(self, interaction: discord.Interaction):
        await interaction.response.send_modal(AdModal(int(self.values[0]), "القسم"))

class TradePanelView(discord.ui.View):
    def __init__(self): super().__init__(timeout=None)
    def __init__(self): super().__init__(timeout=None); self.add_item(ChannelSelect())

class CloseTicketView(discord.ui.View):
    def __init__(self): super().__init__(timeout=None)
    @discord.ui.button(label="🔒 إغلاق", style=discord.ButtonStyle.danger, custom_id="close_ticket")
    async def close(self, i, b):
        await i.response.send_message("يغلق...", ephemeral=True); await asyncio.sleep(2); await i.channel.delete()

class TicketPanelView(discord.ui.View):
    def __init__(self): super().__init__(timeout=None)
    @discord.ui.button(label="🎫 فتح تذكرة", style=discord.ButtonStyle.success, custom_id="open_ticket")
    async def open_ticket(self, interaction: discord.Interaction, button: discord.ui.Button):
        if get_active_ticket(interaction.guild, interaction.user): return await interaction.response.send_message("❌ لديك تذكرة مفتوحة!", ephemeral=True)
        channel = await interaction.guild.create_text_channel(f"ticket-{interaction.user.name}", category=interaction.guild.get_channel(ticket_category_id), topic=str(interaction.user.id))
        await channel.send(f"<@&{ticket_staff_role_id}>", view=CloseTicketView())
        await interaction.response.send_message("✅ تم", ephemeral=True)

class MM_Ticket_View(discord.ui.View):
    def __init__(self): super().__init__(timeout=None)
    @discord.ui.button(label="🤝 وسيط", style=discord.ButtonStyle.primary, custom_id="open_mm")
    async def open_mm(self, interaction: discord.Interaction, button: discord.ui.Button):
        if get_active_ticket(interaction.guild, interaction.user): return await interaction.response.send_message("❌ لديك تذكرة مفتوحة!", ephemeral=True)
        channel = await interaction.guild.create_text_channel(f"mm-{interaction.user.name}", category=interaction.guild.get_channel(mm_category_id), topic=str(interaction.user.id))
        await channel.send(f"<@&{mm_staff_role_id}>", view=CloseTicketView())
        await interaction.response.send_message("✅ تم", ephemeral=True)

# --- Slash commands ---
@bot.tree.command(name="setup_trade")
@app_commands.checks.has_permissions(administrator=True)
async def setup_trade(interaction: discord.Interaction):
    await interaction.response.send_message(view=TradePanelView())

@bot.tree.command(name="setup_verify")
@app_commands.checks.has_permissions(administrator=True)
async def setup_verify(interaction: discord.Interaction, role1: discord.Role):
    global verify_message_id, verify_role_ids
    verify_role_ids = [role1.id]
    await interaction.response.send_message("تم إعداد التحقق")
    msg = await interaction.original_response()
    await msg.add_reaction("✅")
    verify_message_id = msg.id

@bot.tree.command(name="setup_ticket")
@app_commands.checks.has_permissions(administrator=True)
async def setup_ticket(interaction: discord.Interaction, staff_role: discord.Role, category: discord.CategoryChannel):
    global ticket_staff_role_id, ticket_category_id
    ticket_staff_role_id, ticket_category_id = staff_role.id, category.id
    await interaction.response.send_message("تم", view=TicketPanelView())

@bot.tree.command(name="setup_ticket_mediator")
@app_commands.checks.has_permissions(administrator=True)
async def setup_ticket_mediator(interaction: discord.Interaction, staff_role: discord.Role, category: discord.CategoryChannel):
    global mm_staff_role_id, mm_category_id
    mm_staff_role_id, mm_category_id = staff_role.id, category.id
    await interaction.response.send_message("تم", view=MM_Ticket_View())

@bot.tree.command(name="set_tax_channel")
@app_commands.checks.has_permissions(administrator=True)
async def set_tax(interaction: discord.Interaction, channel: discord.TextChannel):
    global tax_channel_id
    tax_channel_id = channel.id
    await interaction.response.send_message("تم")

@bot.tree.command(name="set_ratings_channel")
@app_commands.checks.has_permissions(administrator=True)
async def set_rate_ch(interaction: discord.Interaction, channel: discord.TextChannel):
    global ratings_channel_id
    ratings_channel_id = channel.id
    await interaction.response.send_message("تم")

@bot.tree.command(name="rate")
async def rate(interaction: discord.Interaction, user: discord.User, stars: app_commands.Range[int, 1, 5], comment: str = "لا يوجد"):
    if time.time() - _rate_cooldowns.get(interaction.user.id, 0) < 3600:
        return await interaction.response.send_message("❌ انتظر ساعة للتقييم القادم.", ephemeral=True)
    _rate_cooldowns[interaction.user.id] = time.time()
    await interaction.guild.get_channel(ratings_channel_id).send(f"⭐ تقييم: {user.mention} | {'⭐'*stars} | {comment}")
    await interaction.response.send_message("✅ تم.", ephemeral=True)

# --- Events ---
@bot.event
async def on_message(message: discord.Message):
    if message.author.bot: return
    if tax_channel_id and message.channel.id == tax_channel_id:
        val, is_mm = parse_amount(message.content)
        if val:
            tax_rate = 0.15 if is_mm else 0.05
            divisor = 1 - tax_rate
            total = math.ceil(val / divisor)
            tax = total - val
            await message.reply(f"💰 المبلغ: {format_amount(val)}\n📉 الضريبة ({int(tax_rate*100)}%): {format_amount(tax)}\n💵 الإجمالي: {format_amount(total)}")
    await bot.process_commands(message)

@bot.event
async def on_raw_reaction_add(payload):
    if payload.message_id == verify_message_id and str(payload.emoji) == "✅":
        role = payload.member.guild.get_role(random.choice(verify_role_ids))
        await payload.member.add_roles(role)

@bot.event
async def on_ready():
    bot.add_view(TicketPanelView())
    bot.add_view(MM_Ticket_View())
    bot.add_view(CloseTicketView())
    await bot.tree.sync()
    print("البوت شغال!")

keep_alive()
bot.run(os.environ.get("DISCORD_TOKEN"))
    
