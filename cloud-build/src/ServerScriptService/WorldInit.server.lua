local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local existing = workspace:FindFirstChild("World")
if existing then existing:Destroy() end

local world = Instance.new("Folder")
world.Name = "World"
world:SetAttribute("BuildId", "cloud-live-32")
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
    gui.MaxDistance = 70
    gui.Parent = parent

    local t = Instance.new("TextLabel")
    t.Size = UDim2.fromScale(1, 1)
    t.BackgroundTransparency = 1
    t.Text = text
    t.TextColor3 = color or Color3.new(1, 1, 1)
    t.TextStrokeTransparency = 0.55
    t.Font = Enum.Font.GothamBold
    t.TextScaled = true
    t.Parent = gui
end

local function fence(plot, center, width, depth)
    local wood = Color3.fromRGB(139, 92, 53)
    local rail = Color3.fromRGB(176, 119, 66)
    for _, x in ipairs({-width / 2, width / 2}) do
        for _, z in ipairs({-depth / 2, depth / 2}) do
            part("FencePost", Vector3.new(0.65, 1.8, 0.65), center + Vector3.new(x, 0.9, z), wood, Enum.Material.Wood, plot)
        end
    end
    part("FenceRail", Vector3.new(width, 0.28, 0.28), center + Vector3.new(0, 0.8, -depth / 2), rail, Enum.Material.Wood, plot)
    part("FenceRail", Vector3.new(width, 0.28, 0.28), center + Vector3.new(0, 0.8, depth / 2), rail, Enum.Material.Wood, plot)
    part("FenceRail", Vector3.new(0.28, 0.28, depth), center + Vector3.new(-width / 2, 0.8, 0), rail, Enum.Material.Wood, plot)
    part("FenceRail", Vector3.new(0.28, 0.28, depth), center + Vector3.new(width / 2, 0.8, 0), rail, Enum.Material.Wood, plot)
end

local function makePortal(name, position, accent, titleText)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = world

    part("Base", Vector3.new(12, 0.5, 8), position + Vector3.new(0, 0.25, 0), Color3.fromRGB(72, 112, 70), Enum.Material.SmoothPlastic, model)
    for _, x in ipairs({-4.5, 4.5}) do
        part("Post", Vector3.new(1.0, 6, 1.0), position + Vector3.new(x, 3.25, 0), accent, Enum.Material.SmoothPlastic, model)
    end
    part("Top", Vector3.new(10, 1.0, 1.0), position + Vector3.new(0, 6.0, 0), accent, Enum.Material.SmoothPlastic, model)

    local core = part("Core", Vector3.new(7, 4.5, 0.5), position + Vector3.new(0, 3.0, 0), accent, Enum.Material.Neon, model)
    core.Transparency = 0.35
    core.CanCollide = false

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "PortalPrompt"
    prompt.ActionText = titleText == "EXPLORE" and "Explore" or "Return"
    prompt.ObjectText = titleText
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = core
end

-- STARTER GROVE: straight central boulevard, conveyor lanes, gardens left/right.
local starter = Instance.new("Folder")
starter.Name = "StarterGrove"
starter.Parent = world

part("GroveGround", Vector3.new(170, 1, 180), Vector3.new(0, 0, 0), Color3.fromRGB(104, 158, 82), Enum.Material.Grass, starter)
part("MainPath", Vector3.new(16, 0.2, 150), Vector3.new(0, 0.6, 0), Color3.fromRGB(220, 187, 112), Enum.Material.SmoothPlastic, starter)

local function conveyor(x)
    local belt = part("Conveyor", Vector3.new(7, 0.25, 150), Vector3.new(x, 0.73, 0), Color3.fromRGB(74, 93, 68), Enum.Material.SmoothPlastic, starter)
    for z = -65, 65, 13 do
        local arrow = part("ConveyorMarker", Vector3.new(3.2, 0.05, 1.2), Vector3.new(x, 0.9, z), Color3.fromRGB(232, 205, 107), Enum.Material.Neon, starter)
        arrow.CanCollide = false
    end
    return belt
end
conveyor(-20)
conveyor(20)

