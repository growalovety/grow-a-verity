local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui"); gui.Name="GameHUD"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.DisplayOrder=20; gui.Enabled=true; gui.Parent=player:WaitForChild("PlayerGui")

local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function label(parent,text,size,pos,color,font) local l=Instance.new("TextLabel"); l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=text; l.TextColor3=color; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=parent; return l end
local function button(parent,text,size,pos,bg) local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=bg or Color3.fromRGB(255,232,138); b.TextColor3=Color3.fromRGB(50,54,40); b.Text=text; b.TextScaled=true; b.Font=Enum.Font.GothamBold; b.Parent=parent; corner(b,10); return b end

local top=Instance.new("Frame"); top.Size=UDim2.fromOffset(700,64); top.Position=UDim2.new(.5,-350,0,10); top.BackgroundColor3=Color3.fromRGB(245,241,218); top.BackgroundTransparency=.04; top.BorderSizePixel=0; top.Parent=gui; corner(top,16)
local cash=label(top,"$0",UDim2.fromOffset(110,40),UDim2.fromOffset(10,12),Color3.new(1,1,1),Enum.Font.GothamBlack); cash.BackgroundColor3=Color3.fromRGB(122,177,91); cash.BackgroundTransparency=0; corner(cash,10)
local home=button(top,"MY GARDEN",UDim2.fromOffset(116,40),UDim2.fromOffset(128,12))
local explore=button(top,"EXPLORE",UDim2.fromOffset(106,40),UDim2.fromOffset(252,12))
local cards=button(top,"CARD INDEX",UDim2.fromOffset(112,40),UDim2.fromOffset(366,12))
local seeds=button(top,"SEED INDEX",UDim2.fromOffset(112,40),UDim2.fromOffset(486,12))

local panel=Instance.new("Frame"); panel.Size=UDim2.fromOffset(700,500); panel.Position=UDim2.new(.5,-350,.5,-250); panel.BackgroundColor3=Color3.fromRGB(245,241,218); panel.Visible=false; panel.Parent=gui; corner(panel,18)
label(panel,"INDEX",UDim2.fromScale(.7,.09),UDim2.fromScale(.15,.035),Color3.fromRGB(53,58,43),Enum.Font.GothamBlack)
local close=button(panel,"CLOSE",UDim2.fromOffset(90,34),UDim2.new(1,-105,0,18),Color3.fromRGB(121,177,91))

local left=Instance.new("Frame"); left.Size=UDim2.fromOffset(230,370); left.Position=UDim2.fromOffset(22,82); left.BackgroundColor3=Color3.fromRGB(232,226,197); left.BorderSizePixel=0; left.Parent=panel; corner(left,14)
local right=Instance.new("Frame"); right.Size=UDim2.fromOffset(410,370); right.Position=UDim2.fromOffset(268,82); right.BackgroundColor3=Color3.fromRGB(251,248,231); right.BorderSizePixel=0; right.Parent=panel; corner(right,14)
local detailTitle=label(right,"Select an entry",UDim2.new(.9,0,.1,0),UDim2.fromScale(.05,.04),Color3.fromRGB(53,58,43),Enum.Font.GothamBlack)
local detail=label(right,"",UDim2.new(.88,0,.78,0),UDim2.fromScale(.06,.15),Color3.fromRGB(70,74,57),Enum.Font.GothamBold); detail.TextXAlignment=Enum.TextXAlignment.Left; detail.TextYAlignment=Enum.TextYAlignment.Top; detail.TextWrapped=true; detail.TextSize=20

local BattleDefinitions=require(ReplicatedStorage:WaitForChild("BattleDefinitions"))
local VariantDefinitions=require(ReplicatedStorage:WaitForChild("VariantDefinitions"))
local names={"Verity","Falsity","Cruelty","Lovity"}
local indexMode="Cards"

local function owned(kind,n)
 return player:GetAttribute(kind.."_"..n) or (kind=="Variety" and player:GetAttribute("StarterVariety")==n)
end

local function clearList()
 for _,v in ipairs(left:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
end

local function showEntry(n)
 local v=VariantDefinitions[n] or {}
 local b=BattleDefinitions[n]
 local has=owned(indexMode=="Cards" and "Variety" or "Seed",n)
 if indexMode=="Cards" then
  if not has then detailTitle.Text="???"; detail.Text="LOCKED\n\nThis card has not been collected yet.\n\nDiscover it in the world and add it to your collection."; return end
  detailTitle.Text=n
  if b then
   detail.Text="Rarity: "..tostring(b.Rarity).."\nRole: "..tostring(b.Role).."\n\nHP: "..b.HP.."\nAttack: "..b.Attack.."\nDefense: "..b.Defense.."\nEnergy: "..b.Energy.."\n\nTags: "..table.concat(b.Tags,", ").."\n\nMoves\n• "..b.AttackName.."\n• "..b.SkillName.."\n• "..b.GuardName
  else
   detail.Text="Rarity: "..tostring(v.Rarity).."\nPersonality: "..tostring(v.Personality).."\n\nBattle stats are not defined yet for this Variety."
  end
 else
  if not has then detailTitle.Text="???"; detail.Text="LOCKED\n\nThis seed has not been collected yet.\n\nDefeat Guardians and discover new Seeds."; return end
  detailTitle.Text=n.." Seed"
  detail.Text="Rarity: "..tostring(v.Rarity).."\nSource: "..n.." Guardian\nStatus: COLLECTED\n\nPlantable: YES\n\nGrowth time, harvest item and production stats will appear here when the Garden system is implemented."
 end
end

local function buildIndex(mode)
 indexMode=mode; clearList()
 local y=12
 for _,n in ipairs(names) do
  local has=owned(mode=="Cards" and "Variety" or "Seed",n)
  local b=button(left,(has and "● " or "??? ")..n,UDim2.new(1,-24,0,52),UDim2.fromOffset(12,y),has and Color3.fromRGB(210,235,183) or Color3.fromRGB(216,212,195))
  b.Activated:Connect(function() showEntry(n) end)
  y+=61
 end
 showEntry(names[1])
 panel.Visible=true
end

local function updateCash() cash.Text="$"..tostring(player:GetAttribute("Cash") or 0) end
updateCash(); player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
home.Activated:Connect(function() panel.Visible=false; ReplicatedStorage.GameRemotes.WorldTeleport:FireServer("Garden") end)
explore.Activated:Connect(function() panel.Visible=false; ReplicatedStorage.GameRemotes.WorldTeleport:FireServer("Explore") end)
cards.Activated:Connect(function() buildIndex("Cards") end)
seeds.Activated:Connect(function() buildIndex("Seeds") end)
close.Activated:Connect(function() panel.Visible=false end)
