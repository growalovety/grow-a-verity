local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function panel(titleText)
    local gui=pg:FindFirstChild("GameHUD")
    if not gui then return end
    local old=gui:FindFirstChild("DirectPanel"); if old then old:Destroy() end
    local p=Instance.new("Frame"); p.Name="DirectPanel"; p.Size=UDim2.fromOffset(820,520); p.Position=UDim2.new(.5,-410,.5,-260); p.BackgroundColor3=Color3.fromRGB(18,25,34); p.ZIndex=5000; p.Parent=gui
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-100,0,70); t.Position=UDim2.fromOffset(25,15); t.BackgroundTransparency=1; t.Text=titleText; t.TextColor3=Color3.new(1,1,1); t.Font=Enum.Font.GothamBlack; t.TextScaled=true; t.ZIndex=5001; t.Parent=p
    local x=Instance.new("TextButton"); x.Size=UDim2.fromOffset(55,55); x.Position=UDim2.new(1,-75,0,15); x.Text="X"; x.TextScaled=true; x.ZIndex=5002; x.Parent=p; x.MouseButton1Click:Connect(function() p:Destroy() end)
    local list=Instance.new("TextLabel"); list.Size=UDim2.new(1,-50,1,-110); list.Position=UDim2.fromOffset(25,90); list.BackgroundColor3=Color3.fromRGB(27,36,48); list.Text=""; list.ZIndex=5001; list.Parent=p
    local names={"Verity","Falsity","Lovity","Cruelty","Hopeity","Nullity"}
    list.Text=table.concat(names,"     •     ").."

Panel is active."
    list.TextColor3=Color3.fromRGB(230,235,245); list.Font=Enum.Font.GothamBold; list.TextScaled=true
end

task.spawn(function()
    local ov=pg:WaitForChild("HUDInputOverlay",15)
    if not ov then return end
    ov.Cards.MouseButton1Click:Connect(function() panel("CARDS") end)
    ov.Seeds.MouseButton1Click:Connect(function() panel("SEEDS") end)
    ov.Deck.MouseButton1Click:Connect(function() panel("DECK") end)
end)
