local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local mouse=player:GetMouse()
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local gardenState=remotes:WaitForChild("GardenState")
local gardenPlace=remotes:WaitForChild("GardenPlace")
local gardenHarvest=remotes:WaitForChild("GardenHarvest")
local gardenRemove=remotes:WaitForChild("GardenRemove")
local gardenUpgrade=remotes:WaitForChild("GardenUpgrade")
local Variants=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
local SoundService=game:GetService("SoundService")
local function gardenSfx(id,vol)
 local snd=Instance.new("Sound"); snd.SoundId=id; snd.Volume=vol or .25; snd.SoundGroup=SoundService:FindFirstChild("GrowAVeritySFX"); snd.Parent=SoundService; snd:Play(); game:GetService("Debris"):AddItem(snd,3)
end

local gui=Instance.new("ScreenGui"); gui.Name="GardenUI"; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false; gui.DisplayOrder=30; gui.Parent=player:WaitForChild("PlayerGui")
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function stroke(o,c,t,w) local s=Instance.new("UIStroke"); s.Color=c; s.Transparency=t or 0; s.Thickness=w or 1; s.Parent=o end
local BG=Color3.fromRGB(17,24,20); local PANEL=Color3.fromRGB(28,38,31); local PANEL2=Color3.fromRGB(38,50,40); local TEXT=Color3.fromRGB(240,246,237); local MUTED=Color3.fromRGB(166,181,163); local GREEN=Color3.fromRGB(91,201,116); local GOLD=Color3.fromRGB(245,201,87)
local function label(parent,txt,size,pos,color,font) local l=Instance.new("TextLabel"); l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=color; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=parent; return l end
local function btn(parent,txt,size,pos,bg) local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=bg or PANEL2; b.Text=txt; b.TextColor3=TEXT; b.Font=Enum.Font.GothamBold; b.TextScaled=true; b.Parent=parent; corner(b,10); return b end

local panel=Instance.new("Frame"); panel.Size=UDim2.fromOffset(780,500); panel.Position=UDim2.new(.5,-390,.5,-250); panel.BackgroundColor3=BG; panel.Visible=false; panel.Parent=gui; corner(panel,18); stroke(panel,GREEN,.18,2)
label(panel,"GARDEN",UDim2.fromOffset(300,42),UDim2.fromOffset(24,18),TEXT,Enum.Font.GothamBlack)
local sub=label(panel,"",UDim2.fromOffset(360,30),UDim2.fromOffset(24,58),MUTED,Enum.Font.GothamBold)
local close=btn(panel,"×",UDim2.fromOffset(42,42),UDim2.new(1,-58,0,18),PANEL2)

local seeds=Instance.new("ScrollingFrame"); seeds.Size=UDim2.fromOffset(260,345); seeds.Position=UDim2.fromOffset(22,105); seeds.BackgroundColor3=PANEL; seeds.ScrollBarThickness=4; seeds.BorderSizePixel=0; seeds.Parent=panel; corner(seeds,14)
local list=Instance.new("UIListLayout"); list.Padding=UDim.new(0,8); list.Parent=seeds
local details=Instance.new("Frame"); details.Size=UDim2.fromOffset(458,345); details.Position=UDim2.fromOffset(300,105); details.BackgroundColor3=PANEL; details.BorderSizePixel=0; details.Parent=panel; corner(details,14)
local selected=nil
local state={Level=1,Plants={},MaxPlants=6}

local function seedCount(n) return tonumber(player:GetAttribute("SeedCount_"..n)) or (player:GetAttribute("Seed_"..n) and 1 or 0) end
local function refresh()
    for _,x in ipairs(seeds:GetChildren()) do if x:IsA("TextButton") then x:Destroy() end end
    local found=0
    for n,v in pairs(Variants) do
        local c=seedCount(n)
        if c>0 then
            found+=1
            local b=btn(seeds,n.." Seed   ×"..c,UDim2.new(1,-16,0,46),UDim2.fromOffset(8,0),PANEL2)
            b.TextColor3=v.Color
            b.Activated:Connect(function()
                selected=n
                for _,q in ipairs(seeds:GetChildren()) do if q:IsA("TextButton") then q.BackgroundColor3=PANEL2 end end
                b.BackgroundColor3=Color3.fromRGB(52,72,56)
                details.Visible=true
            end)
        end
    end
    if found==0 then label(seeds,"No seeds available.\nDefeat Guardians or explore.",UDim2.new(1,-20,0,80),UDim2.fromOffset(10,16),MUTED,Enum.Font.GothamBold) end
    sub.Text="Level "..state.Level.."   •   Plants "..#state.Plants.."/"..state.MaxPlants
