local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("GameRemotes")
local startBattle = remotes:WaitForChild("StartBattle")
local battleAction = remotes:WaitForChild("BattleAction")
local battleUpdate = remotes:WaitForChild("BattleUpdate")
local battleEnd = remotes:WaitForChild("BattleEnd")

local screen = Instance.new("ScreenGui")
screen.Name = "BattleUI"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = false
screen.DisplayOrder = 60
screen.Enabled = false
screen.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.68, 0.52)
panel.Position = UDim2.fromScale(0.16, 0.24)
panel.BackgroundColor3 = Color3.fromRGB(18, 24, 19)
panel.BorderSizePixel = 0
panel.Parent = screen

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 22)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(220, 199, 123)
stroke.Transparency = 0.35
stroke.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.fromScale(0.8, 0.12)
title.Position = UDim2.fromScale(0.1, 0.06)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(250, 247, 235)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = panel

local function makeBar(y, accent)
    local track = Instance.new("Frame")
    track.Size = UDim2.fromScale(0.72, 0.045)
    track.Position = UDim2.fromScale(0.14, y)
    track.BackgroundColor3 = Color3.fromRGB(44, 50, 42)
    track.BorderSizePixel = 0
    track.Parent = panel

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    return fill
end

local enemyBar = makeBar(0.25, Color3.fromRGB(240, 94, 94))
local playerBar = makeBar(0.39, Color3.fromRGB(101, 205, 116))

local enemyText = Instance.new("TextLabel")
enemyText.Size = UDim2.fromScale(0.8, 0.07)
enemyText.Position = UDim2.fromScale(0.1, 0.18)
enemyText.BackgroundTransparency = 1
enemyText.TextColor3 = Color3.fromRGB(240, 94, 94)
enemyText.TextScaled = true
enemyText.Font = Enum.Font.GothamBold
enemyText.Parent = panel

local playerText = enemyText:Clone()
playerText.Position = UDim2.fromScale(0.1, 0.32)
playerText.TextColor3 = Color3.fromRGB(101, 205, 116)
playerText.Parent = panel

local resultText = Instance.new("TextLabel")
resultText.Size = UDim2.fromScale(0.82, 0.12)
resultText.Position = UDim2.fromScale(0.09, 0.47)
resultText.BackgroundTransparency = 1
resultText.TextColor3 = Color3.fromRGB(250, 247, 235)
resultText.TextScaled = true
resultText.Font = Enum.Font.GothamBlack
resultText.Visible = false
resultText.Parent = panel

local buttons = Instance.new("Frame")
buttons.Size = UDim2.fromScale(0.82, 0.22)
buttons.Position = UDim2.fromScale(0.09, 0.68)
buttons.BackgroundTransparency = 1
buttons.Parent = panel

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromScale(0.31, 0.82)
layout.CellPadding = UDim2.fromScale(0.035, 0)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = buttons

local function makeButton(text, accent)
    local b = Instance.new("TextButton")
    b.BackgroundColor3 = accent
    b.Text = text
    b.TextColor3 = Color3.fromRGB(18, 20, 17)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBlack
    b.AutoButtonColor = false
    b.Parent = buttons

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 12)
    c.Parent = b
    return b
end

local attack = makeButton("ATTACK", Color3.fromRGB(244, 114, 86))
local skill = makeButton("SKILL", Color3.fromRGB(86, 157, 235))
local guard = makeButton("GUARD", Color3.fromRGB(160, 176, 154))

local function setButtons(enabled)
    attack.Active = enabled
    skill.Active = enabled
    guard.Active = enabled
    attack.AutoButtonColor = enabled
    skill.AutoButtonColor = enabled
    guard.AutoButtonColor = enabled
end

local function action(name)
    setButtons(false)
    battleAction:FireServer(name)
end

attack.Activated:Connect(function() action("Attack") end)
skill.Activated:Connect(function() action("Skill") end)
guard.Activated:Connect(function() action("Guard") end)

startBattle.OnClientEvent:Connect(function(enemyName, starterName)
    screen.Enabled = true
    resultText.Visible = false
    title.Text = enemyName .. " GUARDIAN"
    enemyText.Text = enemyName
    playerText.Text = starterName
    setButtons(true)
end)

battleUpdate.OnClientEvent:Connect(function(state)
    enemyBar.Size = UDim2.fromScale(math.clamp(state.EnemyHP / state.EnemyMaxHP, 0, 1), 1)
    playerBar.Size = UDim2.fromScale(math.clamp(state.PlayerHP / state.PlayerMaxHP, 0, 1), 1)
    enemyText.Text = state.EnemyName .. "  " .. state.EnemyHP .. "/" .. state.EnemyMaxHP
    playerText.Text = player:GetAttribute("StarterVariety") .. "  " .. state.PlayerHP .. "/" .. state.PlayerMaxHP
    setButtons(state.CanAct)
end)

battleEnd.OnClientEvent:Connect(function(won, enemyName)
    setButtons(false)
    resultText.Visible = true
    resultText.Text = won and ("VICTORY  •  " .. enemyName .. " SEED + CARD") or "DEFEATED"
    resultText.TextColor3 = won and Color3.fromRGB(255, 221, 45) or Color3.fromRGB(240, 94, 94)
    task.wait(1.25)
    screen.Enabled = false
end)
