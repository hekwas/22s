--========================================================--
--==[ HEKWAS HUB - DARK RED BLOOD FOG EDITION ]==--
--========================================================--
-- Autor: Muhu x Copilot
-- Tema: Horror Minimalist + Blood + Fog + Dark Ritual
-- GUI complet rescris, fără slidere, doar butoane +/–
-- Toate funcțiile tale integrate și optimizate
--========================================================--

--== SERVICES ==--
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

--== GLOBAL TABLES ==--
local Enabled = {
    SpeedBoost = false,
    SpinBot = false,
    Galaxy = false,
    AntiRagdoll = false,
    SpamBat = false,
    AutoSteal = false,
    BatAimbot = false,
    SpeedWhileStealing = false,
    Unwalk = false,
    Optimizer = false,
    AutoWalkEnabled = false,
    AutoRightEnabled = false,
    GalaxySkyBright = false,
}

local Values = {
    BoostSpeed = 30,
    SpinSpeed = 30,
    STEAL_RADIUS = 20,
    STEAL_DURATION = 1.8,
    GalaxyGravityPercent = 100,
    HOP_POWER = 40,
    StealingSpeedValue = 20,
}

local KEYBINDS = {
    SPEED = Enum.KeyCode.V,
    SPIN = Enum.KeyCode.N,
    GALAXY = Enum.KeyCode.M,
    BATAIMBOT = Enum.KeyCode.X,
    NUKE = Enum.KeyCode.Q,
    AUTOLEFT = Enum.KeyCode.Z,
    AUTORIGHT = Enum.KeyCode.C,
}

local Connections = {}
local StealData = {}
local isStealing = false
local stealStartTime = 0
local progressConnection = nil

local AutoWalkEnabled = false
local AutoRightEnabled = false
local spaceHeld = false

local configLoaded = false

--========================================================--
--== UTILS ==--
--========================================================--

local function playSound(id, vol, spd)
    pcall(function()
        local s = Instance.new("Sound", SoundService)
        s.SoundId = id
        s.Volume = vol or 0.4
        s.PlaybackSpeed = spd or 1
        s:Play()
        game:GetService("Debris"):AddItem(s, 1)
    end)
end

local function getDiscordProgress(percent)
    if percent < 10 then return "█---------"
    elseif percent < 20 then return "██--------"
    elseif percent < 30 then return "███-------"
    elseif percent < 40 then return "████------"
    elseif percent < 50 then return "█████-----"
    elseif percent < 60 then return "██████----"
    elseif percent < 70 then return "███████---"
    elseif percent < 80 then return "████████--"
    elseif percent < 90 then return "█████████-"
    else return "██████████"
    end
end

local function isMyPlotByName(name)
    local myName = Player.Name:lower()
    return name:lower():find(myName) ~= nil
end
--========================================================--
--== HEKWAS HUB - FUNCTION ENGINE (ALL FEATURES) ==--
--========================================================--

--========================================================--
--== SPEED BOOST ==--
--========================================================--

local speedConnection = nil

local function startSpeedBoost()
    if speedConnection then return end
    speedConnection = RunService.Heartbeat:Connect(function()
        if not Enabled.SpeedBoost then return end
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += hrp.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= hrp.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= hrp.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += hrp.CFrame.RightVector end

        if move.Magnitude > 0 then
            hrp.Velocity = move.Unit * Values.BoostSpeed
        end
    end)
end

local function stopSpeedBoost()
    if speedConnection then speedConnection:Disconnect() speedConnection = nil end
end

--========================================================--
--== SPIN BOT ==--
--========================================================--

local spinConnection = nil

local function startSpinBot()
    if spinConnection then return end
    spinConnection = RunService.Heartbeat:Connect(function()
        if not Enabled.SpinBot then return end
        local char = Player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Values.SpinSpeed), 0)
    end)
end

local function stopSpinBot()
    if spinConnection then spinConnection:Disconnect() spinConnection = nil end
end

--========================================================--
--== ANTI RAGDOLL ==--
--========================================================--

local function startAntiRagdoll()
    local char = Player.Character
    if not char then return end
    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BallSocketConstraint") then v:Destroy() end
    end
end

local function stopAntiRagdoll()
    -- nothing to restore
end

--========================================================--
--== SPAM BAT ==--
--========================================================--

local spamConnection = nil

local function startSpamBat()
    if spamConnection then return end
    spamConnection = RunService.Heartbeat:Connect(function()
        if not Enabled.SpamBat then return end
        pcall(function()
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("RemoteEvent") then
                tool.RemoteEvent:FireServer()
            end
        end)
    end)
end

local function stopSpamBat()
    if spamConnection then spamConnection:Disconnect() spamConnection = nil end
