local Players=game:GetService("Players")
local UserInputService=game:GetService("UserInputService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function panel(titleText)
    local gui=pg:FindFirstChild("GameHUD")
    if not gui then return end
    local old=gui:FindFirstChild("DirectPanel"); if old then old:Destroy() end
    local p=Instance.new("Frame")
    p.Name="DirectPanel"; p.Size=UDim2.fromOffset(820,520); p.Position=UDim2.new(.5,-410,.5,-260)
    p.BackgroundColor3=Color3.fromRGB(18,25,34); p.ZIndex=5000; p.Parent=gui
    local t=Instance.new("TextLabel"); t.Size=UDim2.new(1,-100,0,70); t.Position=UDim2.fromOffset(25,15)
    t.BackgroundTransparency=1; t.Text=titleText; t.TextColor3=Color3.new(1,1,1); t.Font=Enum.Font.GothamBlack; t.TextScaled=true; t.ZIndex=5001; t.Parent=p
    local x=Instance.new("TextButton"); x.Size=UDim2.fromOffset(55,55); x.Position=UDim2.new(1,-75,0,15); x.Text="X"; x.TextScaled=true; x.ZIndex=5002; x.Parent=p
    x.MouseButton1Click:Connect(function() p:Destroy() end)
    local list=Instance.new("TextLabel"); list.Size=UDim2.new(1,-50,1,-110); list.Position=UDim2.fromOffset(25,90)
    list.BackgroundColor3=Color3.fromRGB(27,36,48); list.Text="Verity     •     Falsity     •     Lovity\n\nCruelty     •     Hopeity     •     Nullity\n\n"..titleText.." PANEL ACTIVE"
    list.TextColor3=Color3.fromRGB(230,235,245); list.Font=Enum.Font.GothamBold; list.TextScaled=true; list.ZIndex=5001; list.Parent=p
end

local function hit(button, pos)
    if not button or not button:IsA("GuiObject") or not button.Visible then return false end
    local a=button.AbsolutePosition
    local s=button.AbsoluteSize
    return pos.X>=a.X and pos.X<=a.X+s.X and pos.Y>=a.Y and pos.Y<=a.Y+s.Y
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local mouse=UserInputService:GetMouseLocation()
    local gui=pg:FindFirstChild("GameHUD")
    local top=gui and gui:FindFirstChild("TopBar")
    local nav=top and top:FindFirstChild("Nav")
    if not nav then return end
    for _,mode in ipairs({"Cards","Seeds","Deck"}) do
        if hit(nav:FindFirstChild(mode),mouse) then
            panel(string.upper(mode))
            return
        end
    end
end)
