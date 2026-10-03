local Players=game:GetService("Players")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function openPanel(mode)
    local gui=pg:FindFirstChild("GameHUD")
    if not gui then return end
    local old=gui:FindFirstChild("DirectPanel")
    if old then old:Destroy() end

    local panel=Instance.new("Frame")
    panel.Name="DirectPanel"
    panel.Size=UDim2.fromOffset(820,520)
    panel.Position=UDim2.new(.5,-410,.5,-260)
    panel.BackgroundColor3=Color3.fromRGB(18,25,34)
    panel.BorderSizePixel=0
    panel.Active=true
    panel.ZIndex=5000
    panel.Parent=gui

    local title=Instance.new("TextLabel")
    title.Size=UDim2.new(1,-100,0,65)
    title.Position=UDim2.fromOffset(25,15)
    title.BackgroundTransparency=1
    title.Text=mode=="Cards" and "CARDS" or mode=="Seeds" and "SEEDS" or "DECK"
    title.TextColor3=Color3.new(1,1,1)
    title.Font=Enum.Font.GothamBlack
    title.TextScaled=true
    title.ZIndex=5001
    title.Parent=panel

    local close=Instance.new("TextButton")
    close.Size=UDim2.fromOffset(55,55)
    close.Position=UDim2.new(1,-75,0,15)
    close.BackgroundColor3=Color3.fromRGB(170,180,190)
    close.Text="X"
    close.TextColor3=Color3.fromRGB(20,28,38)
    close.Font=Enum.Font.GothamBlack
    close.TextScaled=true
    close.ZIndex=5002
    close.Parent=panel
    close.MouseButton1Click:Connect(function() panel:Destroy() end)

    local names={"Verity","Falsity","Lovity","Cruelty","Hopeity","Nullity"}
    local descriptions={
        Verity="COMMON • TANK / BARRIER",
        Falsity="COMMON • ATTACKER / CONTROL",
        Lovity="COMMON • HEALER / SUPPORT",
        Cruelty="RARE • ATTACKER / DOT",
        Hopeity="LEGENDARY • SUPPORT / BUFF",
        Nullity="MYTHIC • CONTROL / DRAIN"
    }

    local list=Instance.new("ScrollingFrame")
    list.Size=UDim2.new(1,-50,1,-105)
    list.Position=UDim2.fromOffset(25,90)
    list.BackgroundColor3=Color3.fromRGB(27,36,48)
    list.BorderSizePixel=0
    list.ScrollBarThickness=7
    list.ZIndex=5001
    list.Parent=panel

    local layout=Instance.new("UIGridLayout")
    layout.CellSize=UDim2.fromOffset(245,125)
    layout.CellPadding=UDim2.fromOffset(12,12)
    layout.Parent=list

    for _,n in ipairs(names) do
        local card=Instance.new("TextButton")
        card.Size=UDim2.fromOffset(245,125)
        card.BackgroundColor3=Color3.fromRGB(38,50,66)
        card.Text=n.."
"..(mode=="Seeds" and "SEEDS" or descriptions[n])
        card.TextColor3=Color3.new(1,1,1)
        card.Font=Enum.Font.GothamBold
        card.TextScaled=true
        card.ZIndex=5002
        card.Parent=list
    end
    list.CanvasSize=UDim2.fromOffset(0,275)
end

local function bind()
    local gui=pg:FindFirstChild("GameHUD")
    local top=gui and gui:FindFirstChild("TopBar")
    local nav=top and top:FindFirstChild("Nav")
    if not nav then return end
    for _,mode in ipairs({"Cards","Seeds","Deck"}) do
        local b=nav:FindFirstChild(mode)
        if b and b:IsA("GuiButton") then
            b.Active=true
            if not b:GetAttribute("DirectPanelBound") then
                b:SetAttribute("DirectPanelBound",true)
                b.MouseButton1Click:Connect(function() openPanel(mode) end)
            end
        end
    end
end

task.spawn(function()
    while player.Parent do
        bind()
        task.wait(0.25)
    end
end)
