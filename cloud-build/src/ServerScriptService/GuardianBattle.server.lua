local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local DataStoreService = game:GetService("DataStoreService")

local BattleDefinitions = require(ReplicatedStorage:WaitForChild("BattleDefinitions"))

local remotes = ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name = "GameRemotes"
remotes.Parent = ReplicatedStorage

local startBattle = remotes:FindFirstChild("StartBattle") or Instance.new("RemoteEvent")
startBattle.Name = "StartBattle"
startBattle.Parent = remotes

local battleAction = remotes:FindFirstChild("BattleAction") or Instance.new("RemoteEvent")
battleAction.Name = "BattleAction"
battleAction.Parent = remotes

local battleUpdate = remotes:FindFirstChild("BattleUpdate") or Instance.new("RemoteEvent")
battleUpdate.Name = "BattleUpdate"
battleUpdate.Parent = remotes

local battleEnd = remotes:FindFirstChild("BattleEnd") or Instance.new("RemoteEvent")
battleEnd.Name = "BattleEnd"
battleEnd.Parent = remotes

local collectionStore = DataStoreService:GetDataStore("GrowAVerity_Collection_v1")
local active = {}

local GuardianStats = {
    Verity = {HP = 105, Attack = 18, Defense = 18},
    Falsity = {HP = 105, Attack = 21, Defense = 15},
    Lovity = {HP = 110, Attack = 17, Defense = 19},
}

local function loadCollection(player)
    local ok, data = pcall(function()
        return collectionStore:GetAsync("p_" .. player.UserId)
    end)
    if not ok or type(data) ~= "table" then
        return
    end

    for name, owned in pairs(data) do
        if owned == true and BattleDefinitions[name] then
            player:SetAttribute("Variety_" .. name, true)
            player:SetAttribute("Seed_" .. name, true)
        end
    end
end

local function saveCollection(player)
    local data = {}
    for name in pairs(BattleDefinitions) do
        if player:GetAttribute("Variety_" .. name) then
            data[name] = true
        end
    end

    pcall(function()
        collectionStore:SetAsync("p_" .. player.UserId, data)
    end)
end

Players.PlayerAdded:Connect(loadCollection)
Players.PlayerRemoving:Connect(function(player)
    active[player] = nil
    saveCollection(player)
end)

local function distanceOk(player, model)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local target = model and model.PrimaryPart
    return root and target and (root.Position - target.Position).Magnitude <= 16
end

local function sendState(player)
    local state = active[player]
    if not state then
        return
    end
    battleUpdate:FireClient(player, {
        PlayerHP = state.PlayerHP,
        PlayerMaxHP = state.PlayerMaxHP,
        EnemyHP = state.EnemyHP,
        EnemyMaxHP = state.EnemyMaxHP,
        EnemyName = state.EnemyName,
        CanAct = state.CanAct,
    })
end

local function endBattle(player, won)
    local state = active[player]
    if not state then
        return
    end

    active[player] = nil

    if won then
        local name = state.EnemyName
        player:SetAttribute("Variety_" .. name, true)
        player:SetAttribute("Seed_" .. name, true)
        task.spawn(function()
            saveCollection(player)
        end)
    end

    battleEnd:FireClient(player, won, state.EnemyName)
end

local function beginBattle(player, guardianModel)
    if active[player] then
        return
    end
    if not player:GetAttribute("StarterChosen") then
        return
    end
    if not distanceOk(player, guardianModel) then
        return
    end

    local name = guardianModel:GetAttribute("VarietyName")
    local enemy = name and GuardianStats[name]
    local starterName = player:GetAttribute("StarterVariety")
    local starter = starterName and BattleDefinitions[starterName]
    if not enemy or not starter then
        return
    end

    active[player] = {
        EnemyName = name,
        EnemyHP = enemy.HP,
        EnemyMaxHP = enemy.HP,
        EnemyAttack = enemy.Attack,
        EnemyDefense = enemy.Defense,
        PlayerHP = starter.HP,
        PlayerMaxHP = starter.HP,
        PlayerAttack = starter.Attack,
        PlayerDefense = starter.Defense,
        Role = starter.Role,
        Guard = false,
        CanAct = true,
    }

    startBattle:FireClient(player, name, starterName)
    sendState(player)
end

ProximityPromptService.PromptTriggered:Connect(function(prompt, player)
    if prompt.Name ~= "BattlePrompt" then
        return
    end
    local guardian = prompt:FindFirstAncestorOfClass("Model")
    if guardian then
        beginBattle(player, guardian)
    end
end)

battleAction.OnServerEvent:Connect(function(player, action)
    local state = active[player]
    if not state or not state.CanAct then
        return
    end
    if action ~= "Attack" and action ~= "Skill" and action ~= "Guard" then
        return
    end

    state.CanAct = false

    if action == "Attack" then
        local damage = math.max(5, math.floor(state.PlayerAttack - state.EnemyDefense * 0.35))
        state.EnemyHP = math.max(0, state.EnemyHP - damage)
    elseif action == "Skill" then
        if state.Role == "Guardian" then
            state.Guard = true
        elseif state.Role == "Striker" then
            local damage = math.max(8, math.floor(state.PlayerAttack + 10 - state.EnemyDefense * 0.25))
            state.EnemyHP = math.max(0, state.EnemyHP - damage)
        else
            state.PlayerHP = math.min(state.PlayerMaxHP, state.PlayerHP + 24)
        end
    elseif action == "Guard" then
        state.Guard = true
    end

    if state.EnemyHP <= 0 then
        endBattle(player, true)
        return
    end

    task.wait(0.45)

    local damage = math.max(4, math.floor(state.EnemyAttack - state.PlayerDefense * 0.3))
    if state.Guard then
        damage = math.floor(damage * 0.45)
        state.Guard = false
    end
    state.PlayerHP = math.max(0, state.PlayerHP - damage)

    if state.PlayerHP <= 0 then
        endBattle(player, false)
        return
    end

    state.CanAct = true
    sendState(player)
end)
