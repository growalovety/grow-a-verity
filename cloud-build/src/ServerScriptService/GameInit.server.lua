local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Variants = require(ReplicatedStorage:WaitForChild("VariantDefinitions"))

local showcase = workspace:FindFirstChild("Variants")
if showcase then
    showcase:Destroy()
end

showcase = Instance.new("Folder")
showcase.Name = "Variants"
showcase.Parent = workspace

local function addFace(part)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Face"
    gui.Face = Enum.NormalId.Front
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 45
    gui.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "●  ●\n  ◡"
    label.TextColor3 = Color3.new(0.05, 0.05, 0.05)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

local function createVariant(definition, index)
    local model = Instance.new("Model")
    model.Name = definition.Name
    model:SetAttribute("Rarity", definition.Rarity)
    model:SetAttribute("Personality", definition.Personality)
    model:SetAttribute("Income", definition.Income)
    model.Parent = showcase

    local root = Instance.new("Part")
    root.Name = "Root"
    root.Shape = Enum.PartType.Ball
    root.Size = Vector3.new(4, 4, 4)
    root.Position = Vector3.new((index - 2.5) * 6, 3, -8)
    root.Anchored = true
    root.CanCollide = true
    root.Material = Enum.Material.SmoothPlastic
    root.Color = definition.Color
    root.TopSurface = Enum.SurfaceType.Smooth
    root.BottomSurface = Enum.SurfaceType.Smooth
    root.LeftSurface = Enum.SurfaceType.Smooth
    root.RightSurface = Enum.SurfaceType.Smooth
    root.FrontSurface = Enum.SurfaceType.Smooth
    root.BackSurface = Enum.SurfaceType.Smooth
    root.Parent = model

    model.PrimaryPart = root
    addFace(root)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "Name"
    billboard.Size = UDim2.fromOffset(180, 55)
    billboard.StudsOffset = Vector3.new(0, 3.2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = root

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = definition.Name .. " • " .. definition.Rarity
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.25
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
end

local names = {"Verity", "Falsity", "Cruelty", "Lovity"}
for index, name in ipairs(names) do
    createVariant(Variants[name], index)
end
