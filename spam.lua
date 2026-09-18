repeat wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local inputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")

local CONFIG = {
    PrimaryRed = Color3.fromRGB(255, 20, 50),
    AccentGlow = Color3.fromRGB(255, 60, 90),
    DarkBlack = Color3.fromRGB(10, 10, 14),
    PanelBlack = Color3.fromRGB(15, 15, 22),
    InputGray = Color3.fromRGB(25, 25, 36),
    White = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 185)
}

local gui = Instance.new("ScreenGui")
gui.Name = "2U_GodTier_AdminPlus"
gui.Parent = game:GetService("CoreGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- الزر العائم الخارجي المستقل
local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 54, 0, 54)
floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
floatBtn.BackgroundColor3 = CONFIG.PanelBlack
floatBtn.BorderSizePixel = 0
floatBtn.Text = ""
floatBtn.Active = true
floatBtn.Draggable = true
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
floatBtn.Parent = gui

local floatStroke = Instance.new("UIStroke")
floatStroke.Color = CONFIG.PrimaryRed
floatStroke.Thickness = 2.5
floatStroke.Transparency = 0.2
floatStroke.Parent = floatBtn

local floatText = Instance.new("TextLabel")
floatText.Size = UDim2.new(1, 0, 1, 0)
floatText.BackgroundTransparency = 1
floatText.Text = "2U"
floatText.TextColor3 = CONFIG.White
floatText.TextSize = 18
floatText.Font = Enum.Font.GothamBlack
floatText.Parent = floatBtn

-- الواجهة الأساسية
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 460)
main.Position = UDim2.new(0.5, -260, 0.5, -230)
main.BackgroundColor3 = CONFIG.PanelBlack
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 20)
main.Parent = gui

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = CONFIG.PrimaryRed
mainStroke.Thickness = 2.5
mainStroke.Transparency = 0.2
mainStroke.Parent = main

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 12, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14))
}
mainGradient.Rotation = 90
mainGradient.Parent = main

-- الجسيمات المتحركة داخل الواجهة
local particles = {}
for i = 1, 8 do
    local p = Instance.new("Frame")
    p.Size = UDim2.new(0, math.random(3, 6), 0, math.random(3, 6))
    p.Position = UDim2.new(math.random(), 0, math.random(), 0)
    p.BackgroundColor3 = CONFIG.PrimaryRed
    p.BackgroundTransparency = 0.5
    p.BorderSizePixel = 0
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    p.Parent = main
    table.insert(particles, {obj = p, speed = math.random(10, 30) / 1000})
end

runService.RenderStepped:Connect(function()
    for _, part in ipairs(particles) do
        local pos = part.obj.Position
        local newY = pos.Y.Scale - part.speed * 0.05
        if newY < 0 then newY = 1 end
        part.obj.Position = UDim2.new(pos.X.Scale, 0, newY, 0)
    end
end)

-- رأس الواجهة (Header)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 20)
header.Parent = main

local headerCover = Instance.new("Frame")
headerCover.Size = UDim2.new(1, 0, 0, 15)
headerCover.Position = UDim2.new(0, 0, 1, -15)
headerCover.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
headerCover.BackgroundTransparency = 0.3
headerCover.BorderSizePixel = 0
headerCover.Parent = header

local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 40, 0, 40)
logoContainer.Position = UDim2.new(0, 15, 0, 10)
logoContainer.BackgroundColor3 = CONFIG.PrimaryRed
logoContainer.BorderSizePixel = 0
Instance.new("UICorner", logoContainer).CornerRadius = UDim.new(1, 0)
logoContainer.Parent = header

local logoGlow = Instance.new("UIStroke")
logoGlow.Color = CONFIG.White
logoGlow.Thickness = 1.5
logoGlow.Transparency = 0.5
logoGlow.Parent = logoContainer

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "2U"
logoText.TextColor3 = CONFIG.White
logoText.TextSize = 16
logoText.Font = Enum.Font.GothamBlack
logoText.Parent = logoContainer

