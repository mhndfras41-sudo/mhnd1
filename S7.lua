-- ====================================================
-- S7 ULTRA SPAM ENGINE V11 - نسخة مصلحة ومضمونة
-- ====================================================
repeat wait() until game.Players.LocalPlayer
local player = game.Players.LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")

print("🚀 بدء تشغيل S7 V11...")

-- ====================================================
-- إنشاء الواجهة
-- ====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "S7_Spam"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

if not gui.Parent then
    gui.Parent = coreGui
    print("⚠️ تم استخدام CoreGui بدلاً من PlayerGui")
end

print("✅ تم إنشاء ScreenGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 550, 0, 520)
main.Position = UDim2.new(0.5, -275, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
main.BackgroundTransparency = 0.05
main.BorderSizePixel = 3
main.BorderColor3 = Color3.fromRGB(0, 255, 200)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)
main.Parent = gui
main.Visible = true
print("✅ تم إنشاء الإطار الرئيسي")

-- ====================================================
-- باقي الكود كما هو (لم يتغير)
-- ====================================================
local glowBg = Instance.new("Frame")
glowBg.Size = UDim2.new(1, 20, 1, 20)
glowBg.Position = UDim2.new(-0.02, 0, -0.02, 0)
glowBg.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
glowBg.BackgroundTransparency = 0.85
glowBg.BorderSizePixel = 0
Instance.new("UICorner", glowBg).CornerRadius = UDim.new(0, 18)
glowBg.Parent = main

local title = Instance.new("Frame")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
title.BackgroundTransparency = 0.15
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)
title.Parent = main

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -70, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡ S7 ULTRA SPAM ENGINE V11"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextSize = 20
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = title

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 80, 0, 35)
hideBtn.Position = UDim2.new(1, -130, 0, 7)
hideBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
hideBtn.BackgroundTransparency = 0.2
hideBtn.Text = "🔽 إخفاء"
hideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideBtn.TextSize = 13
hideBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 8)
hideBtn.Parent = title

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 35, 0, 35)
close.Position = UDim2.new(1, -42, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
close.Text = "✕"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextSize = 18
close.Font = Enum.Font.GothamBold
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.Parent = title
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0, 80, 0, 40)
showBtn.Position = UDim2.new(0.5, -40, 0.5, -20)
showBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 150)
showBtn.BackgroundTransparency = 0.1
showBtn.Text = "🔓 إظهار"
showBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showBtn.TextSize = 16
showBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0, 10)
showBtn.Visible = false
showBtn.Parent = gui

local function toggleUI(show)
    main.Visible = show
    showBtn.Visible = not show
end

hideBtn.MouseButton1Click:Connect(function() toggleUI(false) end)
showBtn.MouseButton1Click:Connect(function() toggleUI(true) end)

-- ====================================================
-- الأزرار العلوية
-- ====================================================
local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 40)
tabFrame.Position = UDim2.new(0, 10, 0, 55)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = main

local function createTab(text, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 1, -5)
    btn.Position = UDim2.new(0, x, 0, 2)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 200, 150)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.Parent = tabFrame
    return btn
end

local tab1 = createTab("📝 سبام", 5)
local tab2 = createTab("🎯 صمله", 130)
local tab3 = createTab("🛡️ حماية", 255)
local tab4 = createTab("⚡ إضافات", 380)

-- ====================================================
-- الصفحات
-- ====================================================
local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, -20, 1, -120)
pageContainer.Position = UDim2.new(0, 10, 0, 100)
pageContainer.BackgroundTransparency = 1
pageContainer.Parent = main

-- صفحة السبام
local page1 = Instance.new("Frame")
page1.Size = UDim2.new(1, 0, 1, 0)
page1.BackgroundTransparency = 1
page1.Parent = pageContainer

