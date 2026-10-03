local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Variants=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
local store=DataStoreService:GetDataStore("GrowAVerity_Seeds_v1")
local pending={}
local function load(p)
    local data; pcall(function() data=store:GetAsync("p_"..p.UserId) end); data=type(data)=="table" and data or {}
    for n in pairs(Variants) do
        local c=math.max(0,math.floor(tonumber(data[n]) or 0))
        if c>0 then p:SetAttribute("SeedCount_"..n,c); p:SetAttribute("Seed_"..n,true) end
    end
end
local function save(p)
    local data={}
    for n in pairs(Variants) do data[n]=math.max(0,math.floor(tonumber(p:GetAttribute("SeedCount_"..n)) or (p:GetAttribute("Seed_"..n) and 1 or 0))) end
    pcall(function() store:SetAsync("p_"..p.UserId,data) end)
end
local function schedule(p)
    if pending[p] then return end; pending[p]=true
    task.delay(3,function() pending[p]=nil; if p.Parent then save(p) end end)
end
Players.PlayerAdded:Connect(function(p)
    task.spawn(function() load(p) end)
    for n in pairs(Variants) do p:GetAttributeChangedSignal("SeedCount_"..n):Connect(function() schedule(p) end) end
end)
Players.PlayerRemoving:Connect(function(p) pending[p]=nil; save(p) end)
