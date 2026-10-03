local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function bind(gui)
    local top=gui:FindFirstChild("TopBar")
    if not top then return end
    for _,name in ipairs({"Garden","Explore","Cards","Seeds","Deck","Settings"}) do
        local b=top:FindFirstChild(name,true)
        if b and b:IsA("GuiButton") and not b:GetAttribute("BridgeBound") then
            b:SetAttribute("BridgeBound",true)
            b.Active=true
            b.MouseButton1Click:Connect(function()
                if name=="Cards" or name=="Seeds" or name=="Deck" or name=="Settings" then
                    local old=gui:FindFirstChild("BridgePanel")
                    if old then old:Destroy() end
                    local p=Instance.new("Frame")
                    p.Name="BridgePanel"; p.Size=UDim2.fromOffset(650,360); p.Position=UDim2.new(.5,-325,.5,-180)
                    p.BackgroundColor3=Color3.fromRGB(25,33,44); p.ZIndex=1000; p.Parent=gui
                    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-80,0,70); t.Position=UDim2.fromOffset(24,20)
                    t.BackgroundTransparency=1; t.Text=string.upper(name); t.TextColor3=Color3.new(1,1,1)
                    t.Font=Enum.Font.GothamBlack; t.TextScaled=true; t.ZIndex=1001; t.Parent=p
                    local x=Instance.new("TextButton"); x.Size=UDim2.fromOffset(50,50); x.Position=UDim2.new(1,-65,0,15)
                    x.Text="X"; x.TextScaled=true; x.ZIndex=1002; x.Parent=p
                    x.MouseButton1Click:Connect(function() p:Destroy() end)
                end
            end)
        end
    end
end

task.spawn(function()
    while player.Parent do
        local gui=pg:FindFirstChild("GameHUD")
        if gui then bind(gui) end
        task.wait(.5)
    end
end)
