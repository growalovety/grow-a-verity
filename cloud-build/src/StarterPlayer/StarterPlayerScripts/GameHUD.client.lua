local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local deckUpdate=remotes:WaitForChild("DeckUpdate")
local gui=Instance.new("ScreenGui")
gui.Name="GameHUD"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=20
gui.Parent=player:WaitForChild("PlayerGui")

local BG=Color3.fromRGB(247,242,220)
local PANEL=Color3.fromRGB(255,250,235)
local PANEL2=Color3.fromRGB(238,231,204)
local GREEN=Color3.fromRGB(67,137,79)
local GREEN_DARK=Color3.fromRGB(42,91,50)
local TEXT=Color3.fromRGB(43,58,42)
local MUTED=Color3.fromRGB(108,116,94)
local GOLD=Color3.fromRGB(220,175,64)
local LINE=Color3.fromRGB(183,161,108)

local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function stroke(o,c,t,w) local s=Instance.new("UIStroke"); s.Color=c; s.Transparency=t or 0; s.Thickness=w or 1; s.Parent=o end
local function label(parent,text,size,pos,color,font)
 local l=Instance.new("TextLabel"); l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=text; l.TextColor3=color; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=parent; return l
end
local function button(parent,text,size,pos,bg,txt)
 local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=bg or PANEL; b.TextColor3=txt or TEXT; b.Text=text; b.Font=Enum.Font.GothamBold; b.TextScaled=true; b.AutoButtonColor=true; b.Parent=parent; corner(b,11); stroke(b,LINE,.12,1); return b
end

-- Viral-game style: separate chunky navigation buttons instead of one large HUD container.
local cash=button(gui,"$ 0",UDim2.fromOffset(150,48),UDim2.fromOffset(18,16),GREEN,Color3.new(1,1,1))
cash.Font=Enum.Font.GothamBlack
stroke(cash,Color3.fromRGB(38,88,45),.05,2)

local nav=Instance.new("Frame")
nav.Size=UDim2.fromOffset(560,54)
nav.Position=UDim2.new(.5,-280,0,13)
nav.BackgroundTransparency=1
nav.Parent=gui

local home=button(nav,"GARDEN",UDim2.fromOffset(105,44),UDim2.fromOffset(0,5),PANEL,GREEN_DARK)
local explore=button(nav,"EXPLORE",UDim2.fromOffset(105,44),UDim2.fromOffset(113,5),PANEL,GREEN_DARK)
local cards=button(nav,"CARDS",UDim2.fromOffset(95,44),UDim2.fromOffset(226,5),PANEL,GREEN_DARK)
local seeds=button(nav,"SEEDS",UDim2.fromOffset(95,44),UDim2.fromOffset(329,5),PANEL,GREEN_DARK)
local deck=button(nav,"DECK",UDim2.fromOffset(95,44),UDim2.fromOffset(432,5),PANEL,GREEN_DARK)

local settingsButton=button(gui,"⚙",UDim2.fromOffset(50,50),UDim2.new(1,-68,0,14),GREEN,Color3.new(1,1,1))
settingsButton.Font=Enum.Font.GothamBlack
settingsButton.TextScaled=true
stroke(settingsButton,Color3.fromRGB(38,88,45),.05,2)

local panel=Instance.new("Frame")
panel.Size=UDim2.fromOffset(760,510)
panel.Position=UDim2.new(.5,-380,.5,-255)
panel.BackgroundColor3=BG
panel.Visible=false
panel.Parent=gui
corner(panel,18)
stroke(panel,GREEN,.12,2)

local panelTitle=label(panel,"CARD INDEX",UDim2.new(.65,0,0,46),UDim2.fromOffset(24,18),TEXT,Enum.Font.GothamBlack)
local close=button(panel,"×",UDim2.fromOffset(42,42),UDim2.new(1,-58,0,18),PANEL2,TEXT)
local left=Instance.new("Frame")
left.Size=UDim2.fromOffset(245,385)
left.Position=UDim2.fromOffset(20,78)
left.BackgroundColor3=PANEL
left.BorderSizePixel=0
left.Parent=panel
corner(left,14)
stroke(left,LINE,.3,1)

local right=Instance.new("Frame")
right.Size=UDim2.fromOffset(470,385)
right.Position=UDim2.fromOffset(275,78)
right.BackgroundColor3=PANEL
right.BorderSizePixel=0
right.Parent=panel
corner(right,14)
stroke(right,LINE,.3,1)

local detailTitle=label(right,"Select an entry",UDim2.new(.86,0,0,38),UDim2.fromOffset(22,16),TEXT,Enum.Font.GothamBlack)
local detail=label(right,"",UDim2.new(.86,0,.78,0),UDim2.fromOffset(22,62),MUTED,Enum.Font.GothamBold)
detail.TextXAlignment=Enum.TextXAlignment.Left
detail.TextYAlignment=Enum.TextYAlignment.Top
detail.TextWrapped=true
detail.TextSize=19