local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn then spawn:Destroy() end
spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnLocation"
spawn.Size = Vector3.new(7, 1, 7)
spawn.Position = Vector3.new(0, 1.0, -70)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.SmoothPlastic
spawn.Color = Color3.fromRGB(255, 221, 45)
spawn.Transparency = 0.05
spawn.Parent = starter

local titleAnchor = part("TitleAnchor", Vector3.new(1,1,1), Vector3.new(0, 4.5, -55), Color3.new(1,1,1), Enum.Material.SmoothPlastic, starter)
titleAnchor.Transparency = 1
titleAnchor.CanCollide = false
label(titleAnchor, "GROW A VERITY", UDim2.fromOffset(270, 52), Vector3.new(0,0,0), Color3.new(1,1,1))

local plotPositions = {
    Vector3.new(-50, 0.55, -42),
    Vector3.new(50, 0.55, -42),
    Vector3.new(-50, 0.55, 0),
    Vector3.new(50, 0.55, 0),
    Vector3.new(-50, 0.55, 42),
    Vector3.new(50, 0.55, 42),
}
for i, pos in ipairs(plotPositions) do
    local plot = Instance.new("Folder")
    plot.Name = "Plot_" .. i
    plot:SetAttribute("FreePlacement", true)
    plot.Parent = starter

    part("GardenSurface", Vector3.new(28, 0.3, 22), pos, Color3.fromRGB(126, 91, 56), Enum.Material.SmoothPlastic, plot)
    part("GardenGrass", Vector3.new(25.5, 0.12, 19.5), pos + Vector3.new(0, 0.22, 0), Color3.fromRGB(121, 177, 91), Enum.Material.Grass, plot)
    fence(plot, pos, 30, 24)

    local marker = part("PlotMarker", Vector3.new(1,1,1), pos + Vector3.new(0, 2.8, -13), Color3.new(1,1,1), Enum.Material.SmoothPlastic, plot)
    marker.Transparency = 1
    marker.CanCollide = false
    label(marker, "GARDEN " .. i, UDim2.fromOffset(130, 28), Vector3.new(0,0,0), Color3.fromRGB(255,240,190))
end

-- Explore entrance sits on the ground at the far end of the boulevard.
makePortal("ExplorePortal", Vector3.new(0, 0.75, 82), Color3.fromRGB(88, 184, 255), "EXPLORE")

-- EXPLORE WORLD: far away, so the starter grove cannot be seen.
local wilds = Instance.new("Folder")
wilds.Name = "GuardianWilds"
wilds.Parent = world

local exploreOrigin = Vector3.new(0, 0, 900)
part("WildsGround", Vector3.new(220, 1, 190), exploreOrigin, Color3.fromRGB(106, 161, 84), Enum.Material.Grass, wilds)

-- Stylized low-poly hills.
local hillColor = Color3.fromRGB(87, 139, 76)
local rockColor = Color3.fromRGB(126, 124, 103)
for _, h in ipairs({
    {Vector3.new(-80, 18, 850), Vector3.new(45, 36, 55)},
    {Vector3.new(78, 24, 870), Vector3.new(55, 48, 60)},
    {Vector3.new(-82, 14, 965), Vector3.new(50, 28, 50)},
    {Vector3.new(82, 18, 970), Vector3.new(48, 36, 55)},
}) do
    local p = part("LowPolyHill", h[2], h[1], hillColor, Enum.Material.Grass, wilds)
    p.Shape = Enum.PartType.Wedge
end
for _, p in ipairs({
    Vector3.new(-60, 5, 850), Vector3.new(65, 5, 850),
    Vector3.new(-72, 5, 970), Vector3.new(70, 5, 970),
}) do
    part("Rock", Vector3.new(9, 9, 9), p, rockColor, Enum.Material.Rock, wilds)
end

