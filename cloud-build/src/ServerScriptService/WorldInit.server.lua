local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local existing = workspace:FindFirstChild("World")
if existing then
    existing:Destroy()
end

local world = Instance.new("Folder")
world.Name = "World"
world.Parent = workspace

local function part(name, size, position, color, material, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = true
    p.CanCollide = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or world
    return p
end

local function label(parent, text, size, position, color)
    local gui = Instance.new("BillboardGui")
    gui.Size = size
    gui.StudsOffset = position
    gui.AlwaysOnTop = true
    gui.MaxDistance = 90
    gui.Parent = parent

    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = color or Color3.new(1, 1, 1)
    t.TextStrokeTransparency = 0.45
    t.Font = Enum.Font.GothamBold
    t.TextScaled = true
    t.Parent = gui
    return gui
end

local function makeFence(plot, center, width, depth)
    local wood = Color3.fromRGB(124, 86, 52)
    local rail = Color3.fromRGB(151, 104, 62)
    local function post(x, z)
        part("FencePost", Vector3.new(0.7, 2.2, 0.7), center + Vector3.new(x, 1.1, z), wood, Enum.Material.Wood, plot)
    end
    local function bar(size, pos)
        part("FenceRail", size, center + pos, rail, Enum.Material.Wood, plot)
    end

    for _, x in ipairs({-width / 2, 0, width / 2}) do
        post(x, -depth / 2)
        post(x, depth / 2)
    end
    for _, z in ipairs({-depth / 2, 0, depth / 2}) do
        post(-width / 2, z)
        post(width / 2, z)
    end
    bar(Vector3.new(width, 0.35, 0.35), Vector3.new(0, 1.0, -depth / 2))
    bar(Vector3.new(width, 0.35, 0.35), Vector3.new(0, 1.0, depth / 2))
    bar(Vector3.new(0.35, 0.35, depth), Vector3.new(-width / 2, 1.0, 0))
    bar(Vector3.new(0.35, 0.35, depth), Vector3.new(width / 2, 1.0, 0))
end

local function makePortal(name, position, accent, titleText)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = world

    part("PortalBase", Vector3.new(12, 0.5, 8), position, Color3.fromRGB(53, 67, 55), Enum.Material.Slate, model)
    for _, x in ipairs({-4.5, 4.5}) do
        part("PortalPost", Vector3.new(1.2, 8, 1.2), position + Vector3.new(x, 4, 0), accent, Enum.Material.SmoothPlastic, model)
    end
    part("PortalTop", Vector3.new(10, 1.2, 1.2), position + Vector3.new(0, 7.4, 0), accent, Enum.Material.SmoothPlastic, model)

    local core = part("PortalCore", Vector3.new(7, 5.5, 0.6), position + Vector3.new(0, 3.7, 0), accent, Enum.Material.Neon, model)
    core.Transparency = 0.45
    core.CanCollide = false
    label(core, titleText, UDim2.fromOffset(210, 42), Vector3.new(0, 0, 0), Color3.new(1, 1, 1))

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "PortalPrompt"
    prompt.ActionText = titleText == "EXPLORE" and "Explore" or "Return"
    prompt.ObjectText = titleText
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = core
end

part("SafetyGround", Vector3.new(520, 2, 520), Vector3.new(0, 120, 0), Color3.fromRGB(74, 105, 66), Enum.Material.Grass)

-- STARTER GROVE
local starter = Instance.new("Folder")
starter.Name = "StarterGrove"
starter.Parent = world
part("GroveGround", Vector3.new(180, 1, 150), Vector3.new(0, 0, 0), Color3.fromRGB(83, 125, 70), Enum.Material.Grass, starter)
part("GroveHub", Vector3.new(38, 0.35, 38), Vector3.new(0, 0.65, 0), Color3.fromRGB(145, 122, 82), Enum.Material.Ground, starter)

local pathColor = Color3.fromRGB(177, 153, 106)
part("PathNorth", Vector3.new(10, 0.25, 48), Vector3.new(0, 0.72, 40), pathColor, Enum.Material.Ground, starter)
part("PathSouth", Vector3.new(10, 0.25, 48), Vector3.new(0, 0.72, -40), pathColor, Enum.Material.Ground, starter)
part("PathEast", Vector3.new(48, 0.25, 10), Vector3.new(40, 0.72, 0), pathColor, Enum.Material.Ground, starter)
part("PathWest", Vector3.new(48, 0.25, 10), Vector3.new(-40, 0.72, 0), pathColor, Enum.Material.Ground, starter)

local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn then
    spawn:Destroy()
end
spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnLocation"
spawn.Size = Vector3.new(7, 1, 7)
spawn.Position = Vector3.new(0, 2, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.SmoothPlastic
spawn.Color = Color3.fromRGB(255, 221, 45)
spawn.Transparency = 0.08
spawn.Parent = starter

local titleAnchor = part("GroveTitle", Vector3.new(1, 1, 1), Vector3.new(0, 5.5, -13), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, starter)
titleAnchor.Transparency = 1
titleAnchor.CanCollide = false
label(titleAnchor, "GROW A VERITY", UDim2.fromOffset(300, 65), Vector3.new(0, 0, 0), Color3.new(1, 1, 1))

local plotPositions = {
    Vector3.new(-58, 0.55, 43),
    Vector3.new(-58, 0.55, -43),
    Vector3.new(58, 0.55, 43),
    Vector3.new(58, 0.55, -43),
    Vector3.new(-24, 0.55, 61),
    Vector3.new(24, 0.55, 61),
}

for i, pos in ipairs(plotPositions) do
    local plot = Instance.new("Folder")
    plot.Name = "Plot_" .. i
    plot:SetAttribute("FreePlacement", true)
    plot.Parent = starter

    part("Soil", Vector3.new(28, 0.35, 24), pos, Color3.fromRGB(112, 77, 48), Enum.Material.Ground, plot)
    part("GrassEdge", Vector3.new(30, 0.18, 26), pos + Vector3.new(0, 0.28, 0), Color3.fromRGB(92, 133, 73), Enum.Material.Grass, plot)
    makeFence(plot, pos + Vector3.new(0, 0.1, 0), 30, 26)

    local marker = part("PlotMarker", Vector3.new(1, 1, 1), pos + Vector3.new(0, 3.3, -14), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, plot)
    marker.Transparency = 1
    marker.CanCollide = false
    label(marker, "GARDEN", UDim2.fromOffset(150, 32), Vector3.new(0, 0, 0), Color3.fromRGB(246, 226, 180))
end

makePortal("ExplorePortal", Vector3.new(0, 67, 0), Color3.fromRGB(83, 171, 255), "EXPLORE")

-- GUARDIAN WILDS
local wilds = Instance.new("Folder")
wilds.Name = "GuardianWilds"
wilds.Parent = world
part("WildsGround", Vector3.new(160, 1, 120), Vector3.new(0, 235, 0), Color3.fromRGB(61, 101, 60), Enum.Material.Grass, wilds)

for _, p in ipairs({
    Vector3.new(-70, 5, 195), Vector3.new(70, 5, 195),
    Vector3.new(-70, 5, 275), Vector3.new(70, 5, 275),
}) do
    part("Rock", Vector3.new(10, 10, 10), p, Color3.fromRGB(91, 86, 75), Enum.Material.Rock, wilds)
end

local arena = Instance.new("Folder")
arena.Name = "GuardianArena"
arena.Parent = wilds
part("ArenaFloor", Vector3.new(62, 0.5, 50), Vector3.new(0, 0.9, 235), Color3.fromRGB(92, 72, 48), Enum.Material.Ground, arena)
part("ArenaRing", Vector3.new(48, 0.3, 36), Vector3.new(0, 1.35, 235), Color3.fromRGB(168, 132, 67), Enum.Material.Metal, arena)

local BattleDefinitions = require(ReplicatedStorage:WaitForChild("BattleDefinitions"))

local function makeVarietyModel(name, position, scale)
    local def = BattleDefinitions[name]
    local model = Instance.new("Model")
    model.Name = name .. "Guardian"
    model:SetAttribute("VarietyName", name)
    model.Parent = arena

    local root = Instance.new("Part")
    root.Name = "Body"
    root.Shape = Enum.PartType.Ball
    root.Size = Vector3.new(4, 4, 4) * scale
    root.Position = position + Vector3.new(0, 2.2 * scale, 0)
    root.Anchored = true
    root.CanCollide = false
    root.Material = Enum.Material.SmoothPlastic
    root.Color = def.Accent
    root.Parent = model
    model.PrimaryPart = root

    local function feature(size, positionOffset, color, shape)
        local p = Instance.new("Part")
        p.Shape = shape or Enum.PartType.Ball
        p.Size = size * scale
        p.Position = root.Position + positionOffset * scale
        p.Anchored = true
        p.CanCollide = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = color
        p.Parent = model
    end

    feature(Vector3.new(0.55, 0.55, 0.55), Vector3.new(-0.8, 0.35, -1.82), Color3.fromRGB(24, 25, 29))
    feature(Vector3.new(0.55, 0.55, 0.55), Vector3.new(0.8, 0.35, -1.82), Color3.fromRGB(24, 25, 29))
    feature(Vector3.new(1.2, 0.2, 0.22), Vector3.new(0, -0.65, -1.8), Color3.fromRGB(24, 25, 29), Enum.PartType.Block)

    if name == "Verity" then
        feature(Vector3.new(1.5, 2.2, 0.45), Vector3.new(0, 0, 1.95), def.Accent, Enum.PartType.Block)
    elseif name == "Falsity" then
        feature(Vector3.new(1.2, 0.5, 1.8), Vector3.new(-2.0, 0.1, 0), def.Accent, Enum.PartType.Wedge)
        feature(Vector3.new(1.2, 0.5, 1.8), Vector3.new(2.0, 0.1, 0), def.Accent, Enum.PartType.Wedge)
    else
        feature(Vector3.new(1.35, 1.35, 1.35), Vector3.new(-1.25, 1.8, 0), def.Accent)
        feature(Vector3.new(1.35, 1.35, 1.35), Vector3.new(1.25, 1.8, 0), def.Accent)
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "BattlePrompt"
    prompt.ActionText = "Battle"
    prompt.ObjectText = name .. " Guardian"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = root

    label(root, name, UDim2.fromOffset(150, 32), Vector3.new(0, 3.0, 0), Color3.new(1, 1, 1))
end

makeVarietyModel("Verity", Vector3.new(-17, 1.5, 235), 1.1)
makeVarietyModel("Falsity", Vector3.new(0, 1.5, 235), 1.1)
makeVarietyModel("Lovity", Vector3.new(17, 1.5, 235), 1.1)

local seedGarden = Instance.new("Folder")
seedGarden.Name = "SeedGarden"
seedGarden.Parent = wilds
for _, x in ipairs({-32, 32}) do
    part("SeedPad", Vector3.new(14, 0.4, 10), Vector3.new(x, 1, 215), Color3.fromRGB(113, 77, 48), Enum.Material.Ground, seedGarden)
end

makePortal("ReturnPortal", Vector3.new(0, 197, 0), Color3.fromRGB(255, 221, 45), "RETURN")

local portalConnections = {
    {Vector3.new(0, 67, 0), Vector3.new(0, 235, 18)},
    {Vector3.new(0, 197, 0), Vector3.new(0, 3, 52)},
}

local function nearestPortal(position)
    local best, bestDistance
    for _, entry in ipairs(portalConnections) do
        local distance = (position - entry[1]).Magnitude
        if not bestDistance or distance < bestDistance then
            best = entry
            bestDistance = distance
        end
    end
    return best
end

for _, prompt in ipairs(workspace:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") and prompt.Name == "PortalPrompt" then
        prompt.Triggered:Connect(function(player)
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then
                return
            end
            local entry = nearestPortal(root.Position)
            if entry and (root.Position - entry[1]).Magnitude < 16 then
                root.CFrame = CFrame.new(entry[2] + Vector3.new(0, 2.5, 0))
            end
        end)
    end
end

Lighting.ClockTime = 13.5
Lighting.Brightness = 2.2
Lighting.Ambient = Color3.fromRGB(165, 177, 156)
Lighting.OutdoorAmbient = Color3.fromRGB(185, 198, 175)
Lighting.FogColor = Color3.fromRGB(178, 205, 177)
Lighting.FogEnd = 420

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
atmosphere.Density = 0.22
atmosphere.Offset = 0.1
atmosphere.Color = Color3.fromRGB(194, 218, 193)
atmosphere.Decay = Color3.fromRGB(112, 137, 108)
atmosphere.Glare = 0.1
atmosphere.Haze = 0.5
atmosphere.Parent = Lighting
