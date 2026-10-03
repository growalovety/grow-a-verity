local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local Variants=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder"); remotes.Name="GameRemotes"; remotes.Parent=ReplicatedStorage
local seedCollected=remotes:FindFirstChild("SeedCollected") or Instance.new("RemoteEvent"); seedCollected.Name="SeedCollected"; seedCollected.Parent=remotes
local exploreEvent=remotes:FindFirstChild("ExploreEvent") or Instance.new("RemoteEvent"); exploreEvent.Name="ExploreEvent"; exploreEvent.Parent=remotes
local collectionStore=DataStoreService:GetDataStore("GrowAVerity_Collection_v1")
local seedFolder=workspace:WaitForChild("World"):WaitForChild("GuardianWilds"):FindFirstChild("SeedSpawns") or Instance.new("Folder")
seedFolder.Name="SeedSpawns"; seedFolder.Parent=workspace.World.GuardianWilds

local pads={
    {Vector3.new(-105,1,820),"Verity",.55,false},
    {Vector3.new(-70,1,835),"Falsity",.42,false},
    {Vector3.new(-30,1,850),"Lovity",.22,false},
    {Vector3.new(28,1,845),"Verity",.55,false},
    {Vector3.new(72,1,860),"Falsity",.42,false},
    {Vector3.new(105,1,875),"Cruelty",.12,true},
    {Vector3.new(-108,1,955),"Falsity",.42,false},
    {Vector3.new(-58,1,980),"Lovity",.22,false},
    {Vector3.new(12,1,975),"Cruelty",.12,true},
    {Vector3.new(65,1,955),"Verity",.55,false},
    {Vector3.new(105,1,980),"Lovity",.22,false},
    {Vector3.new(-5,1,1020),"Cruelty",.10,true},
}
local live={}
local function count(p,n) return tonumber(p:GetAttribute("SeedCount_"..n)) or (p:GetAttribute("Seed_"..n) and 1 or 0) end
local function collect(p,variant,protected)
    if protected and not p:GetAttribute("Variety_"..variant) then
        seedCollected:FireClient(p,false,"Defeat the "..variant.." Guardian first.")
        return
    end
    local n=count(p,variant)+1
    p:SetAttribute("SeedCount_"..variant,n); p:SetAttribute("Seed_"..variant,true); p:SetAttribute("Variety_"..variant,p:GetAttribute("Variety_"..variant)==true)
    pcall(function() collectionStore:UpdateAsync("p_"..p.UserId,function(old) old=type(old)=="table" and old or {}; old[variant]=true; return old end) end)
    seedCollected:FireClient(p,true,"+"..variant.." Seed")
end
local function spawnAt(i)
    if live[i] then return end
    local pad=workspace.World.GuardianWilds.SeedSpawnPads and workspace.World.GuardianWilds.SeedSpawnPads:FindFirstChild("Pad_"..i)
    local data=pads[i]; if not pad or not data then return end
    if math.random()>data[3] then return end
    local model=Instance.new("Model"); model.Name="Seed_"..data[2]; model:SetAttribute("SpawnIndex",i); model:SetAttribute("VariantName",data[2]); model.Parent=seedFolder
    local core=Instance.new("Part"); core.Name="Seed"; core.Shape=Enum.PartType.Ball; core.Size=Vector3.new(.9,.9,.9); core.Position=pad.Position+Vector3.new(0,1.1,0)
    core.Anchored=true; core.CanCollide=false; core.Material=Enum.Material.Neon; core.Color=Variants[data[2]].Color; core.Parent=model
    model.PrimaryPart=core
    local bill=Instance.new("BillboardGui"); bill.Size=UDim2.fromOffset(150,42); bill.StudsOffset=Vector3.new(0,1.6,0); bill.AlwaysOnTop=true; bill.Parent=core
    local t=Instance.new("TextLabel"); t.Size=UDim2.fromScale(1,1); t.BackgroundTransparency=1; t.Text=data[2].." SEED"; t.TextColor3=Color3.fromRGB(250,247,235); t.Font=Enum.Font.GothamBlack; t.TextScaled=true; t.Parent=bill
    local pr=Instance.new("ProximityPrompt"); pr.ActionText="Collect Seed"; pr.ObjectText=data[2].." • "..Variants[data[2]].SeedRarity; pr.MaxActivationDistance=10; pr.RequiresLineOfSight=false; pr.Parent=core
    live[i]=model
    pr.Triggered:Connect(function(p)
        if live[i]~=model then return end
        collect(p,data[2],data[4]); live[i]=nil; model:Destroy()
    end)
    task.delay(80,function() if live[i]==model then live[i]=nil; model:Destroy() end end)
end
local padsFolder=workspace.World.GuardianWilds:FindFirstChild("SeedSpawnPads") or Instance.new("Folder"); padsFolder.Name="SeedSpawnPads"; padsFolder.Parent=workspace.World.GuardianWilds
for i,data in ipairs(pads) do
    local p=padsFolder:FindFirstChild("Pad_"..i) or Instance.new("Part"); p.Name="Pad_"..i; p.Size=Vector3.new(5,.2,5); p.Position=data[1]; p.Anchored=true; p.CanCollide=false; p.Transparency=.65; p.Material=Enum.Material.Grass; p.Color=Variants[data[2]].Color; p.Parent=padsFolder
end
task.spawn(function()
    while true do
        task.wait(12)
        for i=1,#pads do spawnAt(i) end
    end
end)
task.spawn(function()
    while true do
        task.wait(90)
        local rare={6,9,12}; local i=rare[math.random(1,#rare)]; if not live[i] then spawnAt(i) end
        exploreEvent:FireAllClients("RARE SEED SURGE","A rare Guardian seed has appeared somewhere in the Wilds.")
    end
end)