local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(1, -180, 1, 0)
headerTitle.Position = UDim2.new(0, 65, 0, 0)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "2U • ADMIN PLUS"
headerTitle.TextColor3 = CONFIG.White
headerTitle.TextSize = 16
headerTitle.Font = Enum.Font.GothamBlack
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = header

local function createHeaderButton(posX, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.Position = UDim2.new(1, posX, 0, 12)
    btn.BackgroundColor3 = CONFIG.InputGray
    btn.BackgroundTransparency = 0.5
    btn.Text = text
    btn.TextColor3 = CONFIG.White
    btn.TextSize = 16
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = CONFIG.PrimaryRed
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = btn
    
    btn.Parent = header
    return btn
end

local closeBtn = createHeaderButton(-46, "✕")
local minBtn = createHeaderButton(-88, "—")

-- حاوية المحتوى
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -30, 1, -75)
container.Position = UDim2.new(0, 15, 0, 65)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.CanvasSize = UDim2.new(0, 0, 0, 480)
container.ScrollBarThickness = 4
container.ScrollBarImageColor3 = CONFIG.PrimaryRed
container.Parent = main

local function createLabel(text, posY)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
    lbl.Position = UDim2.new(0, 0, 0, posY)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = CONFIG.SubText
    lbl.TextSize = 13
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = container
    return lbl
end

createLabel("📝  HD ADMIN COMMAND ENGINE", 10)

local cmdBox = Instance.new("TextBox")
cmdBox.Size = UDim2.new(1, 0, 0, 46)
cmdBox.Position = UDim2.new(0, 0, 0, 38)
cmdBox.BackgroundColor3 = CONFIG.InputGray
cmdBox.BackgroundTransparency = 0.3
cmdBox.Text = "/re"
cmdBox.PlaceholderText = "أدخل الأمر هنا... مثال: /re"
cmdBox.TextColor3 = CONFIG.White
cmdBox.PlaceholderColor3 = CONFIG.SubText
cmdBox.TextSize = 15
cmdBox.Font = Enum.Font.Code
cmdBox.ClearTextOnFocus = false
cmdBox.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", cmdBox).CornerRadius = UDim.new(0, 12)
cmdBox.Parent = container

local cmdBoxStroke = Instance.new("UIStroke")
cmdBoxStroke.Color = CONFIG.PrimaryRed
cmdBoxStroke.Thickness = 1.5
cmdBoxStroke.Transparency = 0.4
cmdBoxStroke.Parent = cmdBox

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 15)
pad.Parent = cmdBox

local spamBtn = Instance.new("TextButton")
spamBtn.Size = UDim2.new(1, 0, 0, 50)
spamBtn.Position = UDim2.new(0, 0, 0, 96)
spamBtn.BackgroundColor3 = CONFIG.PrimaryRed
spamBtn.Text = "⚡  START HYPER SPAM  ⚡"
spamBtn.TextColor3 = CONFIG.White
spamBtn.TextSize = 16
spamBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", spamBtn).CornerRadius = UDim.new(0, 12)
spamBtn.Parent = container

local spamGlow = Instance.new("UIStroke")
spamGlow.Color = CONFIG.White
spamGlow.Thickness = 1.5
spamGlow.Transparency = 0.4
spamGlow.Parent = spamBtn

createLabel("⚡  EXECUTION SPEED  ( 0 = MAXIMUM POWER )", 158)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 140, 0, 46)
speedBox.Position = UDim2.new(0, 0, 0, 186)
speedBox.BackgroundColor3 = CONFIG.InputGray
speedBox.BackgroundTransparency = 0.3
speedBox.Text = "0"
speedBox.PlaceholderText = "0"
speedBox.TextColor3 = CONFIG.White
speedBox.PlaceholderColor3 = CONFIG.SubText
speedBox.TextSize = 15
speedBox.Font = Enum.Font.Code
speedBox.ClearTextOnFocus = false
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 12)
speedBox.Parent = container

local speedStroke = Instance.new("UIStroke")
speedStroke.Color = CONFIG.PrimaryRed
speedStroke.Thickness = 1.5
speedStroke.Transparency = 0.4
speedStroke.Parent = speedBox

