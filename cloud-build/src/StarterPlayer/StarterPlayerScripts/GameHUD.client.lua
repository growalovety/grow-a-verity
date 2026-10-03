local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local gui=pg:WaitForChild("GameHUD",15)
if not gui then
    warn("[GameHUD] GameHUD ScreenGui was not found in PlayerGui")
    return
end
gui.Name="GameHUD"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=100
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Enabled=true

local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes"; remotes.Parent=ReplicatedStorage
local deckUpdate=remotes:FindFirstChild("DeckUpdate")
local Variants={}
local BattleDefinitions={}
do
    local ok,v=pcall(function() return require(ReplicatedStorage:WaitForChild("VariantDefinitions",10)) end)
    if ok and type(v)=="table" then Variants=v end
    local ok2,b=pcall(function() return require(ReplicatedStorage:WaitForChild("BattleDefinitions",10)) end)
    if ok2 and type(b)=="table" then BattleDefinitions=b end
end

task.spawn(function()
    while player.Parent do
        local current=player:FindFirstChildOfClass("PlayerGui")
        if current and gui.Parent~=current then gui.Parent=current end
        gui.Enabled=true
        task.wait(.5)
    end
end)
local BG=Color3.fromRGB(17,23,31); local PANEL=Color3.fromRGB(25,33,44); local PANEL2=Color3.fromRGB(34,44,58)
local TEXT=Color3.fromRGB(238,244,252); local MUTED=Color3.fromRGB(154,170,193); local ACCENT=Color3.fromRGB(88,180,239); local GREEN=Color3.fromRGB(76,199,139)
local GOLD=Color3.fromRGB(239,193,78)
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function stroke(o,c,t,w) local s=Instance.new("UIStroke"); s.Color=c; s.Transparency=t or 0; s.Thickness=w or 1; s.Parent=o end
local function label(p,txt,size,pos,color,font) local l=Instance.new("TextLabel"); l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=txt; l.TextColor3=color; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=p; return l end
local function button(p,txt,size,pos,bg,tc) local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=bg or PANEL; b.TextColor3=tc or TEXT; b.Text=txt; b.Font=Enum.Font.GothamBold; b.TextScaled=true; b.AutoButtonColor=true; b.Parent=p; corner(b,10); stroke(b,Color3.fromRGB(90,112,139),.55,1); return b end

local topbar=gui:WaitForChild("TopBar")
local cash=topbar:WaitForChild("Cash")
local levelBadge=topbar:WaitForChild("Level")
local nav=topbar:WaitForChild("Nav")
local garden=nav:WaitForChild("Garden")
local explore=nav:WaitForChild("Explore")
local cards=nav:WaitForChild("Cards")
local seeds=nav:WaitForChild("Seeds")
local deck=nav:WaitForChild("Deck")
local settings=topbar:WaitForChild("Settings")
local function updateProgressBadge() levelBadge.Text="LV "..tostring(player:GetAttribute("ProgressLevel") or 1) end
updateProgressBadge()
player:GetAttributeChangedSignal("ProgressLevel"):Connect(updateProgressBadge)
local function updateCash() cash.Text="$ "..tostring(player:GetAttribute("Cash") or 0) end
updateCash(); player:GetAttributeChangedSignal("Cash"):Connect(updateCash)

local overlay=Instance.new("Frame"); overlay.Size=UDim2.fromScale(1,1); overlay.BackgroundColor3=Color3.fromRGB(5,8,12); overlay.BackgroundTransparency=.28; overlay.Visible=false; overlay.Parent=gui
local panel=Instance.new("Frame"); panel.Size=UDim2.fromOffset(900,590); panel.Position=UDim2.new(.5,-450,.5,-295); panel.BackgroundColor3=BG; panel.Visible=false; panel.Parent=overlay; corner(panel,20); stroke(panel,ACCENT,.55,1.5)
local title=label(panel,"CARD INDEX",UDim2.fromOffset(360,44),UDim2.fromOffset(24,18),TEXT,Enum.Font.GothamBlack)
local progress=label(panel,"0 COLLECTED",UDim2.fromOffset(230,32),UDim2.fromOffset(24,58),MUTED,Enum.Font.GothamBold)
local close=button(panel,"×",UDim2.fromOffset(42,42),UDim2.new(1,-58,0,18),PANEL2,TEXT)
local search=Instance.new("TextBox"); search.Size=UDim2.fromOffset(250,38); search.Position=UDim2.new(1,-410,0,24); search.BackgroundColor3=PANEL; search.PlaceholderText="SEARCH"; search.Text=""; search.TextColor3=TEXT; search.PlaceholderColor3=MUTED; search.Font=Enum.Font.GothamBold; search.TextScaled=true; search.ClearTextOnFocus=false; search.Parent=panel; corner(search,9); stroke(search,Color3.fromRGB(90,112,139),.55,1)
local sort=button(panel,"SORT: NAME",UDim2.fromOffset(135,38),UDim2.new(1,-150,0,24),PANEL2,TEXT)

