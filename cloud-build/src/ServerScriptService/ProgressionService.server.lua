local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")

local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes"; remotes.Parent=ReplicatedStorage
local progressUpdate=remotes:FindFirstChild("ProgressionUpdate") or Instance.new("RemoteEvent")
progressUpdate.Name="ProgressionUpdate"; progressUpdate.Parent=remotes

local award=ReplicatedStorage:FindFirstChild("ProgressionAward")
if not award then award=Instance.new("BindableEvent"); award.Name="ProgressionAward"; award.Parent=ReplicatedStorage end

local store=DataStoreService:GetDataStore("GrowAVerity_Progression_v1")
local playerStore=DataStoreService:GetDataStore("GrowAVerity_Player_v1")
local active={}

local function levelForXP(xp)
    local level=1
    local need=100
    local remaining=xp
    while remaining>=need and level<50 do
        remaining-=need
        level+=1
        need=math.floor(100*(1.18^(level-1)))
    end
    return level,remaining,need
end

local function snapshot(p)
    local s=active[p] or {XP=0,Level=1}
    local level,into,nextNeed=levelForXP(s.XP)
    s.Level=level
    p:SetAttribute("ProgressXP",s.XP)
    p:SetAttribute("ProgressLevel",level)
    p:SetAttribute("GardenLevel",math.max(p:GetAttribute("GardenLevel") or 1,1))
    p:SetAttribute("ExploreMeadowUnlocked",true)
    p:SetAttribute("ExploreBluewoodUnlocked",level>=2)
    p:SetAttribute("ExploreRedstoneUnlocked",level>=4)
    p:SetAttribute("ExploreLoveGardenUnlocked",level>=6)
    p:SetAttribute("ExploreHiddenGroveUnlocked",level>=8)
    progressUpdate:FireClient(p,{XP=s.XP,Level=level,Into=into,Next=nextNeed})
end

local function save(p)
    local s=active[p]
    if not s then return end
    pcall(function() store:SetAsync("p_"..p.UserId,{XP=s.XP}) end)
end

local function load(p)
    local data
    pcall(function() data=store:GetAsync("p_"..p.UserId) end)
    local xp=type(data)=="table" and tonumber(data.XP) or 0
    active[p]={XP=math.max(0,math.floor(xp))}
    snapshot(p)
end

local function awardXP(p,amount,source)
    if not p or not p.Parent then return end
    amount=math.max(0,math.floor(tonumber(amount) or 0))
    if amount<=0 then return end
    local s=active[p]; if not s then return end
    local before=s.Level
    s.XP+=amount
    snapshot(p)
    if s.Level>before then
        local bonus=100*(s.Level-before)
        local newCash=(tonumber(p:GetAttribute("Cash")) or 0)+bonus
        p:SetAttribute("Cash",newCash)
        pcall(function() playerStore:UpdateAsync("p_"..p.UserId,function(old) old=type(old)=="table" and old or {}; old.Cash=newCash; return old end) end)
        progressUpdate:FireClient(p,{LevelUp=true,Level=s.Level,BonusCash=bonus,Source=source})
    end
    task.spawn(function() save(p) end)
end

award.Event:Connect(function(p,source,variety)
    if not active[p] then return end
    local rarityXP={Common=35,Uncommon=55,Rare=80,Epic=120,Legendary=180,Mythic=260}
    local variants=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
    local d=variants[variety]
    local xp=(d and rarityXP[d.Rarity]) or 40
    if source=="Harvest" then xp=math.floor(xp*.75) end
    awardXP(p,xp,source)
end)

Players.PlayerAdded:Connect(function(p) task.spawn(load,p) end)
Players.PlayerRemoving:Connect(function(p) save(p); active[p]=nil end)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(load,p) end

task.spawn(function()
    while true do
        task.wait(60)
        for p in pairs(active) do if p.Parent then task.spawn(save,p) end end
    end
end)