local speedPad = Instance.new("UIPadding")
speedPad.PaddingLeft = UDim.new(0, 15)
speedPad.Parent = speedBox

local protectionBtn = Instance.new("TextButton")
protectionBtn.Size = UDim2.new(1, -152, 0, 46)
protectionBtn.Position = UDim2.new(0, 152, 0, 186)
protectionBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
protectionBtn.BackgroundTransparency = 0.2
protectionBtn.Text = "🛡️  ULTIMATE SHIELD: OFF"
protectionBtn.TextColor3 = CONFIG.White
protectionBtn.TextSize = 13
protectionBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", protectionBtn).CornerRadius = UDim.new(0, 12)
protectionBtn.Parent = container

local protStroke = Instance.new("UIStroke")
protStroke.Color = Color3.fromRGB(0, 170, 255)
protStroke.Thickness = 1.5
protStroke.Transparency = 0.4
protStroke.Parent = protectionBtn

-- لوحة الحالة (Status Dashboard)
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(1, 0, 0, 70)
statusFrame.Position = UDim2.new(0, 0, 0, 244)
statusFrame.BackgroundColor3 = CONFIG.InputGray
statusFrame.BackgroundTransparency = 0.4
statusFrame.BorderSizePixel = 0
Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 12)
statusFrame.Parent = container

local statusStroke = Instance.new("UIStroke")
statusStroke.Color = Color3.fromRGB(60, 60, 80)
statusStroke.Thickness = 1
statusStroke.Transparency = 0.5
statusStroke.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 24)
statusLabel.Position = UDim2.new(0, 12, 0, 10)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "🟢 SYSTEM STATUS: FULLY OPERATIONAL"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

local counterLabel = Instance.new("TextLabel")
counterLabel.Size = UDim2.new(1, -20, 0, 20)
counterLabel.Position = UDim2.new(0, 12, 0, 36)
counterLabel.BackgroundTransparency = 1
counterLabel.Text = "📊 PACKETS TRANSMITTED: 0"
counterLabel.TextColor3 = CONFIG.SubText
counterLabel.TextSize = 12
counterLabel.Font = Enum.Font.Code
counterLabel.TextXAlignment = Enum.TextXAlignment.Left
counterLabel.Parent = statusFrame

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 0, 330)
footer.BackgroundTransparency = 1
footer.Text = "2U ADMIN PLUS • NEXT-GEN ARCHITECTURE"
footer.TextColor3 = CONFIG.SubText
footer.TextSize = 11
footer.Font = Enum.Font.Gotham
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.Parent = container

-- محرك التنفيذ والمنطق
local running = false
local stopSpam = false
local totalSent = 0
local protectionActive = false

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

local function executeProtectionClean()
    pcall(function()
        local hdClient = replicated:FindFirstChild("HDAdminHDClient")
        if hdClient then
            local assets = hdClient:FindFirstChild("Assets")
            if assets then
                for _, asset in ipairs(assets:GetChildren()) do
                    local nameLower = string.lower(asset.Name)
                    if string.find(nameLower, "nightvision") or string.find(nameLower, "nv") then
                        asset:Destroy()
                    end
                end
            end
        end
    end)

    pcall(function()
        local cam = workspace.CurrentCamera
        if cam then
            for _, obj in ipairs(cam:GetChildren()) do
                local nameLower = string.lower(obj.Name)
                if obj:IsA("BlurEffect") or string.find(nameLower, "blur") then
                    obj:Destroy()
                end
            end
        end
    end)

    pcall(function()
        for _, obj in ipairs(lighting:GetChildren()) do
            if obj:IsA("BlurEffect") then
                obj:Destroy()
            end
        end
    end)

    local pg = player:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetChildren()) do
            local nameLower = string.lower(obj.Name)
            if string.find(nameLower, "hdadminface") or 
               string.find(nameLower, "hdadmininterface") or 
               string.find(nameLower, "nightvision") or 
               string.find(nameLower, "nv") or 
               string.find(nameLower, "logs") or 
               string.find(nameLower, "clogs") or
               string.find(nameLower, "cmdbar") then
                pcall(function() obj:Destroy() end)
            end
        end
    end