local listFrame=Instance.new("ScrollingFrame"); listFrame.Size=UDim2.fromOffset(500,445); listFrame.Position=UDim2.fromOffset(20,105); listFrame.BackgroundColor3=PANEL; listFrame.BorderSizePixel=0; listFrame.ScrollBarThickness=5; listFrame.Parent=panel; corner(listFrame,14)
local grid=Instance.new("UIGridLayout"); grid.CellSize=UDim2.fromOffset(150,190); grid.CellPadding=UDim2.fromOffset(10,10); grid.Parent=listFrame
local detail=Instance.new("Frame"); detail.Size=UDim2.fromOffset(350,445); detail.Position=UDim2.fromOffset(535,105); detail.BackgroundColor3=PANEL; detail.BorderSizePixel=0; detail.Parent=panel; corner(detail,14)
local detailTitle=label(detail,"",UDim2.new(1,-28,0,38),UDim2.fromOffset(14,12),TEXT,Enum.Font.GothamBlack)
local detailArt=Instance.new("ViewportFrame"); detailArt.Size=UDim2.fromOffset(150,150); detailArt.Position=UDim2.fromOffset(100,55); detailArt.BackgroundTransparency=1; detailArt.Parent=detail
local detailText=label(detail,"",UDim2.new(1,-28,0,205),UDim2.fromOffset(14,220),MUTED,Enum.Font.GothamBold); detailText.TextWrapped=true; detailText.TextXAlignment=Enum.TextXAlignment.Left; detailText.TextYAlignment=Enum.TextYAlignment.Top; detailText.TextSize=17

local mode="Cards"; local currentDeck={}; local searchText=""; local sortMode="Name"
local order={}
for n in pairs(Variants) do table.insert(order,n) end
table.sort(order,function(a,b)
    local rank={Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5,Mythic=6}
    local ra=rank[Variants[a].Rarity] or 99; local rb=rank[Variants[b].Rarity] or 99
    if ra==rb then return a<b end
    return ra<rb
end)
local rarityRank={Common=1,Uncommon=2,Rare=3,Epic=4,Legendary=5}
local function owned(n) return player:GetAttribute("Variety_"..n)==true or player:GetAttribute("StarterVariety")==n end
local function seedOwned(n) return player:GetAttribute("Seed_"..n)==true or (tonumber(player:GetAttribute("SeedCount_"..n)) or 0)>0 end
local function clear(parent) for _,c in ipairs(parent:GetChildren()) do if not c:IsA("UIGridLayout") then c:Destroy() end end end
local function makeModel(viewport,n,scale)
    viewport:ClearAllChildren()
    local def=BattleDefinitions[n]; if not def then return end
    local world=Instance.new("WorldModel"); world.Parent=viewport
    local m=Instance.new("Model"); m.Parent=world
    local body=Instance.new("Part"); body.Shape=Enum.PartType.Ball; body.Size=Vector3.new(4,4,4)*scale; body.Position=Vector3.new(0,0,0); body.Anchored=true; body.CanCollide=false; body.Material=Enum.Material.SmoothPlastic; body.Color=def.Accent; body.Parent=m
    local function f(size,pos,color,shape) local p=Instance.new("Part"); p.Size=size*scale; p.Position=pos*scale; p.Shape=shape or Enum.PartType.Ball; p.Anchored=true; p.CanCollide=false; p.Material=Enum.Material.SmoothPlastic; p.Color=color; p.Parent=m end
    f(Vector3.new(.5,.5,.5),Vector3.new(-.8,.3,-1.75),Color3.fromRGB(20,23,28)); f(Vector3.new(.5,.5,.5),Vector3.new(.8,.3,-1.75),Color3.fromRGB(20,23,28))
    if n=="Verity" then f(Vector3.new(1.5,2.3,.45),Vector3.new(0,.1,1.8),def.Accent,Enum.PartType.Block)
    elseif n=="Falsity" then f(Vector3.new(1.1,.55,1.7),Vector3.new(-1.8,.1,0),def.Accent,Enum.PartType.Wedge); f(Vector3.new(1.1,.55,1.7),Vector3.new(1.8,.1,0),def.Accent,Enum.PartType.Wedge)
    elseif n=="Cruelty" then f(Vector3.new(.65,2,.65),Vector3.new(-1.35,1.4,0),def.Accent,Enum.PartType.Wedge); f(Vector3.new(.65,2,.65),Vector3.new(1.35,1.4,0),def.Accent,Enum.PartType.Wedge)
    else f(Vector3.new(1.25,1.25,1.25),Vector3.new(-1.15,1.6,0),def.Accent); f(Vector3.new(1.25,1.25,1.25),Vector3.new(1.15,1.6,0),def.Accent) end
    local cam=Instance.new("Camera"); cam.CFrame=CFrame.new(Vector3.new(0,1,9*scale),Vector3.new(0,.4,0)); cam.Parent=viewport; viewport.CurrentCamera=cam
