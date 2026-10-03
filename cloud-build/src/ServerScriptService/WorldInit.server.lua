local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local existing = workspace:FindFirstChild("World")
if existing then existing:Destroy() end
local world = Instance.new("Folder")
world.Name = "World"
world:SetAttribute("BuildId","cloud-live-33")
world.Parent = workspace

local function part(name,size,pos,color,material,parent)
    local p=Instance.new("Part")
    p.Name=name p.Size=size p.Position=pos p.Anchored=true p.CanCollide=true
    p.Material=material or Enum.Material.SmoothPlastic p.Color=color
    p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent or world
    return p
end
local function label(parent,text,size,offset,color)
    local g=Instance.new("BillboardGui") g.Size=size g.StudsOffset=offset g.AlwaysOnTop=false g.MaxDistance=45 g.LightInfluence=.15 g.Parent=parent
    local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Text=text
    t.TextColor3=color or Color3.new(1,1,1) t.TextStrokeTransparency=.35 t.Font=Enum.Font.GothamBlack t.TextScaled=true t.Parent=g
end
local function fence(plot,c,w,d)
    local wood=Color3.fromRGB(139,92,53) local rail=Color3.fromRGB(176,119,66)
    for _,x in ipairs({-w/2,w/2}) do for _,z in ipairs({-d/2,d/2}) do
        part("FencePost",Vector3.new(.65,1.8,.65),c+Vector3.new(x,.9,z),wood,Enum.Material.Wood,plot)
    end end
    part("FenceRail",Vector3.new(w,.28,.28),c+Vector3.new(0,.8,-d/2),rail,Enum.Material.Wood,plot)
    part("FenceRail",Vector3.new(w,.28,.28),c+Vector3.new(0,.8,d/2),rail,Enum.Material.Wood,plot)
    part("FenceRail",Vector3.new(.28,.28,d),c+Vector3.new(-w/2,.8,0),rail,Enum.Material.Wood,plot)
    part("FenceRail",Vector3.new(.28,.28,d),c+Vector3.new(w/2,.8,0),rail,Enum.Material.Wood,plot)
end
local function portal(name,pos,accent,titleText)
    local m=Instance.new("Model") m.Name=name m.Parent=world
    part("Base",Vector3.new(12,.5,8),pos+Vector3.new(0,.25,0),Color3.fromRGB(72,112,70),Enum.Material.SmoothPlastic,m)
    for _,x in ipairs({-4.5,4.5}) do part("Post",Vector3.new(1,6,1),pos+Vector3.new(x,3.25,0),accent,Enum.Material.SmoothPlastic,m) end
    part("Top",Vector3.new(10,1,1),pos+Vector3.new(0,6,0),accent,Enum.Material.SmoothPlastic,m)
    local core=part("Core",Vector3.new(7,4.5,.5),pos+Vector3.new(0,3,0),accent,Enum.Material.Neon,m)
    core.Transparency=.35 core.CanCollide=false
    local pr=Instance.new("ProximityPrompt") pr.Name="PortalPrompt" pr.ActionText=titleText=="EXPLORE" and "Explore" or "Return"
    pr.ObjectText=titleText pr.KeyboardKeyCode=Enum.KeyCode.E pr.MaxActivationDistance=10 pr.RequiresLineOfSight=false pr.Parent=core
end
local function buildConveyor(parent,x,direction)
    local model=Instance.new("Model") model.Name="ConveyorLane" model.Parent=parent
    local base=part("Conveyor",Vector3.new(11,.5,194),Vector3.new(x,.72,0),Color3.fromRGB(55,60,55),Enum.Material.Metal,model)
    base:SetAttribute("ConveyorDirection",direction)
    base:SetAttribute("ConveyorSpeed",30)
    part("BeltSurface",Vector3.new(9.2,.18,190),Vector3.new(x,1.0,0),Color3.fromRGB(35,38,35),Enum.Material.SmoothPlastic,model).CanCollide=false
    for _,sx in ipairs({-5.0,5.0}) do
        part("SideRail",Vector3.new(.35,.8,194),Vector3.new(x+sx,1.25,0),Color3.fromRGB(88,94,84),Enum.Material.Metal,model)
    end
    for z=-90,90,8 do
        local roller=part("Roller",Vector3.new(9.0,.24,.5),Vector3.new(x,1.08,z),Color3.fromRGB(125,130,122),Enum.Material.Metal,model)
        roller.CanCollide=false
        for _,side in ipairs({-1,1}) do
            local tread=part("Tread",Vector3.new(3.1,.06,1.6),Vector3.new(x+side*1.7,1.12,z),Color3.fromRGB(238,199,76),Enum.Material.Neon,model)
            tread.CanCollide=false
        end
    end
    for z=-82,82,28 do
        local arrow=part("FlowMarker",Vector3.new(2.4,.05,4.5),Vector3.new(x,1.16,z),Color3.fromRGB(224,190,73),Enum.Material.Neon,model)
        arrow.CanCollide=false
        arrow.CFrame=arrow.CFrame*CFrame.Angles(0,0,direction<0 and math.rad(180) or 0)
    end