local cmdLabel = Instance.new("TextLabel")
cmdLabel.Size = UDim2.new(0, 120, 0, 30)
cmdLabel.Position = UDim2.new(0, 0, 0, 5)
cmdLabel.BackgroundTransparency = 1
cmdLabel.Text = "📝 الأمر + الهدف:"
cmdLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
cmdLabel.TextSize = 14
cmdLabel.Font = Enum.Font.GothamMedium
cmdLabel.TextXAlignment = Enum.TextXAlignment.Left
cmdLabel.Parent = page1

local cmdBox = Instance.new("TextBox")
cmdBox.Size = UDim2.new(0, 300, 0, 35)
cmdBox.Position = UDim2.new(0, 130, 0, 2)
cmdBox.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
cmdBox.BackgroundTransparency = 0.2
cmdBox.BorderSizePixel = 1
cmdBox.BorderColor3 = Color3.fromRGB(0, 255, 200)
cmdBox.Text = "/re me"
cmdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
cmdBox.TextSize = 15
cmdBox.Font = Enum.Font.SourceSansBold
cmdBox.ClearTextOnFocus = false
Instance.new("UICorner", cmdBox).CornerRadius = UDim.new(0, 8)
cmdBox.Parent = page1

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 120, 0, 30)
speedLabel.Position = UDim2.new(0, 0, 0, 45)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "⏱️ السرعة (ث):"
speedLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
speedLabel.TextSize = 14
speedLabel.Font = Enum.Font.GothamMedium
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = page1

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 100, 0, 35)
speedBox.Position = UDim2.new(0, 130, 0, 42)
speedBox.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
speedBox.BackgroundTransparency = 0.2
speedBox.BorderSizePixel = 1
speedBox.BorderColor3 = Color3.fromRGB(0, 255, 200)
speedBox.Text = "0.1"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.TextSize = 15
speedBox.Font = Enum.Font.SourceSansBold
speedBox.ClearTextOnFocus = false
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)
speedBox.Parent = page1

local startBtn = Instance.new("TextButton")
startBtn.Size = UDim2.new(0, 160, 0, 45)
startBtn.Position = UDim2.new(0, 0, 0, 90)
startBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
startBtn.BackgroundTransparency = 0.15
startBtn.BorderSizePixel = 2
startBtn.BorderColor3 = Color3.fromRGB(0, 255, 150)
startBtn.Text = "▶ بدء السبام"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 16
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 10)
startBtn.Parent = page1

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0, 160, 0, 45)
stopBtn.Position = UDim2.new(0.5, -80, 0, 90)
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.BackgroundTransparency = 0.15
stopBtn.BorderSizePixel = 2
stopBtn.BorderColor3 = Color3.fromRGB(255, 80, 80)
stopBtn.Text = "⏹ إيقاف"
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.TextSize = 16
stopBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 10)
stopBtn.Parent = page1

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 30)
status.Position = UDim2.new(0, 0, 0, 145)
status.BackgroundTransparency = 1
status.Text = "🟢 جاهز"
status.TextColor3 = Color3.fromRGB(0, 255, 100)
status.TextSize = 14
status.Font = Enum.Font.GothamMedium
status.Parent = page1

local log = Instance.new("TextBox")
log.Size = UDim2.new(1, 0, 0, 80)
log.Position = UDim2.new(0, 0, 0, 180)
log.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
log.BackgroundTransparency = 0.2
log.BorderSizePixel = 1
log.BorderColor3 = Color3.fromRGB(0, 200, 150)
log.Text = "✅ جاهز..."
log.TextColor3 = Color3.fromRGB(150, 180, 200)
log.TextSize = 12
log.Font = Enum.Font.SourceSans
log.TextXAlignment = Enum.TextXAlignment.Left
log.TextYAlignment = Enum.TextYAlignment.Top
log.ClearTextOnFocus = false
Instance.new("UICorner", log).CornerRadius = UDim.new(0, 8)
log.Parent = page1

local function addLogMsg(msg)
    local current = log.Text
    if current == "✅ جاهز..." then current = "" end
    local lines = {}
    for line in current:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    table.insert(lines, os.date("%H:%M:%S") .. " | " .. msg)
    if #lines > 12 then table.remove(lines, 1) end
    log.Text = table.concat(lines, "\n")
end