end
local function seedIcon(viewport,n)
    viewport:ClearAllChildren(); local v=Variants[n]; if not v then return end
    local world=Instance.new("WorldModel"); world.Parent=viewport
    local p=Instance.new("Part"); p.Shape=Enum.PartType.Ball; p.Size=Vector3.new(1.5,1.5,1.5); p.Position=Vector3.new(0,0,0); p.Anchored=true; p.CanCollide=false; p.Material=Enum.Material.Neon; p.Color=v.Color; p.Parent=world
    local leaf=Instance.new("Part"); leaf.Size=Vector3.new(.3,1.3,.65); leaf.Position=Vector3.new(.65,.7,0); leaf.Orientation=Vector3.new(0,0,-35); leaf.Anchored=true; leaf.CanCollide=false; leaf.Material=Enum.Material.Grass; leaf.Color=Color3.fromRGB(79,157,76); leaf.Parent=world
    local cam=Instance.new("Camera"); cam.CFrame=CFrame.new(Vector3.new(0,1,6),Vector3.new(0,.2,0)); cam.Parent=viewport; viewport.CurrentCamera=cam
end
local function matches(n)
    return searchText=="" or string.find(string.lower(n),string.lower(searchText),1,true)~=nil or string.find(string.lower(Variants[n].Rarity),string.lower(searchText),1,true)~=nil
end
local function sortedNames()
    local a={}; for _,n in ipairs(order) do if matches(n) then table.insert(a,n) end end
    table.sort(a,function(x,y)
        if sortMode=="Rarity" then
            local rx=rarityRank[Variants[x].Rarity] or 9; local ry=rarityRank[Variants[y].Rarity] or 9
            if rx==ry then return x<y end; return rx<ry
        elseif sortMode=="Collected" then
            if owned(x)~=owned(y) then return owned(x) end
            return x<y
        end
        return x<y
    end)
    return a
end
local function showDetail(n)
    local v=Variants[n]; local b=BattleDefinitions[n]
    detailTitle.Text=n
    detailArt.Visible=true
    if mode=="Seeds" then
        seedIcon(detailArt,n)
        local c=tonumber(player:GetAttribute("SeedCount_"..n)) or (seedOwned(n) and 1 or 0)
        detailText.Text="SEED • "..v.Rarity.."\n\nSource: "..v.SeedSource.."\nOwned: "..c.."\nGrowth: "..v.GrowthTime.."s\nHarvest: +"..v.HarvestValue.." Cash\nProduction cycle: "..v.ProductionTime.."s\n\nTags: "..table.concat(v.Tags,", ")
    elseif mode=="Deck" then
        makeModel(detailArt,n,1.15)
        detailText.Text=v.Rarity.." • "..v.Role.."\n\nHP "..b.HP.."   ATK "..b.Attack.."   DEF "..b.Defense.."\nEnergy "..b.Energy.."/"..b.MaxEnergy.."\n\nTAGS\n"..table.concat(b.Tags,"  •  ").."\n\nSKILLS\n"..b.AttackName.."\n"..b.SkillName.." — "..b.SkillDescription.."\n"..b.GuardName
    else
        makeModel(detailArt,n,1.15)
        detailText.Text=v.Rarity.." • "..b.Role.."\n\nHP "..b.HP.."   ATK "..b.Attack.."   DEF "..b.Defense.."\nEnergy "..b.Energy.."/"..b.MaxEnergy.."\n\nTAGS\n"..table.concat(b.Tags,"  •  ").."\n\nSKILLS\n"..b.AttackName.."\n"..b.SkillName.." — "..b.SkillDescription.."\n"..b.GuardName
    end
