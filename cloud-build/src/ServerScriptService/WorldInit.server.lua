local Lighting = game:GetService("Lighting")

local existing = workspace:FindFirstChild("World")
if existing then
    existing:Destroy()
end

local world = Instance.new("Folder")
world.Name = "World"
world.Parent = workspace

local function part(name, size, position, color, material, parent, anchored)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = position
    p.Anchored = anchored ~= false
    p.CanCollide = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or world
    return p
end

local function sign(name, text, position, size)
    local anchor = part(name, Vector3.new(1,1,1), position, Color3.new(1,1,1), Enum.Material.SmoothPlastic, world)
    anchor.Transparency = 1
    anchor.CanCollide = false

    local gui = Instance.new("BillboardGui")
    gui.Size = size or UDim2.fromOffset(260, 70)
    gui.StudsOffset = Vector3.new(0, 0, 0)
    gui.AlwaysOnTop = true
    gui.Parent = anchor

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.TextStrokeTransparency = 0.25
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Parent = gui
    return anchor
end

-- Large safety floor prevents the first playable build from dropping players into the void.
part("SafetyFloor", Vector3.new(600, 4, 600), Vector3.new(0, -4, 0), Color3.fromRGB(20, 24, 31), Enum.Material.Slate)

-- Main island.
part("IslandBase", Vector3.new(190, 8, 130), Vector3.new(0, 0, 0), Color3.fromRGB(39, 48, 59), Enum.Material.Slate)
part("IslandTop", Vector3.new(184, 2, 124), Vector3.new(0, 5, 0), Color3.fromRGB(64, 92, 70), Enum.Material.Grass)

-- Central plaza and paths.
part("Plaza", Vector3.new(42, 1, 42), Vector3.new(0, 6.5, 0), Color3.fromRGB(78, 82, 91), Enum.Material.Concrete)
part("NorthPath", Vector3.new(14, 1, 48), Vector3.new(0, 6.5, 43), Color3.fromRGB(91, 92, 98), Enum.Material.Concrete)
part("SouthPath", Vector3.new(14, 1, 42), Vector3.new(0, 6.5, -41), Color3.fromRGB(91, 92, 98), Enum.Material.Concrete)
part("EastPath", Vector3.new(65, 1, 14), Vector3.new(45, 6.5, 0), Color3.fromRGB(91, 92, 98), Enum.Material.Concrete)
part("WestPath", Vector3.new(65, 1, 14), Vector3.new(-45, 6.5, 0), Color3.fromRGB(91, 92, 98), Enum.Material.Concrete)

-- Spawn.
local spawn = workspace:FindFirstChild("SpawnLocation")
if spawn then spawn:Destroy() end
spawn = Instance.new("SpawnLocation")
spawn.Name = "SpawnLocation"
spawn.Size = Vector3.new(8, 1, 8)
spawn.Position = Vector3.new(0, 8, 0)
spawn.Anchored = true
spawn.Neutral = true
spawn.Material = Enum.Material.Neon
spawn.Color = Color3.fromRGB(255, 221, 45)
spawn.Transparency = 0.15
spawn.Parent = world

sign("WelcomeSign", "GROW A VERITY", Vector3.new(0, 14, -13), UDim2.fromOffset(300, 80))
sign("ExploreSign", "EXPLORE  •  FIND GUARDIANS  •  EARN SEEDS", Vector3.new(0, 11, 13), UDim2.fromOffset(420, 55))

-- Six personal plots around the perimeter.
local plotPositions = {
    Vector3.new(-68, 7, 42), Vector3.new(-22, 7, 50), Vector3.new(22, 7, 50),
    Vector3.new(68, 7, 42), Vector3.new(-68, 7, -42), Vector3.new(68, 7, -42),
}
for i, pos in ipairs(plotPositions) do
    local plot = Instance.new("Folder")
    plot.Name = "Plot_" .. i
    plot.Parent = world

    part("Plot_" .. i .. "_Base", Vector3.new(30, 2, 24), pos, Color3.fromRGB(111, 82, 54), Enum.Material.Ground, plot)
    part("Plot_" .. i .. "_Soil", Vector3.new(24, 1, 18), pos + Vector3.new(0, 1.5, 0), Color3.fromRGB(84, 57, 39), Enum.Material.Ground, plot)

    for x = -1, 1 do
        for z = -1, 1 do
            part("Plot_" .. i .. "_Bed", Vector3.new(6, 0.5, 5), pos + Vector3.new(x * 7, 2.25, z * 6), Color3.fromRGB(102, 68, 43), Enum.Material.Ground, plot)
        end
    end
    sign("PlotSign_" .. i, "PLOT " .. i .. "  •  PLANT HERE", pos + Vector3.new(0, 8, -10), UDim2.fromOffset(230, 45))
