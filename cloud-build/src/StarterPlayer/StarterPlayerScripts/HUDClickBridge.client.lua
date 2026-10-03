local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")

local function getDefs()
    local variants={}
    local battles={}
    pcall(function() variants=require(ReplicatedStorage:WaitForChild("VariantDefinitions",10)) end)
    pcall(function() battles=require(ReplicatedStorage:WaitForChild("BattleDefinitions",10)) end)
    return variants,battles
end

local function openPanel(mode)
    local gui=pg:FindFirstChild("GameHUD")
    if not gui then return end
    local old=gui:FindFirstChild("RealHUDPanel")
    if old then old:Destroy() end

    local variants,battles=getDefs()
    local panel=Instance.new("Frame")
    panel.Name="RealHUDPanel"
    panel.Size=UDim2.fromOffset(900,590)
    panel.Position=UDim2.new(.5,-450,.5,-295)
    panel.BackgroundColor3=Color3.fromRGB(17,23,31)
    panel.ZIndex=2000
    panel.Parent=gui

    local title=Instance.new("TextLabel")
    title.Size=UDim2.new(1,-90,0,60)
    title.Position=UDim2.fromOffset(25,18)
    title.BackgroundTransparency=1
    title.Text=mode=="Cards" and "CARD INDEX" or mode=="Seeds" and "SEED INDEX" or "BUILD DECK"
    title.TextColor3=Color3.fromRGB(238,244,252)
    title.Font=Enum.Font.GothamBlack
    title.TextScaled=true
    title.ZIndex=2001
    title.Parent=panel

    local close=Instance.new("TextButton")
    close.Size=UDim2.fromOffset(50,50)
    close.Position=UDim2.new(1,-70,0,18)
    close.Text="X"
    close.TextScaled=true
    close.Font=Enum.Font.GothamBold
    close.ZIndex=2002
    close.Parent=panel
    close.MouseButton1Click:Connect(function() panel:Destroy() end)

    local list=Instance.new("ScrollingFrame")
    list.Size=UDim2.fromOffset(850,460)
    list.Position=UDim2.fromOffset(25,95)
    list.BackgroundColor3=Color3.fromRGB(25,33,44)
    list.ScrollBarThickness=6
    list.ZIndex=2001
    list.Parent=panel

    local layout=Instance.new("UIGridLayout")
    layout.CellSize=UDim2.fromOffset(260,135)
    layout.CellPadding=UDim2.fromOffset(10,10)
    layout.Parent=list

    local names={}
    for n in pairs(variants) do table.insert(names,n) end
    table.sort(names)

    local deckRemote=(ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")).Parent and (ReplicatedStorage:FindFirstChild("GameRemotes") and ReplicatedStorage.GameRemotes:FindFirstChild("DeckUpdate"))
    local currentDeck={}
    local attrDeck=player:GetAttribute("Deck")
    for _,n in ipairs(names) do
        local v=variants[n]
        local b=battles[n]
        local has=mode=="Seeds" and ((tonumber(player:GetAttribute("SeedCount_"..n)) or 0)>0 or player:GetAttribute("Seed_"..n)==true) or (player:GetAttribute("Variety_"..n)==true or player:GetAttribute("StarterVariety")==n)
        local card=Instance.new("TextButton")
        card.Size=UDim2.fromOffset(260,135)
        card.BackgroundColor3=has and Color3.fromRGB(34,44,58) or Color3.fromRGB(29,35,43)
        card.Text=""
        card.ZIndex=2002
        card.Parent=list
        local name=Instance.new("TextLabel")
        name.Size=UDim2.new(1,-20,0,38)
        name.Position=UDim2.fromOffset(10,8)
        name.BackgroundTransparency=1
        name.Text=has and n or "???"
        name.TextColor3=has and (v.Color or Color3.new(1,1,1)) or Color3.fromRGB(154,170,193)
        name.Font=Enum.Font.GothamBlack
        name.TextScaled=true
        name.ZIndex=2003
        name.Parent=card
        local info=Instance.new("TextLabel")
        info.Size=UDim2.new(1,-20,0,70)
        info.Position=UDim2.fromOffset(10,50)
        info.BackgroundTransparency=1
        info.Text=has and ((v.Rarity or "").." • "..(v.Role or "").."
"..(b and ("HP "..b.HP.."  ATK "..b.Attack.."  DEF "..b.Defense) or "")..(mode=="Seeds" and ("
Seeds: "..tostring(player:GetAttribute("SeedCount_"..n) or 0)) or "")) or "LOCKED"
        info.TextColor3=Color3.fromRGB(200,210,225)
        info.Font=Enum.Font.GothamBold
        info.TextScaled=true
        info.ZIndex=2003
        info.Parent=card
        if mode=="Deck" and has then
            card.MouseButton1Click:Connect(function()
                if deckRemote then deckRemote:FireServer({n}) end
            end)
        end
    end
    list.CanvasSize=UDim2.fromOffset(0,math.ceil(#names/3)*145)
end

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
        Cards=function() openPanel("Cards") end,
        Seeds=function() openPanel("Seeds") end,
        Deck=function() openPanel("Deck") end,
    }
    for name,fn in pairs(map) do
        local b=nav:FindFirstChild(name)
        if b and b:IsA("GuiButton") and not b:GetAttribute("RealHUDBound") then
            b:SetAttribute("RealHUDBound",true)
            b.Active=true
            b.MouseButton1Click:Connect(function() pcall(fn) end)
        end
    end
end

task.spawn(function()
    while player.Parent do
        bind()
        task.wait(.5)
    end
end)
