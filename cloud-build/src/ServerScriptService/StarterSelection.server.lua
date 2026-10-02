local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local defs=require(ReplicatedStorage:WaitForChild("BattleDefinitions"))
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder") remotes.Name="GameRemotes" remotes.Parent=ReplicatedStorage
local selectStarter=remotes:FindFirstChild("SelectStarter") or Instance.new("RemoteEvent") selectStarter.Name="SelectStarter" selectStarter.Parent=remotes
local store=DataStoreService:GetDataStore("GrowAVerity_Player_v1")
local collection=DataStoreService:GetDataStore("GrowAVerity_Collection_v1")
local function load(p)
 local ok,d=pcall(function() return store:GetAsync("p_"..p.UserId) end)
 if ok and type(d)=="table" then p:SetAttribute("StarterChosen",d.StarterChosen==true); if type(d.Starter)=="string" and defs[d.Starter] then p:SetAttribute("StarterVariety",d.Starter) end; p:SetAttribute("Cash",tonumber(d.Cash) or 250)
 else p:SetAttribute("StarterChosen",false); p:SetAttribute("Cash",250) end
end
local function save(p)
 local starter=p:GetAttribute("StarterVariety"); local cash=tonumber(p:GetAttribute("Cash")) or 0
 pcall(function() store:UpdateAsync("p_"..p.UserId,function(old) old=type(old)=="table" and old or {}; if type(starter)=="string" and defs[starter] then old.Starter=starter; old.StarterChosen=true end; old.Cash=cash; return old end) end)
end
Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(save)
selectStarter.OnServerEvent:Connect(function(p,name)
 if p:GetAttribute("StarterChosen") or type(name)~="string" or not defs[name] then return end
 p:SetAttribute("StarterVariety",name); p:SetAttribute("StarterChosen",true); p:SetAttribute("Variety_"..name,true); p:SetAttribute("Seed_"..name,true); save(p)
 pcall(function() collection:UpdateAsync("p_"..p.UserId,function(old) old=type(old)=="table" and old or {}; old[name]=true; return old end) end)
end)