local arena = Instance.new("Folder")
arena.Name = "GuardianArena"
arena.Parent = wilds
part("ArenaFloor", Vector3.new(66, 0.4, 54), exploreOrigin + Vector3.new(0, 0.7, 0), Color3.fromRGB(184, 145, 75), Enum.Material.SmoothPlastic, arena)
part("ArenaRing", Vector3.new(54, 0.25, 42), exploreOrigin + Vector3.new(0, 1.05, 0), Color3.fromRGB(238, 204, 98), Enum.Material.Neon, arena)

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
    root.Size = Vector3.new(4,4,4) * scale
    root.Position = position
    root.Anchored = true
    root.CanCollide = false
    root.Material = Enum.Material.SmoothPlastic
    root.Color = def.Accent
    root.Parent = model
    model.PrimaryPart = root

    local function feature(size, offset, color, shape)
        local p = Instance.new("Part")
        p.Shape = shape or Enum.PartType.Ball
        p.Size = size * scale
        p.Position = root.Position + offset * scale
        p.Anchored = true
        p.CanCollide = false
        p.Material = Enum.Material.SmoothPlastic
        p.Color = color
        p.Parent = model
    end

    feature(Vector3.new(.55,.55,.55), Vector3.new(-.8,.35,-1.82), Color3.fromRGB(24,25,29))
    feature(Vector3.new(.55,.55,.55), Vector3.new(.8,.35,-1.82), Color3.fromRGB(24,25,29))
    feature(Vector3.new(1.2,.2,.22), Vector3.new(0,-.65,-1.8), Color3.fromRGB(24,25,29), Enum.PartType.Block)

    if name == "Verity" then
        feature(Vector3.new(1.5,2.2,.45), Vector3.new(0,0,1.95), def.Accent, Enum.PartType.Block)
    elseif name == "Falsity" then
        feature(Vector3.new(1.2,.5,1.8), Vector3.new(-2,.1,0), def.Accent, Enum.PartType.Wedge)
        feature(Vector3.new(1.2,.5,1.8), Vector3.new(2,.1,0), def.Accent, Enum.PartType.Wedge)
    else
        feature(Vector3.new(1.35,1.35,1.35), Vector3.new(-1.25,1.8,0), def.Accent)
        feature(Vector3.new(1.35,1.35,1.35), Vector3.new(1.25,1.8,0), def.Accent)
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "BattlePrompt"
    prompt.ActionText = "Battle"
    prompt.ObjectText = name .. " Guardian"
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 12
    prompt.RequiresLineOfSight = false
    prompt.Parent = root
    label(root, name, UDim2.fromOffset(140,30), Vector3.new(0,3,0), Color3.new(1,1,1))
end

makeVarietyModel("Verity", exploreOrigin + Vector3.new(-18, 3.8, 0), 1.1)
makeVarietyModel("Falsity", exploreOrigin + Vector3.new(0, 3.8, 0), 1.1)
makeVarietyModel("Lovity", exploreOrigin + Vector3.new(18, 3.8, 0), 1.1)

local returnPosition = exploreOrigin + Vector3.new(0, 0.75, 72)
makePortal("ReturnPortal", returnPosition, Color3.fromRGB(255, 221, 45), "RETURN")

local portalConnections = {
    {Vector3.new(0, 0.75, 82), exploreOrigin + Vector3.new(0, 0, 12)},
    {returnPosition, Vector3.new(0, 1, -70)},
}
local function nearestPortal(position)
    local best, distance
    for _, entry in ipairs(portalConnections) do
        local d = (position - entry[1]).Magnitude
        if not distance or d < distance then best, distance = entry, d end
    end
    return best
end
for _, prompt in ipairs(world:GetDescendants()) do
    if prompt:IsA("ProximityPrompt") and prompt.Name == "PortalPrompt" then
        prompt.Triggered:Connect(function(player)
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local entry = nearestPortal(root.Position)
            if entry and (root.Position - entry[1]).Magnitude < 18 then
                root.CFrame = CFrame.new(entry[2] + Vector3.new(0, 3, 0))
            end
        end)
    end
end

Lighting.ClockTime = 14
Lighting.Brightness = 3
Lighting.Ambient = Color3.fromRGB(205, 215, 190)
Lighting.OutdoorAmbient = Color3.fromRGB(210, 220, 195)
Lighting.FogColor = Color3.fromRGB(170, 205, 230)
Lighting.FogEnd = 520
Lighting.GlobalShadows = true

local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if atmosphere then atmosphere:Destroy() end
