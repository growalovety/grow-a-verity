local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local RunService=game:GetService("RunService")
local world=workspace:WaitForChild("World"); local starter=world:WaitForChild("StarterGrove"); local wilds=world:WaitForChild("GuardianWilds")
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder"); remotes.Name="GameRemotes"; remotes.Parent=ReplicatedStorage
local teleport=remotes:FindFirstChild("WorldTeleport") or Instance.new("RemoteEvent"); teleport.Name="WorldTeleport"; teleport.Parent=remotes
local slotStore=DataStoreService:GetDataStore("GrowAVerity_GardenSlots_v1")
local plots={Vector3.new(-62,3,-52),Vector3.new(62,3,-52),Vector3.new(-62,3,0),Vector3.new(62,3,0),Vector3.new(-62,3,52),Vector3.new(62,3,52)}
local plotFolders={}; for i=1,#plots do plotFolders[i]=starter:FindFirstChild("Plot_"..i) end
local assigned={}
local function setPlotLabel(plot,name)
    local marker=plot and plot:FindFirstChild("PlotMarker"); local g=marker and marker:FindFirstChildOfClass("BillboardGui"); local l=g and g:FindFirstChildOfClass("TextLabel"); if l then l.Text=name end
end
local function persist(player,index) pcall(function() slotStore:SetAsync("p_"..player.UserId,index) end) end
local function claimPlot(player)
    if assigned[player] then return assigned[player] end
    local saved; pcall(function() saved=slotStore:GetAsync("p_"..player.UserId) end)
    local preferred=tonumber(saved); local index
    if preferred and preferred>=1 and preferred<=#plots and not assigned[preferred] then index=preferred end
    if not index then
        local start=(player.UserId%#plots)+1
        for offset=0,#plots-1 do local i=((start+offset-1)%#plots)+1; if not assigned[i] then index=i; break end end
    end
    if not index then return nil end
    assigned[player]=index; assigned[index]=player; player:SetAttribute("GardenIndex",index); persist(player,index)
    local plot=plotFolders[index]
    if plot then plot.Name="Garten von "..player.Name; plot:SetAttribute("OwnerUserId",player.UserId); plot:SetAttribute("OwnerName",player.Name); setPlotLabel(plot,"GARTEN VON "..player.Name) end
    return index
end
local function releasePlot(player)
    local i=assigned[player]; if not i then return end
    assigned[player]=nil; assigned[i]=nil
    local plot=plotFolders[i]; if plot then plot.Name="Plot_"..i; plot:SetAttribute("OwnerUserId",nil); plot:SetAttribute("OwnerName",nil); setPlotLabel(plot,"GARDEN "..i) end
end
local function tp(player,pos) local ch=player.Character; local root=ch and ch:FindFirstChild("HumanoidRootPart"); if root then root.CFrame=CFrame.new(pos); root.AssemblyLinearVelocity=Vector3.zero end end
local function garden(player) local i=claimPlot(player); return i and plots[i] or Vector3.new(0,3,-100) end
local function onPlayerAdded(player)
    claimPlot(player)
    player.CharacterAdded:Connect(function(character) task.wait(.15); local root=character:FindFirstChild("HumanoidRootPart"); if root then root.CFrame=CFrame.new(Vector3.new(0,4,-100)) end end)
end
for _,p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded); Players.PlayerRemoving:Connect(releasePlot)
teleport.OnServerEvent:Connect(function(player,dest)
    if dest=="Garden" then tp(player,garden(player))
    elseif dest=="Explore" then tp(player,Vector3.new(0,4,912))
    elseif dest=="Spawn" then tp(player,Vector3.new(0,4,-100)) end
end)
local conveyors={}; for _,obj in ipairs(starter:GetDescendants()) do if obj:IsA("BasePart") and obj.Name=="Conveyor" then table.insert(conveyors,obj) end end
local function onConveyor(root)
    local p=root.Position
    for _,belt in ipairs(conveyors) do
        local bp=belt.Position
        if math.abs(p.X-bp.X)<(belt.Size.X/2+2) and p.Z>bp.Z-belt.Size.Z/2 and p.Z<bp.Z+belt.Size.Z/2 and p.Y>bp.Y-.5 and p.Y<bp.Y+5 then
            local dir=belt:GetAttribute("ConveyorDirection") or 1; local speed=belt:GetAttribute("ConveyorSpeed") or 30; local v=root.AssemblyLinearVelocity
            root.AssemblyLinearVelocity=Vector3.new(v.X,v.Y,dir*math.max(speed,math.abs(v.Z))); return true
        end
    end
    return false
end
local function safeClamp(player,root)
    local p=root.Position; local inMain=math.abs(p.X)<=123 and p.Z>=-123 and p.Z<=123; local inWild=math.abs(p.X)<=143 and p.Z>=771 and p.Z<=1029
    if p.Y<-8 or p.Y>85 or (not inMain and not inWild) then
        local i=player:GetAttribute("GardenIndex"); tp(player,i and plots[i] or Vector3.new(0,3,-100))
    end
end
RunService.Heartbeat:Connect(function()
    for _,player in ipairs(Players:GetPlayers()) do
        local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart")
        if root then
            if not onConveyor(root) then
                local v=root.AssemblyLinearVelocity
                if math.abs(v.Z)>17 and math.abs(v.X)<8 then root.AssemblyLinearVelocity=Vector3.new(v.X,v.Y,math.clamp(v.Z,-12,12)) end
            end
            safeClamp(player,root)
        end
    end
end)