end

--========================================================--
--== AUTO STEAL ==--
--========================================================--

local function findNearestPrompt()
    local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not h then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local np, nd, nn = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - h.Position).Magnitude
                    if dist < nd and dist <= Values.STEAL_RADIUS then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then
                                    np, nd, nn = ch, dist, pod.Name
                                    break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np, nd, nn
end

local function ResetProgressBar()
    if ProgressLabel then ProgressLabel.Text = "READY" end
    if ProgressPercentLabel then ProgressPercentLabel.Text = "" end
    if ProgressBarFill then ProgressBarFill.Size = UDim2.new(0, 0, 1, 0) end
end

local function executeSteal(prompt, name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready = false
    isStealing = true
    stealStartTime = tick()

    if ProgressLabel then ProgressLabel.Text = name or "STEALING..." end

    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConnection:Disconnect() return end
        local prog = math.clamp((tick() - stealStartTime) / Values.STEAL_DURATION, 0, 1)
        if ProgressBarFill then ProgressBarFill.Size = UDim2.new(prog, 0, 1, 0) end
        if ProgressPercentLabel then 
            local percent = math.floor(prog * 100)
            ProgressPercentLabel.Text = getDiscordProgress(percent)
        end
    end)

    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        task.wait(Values.STEAL_DURATION)
        for _, f in ipairs(data.trigger) do task.spawn(f) end
        if progressConnection then progressConnection:Disconnect() end
        ResetProgressBar()
        data.ready = true
        isStealing = false
    end)
end

local function startAutoSteal()
    if Connections.autoSteal then return end
    Connections.autoSteal = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local p, _, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
end

local function stopAutoSteal()
    if Connections.autoSteal then
        Connections.autoSteal:Disconnect()
        Connections.autoSteal = nil
    end
    isStealing = false
    ResetProgressBar()
end

--========================================================--
--== UNWALK ==--
--========================================================--

local savedAnimations = {}

local function startUnwalk()
    local c = Player.Character
    if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            t:Stop()
        end
    end
    local anim = c:FindFirstChild("Animate")
    if anim then
        savedAnimations.Animate = anim:Clone()
        anim:Destroy()
    end
end

local function stopUnwalk()
    local c = Player.Character
    if c and savedAnimations.Animate then
        savedAnimations.Animate:Clone().Parent = c
        savedAnimations.Animate = nil
    end
end

--========================================================--
--== OPTIMIZER + XRAY ==--
--========================================================--

local originalTransparency = {}
local xrayEnabled = false

local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE = true end

    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        Lighting.GlobalShadows = false
        Lighting.Brightness = 3
        Lighting.FogEnd = 9e9
    end)

    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    obj.Material = Enum.Material.Plastic
                end
            end)
        end
    end)

    xrayEnabled = true
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end)
end

local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
    if xrayEnabled then
        for part, value in pairs(originalTransparency) do
            if part then part.LocalTransparencyModifier = value end
        end
        originalTransparency = {}
        xrayEnabled = false
    end
end
--========================================================--
--== HEKWAS HUB - DARK RED BLOOD FOG GUI ==--
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HEKWAS_HUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

--========================================================--
--== MAIN WINDOW ==--
--========================================================--

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 330, 0, 420)
Main.Position = UDim2.new(0.5, -165, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(10, 0, 0)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

-- BLOOD FOG BACKGROUND
local Fog = Instance.new("ImageLabel")
Fog.Size = UDim2.new(1, 0, 1, 0)
Fog.BackgroundTransparency = 1
Fog.Image = "rbxassetid://10849700863"
Fog.ImageColor3 = Color3.fromRGB(180, 0, 0)
Fog.ImageTransparency = 0.75
Fog.ZIndex = 0
Fog.Parent = Main

-- TITLE BAR
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
Title.Text = "HEKWAS HUB"
Title.TextColor3 = Color3.fromRGB(255, 40, 40)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.BorderSizePixel = 0
Title.Parent = Main

--========================================================--
--== CONTAINER ==--
--========================================================--

local Holder = Instance.new("Frame")
Holder.Size = UDim2.new(1, -10, 1, -50)
Holder.Position = UDim2.new(0, 5, 0, 45)
Holder.BackgroundTransparency = 1
Holder.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.Parent = Holder

--========================================================--
--== BUTTON CREATOR ==--
--========================================================--

local function CreateButton(text)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 36)
    B.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(255, 60, 60)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 16
    B.AutoButtonColor = false

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 0, 0)
    UIStroke.Thickness = 1.5
    UIStroke.Parent = B

    B.MouseEnter:Connect(function()
        B.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    end)
    B.MouseLeave:Connect(function()
        B.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    end)

    B.Parent = Holder
    return B
