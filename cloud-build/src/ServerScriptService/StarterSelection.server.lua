local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local BattleDefinitions = require(ReplicatedStorage:WaitForChild("BattleDefinitions"))

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name = "GameRemotes"
remotes.Parent = ReplicatedStorage

local selectStarter = remotes:FindFirstChild("SelectStarter") or Instance.new("RemoteEvent")
selectStarter.Name = "SelectStarter"
selectStarter.Parent = remotes

local starterStore = DataStoreService:GetDataStore("GrowAVerity_Player_v1")

local function loadProfile(player)
    local ok, data = pcall(function()
        return starterStore:GetAsync("p_" .. player.UserId)
    end)

    if ok and type(data) == "table" then
        player:SetAttribute("StarterChosen", data.StarterChosen == true)
        if type(data.Starter) == "string" and BattleDefinitions[data.Starter] then
            player:SetAttribute("StarterVariety", data.Starter)
        end
    else
        player:SetAttribute("StarterChosen", false)
    end
end

local function saveProfile(player)
    local starter = player:GetAttribute("StarterVariety")
    if type(starter) ~= "string" or not BattleDefinitions[starter] then
        return
    end

    pcall(function()
        starterStore:UpdateAsync("p_" .. player.UserId, function(old)
            old = type(old) == "table" and old or {}
            old.Starter = starter
            old.StarterChosen = true
            return old
        end)
    end)
end

Players.PlayerAdded:Connect(function(player)
    loadProfile(player)
end)

Players.PlayerRemoving:Connect(saveProfile)

selectStarter.OnServerEvent:Connect(function(player, varietyName)
    if player:GetAttribute("StarterChosen") then
        return
    end

    if type(varietyName) ~= "string" or not BattleDefinitions[varietyName] then
        return
    end

    player:SetAttribute("StarterVariety", varietyName)
    player:SetAttribute("StarterChosen", true)
    saveProfile(player)
end)