end

local starter=Instance.new("Folder") starter.Name="StarterGrove" starter.Parent=world
part("GroveGround",Vector3.new(220,1,220),Vector3.new(0,0,0),Color3.fromRGB(104,158,82),Enum.Material.Grass,starter)
local borderColor=Color3.fromRGB(31,45,38)
for _,data in ipairs({
    {"North",Vector3.new(228,18,8),Vector3.new(0,9,114)},
    {"South",Vector3.new(228,18,8),Vector3.new(0,9,-114)},
    {"West",Vector3.new(8,18,228),Vector3.new(-114,9,0)},
    {"East",Vector3.new(8,18,228),Vector3.new(114,9,0)}
}) do
    local name,size,pos=data[1],data[2],data[3]
    local b=part("MapBorder_"..name,size,pos,borderColor,Enum.Material.Slate,starter)
    b:SetAttribute("AntiExploitBorder",true)
end
part("MainPath",Vector3.new(18,.2,190),Vector3.new(0,.6,0),Color3.fromRGB(220,187,112),Enum.Material.SmoothPlastic,starter)
buildConveyor(starter,-24,1)
buildConveyor(starter,24,-1)

local spawn=workspace:FindFirstChild("SpawnLocation") if spawn then spawn:Destroy() end
spawn=Instance.new("SpawnLocation") spawn.Name="SpawnLocation" spawn.Size=Vector3.new(14,1,14) spawn.Position=Vector3.new(0,1,-101)
spawn.Anchored=true spawn.Neutral=true spawn.Material=Enum.Material.SmoothPlastic spawn.Color=Color3.fromRGB(255,221,45) spawn.Transparency=.05 spawn.Parent=starter
local ta=part("TitleAnchor",Vector3.new(1,1,1),Vector3.new(0,4.5,-78),Color3.new(1,1,1),Enum.Material.SmoothPlastic,starter)
ta.Transparency=1 ta.CanCollide=false label(ta,"GROW A VERITY",UDim2.fromOffset(320,58),Vector3.new(),Color3.new(1,1,1))

local plotPositions={Vector3.new(-62,.55,-52),Vector3.new(62,.55,-52),Vector3.new(-62,.55,0),Vector3.new(62,.55,0),Vector3.new(-62,.55,52),Vector3.new(62,.55,52)}
for i,pos in ipairs(plotPositions) do
    local plot=Instance.new("Folder") plot.Name="Plot_"..i plot:SetAttribute("FreePlacement",true) plot.Parent=starter
    part("GardenSurface",Vector3.new(36,.3,30),pos,Color3.fromRGB(126,91,56),Enum.Material.SmoothPlastic,plot)
    part("GardenGrass",Vector3.new(33,.12,27),pos+Vector3.new(0,.22,0),Color3.fromRGB(121,177,91),Enum.Material.Grass,plot)
    fence(plot,pos,38,32)
    local m=part("PlotMarker",Vector3.new(1,1,1),pos+Vector3.new(0,4.6,-13),Color3.new(1,1,1),Enum.Material.SmoothPlastic,plot)
    m.Transparency=1 m.CanCollide=false
    label(m,"GARDEN "..i,UDim2.fromOffset(390,58),Vector3.new(),Color3.fromRGB(255,246,214))
end
portal("ExplorePortal",Vector3.new(0,.75,108),Color3.fromRGB(88,184,255),"EXPLORE")

