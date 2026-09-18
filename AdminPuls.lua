repeat wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local stats = game:GetService("Stats")
local inputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

local CONFIG = {
    PrimaryRed = Color3.fromRGB(220, 0, 0),
    NeonRed = Color3.fromRGB(255, 30, 30),
    PureWhite = Color3.fromRGB(255, 255, 255),
    DeepRed = Color3.fromRGB(120, 0, 0),
    DarkRed = Color3.fromRGB(60, 0, 0),
    Black = Color3.fromRGB(6, 6, 8),
    DarkGray = Color3.fromRGB(18, 18, 20),
    Gray = Color3.fromRGB(30, 30, 34),
    White = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(190, 120, 120),
    DiscordLink = "https://discord.gg/zfytGe4WFN"
}

local gui = Instance.new("ScreenGui")
gui.Name = "2U_Hub_V6"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = CONFIG.Black
bg.BorderSizePixel = 0
bg.Parent = gui

local bgGrad = Instance.new("UIGradient")
bgGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 5, 5)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(25, 2, 2)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 8))
}
bgGrad.Rotation = 90
bgGrad.Parent = bg

local lines = {}
for i = 1, 30 do
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, math.random(1, 3), 0, math.random(200, 700))
    line.Position = UDim2.new(math.random(), 0, math.random(-1, 0), 0)
    line.BackgroundColor3 = CONFIG.PrimaryRed
    line.BackgroundTransparency = math.random(60, 90) / 100
    line.BorderSizePixel = 0
    line.Parent = bg
    
    table.insert(lines, {
        obj = line,
        speed = math.random(2, 8) / 1000
    })
end

runService.RenderStepped:Connect(function(dt)
    for _, l in ipairs(lines) do
        local pos = l.obj.Position
        local newY = pos.Y.Scale + l.speed * 60 * dt
        if newY > 1.5 then newY = -1 end
        l.obj.Position = UDim2.new(pos.X.Scale, 0, newY, 0)
    end
end)

local centerGlow = Instance.new("ImageLabel")
centerGlow.Size = UDim2.new(0, 900, 0, 900)
centerGlow.Position = UDim2.new(0.5, -450, 0.5, -450)
centerGlow.BackgroundTransparency = 1
centerGlow.Image = "rbxassetid://5028857084"
centerGlow.ImageColor3 = CONFIG.PrimaryRed
centerGlow.ImageTransparency = 0.85
centerGlow.ZIndex = 1
centerGlow.Parent = gui

local logoShadow = Instance.new("TextLabel")
logoShadow.Size = UDim2.new(1, 0, 0, 200)
logoShadow.Position = UDim2.new(0, 6, 0.26, -94)
logoShadow.BackgroundTransparency = 1
logoShadow.Text = "2U"
logoShadow.TextColor3 = Color3.fromRGB(60, 0, 0)
logoShadow.TextSize = 180
logoShadow.Font = Enum.Font.GothamBlack
logoShadow.TextScaled = true
logoShadow.TextTransparency = 0.4
logoShadow.ZIndex = 2
logoShadow.Parent = gui

local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1, 0, 0, 200)
logo.Position = UDim2.new(0, 0, 0.26, -100)
logo.BackgroundTransparency = 1
logo.Text = "2U"
logo.TextColor3 = CONFIG.PrimaryRed
logo.TextSize = 180
logo.Font = Enum.Font.GothamBlack
logo.TextScaled = true
logo.ZIndex = 3
logo.Parent = gui

local logoUnderline = Instance.new("Frame")
logoUnderline.Size = UDim2.new(0, 200, 0, 3)
logoUnderline.Position = UDim2.new(0.5, -100, 0.48, 0)
logoUnderline.BackgroundColor3 = CONFIG.PrimaryRed
logoUnderline.BorderSizePixel = 0
logoUnderline.ZIndex = 3
logoUnderline.Parent = gui

local underlineGrad = Instance.new("UIGradient")
underlineGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(1, 1)
}
underlineGrad.Parent = logoUnderline

local logoPulse = 0
runService.RenderStepped:Connect(function(dt)
    logoPulse = logoPulse + dt * 3
    local scale = 1 + math.sin(logoPulse) * 0.02
    logo.TextSize = 180 * scale
    logoShadow.TextSize = 180 * scale
end)

local welcome = Instance.new("TextLabel")
welcome.Size = UDim2.new(1, 0, 0, 60)
welcome.Position = UDim2.new(0, 0, 0.52, 0)
welcome.BackgroundTransparency = 1
welcome.Text = "W E L C O M E"
welcome.TextColor3 = CONFIG.SubText
welcome.TextSize = 30
welcome.Font = Enum.Font.GothamBold
welcome.TextScaled = true
welcome.ZIndex = 3
welcome.Parent = gui

