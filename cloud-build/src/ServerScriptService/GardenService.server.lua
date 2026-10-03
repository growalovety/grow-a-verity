local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")

local Variants=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes"; remotes.Parent=ReplicatedStorage
local function remote(n) local r=remotes:FindFirstChild(n) or Instance.new("RemoteEvent"); r.Name=n; r.Parent=remotes; return r end
local gardenState=remote("GardenState")
local gardenPlace=remote("GardenPlace")
local gardenHarvest=remote("GardenHarvest")
local gardenRemove=remote("GardenRemove")
local gardenUpgrade=remote("GardenUpgrade")

local store=DataStoreService:GetDataStore("GrowAVerity_Gardens_v2")
local playerStore=DataStoreService:GetDataStore("GrowAVerity_Player_v1")
local active={}

local function getGardenIndex(p)
    return p:GetAttribute("GardenIndex")
end

local function getPlot(p)
    local world=workspace:FindFirstChild("World")
    local grove=world and world:FindFirstChild("StarterGrove")
    local idx=getGardenIndex(p)
    return idx and grove and grove:FindFirstChild("Garten von "..p.Name)
end

local function maxPlants(p)
    return 6 + ((p:GetAttribute("GardenLevel") or 1)-1)*2
end

local function save(p)
    local s=active[p]
    if not s then return end
    pcall(function()
        store:SetAsync("p_"..p.UserId,{Slot=getGardenIndex(p),Level=s.Level,Plants=s.Plants})
    end)
end

local function load(p)
    local data
    pcall(function() data=store:GetAsync("p_"..p.UserId) end)
    data=type(data)=="table" and data or {}
    local level=math.max(1,math.floor(tonumber(data.Level) or 1))
    local plants=type(data.Plants)=="table" and data.Plants or {}
    local clean={}
    for _,plant in ipairs(plants) do
        if type(plant)=="table" and Variants[plant.Variety] and type(plant.X)=="number" and type(plant.Z)=="number" and type(plant.PlantedAt)=="number" then
            table.insert(clean,{Id=tostring(plant.Id or HttpService:GenerateGUID(false)),Variety=plant.Variety,X=plant.X,Z=plant.Z,PlantedAt=plant.PlantedAt})
        end
    end
    active[p]={Level=level,Plants=clean}
    p:SetAttribute("GardenLevel",level)
    task.delay(.5,function() if p.Parent then gardenState:FireClient(p,{Level=level,Plants=clean,MaxPlants=maxPlants(p)}) end end)
end

local function setCash(p,amount)
    local value=math.max(0,math.floor(amount))
    p:SetAttribute("Cash",value)
    pcall(function()
        playerStore:UpdateAsync("p_"..p.UserId,function(old)
            old=type(old)=="table" and old or {}
            old.Cash=value
            return old
        end)
    end)
end

local function addCash(p,amount)
    setCash(p,(tonumber(p:GetAttribute("Cash")) or 0)+amount)
end

local function seedCount(p,n)
    local count=tonumber(p:GetAttribute("SeedCount_"..n))
    if count==nil then count=p:GetAttribute("Seed_"..n) and 1 or 0 end
    return math.max(0,math.floor(count))
end

local function setSeedCount(p,n,count)
    count=math.max(0,math.floor(count))
    p:SetAttribute("SeedCount_"..n,count)
    p:SetAttribute("Seed_"..n,count>0)
end

local function stageFor(v,plantedAt,p)
    local def=Variants[v]
    local elapsed=math.max(0,os.time()-plantedAt)
    local mult=1+((p:GetAttribute("GardenLevel") or 1)-1)*.08
    local progress=math.clamp(elapsed/(def.GrowthTime/math.max(mult,.1)),0,1)
    if progress>=1 then return 3,1 end
    if progress>=.55 then return 2,progress end
    return 1,progress
end

local function clearGardenFolder(plot)
    local folder=plot and plot:FindFirstChild("Plants")
    if folder then folder:Destroy() end
end

