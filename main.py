import discord
from discord.ext import commands
from discord import app_commands
import os
import asyncio
import math
import re

# --- الإعدادات ---
TOKEN = os.environ.get("DISCORD_TOKEN")
intents = discord.Intents.default()
intents.message_content = True
intents.members = True
intents.reactions = True

bot = commands.Bot(command_prefix="!", intents=intents)

# --- متغيرات الذاكرة ---
config = {
    "verify_message_id": None,
    "verify_role_ids": [],
    "ticket_staff_role_id": None,
    "ticket_category_id": None,
    "rating_channel_id": None,
    "tax_channel_id": None
}

# --- دالة حساب المبالغ ---
def parse_amount(text):
    text = text.lower().replace(",", "").strip()
    match = re.match(r"(\d+)([mk]?)", text)
    if not match: return None
    number = float(match.group(1))
    suffix = match.group(2)
    if suffix == 'k': number *= 1000
    elif suffix == 'm': number *= 1000000
    return number

def format_num(num):
    return f"{num:,.2f}"

# --- نظام التذاكر ---
class TicketView(discord.ui.View):
    def __init__(self):
        super().__init__(timeout=None)
    
    async def create_ticket(self, interaction, title):
        guild = interaction.guild
        staff = guild.get_role(config["ticket_staff_role_id"])
        cat = guild.get_channel(config["ticket_category_id"])
        
        overwrites = {
            guild.default_role: discord.PermissionOverwrite(view_channel=False),
            interaction.user: discord.PermissionOverwrite(view_channel=True, send_messages=True),
            guild.me: discord.PermissionOverwrite(view_channel=True, send_messages=True),
            staff: discord.PermissionOverwrite(view_channel=True, send_messages=True)
        }
        
        channel = await guild.create_text_channel(name=f"ticket-{interaction.user.name}", category=cat, overwrites=overwrites)
        await channel.send(f"{interaction.user.mention} {staff.mention if staff else ''}", embed=discord.Embed(title=title, description="انتظر الرد من الإدارة", color=discord.Color.blue()))
        await interaction.response.send_message(f"✅ تم فتح تذكرتك: {channel.mention}", ephemeral=True)

    @discord.ui.button(label="🎫 دعم فني", style=discord.ButtonStyle.primary, custom_id="sup_btn")
    async def sup(self, interaction, button): await self.create_ticket(interaction, "تذكرة دعم")

    @discord.ui.button(label="🤝 وسيط", style=discord.ButtonStyle.success, custom_id="mid_btn")
    async def mid(self, interaction, button): await self.create_ticket(interaction, "تذكرة وسيط")

# --- نظام السوق ---
class TradeSelect(discord.ui.Select):
    def __init__(self):
        options = [
            discord.SelectOption(label="الحسابات", value="1524578445894615060"),
            discord.SelectOption(label="ديسكورد", value="1524578492262383787"),
            discord.SelectOption(label="تصاميم", value="1524578533467488286"),
            discord.SelectOption(label="ألعاب", value="1524578615788830780"),
            discord.SelectOption(label="طلبات", value="1525211150986383522"),
            discord.SelectOption(label="أخرى", value="1524578574273745057"),
        ]
        super().__init__(placeholder="اختر القسم...", options=options)
    
    async def callback(self, interaction):
        await interaction.response.send_modal(AdModal(int(self.values[0])))

class AdModal(discord.ui.Modal, title="نشر إعلان"):
    item = discord.ui.TextInput(label="المنتج", required=True)
    price = discord.ui.TextInput(label="السعر", required=True)
    async def on_submit(self, interaction):
        ch = interaction.guild.get_channel(int(self.children[0].value)) # This logic needs adjustment per channel
        # التصحيح: الإعلان يرسل للروم المختار
        await interaction.guild.get_channel(self.channel_id).send(embed=discord.Embed(title="📦 إعلان جديد", description=f"المنتج: {self.item.value}\nالسعر: {self.price.value}").set_footer(text=f"بواسطة {interaction.user}"))
        await interaction.response.send_message("✅ تم النشر", ephemeral=True)

# --- الأوامر ---