local enterBtn = Instance.new("TextButton")
enterBtn.Size = UDim2.new(0, 520, 0, 85)
enterBtn.Position = UDim2.new(0.5, -260, 0.68, 0)
enterBtn.BackgroundColor3 = CONFIG.PrimaryRed
enterBtn.BackgroundTransparency = 0
enterBtn.BorderSizePixel = 2
enterBtn.BorderColor3 = CONFIG.PureWhite
enterBtn.Text = "⚡  ENTER THE SCRIPT  ⚡\nHOLD TO START"
enterBtn.TextColor3 = CONFIG.PureWhite
enterBtn.TextSize = 24
enterBtn.Font = Enum.Font.GothamBlack
enterBtn.ZIndex = 3
Instance.new("UICorner", enterBtn).CornerRadius = UDim.new(0, 16)
enterBtn.Parent = gui

enterBtn.MouseEnter:Connect(function()
    tweenService:Create(enterBtn, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    }):Play()
end)

enterBtn.MouseLeave:Connect(function()
    tweenService:Create(enterBtn, TweenInfo.new(0.3), {
        BackgroundColor3 = CONFIG.PrimaryRed
    }):Play()
end)

local infoFrame = Instance.new("Frame")
infoFrame.Size = UDim2.new(0, 300, 0, 200)
infoFrame.Position = UDim2.new(0, 25, 0.36, 0)
infoFrame.BackgroundColor3 = CONFIG.DarkGray
infoFrame.BackgroundTransparency = 0.1
infoFrame.BorderSizePixel = 2
infoFrame.BorderColor3 = CONFIG.PrimaryRed
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 14)
infoFrame.ZIndex = 3
infoFrame.Parent = gui

local infoGrad = Instance.new("UIGradient")
infoGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 5, 5)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 3, 5))
}
infoGrad.Rotation = 90
infoGrad.Parent = infoFrame

local infoTitle = Instance.new("Frame")
infoTitle.Size = UDim2.new(1, 0, 0, 34)
infoTitle.BackgroundColor3 = CONFIG.DarkRed
infoTitle.BorderSizePixel = 0
Instance.new("UICorner", infoTitle).CornerRadius = UDim.new(0, 14)
infoTitle.ZIndex = 4
infoTitle.Parent = infoFrame

local infoTitleText = Instance.new("TextLabel")
infoTitleText.Size = UDim2.new(1, -20, 1, 0)
infoTitleText.Position = UDim2.new(0, 12, 0, 0)
infoTitleText.BackgroundTransparency = 1
infoTitleText.Text = "⚡  SYSTEM & GAME INFO"
infoTitleText.TextColor3 = CONFIG.White
infoTitleText.TextSize = 13
infoTitleText.Font = Enum.Font.GothamBold
infoTitleText.TextXAlignment = Enum.TextXAlignment.Left
infoTitleText.ZIndex = 5
infoTitleText.Parent = infoTitle

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -20, 0, 1)
divider.Position = UDim2.new(0, 10, 0, 34)
divider.BackgroundColor3 = CONFIG.PrimaryRed
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.ZIndex = 4
divider.Parent = infoFrame

local infoText = Instance.new("TextLabel")
infoText.Size = UDim2.new(1, -24, 1, -44)
infoText.Position = UDim2.new(0, 12, 0, 40)
infoText.BackgroundTransparency = 1
infoText.Text = ""
infoText.TextColor3 = Color3.fromRGB(220, 220, 220)
infoText.TextSize = 13
infoText.Font = Enum.Font.Code
infoText.TextXAlignment = Enum.TextXAlignment.Left
infoText.TextYAlignment = Enum.TextYAlignment.Top
infoText.ZIndex = 4
infoText.Parent = infoFrame

local gamesFrame = Instance.new("Frame")
gamesFrame.Size = UDim2.new(0, 260, 0, 130)
gamesFrame.Position = UDim2.new(1, -285, 0.36, 0)
gamesFrame.BackgroundColor3 = CONFIG.DarkGray
gamesFrame.BackgroundTransparency = 0.1
gamesFrame.BorderSizePixel = 2
gamesFrame.BorderColor3 = CONFIG.PrimaryRed
Instance.new("UICorner", gamesFrame).CornerRadius = UDim.new(0, 14)
gamesFrame.ZIndex = 3
gamesFrame.Parent = gui

local gamesGrad = Instance.new("UIGradient")
gamesGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 5, 5)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 3, 5))
}
gamesGrad.Rotation = 90
gamesGrad.Parent = gamesFrame

local gamesTitle = Instance.new("Frame")
gamesTitle.Size = UDim2.new(1, 0, 0, 34)
gamesTitle.BackgroundColor3 = CONFIG.DarkRed
gamesTitle.BorderSizePixel = 0
Instance.new("UICorner", gamesTitle).CornerRadius = UDim.new(0, 14)
gamesTitle.ZIndex = 4
gamesTitle.Parent = gamesFrame

