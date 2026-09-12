-- ====================================================
-- 2U - ADMIN PLUS | HD Command Spammer (V3 - Ultra Fast + Persistent)
-- ====================================================
-- واجهة احترافية للسبام أوامر HD Admin عبر RequestCommandModification

repeat wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- ====================================================
-- الإعدادات
-- ====================================================
local CONFIG = {
    PrimaryRed = Color3.fromRGB(220, 0, 0),
    DarkRed = Color3.fromRGB(80, 0, 0),
    Black = Color3.fromRGB(8, 8, 8),
    Gray = Color3.fromRGB(25, 25, 25),
    TextColor = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(200, 100, 100)
}

-- ====================================================
-- الواجهة الرئيسية
-- ====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "2U_AdminPlus"
gui.Parent = player.PlayerGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 480, 0, 420)
main.Position = UDim2.new(0.5, -240, 0.5, -210)
main.BackgroundColor3 = CONFIG.Black
main.BorderSizePixel = 2
main.BorderColor3 = CONFIG.PrimaryRed
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
main.Parent = gui

local glow = Instance.new("UIStroke", main)
glow.Color = CONFIG.PrimaryRed
glow.Thickness = 2
glow.Transparency = 0.4

-- ====================================================
-- شريط العنوان
-- ====================================================
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = CONFIG.PrimaryRed
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)
header.Parent = main

local logoCircle = Instance.new("Frame")
logoCircle.Size = UDim2.new(0, 34, 0, 34)
logoCircle.Position = UDim2.new(0, 12, 0, 8)
logoCircle.BackgroundColor3 = CONFIG.Black
logoCircle.BorderSizePixel = 2
logoCircle.BorderColor3 = CONFIG.PrimaryRed
Instance.new("UICorner", logoCircle).CornerRadius = UDim.new(1, 0)
logoCircle.Parent = header

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "2U"
logoText.TextColor3 = CONFIG.PrimaryRed
logoText.TextSize = 14
logoText.Font = Enum.Font.GothamBlack
logoText.Parent = logoCircle

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -160, 1, 0)
headerTitle.Position = UDim2.new(0, 55, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "2U • ADMIN PLUS"
headerTitle.TextColor3 = CONFIG.TextColor
headerTitle.TextSize = 18
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -46, 0, 8)
closeBtn.BackgroundColor3 = CONFIG.Black
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "✕"
closeBtn.TextColor3 = CONFIG.TextColor
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.Parent = header

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 34, 0, 34)
minBtn.Position = UDim2.new(1, -86, 0, 8)
minBtn.BackgroundColor3 = CONFIG.Black
minBtn.BackgroundTransparency = 0.3
minBtn.Text = "—"
minBtn.TextColor3 = CONFIG.TextColor
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
minBtn.Parent = header

-- ====================================================
-- TextBox الأوامر
-- ====================================================
local label1 = Instance.new("TextLabel")
label1.Size = UDim2.new(1, -30, 0, 22)
label1.Position = UDim2.new(0, 15, 0, 60)
label1.BackgroundTransparency = 1
label1.Text = "📝  HD ADMIN COMMAND"
label1.TextColor3 = CONFIG.SubText
label1.TextSize = 13
label1.Font = Enum.Font.GothamBold
label1.TextXAlignment = Enum.TextXAlignment.Left
label1.Parent = main

local cmdBox = Instance.new("TextBox")
cmdBox.Size = UDim2.new(1, -30, 0, 42)
cmdBox.Position = UDim2.new(0, 15, 0, 85)
cmdBox.BackgroundColor3 = CONFIG.Gray
cmdBox.BackgroundTransparency = 0.1
cmdBox.BorderSizePixel = 2
cmdBox.BorderColor3 = CONFIG.PrimaryRed
cmdBox.Text = "/re"
cmdBox.PlaceholderText = "اكتب الأمر هنا... مثال: /re"
cmdBox.TextColor3 = CONFIG.TextColor
cmdBox.PlaceholderColor3 = CONFIG.SubText
cmdBox.TextSize = 15
cmdBox.Font = Enum.Font.Code
cmdBox.ClearTextOnFocus = false
cmdBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", cmdBox).CornerRadius = UDim.new(0, 8)
cmdBox.Parent = main

-- ====================================================
-- زر السبام
-- ====================================================
local spamBtn = Instance.new("TextButton")
spamBtn.Size = UDim2.new(1, -30, 0, 46)
spamBtn.Position = UDim2.new(0, 15, 0, 138)
spamBtn.BackgroundColor3 = CONFIG.PrimaryRed
spamBtn.BackgroundTransparency = 0.1
spamBtn.BorderSizePixel = 2
spamBtn.BorderColor3 = CONFIG.TextColor
spamBtn.Text = "▶  START SPAM"
spamBtn.TextColor3 = CONFIG.TextColor
spamBtn.TextSize = 17
spamBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", spamBtn).CornerRadius = UDim.new(0, 10)
spamBtn.Parent = main

local spamGlow = Instance.new("UIStroke", spamBtn)
spamGlow.Color = CONFIG.TextColor
spamGlow.Thickness = 2
spamGlow.Transparency = 0.5

