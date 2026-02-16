-- Services
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Config
local guiScale = 1
local KEY = "67" -- cheia corecta

-- Colors
local C = {
    bgDark = Color3.fromRGB(0,0,0),
    darkRed = Color3.fromRGB(120,0,0),
    blood = Color3.fromRGB(150,0,0),
    text = Color3.fromRGB(255,255,255)
}

-- ScreenGui
local sg = Instance.new("ScreenGui")
sg.Name = "HekwasAuth"
sg.ResetOnSpawn = false
sg.Parent = Player.PlayerGui

-- Function to spawn downward blood streams
local function spawnBlood(parent, amount)
    for i=1,amount do
        local drip = Instance.new("Frame", parent)
        local sizeX = math.random(4,12)
        local sizeY = math.random(12,25)
        drip.Size = UDim2.new(0,sizeX,0,sizeY)
        drip.Position = UDim2.new(math.random(),0,-0.1,0) -- spawn deasupra ecranului
        drip.BackgroundColor3 = C.blood
        drip.BorderSizePixel = 0
        Instance.new("UICorner", drip).CornerRadius = UDim.new(0.5,0)
        task.spawn(function()
            local speedY = 0.003 + math.random()/100
            while drip.Parent do
                local newY = drip.Position.Y.Scale + speedY
                drip.Position = UDim2.new(drip.Position.X.Scale,0,newY,0)
                if drip.Position.Y.Scale > 1 then
                    drip.Position = UDim2.new(math.random(),0,-0.1,0) -- restart sus
                end
                task.wait(0.03)
            end
        end)
    end
end

-- Minimalist Auth Panel
local authPanel = Instance.new("Frame", sg)
authPanel.Size = UDim2.new(0,400*guiScale,0,140*guiScale)
authPanel.Position = UDim2.new(0.5,-200*guiScale,0.5,-70*guiScale)
authPanel.BackgroundColor3 = C.bgDark
authPanel.BorderSizePixel = 0
Instance.new("UICorner", authPanel).CornerRadius = UDim.new(0,12*guiScale)

-- Spawn blood on auth panel
spawnBlood(authPanel, 20)

-- Title
local title = Instance.new("TextLabel", authPanel)
title.Size = UDim2.new(1,0,0,36*guiScale)
title.Position = UDim2.new(0,0,0,10*guiScale)
title.BackgroundTransparency = 1
title.Text = "HEKWAS AUTH"
title.TextColor3 = C.text
title.Font = Enum.Font.GothamBlack
title.TextScaled = true

-- TextBox
local keyBox = Instance.new("TextBox", authPanel)
keyBox.Size = UDim2.new(0.7,0,0,32*guiScale)
keyBox.Position = UDim2.new(0.15,0,0,60*guiScale)
keyBox.BackgroundColor3 = C.bgDark
keyBox.TextColor3 = C.text
keyBox.PlaceholderText = "Enter Key"
keyBox.Font = Enum.Font.GothamBold
keyBox.TextSize = 18*guiScale
keyBox.ClearTextOnFocus = false
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,6*guiScale)

-- Verify Button
local verifyBtn = Instance.new("TextButton", authPanel)
verifyBtn.Size = UDim2.new(0.5,0,0,32*guiScale)
verifyBtn.Position = UDim2.new(0.25,0,0,100*guiScale)
verifyBtn.BackgroundColor3 = C.darkRed
verifyBtn.Text = "VERIFY"
verifyBtn.TextColor3 = C.text
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 18*guiScale
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0,6*guiScale)

-- Intro function
local function runIntro()
    authPanel:Destroy()
    
    local intro = Instance.new("Frame", sg)
    intro.Size = UDim2.new(1,0,1,0)
    intro.Position = UDim2.new(0,0,0,0)
    intro.BackgroundTransparency = 1

    -- Slight vignette
    local vignette = Instance.new("Frame", intro)
    vignette.Size = UDim2.new(1,0,1,0)
    vignette.BackgroundColor3 = Color3.fromRGB(0,0,0)
    vignette.BackgroundTransparency = 0.8
    vignette.ZIndex = 5

    -- HEKWAS Label
    local hekwasLabel = Instance.new("TextLabel", intro)
    hekwasLabel.Size = UDim2.new(1,0,0.5,0)
    hekwasLabel.Position = UDim2.new(0,0,0.25,0)
    hekwasLabel.BackgroundTransparency = 1
    hekwasLabel.Text = "HEKWAS"
    hekwasLabel.TextColor3 = C.darkRed
    hekwasLabel.Font = Enum.Font.GothamBlack
    hekwasLabel.TextScaled = true

    -- Pulse text color
    task.spawn(function()
        while hekwasLabel.Parent do
            TweenService:Create(hekwasLabel,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,0,true),{TextColor3=C.blood}):Play()
            task.wait(0.8)
        end
    end)

    -- Blood dripping down intro
    spawnBlood(intro, 50)

    -- Fade out intro
    task.wait(3)
    local fadeTween = TweenService:Create(intro,TweenInfo.new(1.5),{BackgroundTransparency=1})
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hekwas/22s/refs/heads/main/22s.lua"))()
    fadeTween:Play()
    intro:Destroy()

    -- Loadstring script
    
end

-- Verify Button Logic
verifyBtn.MouseButton1Click:Connect(function()
    local entered = keyBox.Text
    keyBox.Text = "CHECKING..."
    if entered == KEY then
        runIntro()
    else
        keyBox.Text = "INVALID KEY"
    end
end)
