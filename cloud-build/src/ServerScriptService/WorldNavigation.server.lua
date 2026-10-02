local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder") remotes.Name="GameRemotes" remotes.Parent=ReplicatedStorage
local teleport=remotes:FindFirstChild("WorldTeleport") or Instance.new("RemoteEvent") teleport.Name="WorldTeleport" teleport.Parent=remotes
local plots={Vector3.new(-50,3,-42),Vector3.new(50,3,-42),Vector3.new(-50,3,0),Vector3.new(50,3,0),Vector3.new(-50,3,42),Vector3.new(50,3,42)}
local assigned={}
local function garden(player) if not assigned[player] then assigned[player]=(player.UserId%#plots)+1 player:SetAttribute("GardenIndex",assigned[player]) end return plots[assigned[player]] end
local function tp(player,pos) local ch=player.Character local root=ch and ch:FindFirstChild("HumanoidRootPart") if root then root.CFrame=CFrame.new(pos) end end
Players.PlayerAdded:Connect(function(p) p:SetAttribute("GardenIndex",(p.UserId%#plots)+1) end)
Players.PlayerRemoving:Connect(function(p) assigned[p]=nil end)
teleport.OnServerEvent:Connect(function(player,dest)
    if dest=="Garden" then tp(player,garden(player))
    elseif dest=="Explore" then tp(player,Vector3.new(0,3,912))
    elseif dest=="Spawn" then tp(player,Vector3.new(0,3,-70)) end
end)