end

local help=label(details,"SELECT A SEED",UDim2.new(1,-32,0,42),UDim2.fromOffset(16,16),TEXT,Enum.Font.GothamBlack)
local info=label(details,"Pick a seed, then click inside your garden to place it.\n\nPlants grow automatically. Mature plants can be harvested at the plant or with the prompt.",UDim2.new(1,-32,0,150),UDim2.fromOffset(16,62),MUTED,Enum.Font.GothamBold)
info.TextWrapped=true; info.TextXAlignment=Enum.TextXAlignment.Left; info.TextYAlignment=Enum.TextYAlignment.Top
local place=btn(details,"PLACE SELECTED SEED",UDim2.fromOffset(210,48),UDim2.fromOffset(16,225),GREEN); place.TextColor3=Color3.fromRGB(18,25,19)
local harvest=btn(details,"HARVEST READY",UDim2.fromOffset(190,48),UDim2.fromOffset(236,225),GOLD); harvest.TextColor3=Color3.fromRGB(35,30,15)
local upgrade=btn(panel,"UPGRADE GARDEN",UDim2.fromOffset(210,44),UDim2.fromOffset(300,455),PANEL2)
local status=label(panel,"",UDim2.fromOffset(250,34),UDim2.fromOffset(520,458),MUTED,Enum.Font.GothamBold); status.TextXAlignment=Enum.TextXAlignment.Right

local placing=false
local marker=Instance.new("Part"); marker.Name="GardenPlacementPreview"; marker.Size=Vector3.new(2.4,.35,2.4); marker.Anchored=true; marker.CanCollide=false; marker.Material=Enum.Material.Neon; marker.Transparency=.35; marker.Parent=workspace; marker.Color=GREEN
marker.Transparency=1

local function gardenPlot()
    local world=workspace:FindFirstChild("World"); local grove=world and world:FindFirstChild("StarterGrove"); local idx=player:GetAttribute("GardenIndex")
    return idx and grove and grove:FindFirstChild("Garten von "..player.Name)
end
local function getLocalHit()
    local plot=gardenPlot(); if not plot then return end
    local hit=mouse.Hit.Position
    local surface=plot:FindFirstChild("GardenSurface"); if not surface then return end
    local localPos=hit-surface.Position
    local x=math.clamp(localPos.X,-14.5,14.5); local z=math.clamp(localPos.Z,-11.5,11.5)
    return x,z,surface.Position+Vector3.new(x,1.0,z)
end
RunService.RenderStepped:Connect(function()
    if not placing then marker.Transparency=1; return end
    local x,z,pos=getLocalHit()
    if x then marker.Position=pos; marker.Transparency=.45 end
end)
place.Activated:Connect(function()
    if not selected then status.Text="Select a seed first." return end
    placing=true; marker.Transparency=.45; status.Text="CLICK A SPOT IN YOUR GARDEN"
end)
UserInputService.InputBegan:Connect(function(input,gp)
    if gp or not placing or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local x,z=getLocalHit()
    if x and selected then
        gardenPlace:FireServer(selected,x,z)
        placing=false; marker.Transparency=1
        status.Text="Seed planted."
    end
end)
harvest.Activated:Connect(function()
    local any=false
    for _,plant in ipairs(state.Plants) do
        local def=Variants[plant.Variety]
        if def and os.time()-plant.PlantedAt>=def.GrowthTime then gardenHarvest:FireServer(plant.Id); any=true end
    end
    if any then gardenSfx("rbxassetid://17403146731",.28) end; status.Text=any and "Harvesting..." or "Nothing ready yet."
end)
upgrade.Activated:Connect(function() gardenUpgrade:FireServer() end)
close.Activated:Connect(function() panel.Visible=false; placing=false; marker.Transparency=1 end)

gardenState.OnClientEvent:Connect(function(s)
    if type(s)~="table" then return end
    state=s; refresh()
    if s.Harvest then status.Text="Harvested for +"..s.Harvest.." Cash!" end
    if s.Error then status.Text=s.Error end
    if s.Upgrade then status.Text="Garden upgraded." end
end)

_G.GrowAVerityOpenGarden=function()
    panel.Visible=true; refresh()
end

local seedCollected=remotes:WaitForChild("SeedCollected")
seedCollected.OnClientEvent:Connect(function(ok,msg)
    status.Text=msg or ""
    if ok then gardenSfx("rbxassetid://17403146731",.22) end
end)