end
local function rebuild()
    clear(listFrame)
    local arr=sortedNames()
    local collected=0
    for _,n in ipairs(order) do if owned(n) then collected+=1 end end
    if mode=="Seeds" then local seedCollected=0; for _,n in ipairs(order) do if seedOwned(n) then seedCollected+=1 end end; progress.Text=seedCollected.." / "..#order.." SEEDS • "..math.floor(seedCollected/#order*100).."%"
    elseif mode=="Deck" then progress.Text=#currentDeck.." / 6 SLOTS USED"
    else progress.Text=collected.." / "..#order.." CARDS • "..math.floor(collected/#order*100).."%" end
    for _,n in ipairs(arr) do
        local v=Variants[n]; local b=BattleDefinitions[n]
        local has=mode=="Seeds" and seedOwned(n) or owned(n)
        local card=Instance.new("TextButton"); card.Name=n; card.BackgroundColor3=has and PANEL2 or Color3.fromRGB(29,35,43); card.Text=""; card.AutoButtonColor=true; card.Parent=listFrame; corner(card,12); stroke(card,has and v.Color or Color3.fromRGB(76,86,101),.35,1)
        local art=Instance.new("ViewportFrame"); art.Size=UDim2.fromOffset(110,105); art.Position=UDim2.fromOffset(20,8); art.BackgroundTransparency=1; art.Parent=card
        if mode=="Seeds" then seedIcon(art,n) else makeModel(art,n,.72) end
        local name=label(card,has and n or "???",UDim2.new(1,-14,0,24),UDim2.fromOffset(7,116),has and TEXT or MUTED,Enum.Font.GothamBlack)
        local sub=label(card,has and v.Rarity or "LOCKED",UDim2.new(1,-14,0,20),UDim2.fromOffset(7,143),has and v.Color or MUTED,Enum.Font.GothamBold)
        if mode=="Deck" and has then
            local selected=false; for _,d in ipairs(currentDeck) do if d==n then selected=true end end
            card.BackgroundColor3=selected and Color3.fromRGB(48,76,58) or PANEL2
            sub.Text=(selected and "IN DECK  " or "ADD  ")..#currentDeck.."/6
        end
        card.Activated:Connect(function()
            if not has then return end
            if mode=="Deck" then
                local idx; for i,d in ipairs(currentDeck) do if d==n then idx=i break end end
                if idx then table.remove(currentDeck,idx) elseif #currentDeck<6 then table.insert(currentDeck,n) end
                if deckUpdate then deckUpdate:FireServer(currentDeck) end; rebuild()
            end
            showDetail(n)
        end)
    end
    listFrame.CanvasSize=UDim2.fromOffset(0,math.ceil(#arr/3)*200)
    if arr[1] then showDetail(arr[1]) else detailTitle.Text="EMPTY"; detailText.Text="No matching entries." end
end
local function open(m)
    mode=m; title.Text=m=="Deck" and "BUILD DECK" or (m=="Seeds" and "SEED INDEX" or "CARD INDEX")
    search.Text=""; searchText=""; sortMode="Name"; sort.Text="SORT: NAME"; panel.Visible=true; overlay.Visible=true; rebuild()
end
search:GetPropertyChangedSignal("Text"):Connect(function() searchText=search.Text; rebuild() end)
sort.Activated:Connect(function()
    sortMode=sortMode=="Name" and "Rarity" or (sortMode=="Rarity" and "Collected" or "Name")
    sort.Text="SORT: "..string.upper(sortMode); rebuild()
end)
close.Activated:Connect(function() overlay.Visible=false; panel.Visible=false end)
local function fireTeleport(destination)
    local r=remotes:FindFirstChild("WorldTeleport")
    if r and r:IsA("RemoteEvent") then r:FireServer(destination) end
end
garden.Activated:Connect(function() fireTeleport("Garden"); if _G.GrowAVerityOpenGarden then task.delay(.2,_G.GrowAVerityOpenGarden) end end)
explore.Activated:Connect(function() fireTeleport("Explore") end)
cards.Activated:Connect(function() open("Cards") end)
seeds.Activated:Connect(function() open("Seeds") end)
deck.Activated:Connect(function() open("Deck") end)
settings.Activated:Connect(function() if _G.GrowAVerityOpenSettings then _G.GrowAVerityOpenSettings() end end)
local function bindDeckRemote(r)
    deckUpdate=r
    r.OnClientEvent:Connect(function(d)
        if type(d)=="table" then currentDeck=d; if mode=="Deck" then rebuild() end end
    end)
end
if deckUpdate then
    bindDeckRemote(deckUpdate)
else
    remotes.ChildAdded:Connect(function(child)
        if child.Name=="DeckUpdate" and child:IsA("RemoteEvent") and not deckUpdate then bindDeckRemote(child) end
    end)
end
player.CharacterAdded:Connect(function() task.defer(function() gui.Enabled=true end) end)
task.spawn(function()
    while gui.Parent do
        task.wait(1)
        local battleGui=player.PlayerGui:FindFirstChild("BattleUI")
        gui.Enabled=true
    end
end)