local gamesTitleText = Instance.new("TextLabel")
gamesTitleText.Size = UDim2.new(1, -20, 1, 0)
gamesTitleText.Position = UDim2.new(0, 12, 0, 0)
gamesTitleText.BackgroundTransparency = 1
gamesTitleText.Text = "🎮  SUPPORTED GAMES"
gamesTitleText.TextColor3 = CONFIG.White
gamesTitleText.TextSize = 13
gamesTitleText.Font = Enum.Font.GothamBold
gamesTitleText.TextXAlignment = Enum.TextXAlignment.Left
gamesTitleText.ZIndex = 5
gamesTitleText.Parent = gamesTitle

local divider2 = Instance.new("Frame")
divider2.Size = UDim2.new(1, -20, 0, 1)
divider2.Position = UDim2.new(0, 10, 0, 34)
divider2.BackgroundColor3 = CONFIG.PrimaryRed
divider2.BackgroundTransparency = 0.5
divider2.BorderSizePixel = 0
divider2.ZIndex = 4
divider2.Parent = gamesFrame

local card = Instance.new("TextButton")
card.Size = UDim2.new(1, -20, 0, 60)
card.Position = UDim2.new(0, 10, 0, 45)
card.BackgroundColor3 = CONFIG.Gray
card.BackgroundTransparency = 0.2
card.BorderSizePixel = 2
card.BorderColor3 = CONFIG.PrimaryRed
card.Text = ""
card.AutoButtonColor = false
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
card.ZIndex = 4
card.Parent = gamesFrame

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, -20, 0, 22)
nameLabel.Position = UDim2.new(0, 12, 0, 8)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = "Admin Plus"
nameLabel.TextColor3 = CONFIG.White
nameLabel.TextSize = 15
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.ZIndex = 5
nameLabel.Parent = card

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 8, 0, 8)
statusDot.Position = UDim2.new(0, 12, 0, 38)
statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
statusDot.BorderSizePixel = 0
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)
statusDot.ZIndex = 5
statusDot.Parent = card

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -40, 0, 16)
statusLabel.Position = UDim2.new(0, 25, 0, 34)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ONLINE"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 5
statusLabel.Parent = card

card.MouseEnter:Connect(function()
    tweenService:Create(card, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(50, 10, 10)
    }):Play()
end)

card.MouseLeave:Connect(function()
    tweenService:Create(card, TweenInfo.new(0.2), {
        BackgroundColor3 = CONFIG.Gray
    }):Play()
end)

local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(0, 230, 0, 52)
discordBtn.Position = UDim2.new(0.5, -240, 1, -130)
discordBtn.BackgroundColor3 = CONFIG.DarkGray
discordBtn.BackgroundTransparency = 0.05
discordBtn.BorderSizePixel = 2
discordBtn.BorderColor3 = Color3.fromRGB(100, 100, 220)
discordBtn.Text = "🎧   DISCORD"
discordBtn.TextColor3 = CONFIG.White
discordBtn.TextSize = 16
discordBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 12)
discordBtn.ZIndex = 3
discordBtn.Parent = gui

discordBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CONFIG.DiscordLink)
    end
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow(CONFIG.DiscordLink)
    end)
end)

discordBtn.MouseEnter:Connect(function()
    tweenService:Create(discordBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(30, 30, 70)
    }):Play()
end)

discordBtn.MouseLeave:Connect(function()
    tweenService:Create(discordBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = CONFIG.DarkGray
    }):Play()
end)

local devBtn = Instance.new("TextButton")
devBtn.Size = UDim2.new(0, 230, 0, 52)
devBtn.Position = UDim2.new(0.5, 10, 1, -130)
devBtn.BackgroundColor3 = CONFIG.DarkGray
devBtn.BackgroundTransparency = 0.05
devBtn.BorderSizePixel = 2
devBtn.BorderColor3 = CONFIG.PrimaryRed
devBtn.Text = "⚙️   DEVELOPER: 2U"
devBtn.TextColor3 = CONFIG.White
devBtn.TextSize = 16
devBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", devBtn).CornerRadius = UDim.new(0, 12)
devBtn.ZIndex = 3
devBtn.Parent = gui

devBtn.MouseEnter:Connect(function()
    tweenService:Create(devBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(50, 10, 10)
    }):Play()
end)

devBtn.MouseLeave:Connect(function()
    tweenService:Create(devBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = CONFIG.DarkGray
    }):Play()
end)

local topRightFrame = Instance.new("Frame")
topRightFrame.Size = UDim2.new(0, 200, 0, 50)
topRightFrame.Position = UDim2.new(1, -215, 0, 20)
topRightFrame.BackgroundTransparency = 1
topRightFrame.ZIndex = 3
topRightFrame.Parent = gui