end

task.spawn(function()
    while true do
        if protectionActive then
            executeProtectionClean()
        end
        task.wait(0.02)
    end
end)

protectionBtn.MouseButton1Click:Connect(function()
    protectionActive = not protectionActive
    if protectionActive then
        protectionBtn.Text = "🛡️  ULTIMATE SHIELD: ACTIVE"
        protectionBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        protStroke.Color = Color3.fromRGB(0, 255, 200)
        updateStatus("🛡️ STATUS: SHIELD DESTROYING BLUR & NV", Color3.fromRGB(0, 200, 255))
    else
        protectionBtn.Text = "🛡️  ULTIMATE SHIELD: OFF"
        protectionBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
        protStroke.Color = Color3.fromRGB(0, 170, 255)
        updateStatus("🟢 SYSTEM STATUS: FULLY OPERATIONAL", Color3.fromRGB(0, 255, 120))
    end
end)

spamBtn.MouseButton1Click:Connect(function()
    if running then
        stopSpam = true
        running = false
        spamBtn.Text = "⚡  START HYPER SPAM  ⚡"
        spamBtn.BackgroundColor3 = CONFIG.PrimaryRed
        updateStatus("⏹ STATUS: OPERATION HALTED", Color3.fromRGB(255, 200, 0))
        return
    end
    
    local cmd = cmdBox.Text
    if cmd == "" then cmd = "/re" end
    
    local speedInput = tonumber(speedBox.Text) or 0
    if speedInput < 0 then speedInput = 0 end
    
    local delay = speedInput == 0 and 0 or (1 / speedInput)
    
    running = true
    stopSpam = false
    totalSent = 0
    counterLabel.Text = "📊 PACKETS TRANSMITTED: 0"
    updateStatus("🟡 STATUS: FLOODING COMMAND STREAM...", Color3.fromRGB(255, 200, 0))
    spamBtn.Text = "⏹  HALT HYPER SPAM"
    spamBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 30)
    
    task.spawn(function()
        while not stopSpam do
            sendCommand(cmd)
            totalSent = totalSent + 1
            
            if totalSent % 15 == 0 then
                counterLabel.Text = "📊 PACKETS TRANSMITTED: " .. totalSent
            end
            
            if delay > 0 then
                task.wait(delay)
            else
                task.defer(task.wait)
            end
        end
        
        running = false
        counterLabel.Text = "📊 PACKETS TRANSMITTED: " .. totalSent
    end)
end)

spamBtn.MouseEnter:Connect(function()
    if not running then
        tweenService:Create(spamBtn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(255, 50, 80) }):Play()
    end
end)
spamBtn.MouseLeave:Connect(function()
    if not running then
        tweenService:Create(spamBtn, TweenInfo.new(0.2), { BackgroundColor3 = CONFIG.PrimaryRed }):Play()
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    stopSpam = true
    running = false
    protectionActive = false
    gui:Destroy()
end)

-- التحكم بالتحويل وإظهار/إخفاء الواجهة بالزر العائم الخارجي
local uiVisible = true
floatBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    main.Visible = uiVisible
end)

local minimized = false
local originalSize = main.Size

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 520, 0, 60)
        }):Play()
        container.Visible = false
    else
        container.Visible = true
        tweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = originalSize
        }):Play()
    end
end)

-- حركات النبض والإنيميشن
local pulse = 0
runService.RenderStepped:Connect(function(dt)
    pulse = pulse + dt * 2.5
    local scale = 1 + math.sin(pulse) * 0.04
    logoContainer.Size = UDim2.new(0, math.floor(40 * scale), 0, math.floor(40 * scale))
    
    local floatScale = 1 + math.cos(pulse) * 0.05
    floatBtn.Size = UDim2.new(0, math.floor(54 * floatScale), 0, math.floor(54 * floatScale))
end)