local BattleDefinitions=require(ReplicatedStorage:WaitForChild("BattleDefinitions"))
local VariantDefinitions=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
local names={"Verity","Falsity","Cruelty","Lovity"}
local mode="Cards"
local currentDeck={}
local function owned(n) return player:GetAttribute("Variety_"..n) or player:GetAttribute("StarterVariety")==n end
local function clear() for _,v in ipairs(left:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end end

local function showEntry(n)
 local v=VariantDefinitions[n] or {}
 local b=BattleDefinitions[n]
 local has=owned(n)
 if mode=="Deck" then
  detailTitle.Text="DECK  "..#currentDeck.."/6"
  detail.Text="Choose up to 6 owned cards.\\n\\nSelected cards:\\n"..(#currentDeck>0 and table.concat(currentDeck,", ") or "None").."\\n\\nClick a card to add/remove it."
  return
 end
 local seed=mode=="Seeds"
 if not (seed and player:GetAttribute("Seed_"..n) or (not seed and has)) then
  detailTitle.Text="???"
  detail.Text="LOCKED\\n\\nThis entry has not been collected yet."
  return
 end
 detailTitle.Text=seed and n.." Seed" or n
 if seed then
  detail.Text="Rarity: "..tostring(v.Rarity).."\\nSource: "..n.." Guardian\\nStatus: COLLECTED\\n\\nPlantable: YES\\n\\nGrowth and harvest stats will appear when the Garden system is implemented."
 elseif b then
  detail.Text="Rarity: "..b.Rarity.."\\nRole: "..b.Role.."\\n\\nHP: "..b.HP.."\\nAttack: "..b.Attack.."\\nDefense: "..b.Defense.."\\nEnergy: "..b.Energy.."\\n\\nTags: "..table.concat(b.Tags,", ").."\\n\\nMoves\\n• "..b.AttackName.."\\n• "..b.SkillName.."\\n• "..b.GuardName.."\\n\\n"..b.SkillDescription
 end
end

local function inDeck(n) for i,v in ipairs(currentDeck) do if v==n then return i end end end
local function build(modeIn)
 mode=modeIn
 panelTitle.Text=mode=="Deck" and "BUILD YOUR DECK" or (mode=="Cards" and "CARD INDEX" or "SEED INDEX")
 clear()
 if mode=="Deck" then
  local y=12
  for _,n in ipairs(names) do
   if owned(n) then
    local selected=inDeck(n)
    local b=button(left,(selected and "✓  " or "+  ")..n,UDim2.new(1,-24,0,52),UDim2.fromOffset(12,y),selected and Color3.fromRGB(206,232,208) or PANEL2,GREEN_DARK)
    b.Activated:Connect(function()
     local i=inDeck(n)
     if i then table.remove(currentDeck,i) elseif #currentDeck<6 then table.insert(currentDeck,n) end
     build("Deck")
    end)
    y+=61
   end
  end
  detailTitle.Text="DECK  "..#currentDeck.."/6"
  detail.Text="Select 1–6 owned cards.\\n\\n"..(#currentDeck>0 and table.concat(currentDeck,"\\n") or "No cards selected.").."\\n\\nChanges are saved automatically."
  panel.Visible=true
  deckUpdate:FireServer(currentDeck)
  return
 end
 local y=12
 for _,n in ipairs(names) do
  local has=(mode=="Cards" and owned(n)) or (mode=="Seeds" and player:GetAttribute("Seed_"..n))
  local b=button(left,(has and "●  " or "???  ")..n,UDim2.new(1,-24,0,52),UDim2.fromOffset(12,y),has and Color3.fromRGB(221,239,220) or Color3.fromRGB(231,226,207),has and GREEN_DARK or MUTED)
  b.Activated:Connect(function() showEntry(n) end)
  y+=61
 end
 showEntry(names[1])
 panel.Visible=true
end

local function updateCash() cash.Text="$  "..tostring(player:GetAttribute("Cash") or 0) end
updateCash()
player:GetAttributeChangedSignal("Cash"):Connect(updateCash)

home.Activated:Connect(function() panel.Visible=false; remotes.WorldTeleport:FireServer("Garden") end)
explore.Activated:Connect(function() panel.Visible=false; remotes.WorldTeleport:FireServer("Explore") end)
cards.Activated:Connect(function() build("Cards") end)
seeds.Activated:Connect(function() build("Seeds") end)
deck.Activated:Connect(function() build("Deck") end)
close.Activated:Connect(function() panel.Visible=false end)
settingsButton.Activated:Connect(function()
 if _G.GrowAVerityOpenSettings then _G.GrowAVerityOpenSettings() end
end)
deckUpdate.OnClientEvent:Connect(function(d) if type(d)=="table" and mode~="Deck" then currentDeck=d end end)