end

-- Guardian arena.
local arena = Instance.new("Folder")
arena.Name = "GuardianArena"
arena.Parent = world
part("ArenaFloor", Vector3.new(52, 2, 38), Vector3.new(0, 8, 73), Color3.fromRGB(35, 39, 49), Enum.Material.Basalt, arena)
part("ArenaRing", Vector3.new(38, 1, 26), Vector3.new(0, 9.2, 73), Color3.fromRGB(91, 73, 42), Enum.Material.Metal, arena)
part("ArenaNorthWall", Vector3.new(52, 10, 2), Vector3.new(0, 13, 92), Color3.fromRGB(47, 52, 63), Enum.Material.Basalt, arena)
sign("ArenaSign", "GUARDIAN ARENA", Vector3.new(0, 19, 72), UDim2.fromOffset(280, 65))

-- Three guardian pedestals: visual encounter anchors for the battle system.
local guardianData = {
    {"VerityGuardian", Vector3.new(-15, 11, 73), Color3.fromRGB(255,221,45), "VERITY"},
    {"FalsityGuardian", Vector3.new(0, 11, 73), Color3.fromRGB(55,145,255), "FALSITY"},
    {"LovityGuardian", Vector3.new(15, 11, 73), Color3.fromRGB(255,105,180), "LOVITY"},
}
for _, data in ipairs(guardianData) do
    local model = Instance.new("Model")
    model.Name = data[1]
    model.Parent = arena
    part("Pedestal", Vector3.new(8, 3, 8), data[2] - Vector3.new(0, 2, 0), Color3.fromRGB(70, 74, 84), Enum.Material.Marble, model)
    local orb = part("GuardianOrb", Vector3.new(5,5,5), data[2] + Vector3.new(0, 2, 0), data[3], Enum.Material.Neon, model)
    orb.Shape = Enum.PartType.Ball
    orb.CanCollide = false
    sign(data[1] .. "_Sign", data[4] .. " GUARDIAN", data[2] + Vector3.new(0, 7, 0), UDim2.fromOffset(180, 42))
end

-- Seed discovery garden.
local garden = Instance.new("Folder")
garden.Name = "SeedGarden"
garden.Parent = world
part("GardenBase", Vector3.new(58, 2, 30), Vector3.new(0, 8, -67), Color3.fromRGB(44, 72, 52), Enum.Material.Grass, garden)
part("GardenPath", Vector3.new(10, 1, 30), Vector3.new(0, 9.5, -67), Color3.fromRGB(91, 92, 98), Enum.Material.Concrete, garden)
for _, x in ipairs({-18, 18}) do
    part("SeedSpawn_" .. x, Vector3.new(10, 1, 8), Vector3.new(x, 10, -67), Color3.fromRGB(53, 62, 55), Enum.Material.Slate, garden)
end
sign("GardenSign", "SEED DISCOVERY", Vector3.new(0, 17, -67), UDim2.fromOffset(260, 55))

-- Simple environmental pillars to give the island silhouette.
for _, pos in ipairs({
    Vector3.new(-88, 13, 55), Vector3.new(88, 13, 55),
    Vector3.new(-88, 13, -55), Vector3.new(88, 13, -55),
}) do
    part("Pillar", Vector3.new(5, 16, 5), pos, Color3.fromRGB(48, 55, 66), Enum.Material.Slate)
end

Lighting.ClockTime = 14
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(110, 110, 110)
Lighting.OutdoorAmbient = Color3.fromRGB(145, 145, 145)
Lighting.FogEnd = 500
