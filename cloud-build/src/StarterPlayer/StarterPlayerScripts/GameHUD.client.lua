local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local gui=Instance.new("ScreenGui") gui.Name="GameHUD" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=20 gui.Parent=player:WaitForChild("PlayerGui")
local function corner(o,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=o end
local top=Instance.new("Frame") top.Size=UDim2.fromOffset(630,62) top.Position=UDim2.new(.5,-315,0,12) top.BackgroundColor3=Color3.fromRGB(245,241,218) top.BackgroundTransparency=.08 top.BorderSizePixel=0 top.Parent=gui corner(top,16)
local cash=Instance.new("TextLabel") cash.Size=UDim2.fromOffset(105,38) cash.Position=UDim2.fromOffset(10,12) cash.BackgroundColor3=Color3.fromRGB(122,177,91) cash.TextColor3=Color3.new(1,1,1) cash.TextScaled=true cash.Font=Enum.Font.GothamBlack cash.Parent=top corner(cash,10)
local function btn(text,x) local b=Instance.new("TextButton") b.Size=UDim2.fromOffset(112,38) b.Position=UDim2.fromOffset(x,12) b.BackgroundColor3=Color3.fromRGB(255,232,138) b.TextColor3=Color3.fromRGB(50,54,40) b.Text=text b.TextScaled=true b.Font=Enum.Font.GothamBold b.Parent=top corner(b,10) return b end
local home=btn("MY GARDEN",125) local explore=btn("EXPLORE",245) local cards=btn("CARDS",365) local seeds=btn("SEEDS",485)
local panel=Instance.new("Frame") panel.Size=UDim2.fromOffset(360,300) panel.Position=UDim2.new(.5,-180,.5,-150) panel.BackgroundColor3=Color3.fromRGB(245,241,218) panel.Visible=false panel.Parent=gui corner(panel,18)
local title=Instance.new("TextLabel") title.Size=UDim2.fromScale(.85,.15) title.Position=UDim2.fromScale(.075,.05) title.BackgroundTransparency=1 title.TextColor3=Color3.fromRGB(53,58,43) title.TextScaled=true title.Font=Enum.Font.GothamBlack title.Parent=panel
local list=Instance.new("TextLabel") list.Size=UDim2.fromScale(.82,.68) list.Position=UDim2.fromScale(.09,.22) list.BackgroundTransparency=1 list.TextColor3=Color3.fromRGB(70,74,57) list.TextXAlignment=Enum.TextXAlignment.Left list.TextYAlignment=Enum.TextYAlignment.Top list.TextSize=22 list.Font=Enum.Font.GothamBold list.Parent=panel
local close=Instance.new("TextButton") close.Size=UDim2.fromOffset(90,34) close.Position=UDim2.new(.5,-45,1,-48) close.BackgroundColor3=Color3.fromRGB(121,177,91) close.Text="CLOSE" close.TextColor3=Color3.new(1,1,1) close.TextScaled=true close.Font=Enum.Font.GothamBold close.Parent=panel corner(close,9)
local function updateCash() cash.Text="$"..tostring(player:GetAttribute("Cash") or 0) end updateCash() player:GetAttributeChangedSignal("Cash"):Connect(updateCash)
local function owned(kind) local out={} for _,n in ipairs({"Verity","Falsity","Cruelty","Lovity"}) do if player:GetAttribute(kind.."_"..n) then table.insert(out,n) end end return #out>0 and table.concat(out,"\n") or "None yet" end
local function show(t,b) title.Text=t list.Text=b panel.Visible=true end
home.Activated:Connect(function() ReplicatedStorage.GameRemotes.WorldTeleport:FireServer("Garden") end)
explore.Activated:Connect(function() ReplicatedStorage.GameRemotes.WorldTeleport:FireServer("Explore") end)
cards.Activated:Connect(function() show("MY CARDS","Collected Varieties\n\n"..owned("Variety")) end)
seeds.Activated:Connect(function() show("MY SEEDS","Plantable Seeds\n\n"..owned("Seed")) end)
close.Activated:Connect(function() panel.Visible=false end)