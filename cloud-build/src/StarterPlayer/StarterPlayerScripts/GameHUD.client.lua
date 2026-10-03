local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local deckUpdate=remotes:WaitForChild("DeckUpdate")
local gui=Instance.new("ScreenGui"); gui.Name="GameHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=20; gui.Enabled=true; gui.Parent=player:WaitForChild("PlayerGui")
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function label(parent,text,size,pos,color,font) local l=Instance.new("TextLabel"); l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=text; l.TextColor3=color; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=parent; return l end
local function button(parent,text,size,pos,bg) local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=bg or Color3.fromRGB(255,232,138); b.TextColor3=Color3.fromRGB(50,54,40); b.Text=text; b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.Parent=parent; corner(b,10); return b end
local top=Instance.new("Frame"); top.Size=UDim2.fromOffset(820,64); top.Position=UDim2.new(.5,-410,0,10); top.BackgroundColor3=Color3.fromRGB(245,241,218); top.BorderSizePixel=0; top.Parent=gui; corner(top,16)
local cash=label(top,"$0",UDim2.fromOffset(105,40),UDim2.fromOffset(10,12),Color3.new(1,1,1),Enum.Font.GothamBlack); cash.BackgroundColor3=Color3.fromRGB(122,177,91); cash.BackgroundTransparency=0; corner(cash,10)
local home=button(top,"MY GARDEN",UDim2.fromOffset(110,40),UDim2.fromOffset(123,12)); local explore=button(top,"EXPLORE",UDim2.fromOffset(100,40),UDim2.fromOffset(241,12)); local cards=button(top,"CARD INDEX",UDim2.fromOffset(110,40),UDim2.fromOffset(349,12)); local seeds=button(top,"SEED INDEX",UDim2.fromOffset(110,40),UDim2.fromOffset(467,12)); local deck=button(top,"BUILD DECK",UDim2.fromOffset(110,40),UDim2.fromOffset(585,12))
local panel=Instance.new("Frame"); panel.Size=UDim2.fromOffset(700,500); panel.Position=UDim2.new(.5,-350,.5,-250); panel.BackgroundColor3=Color3.fromRGB(245,241,218); panel.Visible=false; panel.Parent=gui; corner(panel,18)
local panelTitle=label(panel,"INDEX",UDim2.fromScale(.7,.09),UDim2.fromScale(.15,.035),Color3.fromRGB(53,58,43),Enum.Font.GothamBlack)
local close=button(panel,"CLOSE",UDim2.fromOffset(90,34),UDim2.new(1,-105,0,18),Color3.fromRGB(121,177,91))
local left=Instance.new("Frame"); left.Size=UDim2.fromOffset(230,370); left.Position=UDim2.fromOffset(22,82); left.BackgroundColor3=Color3.fromRGB(232,226,197); left.BorderSizePixel=0; left.Parent=panel; corner(left,14)
local right=Instance.new("Frame"); right.Size=UDim2.fromOffset(410,370); right.Position=UDim2.fromOffset(268,82); right.BackgroundColor3=Color3.fromRGB(251,248,231); right.BorderSizePixel=0; right.Parent=panel; corner(right,14)
local detailTitle=label(right,"Select an entry",UDim2.new(.9,0,.1,0),UDim2.fromScale(.05,.04),Color3.fromRGB(53,58,43),Enum.Font.GothamBlack)
local detail=label(right,"",UDim2.new(.88,0,.78,0),UDim2.fromScale(.06,.15),Color3.fromRGB(70,74,57),Enum.Font.GothamBold); detail.TextXAlignment=Enum.TextXAlignment.Left; detail.TextYAlignment=Enum.TextYAlignment.Top; detail.TextWrapped=true; detail.TextSize=20
local BattleDefinitions=require(ReplicatedStorage:WaitForChild("BattleDefinitions")); local VariantDefinitions=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
local names={"Verity","Falsity","Cruelty","Lovity"}; local mode="Cards"; local currentDeck={}; local deckButtons={}
local function owned(n) return player:GetAttribute("Variety_"..n) or player:GetAttribute("StarterVariety")==n end
local function clear() for _,v in ipairs(left:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end end
local function showEntry(n)
 local v=VariantDefinitions[n] or {}; local b=BattleDefinitions[n]; local has=owned(n)
 if mode=="Deck" then
  detailTitle.Text="DECK "..#currentDeck.."/6"; detail.Text="Choose up to 6 owned cards.\n\nSelected cards:\n"..(#currentDeck>0 and table.concat(currentDeck,", ") or "None").."\n\nClick a card to add/remove it. The deck is used for switching during battles."; return
 end
 local seed=mode=="Seeds"
 if not (seed and player:GetAttribute("Seed_"..n) or (not seed and has)) then detailTitle.Text="???"; detail.Text="LOCKED\n\nThis entry has not been collected yet."; return end
 detailTitle.Text=seed and n.." Seed" or n
 if seed then detail.Text="Rarity: "..tostring(v.Rarity).."\nSource: "..n.." Guardian\nStatus: COLLECTED\n\nPlantable: YES\n\nGrowth and harvest stats will appear when the Garden system is implemented."
 elseif b then detail.Text="Rarity: "..b.Rarity.."\nRole: "..b.Role.."\n\nHP: "..b.HP.."\nAttack: "..b.Attack.."\nDefense: "..b.Defense.."\nEnergy: "..b.Energy.."\n\nTags: "..table.concat(b.Tags,", ").."\n\nMoves\n• "..b.AttackName.."\n• "..b.SkillName.."\n• "..b.GuardName.."\n\n"..b.SkillDescription end
end
local function inDeck(n) for i,v in ipairs(currentDeck) do if v==n then return i end end end
local function build(modeIn)
 mode=modeIn; panelTitle.Text=mode=="Deck" and "BUILD YOUR DECK" or (mode=="Cards" and "CARD INDEX" or "SEED INDEX"); clear()
 if mode=="Deck" then
  local y=12
  for _,n in ipairs(names) do if owned(n) then
   local selected=inDeck(n); local b=button(left,(selected and "✓ " or "+ ")..n,UDim2.new(1,-24,0,52),UDim2.fromOffset(12,y),selected and Color3.fromRGB(210,235,183) or Color3.fromRGB(245,241,218))
   b.Activated:Connect(function() local i=inDeck(n); if i then table.remove(currentDeck,i) elseif #currentDeck<6 then table.insert(currentDeck,n) end; build("Deck") end); y+=61
  end end
  detailTitle.Text="DECK "..#currentDeck.."/6"; detail.Text="Select 1–6 owned cards.\n\n"..(#currentDeck>0 and table.concat(currentDeck,"\n") or "No cards selected.").."\n\nChanges are saved automatically."; panel.Visible=true; deckUpdate:FireServer(currentDeck); return
 end
 local y=12
 for _,n in ipairs(names) do local has=(mode=="Cards" and owned(n)) or (mode=="Seeds" and player:GetAttribute("Seed_"..n)); local b=button(left,(has and "● " or "??? ")..n,UDim2.new(1,-24,0,52),UDim2.fromOffset(12,y),has and Color3.fromRGB(210,235,183) or Color3.fromRGB(216,212,195)); b.Activated:Connect(function() showEntry(n) end); y+=61 end
 showEntry(names[1]); panel.Visible=true
end
local function updateCash() cash.Text="$"..tostring(player:GetAttribute("Cash") or 0) end
updateCash(); player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
home.Activated:Connect(function() panel.Visible=false; remotes.WorldTeleport:FireServer("Garden") end); explore.Activated:Connect(function() panel.Visible=false; remotes.WorldTeleport:FireServer("Explore") end)
cards.Activated:Connect(function() build("Cards") end); seeds.Activated:Connect(function() build("Seeds") end); deck.Activated:Connect(function() build("Deck") end); close.Activated:Connect(function() panel.Visible=false end)
deckUpdate.OnClientEvent:Connect(function(d) if type(d)=="table" and mode~="Deck" then currentDeck=d end end)