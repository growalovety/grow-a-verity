local function makePart(parent, name, size, position, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Color = color
    part.Material = material
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.LeftSurface = Enum.SurfaceType.Smooth
    part.RightSurface = Enum.SurfaceType.Smooth
    part.FrontSurface = Enum.SurfaceType.Smooth
    part.BackSurface = Enum.SurfaceType.Smooth
    part.Parent = parent
    return part
end

local workspaceRoot = workspace

local oldBase = workspaceRoot:FindFirstChild("Baseplate")
if oldBase then oldBase:Destroy() end

local base = makePart(
    workspaceRoot,
    "Baseplate",
    Vector3.new(64, 1, 64),
    Vector3.new(0, -0.5, 0),
    Color3.fromRGB(64, 140, 64),
    Enum.Material.Grass
)

local spawn = workspaceRoot:FindFirstChildOfClass("SpawnLocation")
if not spawn then
    spawn = Instance.new("SpawnLocation")
    spawn.Parent = workspaceRoot
end
spawn.Name = "SpawnLocation"
spawn.Size = Vector3.new(6, 1, 6)
spawn.Position = Vector3.new(0, 0.5, 0)
spawn.Anchored = true
spawn.Neutral = true

local oldVerity = workspaceRoot:FindFirstChild("Verity")
if oldVerity then oldVerity:Destroy() end

local model = Instance.new("Model")
model.Name = "Verity"
model.Parent = workspaceRoot

local root = Instance.new("Part")
root.Name = "Root"
root.Shape = Enum.PartType.Ball
root.Size = Vector3.new(4, 4, 4)
root.Position = Vector3.new(0, 3, -8)
root.Anchored = true
root.CanCollide = true
root.Material = Enum.Material.SmoothPlastic
root.Color = Color3.fromRGB(255, 221, 45)
root.TopSurface = Enum.SurfaceType.Smooth
root.BottomSurface = Enum.SurfaceType.Smooth
root.LeftSurface = Enum.SurfaceType.Smooth
root.RightSurface = Enum.SurfaceType.Smooth
root.FrontSurface = Enum.SurfaceType.Smooth
root.BackSurface = Enum.SurfaceType.Smooth
root.Parent = model

model.PrimaryPart = root
model:SetAttribute("Rarity", "Common")
model:SetAttribute("Style", "classic")
