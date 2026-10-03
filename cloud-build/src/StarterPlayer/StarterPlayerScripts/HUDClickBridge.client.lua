local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local function bind()
    local gui=pg:FindFirstChild("GameHUD")
    local top=gui and gui:FindFirstChild("TopBar")
    local nav=top and top:FindFirstChild("Nav")
    if not nav then return end
    local remotes=ReplicatedStorage:FindFirstChild("GameRemotes")
    local teleport=remotes and remotes:FindFirstChild("WorldTeleport")
    local map={
        Garden=function() if teleport then teleport:FireServer("Garden") end end,
        Explore=function() if teleport then teleport:FireServer("Explore") end end,
        Cards=function() if _G.GrowAVerityOpenCards then _G.GrowAVerityOpenCards() end end,
        Seeds=function() if _G.GrowAVerityOpenSeeds then _G.GrowAVerityOpenSeeds() end end,
        Deck=function() if _G.GrowAVerityOpenDeck then _G.GrowAVerityOpenDeck() end end,
        Settings=function() if _G.GrowAVerityOpenSettings then _G.GrowAVerityOpenSettings() end end,
    }
    for name,fn in pairs(map) do
        local b=(name=="Settings" and top:FindFirstChild(name)) or nav:FindFirstChild(name)
        if b and b:IsA("GuiButton") and not b:GetAttribute("RealHUDBound") then
            b:SetAttribute("RealHUDBound",true)
            b.Active=true
            b.Activated:Connect(function() pcall(fn) end)
        end
    end
end
task.spawn(function()
    while player.Parent do bind(); task.wait(.5) end
end)