-- ====================================================
-- TextBox السرعة
-- ====================================================
local label2 = Instance.new("TextLabel")
label2.Size = UDim2.new(1, -30, 0, 22)
label2.Position = UDim2.new(0, 15, 0, 195)
label2.BackgroundTransparency = 1
label2.Text = "⚡  SPEED  ( 0 = أقصى سرعة )"
label2.TextColor3 = CONFIG.SubText
label2.TextSize = 13
label2.Font = Enum.Font.GothamBold
label2.TextXAlignment = Enum.TextXAlignment.Left
label2.Parent = main

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 150, 0, 42)
speedBox.Position = UDim2.new(0, 15, 0, 220)
speedBox.BackgroundColor3 = CONFIG.Gray
speedBox.BackgroundTransparency = 0.1
speedBox.BorderSizePixel = 2
speedBox.BorderColor3 = CONFIG.PrimaryRed
speedBox.Text = "0"
speedBox.PlaceholderText = "0"
speedBox.TextColor3 = CONFIG.TextColor
speedBox.PlaceholderColor3 = CONFIG.SubText
speedBox.TextSize = 15
speedBox.Font = Enum.Font.Code
speedBox.ClearTextOnFocus = false
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)
speedBox.Parent = main

-- ====================================================
-- شريط الحالة
-- ====================================================
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, -30, 0, 60)
statusFrame.Position = UDim2.new(0, 15, 0, 275)
statusFrame.BackgroundColor3 = CONFIG.Gray
statusFrame.BackgroundTransparency = 0.2
statusFrame.BorderSizePixel = 1
statusFrame.BorderColor3 = CONFIG.DarkRed
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 8)
statusFrame.Parent = main

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 6)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 STATUS: READY"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, -20, 0, 20)
counterLabel.Position = UDim2.new(0, 10, 0, 30)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "📊 SENT: 0"
counterLabel.TextColor3 = CONFIG.SubText
counterLabel.TextSize = 12
counterLabel.Font = Enum.Font.Code
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.Parent = statusFrame

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -30, 0, 18)
footer.Position = UDim2.new(0, 15, 1, -25)
footer.BackgroundTransparency = 1
footer.Text = "2U ADMIN PLUS • HD SPAMMER"
footer.TextColor3 = CONFIG.SubText
footer.TextSize = 11
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Left
footer.Parent = main

-- ====================================================
-- وظائف الواجهة
-- ====================================================
local running = false
local stopSpam = false
local totalSent = 0

local function sendCommand(cmd)
    pcall(function()
        local args = { [1] = cmd }
        replicated.HDAdminHDClient.Signals.RequestCommandModification:InvokeServer(unpack(args))
    end)
end

local function updateStatus(text, color)
    statusLabel.Text = text
    statusLabel.TextColor3 = color
end

local function updateCounter()
    counterLabel.Text = "📊 SENT: " .. totalSent
end

-- ====================================================
-- زر السبام
-- ====================================================
spamBtn.MouseButton1Click:Connect(function()
    if running then
        stopSpam = true
        running = false
        spamBtn.Text = "▶  START SPAM"
        spamBtn.BackgroundColor3 = CONFIG.PrimaryRed
        updateStatus("⏹ STATUS: STOPPED", Color3.fromRGB(255, 200, 0))
        return
    end
    
    local cmd = cmdBox.Text
    if cmd == "" then cmd = "/re" end
    
    local speedInput = tonumber(speedBox.Text) or 0
    if speedInput < 0 then speedInput = 0 end
    
    local delay
    if speedInput == 0 then
        delay = 0 -- أقصى سرعة (بدون تأخير)
    else
        delay = 1 / speedInput
    end
    
    running = true
    stopSpam = false
    totalSent = 0
    updateCounter()
    updateStatus("🟡 STATUS: SPAMMING...", Color3.fromRGB(255, 200, 0))
    spamBtn.Text = "⏹  STOP SPAM"
    spamBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    
    spawn(function()
        while not stopSpam do
            sendCommand(cmd)
            totalSent = totalSent + 1
            
            if totalSent % 10 == 0 then
                updateCounter()
            end
            
            if delay > 0 then
                wait(delay)
            else
                -- أقصى سرعة - لا تأخير
            end
        end
        
        running = false
        updateCounter()
    end)
end)

-- ====================================================
-- تأثيرات Hover
-- ====================================================
spamBtn.MouseEnter:Connect(function()
    if not running then
        tweenService:Create(spamBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 40, 40)
        }):Play()
    end
end)

spamBtn.MouseLeave:Connect(function()
    if not running then
        tweenService:Create(spamBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = CONFIG.PrimaryRed
        }):Play()
    end
end)

-- ====================================================
-- زر الإغلاق و التصغير
-- ====================================================
closeBtn.MouseButton1Click:Connect(function()
    stopSpam = true
    running = false
    gui:Destroy()
end)

local minimized = false
local originalSize = main.Size

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tweenService:Create(main, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 480, 0, 50)
        }):Play()
        label1.Visible = false
        cmdBox.Visible = false
        spamBtn.Visible = false
        label2.Visible = false
        speedBox.Visible = false
        statusFrame.Visible = false
        footer.Visible = false
    else
        tweenService:Create(main, TweenInfo.new(0.3), {
            Size = originalSize
        }):Play()
        task.wait(0.3)
        label1.Visible = true
        cmdBox.Visible = true
        spamBtn.Visible = true
        label2.Visible = true
        speedBox.Visible = true
        statusFrame.Visible = true
        footer.Visible = true
    end
end)

-- ====================================================
-- نبض الشعار
-- ====================================================
local pulse = 0
runService.RenderStepped:Connect(function(dt)
    pulse = pulse + dt * 3
    local scale = 1 + math.sin(pulse) * 0.05
    logoText.TextSize = 14 * scale
end)

print("✅ 2U ADMIN PLUS V3 - ULTRA FAST + PERSISTENT SPAMMER LOADED!")
