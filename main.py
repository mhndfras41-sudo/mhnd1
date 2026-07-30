import discord
from discord.ext import commands
import random
import json
import os

intents = discord.Intents.default()
intents.message_content = True
bot = commands.Bot(command_prefix='/', intents=intents)

DATA_FILE = 'shop_data.json'

def load_data():
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, 'r') as f:
            return json.load(f)
    return {
        'users': {},
        'price_per_unit': 1,
        'robux_id': None
    }

def save_data(data):
    with open(DATA_FILE, 'w') as f:
        json.dump(data, f, indent=4)

data = load_data()

@bot.event
async def on_ready():
    print(f'Bot is ready as {bot.user}')

@bot.command()
@commands.is_owner()
async def setprice(ctx, price: int):
    data['price_per_unit'] = price
    save_data(data)
    await ctx.send(f"✅ Price per Robux set to {price} coins")

@bot.command()
@commands.is_owner()
async def setid(ctx, robux_id: int):
    data['robux_id'] = robux_id
    save_data(data)
    await ctx.send(f"✅ Roblox ID set to {robux_id}")

@bot.command()
@commands.is_owner()
async def give(ctx, member: discord.Member, amount: int):
    user_id = str(member.id)
    if user_id not in data['users']:
        data['users'][user_id] = {'balance': 0, 'total_purchased': 0}
    data['users'][user_id]['balance'] += amount
    data['users'][user_id]['total_purchased'] += amount
    save_data(data)
    await ctx.send(f"✅ Gave {amount} Robux to {member.mention}")

@bot.command()
async def me(ctx):
    user_id = str(ctx.author.id)
    if user_id not in data['users']:
        data['users'][user_id] = {'balance': 0, 'total_purchased': 0}
        save_data(data)
    user_data = data['users'][user_id]
    embed = discord.Embed(
        title="📊 Your Roblox Info",
        color=discord.Color.blue()
    )
    embed.add_field(name="💰 Balance", value=f"{user_data['balance']} Robux", inline=False)
    embed.add_field(name="🛒 Total Purchased", value=f"{user_data['total_purchased']} Robux", inline=False)
    embed.add_field(name="🎁 Reward Game", value="Click the button below to play!", inline=False)
    embed.set_footer(text="Buy more Robux using /buy <amount>")
    view = RewardButton(user_id)
    await ctx.send(embed=embed, view=view)

class RewardButton(discord.ui.View):
    def __init__(self, user_id):
        super().__init__(timeout=60)
        self.user_id = user_id

    @discord.ui.button(label="🎁 Play Reward Game", style=discord.ButtonStyle.green)
    async def reward_button(self, interaction: discord.Interaction, button: discord.ui.Button):
        if str(interaction.user.id) != self.user_id:
            await interaction.response.send_message("❌ This button is not for you!", ephemeral=True)
            return
        num1 = random.randint(1, 10)
        num2 = random.randint(1, 10)
        answer = num1 + num2
        await interaction.response.send_message(
            f"🧮 Solve: {num1} + {num2} = ?\nType your answer in chat within 15 seconds!",
            ephemeral=True
        )
        def check(m):
            return m.author.id == interaction.user.id and m.content.isdigit()
        try:
            msg = await bot.wait_for('message', timeout=15.0, check=check)
            if int(msg.content) == answer:
                reward = random.randint(1, 15)
                data['users'][self.user_id]['balance'] += reward
                save_data(data)
                await interaction.followup.send(f"✅ Correct! You earned {reward} Robux!", ephemeral=True)
            else:
                await interaction.followup.send("❌ Wrong answer! Try again later.", ephemeral=True)
        except TimeoutError:
            await interaction.followup.send("⏰ Time's up! Try again.", ephemeral=True)

@bot.command()
async def buy(ctx, amount: int):
    user_id = str(ctx.author.id)
    if user_id not in data['users']:
        data['users'][user_id] = {'balance': 0, 'total_purchased': 0}
        save_data(data)
    price = amount * data['price_per_unit']
    embed = discord.Embed(
        title="🧾 Purchase Confirmation",
        color=discord.Color.green()
    )
    embed.add_field(name="Amount", value=f"{amount} Robux", inline=True)
    embed.add_field(name="Price", value=f"{price} coins", inline=True)
    embed.add_field(name="Roblox ID", value=f"`{data['robux_id'] or 'Not set'}`", inline=False)
    embed.set_footer(text="Transfer the coins to the ID above to complete purchase")
    data['users'][user_id]['balance'] += amount
    data['users'][user_id]['total_purchased'] += amount
    save_data(data)
    await ctx.send(embed=embed)

@bot.command()
async def transh(ctx):
    user_id = str(ctx.author.id)
    if user_id not in data['users']:
        await ctx.send("❌ You have no transactions yet!")
        return
    user_data = data['users'][user_id]
    embed = discord.Embed(
        title="📜 Transaction History",
        color=discord.Color.gold()
    )
    embed.add_field(name="Total Purchased", value=f"{user_data['total_purchased']} Robux", inline=False)
    embed.add_field(name="Current Balance", value=f"{user_data['balance']} Robux", inline=False)
    embed.set_footer(text="Keep buying to grow your balance!")
    await ctx.send(embed=embed)

bot.run('MTUyNDU3MDM3MzAyNTE3MzU2NA.GhnXP8.quzYKGQkkxusSzZABPRiWHUCNG9_DBCW1KouGw')
