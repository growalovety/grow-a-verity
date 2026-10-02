local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local BattleDefinitions = require(ReplicatedStorage:WaitForChild("BattleDefinitions"))
local selectStarter = ReplicatedStorage:WaitForChild("GameRemotes"):WaitForChild("SelectStarter")

local screen = Instance.new("ScreenGui")
screen.Name = "StarterSelection"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.DisplayOrder = 50
screen.Parent = playerGui

local background = Instance.new("Frame")
background.Size = UDim2.fromScale(1, 1)
background.BackgroundColor3 = Color3.fromRGB(12, 17, 13)
background.BorderSizePixel = 0
background.Parent = screen

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
end

local function stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Transparency = transparency
    s.Thickness = thickness
    s.Parent = parent
end

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(0.8, 0.08)
title.Position = UDim2.fromScale(0.1, 0.07)
title.BackgroundTransparency = 1
title.Text = "CHOOSE YOUR VARIETY"
title.TextColor3 = Color3.fromRGB(250, 247, 235)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = background

local cards = Instance.new("Frame")
cards.Size = UDim2.fromScale(0.86, 0.67)
cards.Position = UDim2.fromScale(0.07, 0.19)
cards.BackgroundTransparency = 1
cards.Parent = background

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromScale(0.30, 0.94)
layout.CellPadding = UDim2.fromScale(0.05, 0)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = cards

local order = {"Verity", "Falsity", "Lovity"}

local function addBar(parent, value, maxValue, accent, y)
    local track = Instance.new("Frame")
    track.Size = UDim2.fromScale(0.74, 0.022)
    track.Position = UDim2.fromScale(0.13, y)
    track.BackgroundColor3 = Color3.fromRGB(42, 48, 40)
    track.BorderSizePixel = 0
    track.Parent = parent
    corner(track, 8)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(math.clamp(value / maxValue, 0, 1), 1)
    fill.BackgroundColor3 = accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 8)
end

local function buildModel(viewport, name)
    local def = BattleDefinitions[name]
    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = viewport

    local model = Instance.new("Model")
    model.Name = name
    model.Parent = worldModel

    local body = Instance.new("Part")
    body.Name = "Body"
    body.Shape = Enum.PartType.Ball
    body.Size = Vector3.new(5, 5, 5)
    body.Anchored = true
    body.CanCollide = false
    body.Material = Enum.Material.SmoothPlastic
    body.Color = def.Accent
    body.Parent = model

    local function feature(size, position, color, shape)
        local p = Instance.new("Part")
        p.Shape = shape or Enum.PartType.Ball
        p.Size = size
        p.Position = position
        p.Anchored = true
        p.CanCollide = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = color
        p.Parent = model
    end

    feature(Vector3.new(0.62, 0.62, 0.62), Vector3.new(-0.9, 0.45, -2.3), Color3.fromRGB(25, 26, 30))
    feature(Vector3.new(0.62, 0.62, 0.62), Vector3.new(0.9, 0.45, -2.3), Color3.fromRGB(25, 26, 30))
    feature(Vector3.new(1.35, 0.22, 0.25), Vector3.new(0, -0.8, -2.28), Color3.fromRGB(25, 26, 30), Enum.PartType.Block)

    if name == "Verity" then
        feature(Vector3.new(1.4, 2.2, 0.45), Vector3.new(0, 0, 2.35), def.Accent, Enum.PartType.Block)
    elseif name == "Falsity" then
        feature(Vector3.new(1.2, 0.5, 1.8), Vector3.new(-2.2, 0.2, 0), def.Accent, Enum.PartType.Wedge)
        feature(Vector3.new(1.2, 0.5, 1.8), Vector3.new(2.2, 0.2, 0), def.Accent, Enum.PartType.Wedge)
    else
        feature(Vector3.new(1.5, 1.5, 1.5), Vector3.new(-1.35, 2.0, 0), def.Accent)
        feature(Vector3.new(1.5, 1.5, 1.5), Vector3.new(1.35, 2.0, 0), def.Accent)
    end

    local camera = Instance.new("Camera")
    camera.CFrame = CFrame.new(Vector3.new(0, 1, 11), Vector3.new(0, 0, 0))
    camera.Parent = viewport
    viewport.CurrentCamera = camera
end

local function createCard(name)
    local def = BattleDefinitions[name]

    local card = Instance.new("Frame")
    card.Name = name
    card.BackgroundColor3 = Color3.fromRGB(24, 31, 24)
    card.BorderSizePixel = 0
    card.Parent = cards
    corner(card, 20)
    stroke(card, def.Accent, 0.55, 1)

    local viewport = Instance.new("ViewportFrame")
    viewport.Size = UDim2.fromScale(0.9, 0.52)
    viewport.Position = UDim2.fromScale(0.05, 0.08)
    viewport.BackgroundTransparency = 1
    viewport.Ambient = Color3.fromRGB(210, 210, 210)
    viewport.LightColor = Color3.fromRGB(255, 255, 255)
    viewport.Parent = card
    buildModel(viewport, name)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.fromScale(0.82, 0.08)
    nameLabel.Position = UDim2.fromScale(0.09, 0.57)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(248, 246, 235)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.Parent = card

    addBar(card, def.HP, 110, def.Accent, 0.68)
    addBar(card, def.Attack, 25, def.Accent, 0.735)
    addBar(card, def.Defense, 25, def.Accent, 0.79)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(0.82, 0.10)
    button.Position = UDim2.fromScale(0.09, 0.86)
    button.BackgroundColor3 = def.Accent
    button.Text = "CHOOSE"
    button.TextColor3 = Color3.fromRGB(18, 20, 17)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBlack
    button.AutoButtonColor = false
    button.Parent = card
    corner(button, 12)

    button.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {Size = UDim2.fromScale(1.02, 1.02)}):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.12), {Size = UDim2.fromScale(1, 1)}):Play()
    end)

    button.Activated:Connect(function()
        selectStarter:FireServer(name)
        button.Text = "SELECTED"
        task.wait(0.35)
        TweenService:Create(background, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.wait(0.35)
        screen.Enabled = false
    end)
end

for _, name in ipairs(order) do
    createCard(name)
end

local function updateVisibility()
    screen.Enabled = not player:GetAttribute("StarterChosen")
end

player:GetAttributeChangedSignal("StarterChosen"):Connect(updateVisibility)
updateVisibility()
