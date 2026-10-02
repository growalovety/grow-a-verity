local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local existing = workspace:FindFirstChild("World")
if existing then existing:Destroy() end
local world = Instance.new("Folder")
world.Name = "World"
world:SetAttribute("BuildId","cloud-live-32")
world.Parent = workspace

local function part(name,size,pos,color,material,parent)
    local p=Instance.new("Part")
    p.Name=name p.Size=size p.Position=pos p.Anchored=true p.CanCollide=true
    p.Material=material or Enum.Material.SmoothPlastic p.Color=color
    p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent or world
    return p
end
local function label(parent,text,size,offset,color)
    local g=Instance.new("BillboardGui") g.Size=size g.StudsOffset=offset g.AlwaysOnTop=true g.MaxDistance=70 g.Parent=parent
    local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(1,1) t.BackgroundTransparency=1 t.Text=text
    t.TextColor3=color or Color3.new(1,1,1) t.TextStrokeTransparency=.55 t.Font=Enum.Font.GothamBold t.TextScaled=true t.Parent=g
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

local starter=Instance.new("Folder") starter.Name="StarterGrove" starter.Parent=world
part("GroveGround",Vector3.new(170,1,180),Vector3.new(0,0,0),Color3.fromRGB(104,158,82),Enum.Material.Grass,starter)
part("MainPath",Vector3.new(16,.2,150),Vector3.new(0,.6,0),Color3.fromRGB(220,187,112),Enum.Material.SmoothPlastic,starter)
for _,x in ipairs({-20,20}) do
    part("Conveyor",Vector3.new(7,.25,150),Vector3.new(x,.73,0),Color3.fromRGB(74,93,68),Enum.Material.SmoothPlastic,starter)
    for z=-65,65,13 do part("ConveyorMarker",Vector3.new(3.2,.05,1.2),Vector3.new(x,.9,z),Color3.fromRGB(232,205,107),Enum.Material.Neon,starter).CanCollide=false end
end
local spawn=workspace:FindFirstChild("SpawnLocation") if spawn then spawn:Destroy() end
spawn=Instance.new("SpawnLocation") spawn.Name="SpawnLocation" spawn.Size=Vector3.new(7,1,7) spawn.Position=Vector3.new(0,1,-70)
spawn.Anchored=true spawn.Neutral=true spawn.Material=Enum.Material.SmoothPlastic spawn.Color=Color3.fromRGB(255,221,45) spawn.Transparency=.05 spawn.Parent=starter
local ta=part("TitleAnchor",Vector3.new(1,1,1),Vector3.new(0,4.5,-55),Color3.new(1,1,1),Enum.Material.SmoothPlastic,starter)
ta.Transparency=1 ta.CanCollide=false label(ta,"GROW A VERITY",UDim2.fromOffset(270,52),Vector3.new(),Color3.new(1,1,1))
local plotPositions={Vector3.new(-50,.55,-42),Vector3.new(50,.55,-42),Vector3.new(-50,.55,0),Vector3.new(50,.55,0),Vector3.new(-50,.55,42),Vector3.new(50,.55,42)}
for i,pos in ipairs(plotPositions) do
    local plot=Instance.new("Folder") plot.Name="Plot_"..i plot:SetAttribute("FreePlacement",true) plot.Parent=starter
    part("GardenSurface",Vector3.new(28,.3,22),pos,Color3.fromRGB(126,91,56),Enum.Material.SmoothPlastic,plot)
    part("GardenGrass",Vector3.new(25.5,.12,19.5),pos+Vector3.new(0,.22,0),Color3.fromRGB(121,177,91),Enum.Material.Grass,plot)
    fence(plot,pos,30,24)
    local m=part("PlotMarker",Vector3.new(1,1,1),pos+Vector3.new(0,2.8,-13),Color3.new(1,1,1),Enum.Material.SmoothPlastic,plot)
    m.Transparency=1 m.CanCollide=false label(m,"GARDEN "..i,UDim2.fromOffset(130,28),Vector3.new(),Color3.fromRGB(255,240,190))
end
portal("ExplorePortal",Vector3.new(0,.75,82),Color3.fromRGB(88,184,255),"EXPLORE")

local wilds=Instance.new("Folder") wilds.Name="GuardianWilds" wilds.Parent=world
local o=Vector3.new(0,0,900)
part("WildsGround",Vector3.new(220,1,190),o,Color3.fromRGB(106,161,84),Enum.Material.Grass,wilds)
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
    local def=defs[name] local m=Instance.new("Model") m.Name=name.."Guardian" m:SetAttribute("VarietyName",name) m.Parent=arena
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
    local pr=Instance.new("ProximityPrompt") pr.Name="BattlePrompt" pr.ActionText="Battle" pr.ObjectText=name.." Guardian" pr.KeyboardKeyCode=Enum.KeyCode.E pr.MaxActivationDistance=12 pr.RequiresLineOfSight=false pr.Parent=root
    label(root,name,UDim2.fromOffset(140,30),Vector3.new(0,3,0),Color3.new(1,1,1))
end
guardian("Verity",o+Vector3.new(-18,3.8,0),1.1) guardian("Falsity",o+Vector3.new(0,3.8,0),1.1) guardian("Lovity",o+Vector3.new(18,3.8,0),1.1)
local returnPos=o+Vector3.new(0,.75,72) portal("ReturnPortal",returnPos,Color3.fromRGB(255,221,45),"RETURN")
local links={{Vector3.new(0,.75,82),o+Vector3.new(0,0,12)},{returnPos,Vector3.new(0,1,-70)}}
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
Lighting.ClockTime=14 Lighting.Brightness=3 Lighting.Ambient=Color3.fromRGB(205,215,190)
Lighting.OutdoorAmbient=Color3.fromRGB(210,220,195) Lighting.FogColor=Color3.fromRGB(170,205,230) Lighting.FogEnd=520 Lighting.GlobalShadows=true
local at=Lighting:FindFirstChildOfClass("Atmosphere") if at then at:Destroy() end