@bot.tree.command(name="calculate_tax", description="حساب ضريبة البروبوت + وسيط 25%")
async def calculate_tax(interaction, amount: str):
    val = parse_amount(amount)
    if not val: return await interaction.response.send_message("❌ اكتب المبلغ بشكل صحيح (مثال: 1m أو 1000)", ephemeral=True)
    
    probot = math.ceil((val * 20) / 19)
    broker = val * 0.25
    total = probot + broker
    
    embed = discord.Embed(title="💰 حاسبة الضرائب", color=discord.Color.gold())
    embed.add_field(name="المبلغ الأساسي", value=format_num(val), inline=True)
    embed.add_field(name="ضريبة البروبوت", value=format_num(probot - val), inline=True)
    embed.add_field(name="ضريبة الوسيط (25%)", value=format_num(broker), inline=True)
    embed.add_field(name="المبلغ الإجمالي للتحويل", value=format_num(total), inline=False)
    await interaction.response.send_message(embed=embed)

@bot.tree.command(name="setup_rating", description="تحديد روم التقييم")
async def setup_rating(interaction, channel: discord.TextChannel):
    config["rating_channel_id"] = channel.id
    await interaction.response.send_message(f"✅ تم تحديد {channel.mention} للتقييمات", ephemeral=True)

@bot.tree.command(name="rate", description="تقييم وسيط")
async def rate(interaction, user: discord.Member, stars: int, comment: str):
    if not config["rating_channel_id"]: return await interaction.response.send_message("❌ لم يتم تحديد روم التقييم", ephemeral=True)
    ch = interaction.guild.get_channel(config["rating_channel_id"])
    await ch.send(embed=discord.Embed(title="⭐ تقييم جديد", description=f"الوسيط: {user.mention}\nالتقييم: {'⭐'*stars}\nالتعليق: {comment}"))
    await interaction.response.send_message("✅ تم إرسال تقييمك", ephemeral=True)

@bot.tree.command(name="setup_ticket", description="إعداد التذاكر")
async def setup_ticket(interaction, role: discord.Role, cat: discord.CategoryChannel):
    config["ticket_staff_role_id"] = role.id
    config["ticket_category_id"] = cat.id
    await interaction.channel.send(embed=discord.Embed(title="🎫 تذاكر السيرفر", description="اختر زر"), view=TicketView())
    await interaction.response.send_message("✅ تم إعداد التذاكر", ephemeral=True)

@bot.tree.command(name="setup_verify", description="إعداد التحقق")
async def setup_verify(interaction, role1: discord.Role):
    config["verify_role_ids"] = [role1.id]
    msg = await interaction.channel.send(embed=discord.Embed(title="✅ تحقق", description="اضغط ✅ للحصول على الرتبة"))
    await msg.add_reaction("✅")
    config["verify_message_id"] = msg.id
    await interaction.response.send_message("✅ تم إعداد التحقق", ephemeral=True)

@bot.tree.command(name="set_tax_channel", description="تفعيل حساب الضريبة التلقائي في هذا الروم")
async def set_tax_channel(interaction):
    config["tax_channel_id"] = interaction.channel.id
    await interaction.response.send_message("✅ تم تفعيل حساب الضريبة التلقائي هنا", ephemeral=True)

# --- الأحداث ---

@bot.event
async def on_message(message):
    if message.author.bot: return
    if config["tax_channel_id"] == message.channel.id:
        val = parse_amount(message.content)
        if val:
            probot = math.ceil((val * 20) / 19)
            broker = val * 0.25
            await message.reply(f"💰 المبلغ: {format_num(val)} | الإجمالي المطلوب (بروبوت + وسيط 25%): **{format_num(probot + broker)}**")
    await bot.process_commands(message)

@bot.event
async def on_raw_reaction_add(payload):
    if payload.message_id == config["verify_message_id"] and str(payload.emoji) == "✅":
        role = payload.member.guild.get_role(config["verify_role_ids"][0])
        await payload.member.add_roles(role)

@bot.event
async def on_ready():
    print(f"Logged in as {bot.user}")
    bot.add_view(TicketView())
    try:
        synced = await bot.tree.sync()
        print(f"Synced {len(synced)} commands.")
    except Exception as e:
        print(e)

bot.run(TOKEN)