-- ====================================================
-- صفحة الصمله
-- ====================================================
local page2 = Instance.new("Frame")
page2.Size = UDim2.new(1, 0, 1, 0)
page2.BackgroundTransparency = 1
page2.Visible = false
page2.Parent = pageContainer

local userLabel = Instance.new("TextLabel")
userLabel.Size = UDim2.new(0, 120, 0, 30)
userLabel.Position = UDim2.new(0, 0, 0, 5)
userLabel.BackgroundTransparency = 1
userLabel.Text = "👤 اسم المستخدم:"
userLabel.TextColor3 = Color3.fromRGB(180, 200, 220)
userLabel.TextSize = 14
userLabel.Font = Enum.Font.GothamMedium
userLabel.TextXAlignment = Enum.TextXAlignment.Left
userLabel.Parent = page2

local userBox = Instance.new("TextBox")
userBox.Size = UDim2.new(0, 200, 0, 35)
userBox.Position = UDim2.new(0, 130, 0, 2)
userBox.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
userBox.BackgroundTransparency = 0.2
userBox.BorderSizePixel = 1
userBox.BorderColor3 = Color3.fromRGB(0, 255, 200)
userBox.Text = ""
userBox.TextColor3 = Color3.fromRGB(255, 255, 255)
userBox.TextSize = 14
userBox.Font = Enum.Font.SourceSansBold
userBox.ClearTextOnFocus = false
Instance.new("UICorner", userBox).CornerRadius = UDim.new(0, 8)
userBox.Parent = page2

local userImage = Instance.new("ImageLabel")
userImage.Size = UDim2.new(0, 80, 0, 80)
userImage.Position = UDim2.new(0, 340, 0, 2)
userImage.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
userImage.BackgroundTransparency = 0.2
userImage.BorderSizePixel = 2
userImage.BorderColor3 = Color3.fromRGB(0, 255, 200)
userImage.Image = ""
userImage.ImageTransparency = 0
Instance.new("UICorner", userImage).CornerRadius = UDim.new(0, 40)
userImage.Parent = page2

local function updateUserImage()
    local name = userBox.Text
    for _, p in ipairs(players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name:lower() or p.DisplayName:lower():sub(1, #name) == name:lower() then
            local userId = p.UserId
            userImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=200&height=200&format=png"
            return
        end
    end
    userImage.Image = ""
end

userBox:GetPropertyChangedSignal("Text"):Connect(updateUserImage)

local function createActionBtn(text, color, y, x)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 40)
    btn.Position = UDim2.new(x or 0, 0, y or 0, 0)
    btn.BackgroundColor3 = color or Color3.fromRGB(150, 50, 200)
    btn.BackgroundTransparency = 0.15
    btn.BorderSizePixel = 2
    btn.BorderColor3 = Color3.fromRGB(200, 100, 255)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.Parent = page2
    
    btn.MouseButton1Click:Connect(function()
        local name = userBox.Text
        local target
        for _, p in ipairs(players:GetPlayers()) do
            if p.Name:lower():sub(1, #name) == name:lower() or p.DisplayName:lower():sub(1, #name) == name:lower() then
                target = p
                break
            end
        end
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            
            if text:find("الاغتصاب") then
                for i = 1, 10 do
                    myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -i * 0.5)
                    wait(0.05)
                end
                for i = 10, 1, -1 do
                    myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -i * 0.5)
                    wait(0.05)
                end
            elseif text:find("مص") then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    for i = 1, 8 do
                        myHrp.CFrame = head.CFrame * CFrame.new(0, -1.5, -i * 0.3)
                        wait(0.05)
                    end
                    for i = 8, 1, -1 do
                        myHrp.CFrame = head.CFrame * CFrame.new(0, -1.5, -i * 0.3)
                        wait(0.05)
                    end
                end
            elseif text:find("صعود") then
                local head = target.Character:FindFirstChild("Head")
                if head then
                    myHrp.CFrame = head.CFrame * CFrame.new(0, 3, 0)
                end
            end
        else
            addLogMsg("❌ اللاعب غير موجود")
        end
    end)
    return btn