local function makePlant(p,plant)
    local plot=getPlot(p); if not plot then return end
    local folder=plot:FindFirstChild("Plants") or Instance.new("Folder")
    folder.Name="Plants"; folder.Parent=plot
    local def=Variants[plant.Variety]
    local model=Instance.new("Model")
    model.Name="Plant_"..plant.Id
    model:SetAttribute("PlantId",plant.Id)
    model:SetAttribute("VarietyName",plant.Variety)
    model.Parent=folder

    local base=Instance.new("Part")
    base.Name="Root"; base.Shape=Enum.PartType.Cylinder
    base.Size=Vector3.new(2.2,.5,2.2)
    base.Position=plot.Position+Vector3.new(plant.X,.55,plant.Z)
    base.Anchored=true; base.CanCollide=false; base.Material=Enum.Material.Grass
    base.Color=Color3.fromRGB(92,70,45); base.Parent=model
    model.PrimaryPart=base

    local stage,progress=stageFor(plant.Variety,plant.PlantedAt,p)
    model:SetAttribute("Stage",stage)
    model:SetAttribute("Progress",progress)

    local stem=Instance.new("Part")
    stem.Name="Stem"; stem.Size=Vector3.new(.45,math.max(.7,stage*1.1),.45)
    stem.Position=base.Position+Vector3.new(0,stem.Size.Y/2+.2,0)
    stem.Anchored=true; stem.CanCollide=false; stem.Material=Enum.Material.Grass
    stem.Color=Color3.fromRGB(65,130,62); stem.Parent=model

    local function fruit(offset,size)
        local f=Instance.new("Part"); f.Name="Fruit"; f.Shape=Enum.PartType.Ball; f.Size=size; f.Position=base.Position+offset
        f.Anchored=true; f.CanCollide=false; f.Material=Enum.Material.Neon; f.Color=def.Color; f.Parent=model
    end
    if stage>=2 then
        fruit(Vector3.new(-.75,1.6,.1),Vector3.new(.8,.8,.8))
        fruit(Vector3.new(.75,1.9,.15),Vector3.new(.9,.9,.9))
    end
    if stage>=3 then
        fruit(Vector3.new(0,2.55,-.25),Vector3.new(1.05,1.05,1.05))
        local prompt=Instance.new("ProximityPrompt")
        prompt.Name="HarvestPrompt"; prompt.ActionText="Harvest"; prompt.ObjectText=plant.Variety.." Produce"
        prompt.MaxActivationDistance=10; prompt.RequiresLineOfSight=false; prompt.Parent=base
        prompt.Triggered:Connect(function(who)
            if who==p then gardenHarvest:FireServer(plant.Id) end
        end)
    end
    local bill=Instance.new("BillboardGui"); bill.Size=UDim2.fromOffset(170,38); bill.StudsOffset=Vector3.new(0,3.4,0); bill.AlwaysOnTop=true; bill.Parent=base
    local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.TextColor3=Color3.fromRGB(250,247,235); t.Font=Enum.Font.GothamBold; t.TextScaled=true
    t.Text=stage>=3 and plant.Variety.." • READY" or plant.Variety.." • "..math.floor(progress*100).."%"; t.Parent=bill
end

local function rebuild(p)
    local plot=getPlot(p); if not plot then return end
    clearGardenFolder(plot)
    for _,plant in ipairs(active[p].Plants) do makePlant(p,plant) end
end

local function validPosition(p,x,z)
    local plot=getPlot(p); if not plot then return false end
    if type(x)~="number" or type(z)~="number" then return false end
    return math.abs(x)<=14.5 and math.abs(z)<=11.5
end

local function findPlant(s,id)
    for i,plant in ipairs(s.Plants) do if plant.Id==id then return i,plant end end
end

Players.PlayerAdded:Connect(function(p)
    task.spawn(function()
        repeat task.wait() until p:GetAttribute("GardenIndex")
        load(p)
    end)
end)

Players.PlayerRemoving:Connect(function(p) save(p); active[p]=nil end)

gardenPlace.OnServerEvent:Connect(function(p,variant,x,z)
    local s=active[p]; if not s or not Variants[variant] or not validPosition(p,x,z) then return end
    if #s.Plants>=maxPlants(p) or seedCount(p,variant)<=0 then return end
    for _,plant in ipairs(s.Plants) do
        if (plant.X-x)^2+(plant.Z-z)^2<4 then return end
    end
    setSeedCount(p,variant,seedCount(p,variant)-1)
    local plant={Id=HttpService:GenerateGUID(false),Variety=variant,X=x,Z=z,PlantedAt=os.time()}
    table.insert(s.Plants,plant)
    rebuild(p); save(p)
    gardenState:FireClient(p,{Level=s.Level,Plants=s.Plants,MaxPlants=maxPlants(p)})
end)

gardenHarvest.OnServerEvent:Connect(function(p,id)
    local s=active[p]; if not s then return end
    local i,plant=findPlant(s,id); if not i then return end
    local stage=stageFor(plant.Variety,plant.PlantedAt,p)
    if stage<3 then return end
    local def=Variants[plant.Variety]
    local mult=1+((s.Level-1)*.15)
    addCash(p,math.floor(def.HarvestValue*mult))
    table.remove(s.Plants,i)
    rebuild(p); save(p)
    gardenState:FireClient(p,{Level=s.Level,Plants=s.Plants,MaxPlants=maxPlants(p),Harvest=math.floor(def.HarvestValue*mult)})
end)

gardenRemove.OnServerEvent:Connect(function(p,id)
    local s=active[p]; if not s then return end
    local i,plant=findPlant(s,id); if not i then return end
    setSeedCount(p,plant.Variety,seedCount(p,plant.Variety)+1)
    table.remove(s.Plants,i)
    rebuild(p); save(p)
    gardenState:FireClient(p,{Level=s.Level,Plants=s.Plants,MaxPlants=maxPlants(p)})
end)

gardenUpgrade.OnServerEvent:Connect(function(p)
    local s=active[p]; if not s then return end
    local cost=250*s.Level
    local cash=tonumber(p:GetAttribute("Cash")) or 0
    if cash<cost then gardenState:FireClient(p,{Level=s.Level,Plants=s.Plants,MaxPlants=maxPlants(p),Error="Need "..cost.." Cash"}) return end
    setCash(p,cash-cost); s.Level+=1; p:SetAttribute("GardenLevel",s.Level)
    save(p); rebuild(p)
    gardenState:FireClient(p,{Level=s.Level,Plants=s.Plants,MaxPlants=maxPlants(p),Upgrade=true})
end)

task.spawn(function()
    while true do
        task.wait(5)
        for p,s in pairs(active) do
            if p.Parent and s then rebuild(p) end
        end
    end
end)