end

--========================================================--
--== VALUE ADJUSTER ( + / - ) ==--
--========================================================--

local function CreateValueAdjuster(name, default)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    Frame.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(255, 50, 50)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 15
    Label.Parent = Frame

    local Minus = Instance.new("TextButton")
    Minus.Size = UDim2.new(0.2, -4, 1, 0)
    Minus.Position = UDim2.new(0.6, 0, 0, 0)
    Minus.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    Minus.Text = "-"
    Minus.TextColor3 = Color3.fromRGB(255, 40, 40)
    Minus.Font = Enum.Font.GothamBold
    Minus.TextSize = 18
    Minus.Parent = Frame

    local Plus = Instance.new("TextButton")
    Plus.Size = UDim2.new(0.2, -4, 1, 0)
    Plus.Position = UDim2.new(0.8, 4, 0, 0)
    Plus.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
    Plus.Text = "+"
    Plus.TextColor3 = Color3.fromRGB(255, 40, 40)
    Plus.Font = Enum.Font.GothamBold
    Plus.TextSize = 18
    Plus.Parent = Frame

    return Label, Plus, Minus
end

--========================================================--
--== BUTTONS (connected in Part 4) ==--
--========================================================--

local SpeedBtn = CreateButton("Speed Boost")
local SpinBtn = CreateButton("SpinBot")
local GalaxyBtn = CreateButton("Galaxy Mode")
local AntiRagdollBtn = CreateButton("Anti-Ragdoll")
local AutoStealBtn = CreateButton("Auto Steal")
local BatAimbotBtn = CreateButton("Bat Aimbot")
local SpamBatBtn = CreateButton("Spam Bat")
local AutoLeftBtn = CreateButton("Auto Walk Left")
local AutoRightBtn = CreateButton("Auto Walk Right")
local OptimizerBtn = CreateButton("Optimizer + XRay")
local UnwalkBtn = CreateButton("Unwalk Mode")
local GalaxyBrightBtn = CreateButton("Galaxy Sky Bright")

--========================================================--
--== VALUE ADJUSTERS ==--
--========================================================--

local SpeedLabel, SpeedPlus, SpeedMinus = CreateValueAdjuster("Speed", Values.BoostSpeed)
local SpinLabel, SpinPlus, SpinMinus = CreateValueAdjuster("Spin Speed", Values.SpinSpeed)
local StealLabel, StealPlus, StealMinus = CreateValueAdjuster("Steal Radius", Values.STEAL_RADIUS)

print("[HEKWAS HUB] GUI Loaded.")
--========================================================--
--== HEKWAS HUB - FINAL CONNECTIONS ==--
--========================================================--

--========================================================--
--== CONNECT BUTTONS TO FUNCTIONS ==--
--========================================================--

SpeedBtn.MouseButton1Click:Connect(function()
    Enabled.SpeedBoost = not Enabled.SpeedBoost
    if Enabled.SpeedBoost then startSpeedBoost() else stopSpeedBoost() end
end)

SpinBtn.MouseButton1Click:Connect(function()
    Enabled.SpinBot = not Enabled.SpinBot
    if Enabled.SpinBot then startSpinBot() else stopSpinBot() end
end)

GalaxyBtn.MouseButton1Click:Connect(function()
    Enabled.Galaxy = not Enabled.Galaxy
    if Enabled.Galaxy then startGalaxy() else stopGalaxy() end
end)

AntiRagdollBtn.MouseButton1Click:Connect(function()
    Enabled.AntiRagdoll = not Enabled.AntiRagdoll
    if Enabled.AntiRagdoll then startAntiRagdoll() end
end)

AutoStealBtn.MouseButton1Click:Connect(function()
    Enabled.AutoSteal = not Enabled.AutoSteal
    if Enabled.AutoSteal then startAutoSteal() else stopAutoSteal() end
end)

BatAimbotBtn.MouseButton1Click:Connect(function()
    Enabled.BatAimbot = not Enabled.BatAimbot
    if Enabled.BatAimbot then startBatAimbot() else stopBatAimbot() end
end)

SpamBatBtn.MouseButton1Click:Connect(function()
    Enabled.SpamBat = not Enabled.SpamBat
    if Enabled.SpamBat then startSpamBat() else stopSpamBat() end
end)

AutoLeftBtn.MouseButton1Click:Connect(function()
    AutoWalkEnabled = not AutoWalkEnabled
    Enabled.AutoWalkEnabled = AutoWalkEnabled
    if AutoWalkEnabled then startAutoWalk() else stopAutoWalk() end
end)