local wilds=Instance.new("Folder") wilds.Name="GuardianWilds" wilds.Parent=world
local o=Vector3.new(0,0,900)
part("WildsGround",Vector3.new(260,1,220),o,Color3.fromRGB(106,161,84),Enum.Material.Grass,wilds)
for _,data in ipairs({
    {"North",Vector3.new(268,18,8),o+Vector3.new(0,9,114)},
    {"South",Vector3.new(268,18,8),o+Vector3.new(0,9,-114)},
    {"West",Vector3.new(8,18,268),o+Vector3.new(-134,9,0)},
    {"East",Vector3.new(8,18,268),o+Vector3.new(134,9,0)}
}) do
    local name,size,pos=data[1],data[2],data[3]
    local b=part("MapBorder_"..name,size,pos,borderColor,Enum.Material.Slate,wilds)
    b:SetAttribute("AntiExploitBorder",true)
end
for _,h in ipairs({{Vector3.new(-80,18,850),Vector3.new(45,36,55)},{Vector3.new(78,24,870),Vector3.new(55,48,60)},{Vector3.new(-82,14,965),Vector3.new(50,28,50)},{Vector3.new(82,18,970),Vector3.new(48,36,55)}}) do
    local p=part("LowPolyHill",h[2],h[1],Color3.fromRGB(87,139,76),Enum.Material.Grass,wilds) p.Shape=Enum.PartType.Wedge
end
for _,p in ipairs({Vector3.new(-60,5,850),Vector3.new(65,5,850),Vector3.new(-72,5,970),Vector3.new(70,5,970)}) do
    part("Rock",Vector3.new(9,9,9),p,Color3.fromRGB(126,124,103),Enum.Material.Rock,wilds)
end
local arena=Instance.new("Folder") arena.Name="GuardianArena" arena.Parent=wilds
part("ArenaFloor",Vector3.new(66,.4,54),o+Vector3.new(0,.7,0),Color3.fromRGB(184,145,75),Enum.Material.SmoothPlastic,arena)
part("ArenaRing",Vector3.new(54,.25,42),o+Vector3.new(0,1.05,0),Color3.fromRGB(238,204,98),Enum.Material.Neon,arena)
local defs=require(ReplicatedStorage:WaitForChild("BattleDefinitions"))
local function guardian(name,pos,scale)
    local def=defs[name] local m=Instance.new("Model") m.Name=name.."Guardian" m:SetAttribute("VarietyName",name) m:SetAttribute("GuardianTier",scale>=1.4 and "Elite" or "Normal") m.Parent=arena
    local root=Instance.new("Part") root.Name="Body" root.Shape=Enum.PartType.Ball root.Size=Vector3.new(4,4,4)*scale root.Position=pos
    root.Anchored=true root.CanCollide=false root.Material=Enum.Material.SmoothPlastic root.Color=def.Accent root.Parent=m m.PrimaryPart=root
    local function f(size,off,color,shape)
        local p=Instance.new("Part") p.Shape=shape or Enum.PartType.Ball p.Size=size*scale p.Position=root.Position+off*scale
        p.Anchored=true p.CanCollide=false p.Material=Enum.Material.SmoothPlastic p.Color=color p.Parent=m
    end
    f(Vector3.new(.55,.55,.55),Vector3.new(-.8,.35,-1.82),Color3.fromRGB(24,25,29))
    f(Vector3.new(.55,.55,.55),Vector3.new(.8,.35,-1.82),Color3.fromRGB(24,25,29))
    f(Vector3.new(1.2,.2,.22),Vector3.new(0,-.65,-1.8),Color3.fromRGB(24,25,29),Enum.PartType.Block)
    if name=="Verity" then f(Vector3.new(1.5,2.2,.45),Vector3.new(0,0,1.95),def.Accent,Enum.PartType.Block)
    elseif name=="Falsity" then f(Vector3.new(1.2,.5,1.8),Vector3.new(-2,.1,0),def.Accent,Enum.PartType.Wedge) f(Vector3.new(1.2,.5,1.8),Vector3.new(2,.1,0),def.Accent,Enum.PartType.Wedge)
    else f(Vector3.new(1.35,1.35,1.35),Vector3.new(-1.25,1.8,0),def.Accent) f(Vector3.new(1.35,1.35,1.35),Vector3.new(1.25,1.8,0),def.Accent) end
    local pr=Instance.new("ProximityPrompt") pr.Name="BattlePrompt" pr.ActionText="Battle" pr.ObjectText=name.." Guardian" pr.KeyboardKeyCode=Enum.KeyCode.E pr.MaxActivationDistance=12 pr.RequiresLineOfSight=true pr.Parent=root
    label(root,name,UDim2.fromOffset(140,30),Vector3.new(0,3,0),Color3.new(1,1,1))