local function createTopBtn(posX, text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 50)
    btn.Position = UDim2.new(0, posX, 0, 0)
    btn.BackgroundColor3 = CONFIG.DarkGray
    btn.BackgroundTransparency = 0.05
    btn.BorderSizePixel = 2
    btn.BorderColor3 = color or CONFIG.PrimaryRed
    btn.Text = text
    btn.TextColor3 = CONFIG.White
    btn.TextSize = 22
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)
    btn.ZIndex = 4
    btn.Parent = topRightFrame
    
    btn.MouseEnter:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(40, 5, 5)
        }):Play()
    end)
    
    btn.MouseLeave:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.DarkGray
        }):Play()
    end)
    
    return btn
end

local settingsBtn = createTopBtn(0, "⚙️", CONFIG.PrimaryRed)
local favBtn = createTopBtn(60, "★", Color3.fromRGB(255, 200, 0))
local closeBtn = createTopBtn(120, "✕", Color3.fromRGB(255, 50, 50))

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local menuBtn = Instance.new("TextButton")
menuBtn.Size = UDim2.new(0, 50, 0, 50)
menuBtn.Position = UDim2.new(0, 20, 0, 20)
menuBtn.BackgroundColor3 = CONFIG.DarkGray
menuBtn.BackgroundTransparency = 0.05
menuBtn.BorderSizePixel = 2
menuBtn.BorderColor3 = CONFIG.PrimaryRed
menuBtn.Text = "☰"
menuBtn.TextColor3 = CONFIG.White
menuBtn.TextSize = 24
menuBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0, 12)
menuBtn.ZIndex = 3
menuBtn.Parent = gui

local startTime = tick()
local frameCount = 0
local lastFpsUpdate = tick()
local currentFps = 0

runService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    if tick() - lastFpsUpdate >= 1 then
        currentFps = frameCount
        frameCount = 0
        lastFpsUpdate = tick()
    end
end)

task.spawn(function()
    while gui.Parent do
        local mapName = "Loading..."
        pcall(function()
            mapName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        
        local ping = 0
        pcall(function()
            ping = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        
        local players = #game.Players:GetPlayers()
        local uptime = math.floor(tick() - startTime)
        local mins = math.floor(uptime / 60)
        local secs = uptime % 60
        
        infoText.Text = "▸ MAP: " .. mapName .. "\n"
        infoText.Text = infoText.Text .. "▸ EXECUTOR: Delta\n"
        infoText.Text = infoText.Text .. "▸ FPS: " .. currentFps .. "\n"
        infoText.Text = infoText.Text .. "▸ PING: " .. ping .. "ms\n"
        infoText.Text = infoText.Text .. "▸ PLAYERS: " .. players .. "\n"
        infoText.Text = infoText.Text .. "▸ UPTIME: " .. string.format("%02d:%02d", mins, secs)
        
        task.wait(1)
    end
end)

local holdTime = 0
local isHolding = false

enterBtn.MouseButton1Down:Connect(function()
    isHolding = true
    holdTime = tick()
    
    task.spawn(function()
        while isHolding and tick() - holdTime < 1.5 do
            local progress = (tick() - holdTime) / 1.5
            enterBtn.Text = "⚡  ENTER THE SCRIPT  ⚡\n" .. string.rep("█", math.floor(progress * 20)) .. string.rep("░", 20 - math.floor(progress * 20))
            task.wait(0.05)
        end
        
        if isHolding and tick() - holdTime >= 1.5 then
            enterBtn.Text = "✅  LOADING..."
            
            local fadeOut = tweenService:Create(bg, TweenInfo.new(0.8), {
                BackgroundTransparency = 1
            })
            fadeOut:Play()
            
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("Frame") or obj:IsA("ImageLabel") then
                    pcall(function()
                        tweenService:Create(obj, TweenInfo.new(0.8), {
                            BackgroundTransparency = 1,
                            TextTransparency = 1,
                            ImageTransparency = 1
                        }):Play()
                    end)
                end
            end
            
            task.wait(1)
            gui:Destroy()
            
            print("✅ 2U HUB V6 LOADED SUCCESSFULLY!")
            
            pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/mhndfras41-sudo/Mm/refs/heads/main/Spam.lua"))()
            end)
        end
    end)
end)

enterBtn.MouseButton1Up:Connect(function()
    if isHolding then
        isHolding = false
        if tick() - holdTime < 1.5 then
            enterBtn.Text = "⚡  ENTER THE SCRIPT  ⚡\nHOLD TO START"
        end
    end
end)

print("✅ 2U HUB V6 - RED BUTTON WITH WHITE TEXT (No Neon) LOADED!")