end

createActionBtn("🔞 الاغتصاب", Color3.fromRGB(200, 50, 100), 0.25, 0)
createActionBtn("💋 مص", Color3.fromRGB(200, 100, 50), 0.25, 0.35)
createActionBtn("⬆️ صعود", Color3.fromRGB(50, 100, 200), 0.25, 0.7)

-- ====================================================
-- صفحة الحماية
-- ====================================================
local page3 = Instance.new("Frame")
page3.Size = UDim2.new(1, 0, 1, 0)
page3.BackgroundTransparency = 1
page3.Visible = false
page3.Parent = pageContainer

local protectBtn2 = Instance.new("TextButton")
protectBtn2.Size = UDim2.new(0, 200, 0, 50)
protectBtn2.Position = UDim2.new(0.5, -100, 0, 20)
protectBtn2.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
protectBtn2.BackgroundTransparency = 0.15
protectBtn2.BorderSizePixel = 2
protectBtn2.BorderColor3 = Color3.fromRGB(200, 100, 255)
protectBtn2.Text = "🛡️ حماية شاملة"
protectBtn2.TextColor3 = Color3.fromRGB(255, 255, 255)
protectBtn2.TextSize = 16
protectBtn2.Font = Enum.Font.GothamBold
Instance.new("UICorner", protectBtn2).CornerRadius = UDim.new(0, 10)
protectBtn2.Parent = page3

local lagBtn = Instance.new("TextButton")
lagBtn.Size = UDim2.new(0, 200, 0, 50)
lagBtn.Position = UDim2.new(0.5, -100, 0, 80)
lagBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
lagBtn.BackgroundTransparency = 0.15
lagBtn.BorderSizePixel = 2
lagBtn.BorderColor3 = Color3.fromRGB(255, 200, 80)
lagBtn.Text = "🐢 تباطؤ (حذف بكسلات)"
lagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lagBtn.TextSize = 16
lagBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", lagBtn).CornerRadius = UDim.new(0, 10)
lagBtn.Parent = page3

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0, 200, 0, 50)
rejoinBtn.Position = UDim2.new(0.5, -100, 0, 140)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
rejoinBtn.BackgroundTransparency = 0.15
rejoinBtn.BorderSizePixel = 2
rejoinBtn.BorderColor3 = Color3.fromRGB(80, 200, 255)
rejoinBtn.Text = "🔄 إعادة الدخول (Rejoin)"
rejoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rejoinBtn.TextSize = 16
rejoinBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", rejoinBtn).CornerRadius = UDim.new(0, 10)
rejoinBtn.Parent = page3

-- ====================================================
-- صفحة الإضافات
-- ====================================================
local page4 = Instance.new("Frame")
page4.Size = UDim2.new(1, 0, 1, 0)
page4.BackgroundTransparency = 1
page4.Visible = false
page4.Parent = pageContainer

local extraLabel = Instance.new("TextLabel")
extraLabel.Size = UDim2.new(1, 0, 0, 30)
extraLabel.Position = UDim2.new(0, 0, 0, 20)
extraLabel.BackgroundTransparency = 1
extraLabel.Text = "⚡ إضافات قوية"
extraLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
extraLabel.TextSize = 20
extraLabel.Font = Enum.Font.GothamBold
extraLabel.Parent = page4