end
guardian("Verity",o+Vector3.new(-18,3.8,0),1.1) guardian("Falsity",o+Vector3.new(0,3.8,0),1.1) guardian("Lovity",o+Vector3.new(18,3.8,0),1.1)
local returnPos=o+Vector3.new(0,.75,72) portal("ReturnPortal",returnPos,Color3.fromRGB(255,221,45),"RETURN")
local links={{Vector3.new(0,.75,108),o+Vector3.new(0,0,12)},{returnPos,Vector3.new(0,1,-100)}}
for _,pr in ipairs(world:GetDescendants()) do
    if pr:IsA("ProximityPrompt") and pr.Name=="PortalPrompt" then
        pr.Triggered:Connect(function(player)
            local ch=player.Character local root=ch and ch:FindFirstChild("HumanoidRootPart") if not root then return end
            local best,bd
            for _,e in ipairs(links) do local d=(root.Position-e[1]).Magnitude if not bd or d<bd then best,bd=e,d end end
            if best and bd<18 then root.CFrame=CFrame.new(best[2]+Vector3.new(0,3,0)) end
        end)
    end
end
local biomes=Instance.new("Folder"); biomes.Name="Biomes"; biomes.Parent=wilds
local function zone(name,pos,size,color)
    local p=part(name.."Biome",size,pos,color,Enum.Material.Grass,biomes); p.Transparency=.12
    p:SetAttribute("Biome",name); return p
end
zone("Meadow",o+Vector3.new(-82,.52,-55),Vector3.new(105,.25,88),Color3.fromRGB(117,177,91))
zone("Bluewood",o+Vector3.new(78,.52,-48),Vector3.new(100,.25,86),Color3.fromRGB(91,157,121))
zone("Redstone",o+Vector3.new(-72,.52,58),Vector3.new(110,.25,78),Color3.fromRGB(164,112,82))
zone("LoveGarden",o+Vector3.new(70,.52,60),Vector3.new(105,.25,76),Color3.fromRGB(178,125,157))
local explorePath=part("ExplorePath",Vector3.new(14,.22,190),o+Vector3.new(0,.7,0),Color3.fromRGB(188,166,117),Enum.Material.Ground,wilds)
for _,tree in ipairs({Vector3.new(-108,4,855),Vector3.new(-95,4,925),Vector3.new(104,4,835),Vector3.new(112,4,930),Vector3.new(88,4,1000),Vector3.new(-100,4,1005)}) do
    local trunk=part("TreeTrunk",Vector3.new(2.2,8,2.2),o+tree,Color3.fromRGB(101,71,49),Enum.Material.Wood,wilds)
    local crown=part("TreeCrown",Vector3.new(9,7,9),trunk.Position+Vector3.new(0,5,0),Color3.fromRGB(67,128,72),Enum.Material.Grass,wilds); crown.Shape=Enum.PartType.Ball
end
local hidden=Instance.new("Folder"); hidden.Name="HiddenGrove"; hidden.Parent=wilds
part("HiddenFloor",Vector3.new(48,.3,38),o+Vector3.new(90,.8,40),Color3.fromRGB(89,142,83),Enum.Material.Grass,hidden)
for _,p in ipairs({o+Vector3.new(66,4,22),o+Vector3.new(114,4,22),o+Vector3.new(66,4,58),o+Vector3.new(114,4,58)}) do
    part("HiddenRock",Vector3.new(7,8,7),p,Color3.fromRGB(104,105,92),Enum.Material.Rock,hidden)
end
local sign=part("ExploreSign",Vector3.new(1,1,1),o+Vector3.new(-116,3,885),Color3.new(1,1,1),Enum.Material.SmoothPlastic,wilds); sign.Transparency=1; sign.CanCollide=false
label(sign,"MEADOW  •  BLUEWOOD  •  REDSTONE  •  LOVE GARDEN",UDim2.fromOffset(540,48),Vector3.new(),Color3.fromRGB(246,243,226))
guardian("Cruelty",o+Vector3.new(-82,4.2,970),1.25)
guardian("Cruelty",o+Vector3.new(82,4.2,970),1.55)

Lighting.ClockTime=14
Lighting.Brightness=3
Lighting.Ambient=Color3.fromRGB(205,215,190)
Lighting.OutdoorAmbient=Color3.fromRGB(210,220,195)
Lighting.FogColor=Color3.fromRGB(170,205,230)
Lighting.FogEnd=620
Lighting.GlobalShadows=true
local at=Lighting:FindFirstChildOfClass("Atmosphere") if at then at:Destroy() end