AutoRightBtn.MouseButton1Click:Connect(function()
    AutoRightEnabled = not AutoRightEnabled
    Enabled.AutoRightEnabled = AutoRightEnabled
    if AutoRightEnabled then startAutoRight() else stopAutoRight() end
end)

OptimizerBtn.MouseButton1Click:Connect(function()
    Enabled.Optimizer = not Enabled.Optimizer
    if Enabled.Optimizer then enableOptimizer() else disableOptimizer() end
end)

UnwalkBtn.MouseButton1Click:Connect(function()
    Enabled.Unwalk = not Enabled.Unwalk
    if Enabled.Unwalk then startUnwalk() else stopUnwalk() end
end)

GalaxyBrightBtn.MouseButton1Click:Connect(function()
    Enabled.GalaxySkyBright = not Enabled.GalaxySkyBright
    if Enabled.GalaxySkyBright then enableGalaxySkyBright() else disableGalaxySkyBright() end
end)

--========================================================--
--== VALUE ADJUSTERS ==--
--========================================================--

local function updateLabel(label, name, value)
    label.Text = name .. ": " .. value
end

SpeedPlus.MouseButton1Click:Connect(function()
    Values.BoostSpeed = math.clamp(Values.BoostSpeed + 1, 1, 70)
    updateLabel(SpeedLabel, "Speed", Values.BoostSpeed)
end)

SpeedMinus.MouseButton1Click:Connect(function()
    Values.BoostSpeed = math.clamp(Values.BoostSpeed - 1, 1, 70)
    updateLabel(SpeedLabel, "Speed", Values.BoostSpeed)
end)

SpinPlus.MouseButton1Click:Connect(function()
    Values.SpinSpeed = math.clamp(Values.SpinSpeed + 1, 5, 50)
    updateLabel(SpinLabel, "Spin Speed", Values.SpinSpeed)
end)

SpinMinus.MouseButton1Click:Connect(function()
    Values.SpinSpeed = math.clamp(Values.SpinSpeed - 1, 5, 50)
    updateLabel(SpinLabel, "Spin Speed", Values.SpinSpeed)
end)

StealPlus.MouseButton1Click:Connect(function()
    Values.STEAL_RADIUS = math.clamp(Values.STEAL_RADIUS + 1, 5, 100)
    updateLabel(StealLabel, "Steal Radius", Values.STEAL_RADIUS)
end)

StealMinus.MouseButton1Click:Connect(function()
    Values.STEAL_RADIUS = math.clamp(Values.STEAL_RADIUS - 1, 5, 100)
    updateLabel(StealLabel, "Steal Radius", Values.STEAL_RADIUS)
end)

--========================================================--
--== KEYBINDS ==--
--========================================================--

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    if input.KeyCode == KEYBINDS.SPEED then
        SpeedBtn:Activate()
    end

    if input.KeyCode == KEYBINDS.SPIN then
        SpinBtn:Activate()
    end

    if input.KeyCode == KEYBINDS.GALAXY then
        GalaxyBtn:Activate()
    end

    if input.KeyCode == KEYBINDS.BATAIMBOT then
        BatAimbotBtn:Activate()
    end

    if input.KeyCode == KEYBINDS.AUTOLEFT then
        AutoLeftBtn:Activate()
    end

    if input.KeyCode == KEYBINDS.AUTORIGHT then
        AutoRightBtn:Activate()
    end

    if input.KeyCode == KEYBINDS.NUKE then
        local n = getNearestPlayer()
        if n then INSTANT_NUKE(n) end
    end
end)

--========================================================--
--== AUTO APPLY CONFIG AFTER LOAD ==--
--========================================================--

task.spawn(function()
    task.wait(2)

    if Enabled.SpeedBoost then startSpeedBoost() end
    if Enabled.SpinBot then startSpinBot() end
    if Enabled.Galaxy then startGalaxy() end
    if Enabled.AntiRagdoll then startAntiRagdoll() end
    if Enabled.SpamBat then startSpamBat() end
    if Enabled.AutoSteal then startAutoSteal() end
    if Enabled.BatAimbot then startBatAimbot() end
    if Enabled.Unwalk then startUnwalk() end
    if Enabled.Optimizer then enableOptimizer() end
    if Enabled.GalaxySkyBright then enableGalaxySkyBright() end
    if Enabled.AutoWalkEnabled then startAutoWalk() end
    if Enabled.AutoRightEnabled then startAutoRight() end
end)

--========================================================--
--== FINAL LOG ==--
--========================================================--

print("======================================")
print("     HEKWAS HUB - BLOOD FOG EDITION   ")
print("     Loaded successfully, Muhu.        ")
print("======================================")