-- ====================================================
-- وظائف الأزرار
-- ====================================================
local function protectPlayer()
    local plr = game.Players.LocalPlayer
    if not plr then return end
    
    addLogMsg("🛡️ جاري التنظيف الشامل...")
    
    if plr.PlayerGui then
        for _, gui in ipairs(plr.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name == "HDAdminInterface" then
                gui:Destroy()
                addLogMsg("🧹 تم حذف HDAdminInterface")
            end
        end
    end
    
    for _, child in ipairs(replicated:GetChildren()) do
        if child.Name == "NightVision" then
            child:Destroy()
            addLogMsg("🧹 تم حذف NightVision من ReplicatedStorage")
        end
    end
    
    for _, child in ipairs(lighting:GetChildren()) do
        if child.Name:lower():find("nightvision") or child.Name:lower():find("nv") then
            child:Destroy()
            addLogMsg("🧹 تم حذف NightVision من Lighting")
        end
    end
    
    lighting.Brightness = 1
    lighting.Ambient = Color3.fromRGB(128, 128, 128)
    lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
    lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
    
    for _, child in ipairs(coreGui:GetChildren()) do
        if child:IsA("ScreenGui") and child.Name:lower():find("hdadmin") then
            child:Destroy()
            addLogMsg("🧹 تم حذف من CoreGui")
        end
    end
    
    addLogMsg("✅ تم تنظيف جميع التأثيرات نهائياً")
end

local function createLag()
    addLogMsg("🐢 جاري التباطؤ...")
    for i = 1, 50 do
        for _, p in ipairs(players:GetPlayers()) do
            if p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material.Neon
                        part.Transparency = 0.5
                    end
                end
            end
        end
        wait(0.05)
    end
    addLogMsg("✅ تم التباطؤ")
end

local function rejoin()
    addLogMsg("🔄 جاري إعادة الدخول...")
    local ts = game:GetService("TeleportService")
    local placeId = game.PlaceId
    local jobId = game.JobId
    ts:TeleportToPlaceInstance(placeId, jobId, player)
end

protectBtn2.MouseButton1Click:Connect(protectPlayer)
lagBtn.MouseButton1Click:Connect(createLag)
rejoinBtn.MouseButton1Click:Connect(rejoin)

-- ====================================================
-- وظيفة السبام (مكمل)
-- ====================================================
startBtn.MouseButton1Click:Connect(function()
    if running then
        addLogMsg("⚠️ السبام يعمل بالفعل")
        return
    end
    local fullCmd = cmdBox.Text
    if fullCmd == "" then fullCmd = "/re me" end
    local speed = tonumber(speedBox.Text) or 0.1
    if speed < 0.01 then speed = 0.01 end
    
    running = true
    stopSpam = false
    status.Text = "🟡 جاري السبام..."
    status.TextColor3 = Color3.fromRGB(255, 200, 0)
    addLogMsg("🚀 بدء: " .. fullCmd .. " | سرعة: " .. speed .. "ث")
    
    spawn(function()
        local count = 0
        while not stopSpam do
            count = count + 1
            pcall(function()
                replicated.HDAdminHDClient.Signals.CreateLog:FireServer(fullCmd)
                replicated.RemoteEvents.DataService:FireServer(fullCmd)
                replicated.HDAdminHDClient.Signals.RequestCommandModification:InvokeServer(fullCmd)
            end)
            if count % 10 == 0 then
                addLogMsg("📌 أرسل " .. count .. " أمر")
            end
            wait(speed)
        end
        running = false
        status.Text = "🟢 متوقف"
        status.TextColor3 = Color3.fromRGB(0, 255, 100)
        addLogMsg("⏹ توقف بعد " .. count .. " أمر")
    end)
end)

stopBtn.MouseButton1Click:Connect(function()
    if running then
        stopSpam = true
        addLogMsg("⏳ جاري الإيقاف...")
    else
        addLogMsg("⚠️ لا يوجد سبام نشط")
    end
end)

-- ====================================================
-- تبديل الصفحات
-- ====================================================
local function setPage(page)
    page1.Visible = page == 1
    page2.Visible = page == 2
    page3.Visible = page == 3
    page4.Visible = page == 4
end

tab1.MouseButton1Click:Connect(function() setPage(1) end)
tab2.MouseButton1Click:Connect(function() setPage(2) end)
tab3.MouseButton1Click:Connect(function() setPage(3) end)
tab4.MouseButton1Click:Connect(function() setPage(4) end)

addLogMsg("💡 S7 ULTRA SPAM ENGINE V11")
addLogMsg("🛡️ اضغط على حماية لتنظيف NightVision")
print("✅ S7 ULTRA SPAM ENGINE V11 جاهز!")
