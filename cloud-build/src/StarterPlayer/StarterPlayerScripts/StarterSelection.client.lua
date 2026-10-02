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
background.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
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
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
end

local function gradient(parent, colorA, colorB, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(colorA, colorB)
    g.Rotation = rotation or 90
    g.Parent = parent
end

local glow = Instance.new("Frame")
glow.Size = UDim2.fromScale(0.8, 0.8)
glow.Position = UDim2.fromScale(0.1, 0.1)
glow.BackgroundColor3 = Color3.fromRGB(35, 42, 68)
glow.BackgroundTransparency = 0.86
glow.BorderSizePixel = 0
glow.Parent = background
corner(glow, 100)

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(0.8, 0.075)
title.Position = UDim2.fromScale(0.1, 0.075)
title.BackgroundTransparency = 1
title.Text = "CHOOSE YOUR FIRST VERITY"
title.TextColor3 = Color3.fromRGB(245, 246, 250)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = background

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromScale(0.72, 0.05)
subtitle.Position = UDim2.fromScale(0.14, 0.15)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Your first card defines how you enter the battle."
subtitle.TextColor3 = Color3.fromRGB(150, 156, 173)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.GothamMedium
subtitle.Parent = background

local cards = Instance.new("Frame")
cards.Size = UDim2.fromScale(0.84, 0.59)
cards.Position = UDim2.fromScale(0.08, 0.225)
cards.BackgroundTransparency = 1
cards.Parent = background

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromScale(0.31, 0.94)
layout.CellPadding = UDim2.fromScale(0.035, 0)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Parent = cards

local order = {"Verity", "Falsity", "Lovity"}

local function addStat(parent, labelText, value, maxValue, accent, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(0.25, 0.055)
    label.Position = UDim2.fromScale(0.08, y)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(142, 148, 164)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    local track = Instance.new("Frame")
    track.Size = UDim2.fromScale(0.56, 0.022)
    track.Position = UDim2.fromScale(0.34, y + 0.017)
    track.BackgroundColor3 = Color3.fromRGB(31, 34, 44)
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

local function createCard(name, index)
    local def = BattleDefinitions[name]

    local card = Instance.new("Frame")
    card.Name = name
    card.BackgroundColor3 = Color3.fromRGB(18, 21, 30)
    card.BorderSizePixel = 0
    card.Parent = cards
    corner(card, 18)
    stroke(card, Color3.fromRGB(55, 60, 76), 0.15, 1)
    gradient(card, Color3.fromRGB(25, 28, 40), Color3.fromRGB(13, 15, 22), 90)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromScale(1, 0.012)
    accent.BackgroundColor3 = def.Accent
    accent.BorderSizePixel = 0
    accent.Parent = card
    corner(accent, 8)

    local role = Instance.new("TextLabel")
    role.Size = UDim2.fromScale(0.82, 0.05)
    role.Position = UDim2.fromScale(0.09, 0.065)
    role.BackgroundTransparency = 1
    role.Text = string.upper(def.Role) .. "  •  " .. string.upper(def.Rarity)
    role.TextColor3 = def.Accent
    role.TextScaled = true
    role.Font = Enum.Font.GothamBold
    role.TextXAlignment = Enum.TextXAlignment.Left
    role.Parent = card

    local orb = Instance.new("Frame")
    orb.Size = UDim2.fromScale(0.39, 0.30)
    orb.Position = UDim2.fromScale(0.305, 0.13)
    orb.BackgroundColor3 = def.Accent
    orb.BackgroundTransparency = 0.08
    orb.BorderSizePixel = 0
    orb.Parent = card
    corner(orb, 999)

    local inner = Instance.new("Frame")
    inner.Size = UDim2.fromScale(0.82, 0.82)
    inner.Position = UDim2.fromScale(0.09, 0.09)
    inner.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
    inner.BackgroundTransparency = 0.15
    inner.BorderSizePixel = 0
    inner.Parent = orb
    corner(inner, 999)

    local face = Instance.new("TextLabel")
    face.Size = UDim2.fromScale(0.8, 0.65)
    face.Position = UDim2.fromScale(0.1, 0.18)
    face.BackgroundTransparency = 1
    face.Text = "●  ●\n  ◡"
    face.TextColor3 = Color3.fromRGB(20, 22, 28)
    face.TextScaled = true
    face.Font = Enum.Font.GothamBlack
    face.Parent = inner

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.fromScale(0.84, 0.075)
    nameLabel.Position = UDim2.fromScale(0.08, 0.455)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(245, 246, 250)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBlack
    nameLabel.Parent = card

    local tagText = table.concat(def.Tags, "   ")
    local tags = Instance.new("TextLabel")
    tags.Size = UDim2.fromScale(0.84, 0.055)
    tags.Position = UDim2.fromScale(0.08, 0.53)
    tags.BackgroundTransparency = 1
    tags.Text = tagText
    tags.TextColor3 = Color3.fromRGB(128, 135, 151)
    tags.TextScaled = true
    tags.Font = Enum.Font.GothamBold
    tags.Parent = card

    addStat(card, "HP", def.HP, 140, def.Accent, 0.61)
    addStat(card, "ATK", def.Attack, 35, def.Accent, 0.675)
    addStat(card, "DEF", def.Defense, 35, def.Accent, 0.74)

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromScale(0.84, 0.095)
    button.Position = UDim2.fromScale(0.08, 0.855)
    button.BackgroundColor3 = def.Accent
    button.Text = "CHOOSE " .. string.upper(name)
    button.TextColor3 = Color3.fromRGB(12, 14, 18)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBlack
    button.AutoButtonColor = false
    button.Parent = card
    corner(button, 11)

    button.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.14), {
            Position = UDim2.new(card.Position.X.Scale, 0, card.Position.Y.Scale - 0.015, 0)
        }):Play()
        TweenService:Create(button, TweenInfo.new(0.14), {
            BackgroundTransparency = 0.08
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.14), {
            Position = UDim2.new(card.Position.X.Scale, 0, card.Position.Y.Scale + 0.015, 0)
        }):Play()
        TweenService:Create(button, TweenInfo.new(0.14), {
            BackgroundTransparency = 0
        }):Play()
    end)

    button.Activated:Connect(function()
        selectStarter:FireServer(name)
        title.Text = "YOUR VERITY AWAITS"
        subtitle.Text = name .. " has joined your collection."
        button.Text = "SELECTED"
        for _, other in ipairs(cards:GetChildren()) do
            if other:IsA("Frame") and other ~= card then
                TweenService:Create(other, TweenInfo.new(0.2), {BackgroundTransparency = 0.45}):Play()
            end
        end
        task.wait(0.9)
        TweenService:Create(screen, TweenInfo.new(0.35), {GroupTransparency = 1}):Play()
        task.wait(0.4)
        screen.Enabled = false
    end)
end

for index, name in ipairs(order) do
    createCard(name, index)
end

local function updateVisibility()
    screen.Enabled = not player:GetAttribute("StarterChosen")
end

player:GetAttributeChangedSignal("StarterChosen"):Connect(updateVisibility)
updateVisibility()
