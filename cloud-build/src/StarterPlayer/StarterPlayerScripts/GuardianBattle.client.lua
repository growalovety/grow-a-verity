local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local startBattle=remotes:WaitForChild("StartBattle"); local battleAction=remotes:WaitForChild("BattleAction"); local battleUpdate=remotes:WaitForChild("BattleUpdate"); local battleEnd=remotes:WaitForChild("BattleEnd")
local switchCard=remotes:WaitForChild("SwitchBattleCard"); local cancelBattle=remotes:WaitForChild("CancelBattle")
local screen=Instance.new("ScreenGui"); screen.Name="BattleUI"; screen.IgnoreGuiInset=true; screen.ResetOnSpawn=false; screen.DisplayOrder=60; screen.Enabled=false; screen.Parent=pg
local dim=Instance.new("Frame"); dim.Size=UDim2.fromScale(1,1); dim.BackgroundColor3=Color3.fromRGB(80,105,76); dim.BackgroundTransparency=.72; dim.BorderSizePixel=0; dim.Parent=screen
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local enemyCard=Instance.new("Frame"); enemyCard.Size=UDim2.fromOffset(280,82); enemyCard.Position=UDim2.new(1,-310,0,42); enemyCard.BackgroundColor3=Color3.fromRGB(245,241,218); enemyCard.Parent=screen; corner(enemyCard,18)
local playerCard=enemyCard:Clone(); playerCard.Size=UDim2.fromOffset(310,92); playerCard.Position=UDim2.new(0,28,1,-255); playerCard.Parent=screen
local enemyName=Instance.new("TextLabel"); enemyName.Size=UDim2.fromScale(.88,.38); enemyName.Position=UDim2.fromScale(.06,.08); enemyName.BackgroundTransparency=1; enemyName.TextColor3=Color3.fromRGB(45,52,40); enemyName.TextScaled=true; enemyName.Font=Enum.Font.GothamBlack; enemyName.Parent=enemyCard
local playerName=enemyName:Clone(); playerName.Parent=playerCard
local function hp(parent,y)
 local t=Instance.new("Frame"); t.Size=UDim2.fromScale(.88,.15); t.Position=UDim2.fromScale(.06,y); t.BackgroundColor3=Color3.fromRGB(55,61,50); t.BorderSizePixel=0; t.Parent=parent; corner(t,9)
 local f=Instance.new("Frame"); f.Size=UDim2.fromScale(1,1); f.BackgroundColor3=Color3.fromRGB(101,205,116); f.BorderSizePixel=0; f.Parent=t; corner(f,9); return f
end
local enemyBar=hp(enemyCard,.54); local playerBar=hp(playerCard,.54)
local message=Instance.new("TextLabel"); message.Size=UDim2.fromScale(.62,.09); message.Position=UDim2.fromScale(.19,.49); message.BackgroundColor3=Color3.fromRGB(245,241,218); message.BackgroundTransparency=.04; message.TextColor3=Color3.fromRGB(47,53,42); message.TextScaled=true; message.Font=Enum.Font.GothamBlack; message.Parent=screen; corner(message,16)
local close=Instance.new("TextButton"); close.Size=UDim2.fromOffset(48,48); close.Position=UDim2.new(1,-62,0,12); close.Text="×"; close.TextScaled=true; close.Font=Enum.Font.GothamBlack; close.TextColor3=Color3.fromRGB(50,54,40); close.BackgroundColor3=Color3.fromRGB(245,241,218); close.Parent=screen; corner(close,14)
local actionBox=Instance.new("Frame"); actionBox.Size=UDim2.new(0,520,0,92); actionBox.Position=UDim2.new(.5,-260,1,-112); actionBox.BackgroundColor3=Color3.fromRGB(245,241,218); actionBox.Parent=screen; corner(actionBox,20)
local actionLayout=Instance.new("UIListLayout"); actionLayout.FillDirection=Enum.FillDirection.Horizontal; actionLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center; actionLayout.VerticalAlignment=Enum.VerticalAlignment.Center; actionLayout.Padding=UDim.new(0,10); actionLayout.Parent=actionBox
local function actionButton(accent) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(155,58); b.BackgroundColor3=accent; b.TextColor3=Color3.fromRGB(28,31,26); b.TextScaled=true; b.Font=Enum.Font.GothamBlack; b.AutoButtonColor=false; b.Parent=actionBox; corner(b,14); return b end
local attack=actionButton(Color3.fromRGB(244,114,86)); local skill=actionButton(Color3.fromRGB(86,157,235)); local guard=actionButton(Color3.fromRGB(160,176,154))
local cards=Instance.new("Frame"); cards.Size=UDim2.new(1,-60,0,72); cards.Position=UDim2.new(0,30,1,-190); cards.BackgroundTransparency=1; cards.Parent=screen
local cardLayout=Instance.new("UIListLayout"); cardLayout.FillDirection=Enum.FillDirection.Horizontal; cardLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left; cardLayout.VerticalAlignment=Enum.VerticalAlignment.Center; cardLayout.Padding=UDim.new(0,8); cardLayout.Parent=cards
local cardButtons={}; local currentCard=""; local busy=false
local function findGuardian(name) for _,m in ipairs(workspace:GetDescendants()) do if m:IsA("Model") and m:GetAttribute("VarietyName")==name and m.PrimaryPart then return m end end end
local function cameraFor(enemyName,side)
 local cam=workspace.CurrentCamera; local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); local g=findGuardian(enemyName); if not root or not g then return end
 local target=g.PrimaryPart.Position+Vector3.new(0,2.8,0); local base=side=="enemy" and g.PrimaryPart.Position or root.Position; local offset=side=="enemy" and Vector3.new(0,5,11) or Vector3.new(0,4,10)
 cam.CameraType=Enum.CameraType.Scriptable; TweenService:Create(cam,TweenInfo.new(.45,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{CFrame=CFrame.lookAt(base+offset,target)}):Play()
end
local function restoreCamera() local cam=workspace.CurrentCamera; cam.CameraType=Enum.CameraType.Custom; local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if hum then cam.CameraSubject=hum end end
local function setActions(enabled) busy=not enabled; attack.Active=enabled; skill.Active=enabled; guard.Active=enabled; attack.AutoButtonColor=enabled; skill.AutoButtonColor=enabled; guard.AutoButtonColor=enabled end
local function rebuildCards()
 for _,b in ipairs(cardButtons) do b:Destroy() end cardButtons={}
 for _,n in ipairs({"Verity","Falsity","Cruelty","Lovity"}) do
  if player:GetAttribute("Variety_"..n) or player:GetAttribute("StarterVariety")==n then
   local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(115,58); b.Text=n; b.TextScaled=true; b.Font=Enum.Font.GothamBlack; b.TextColor3=Color3.fromRGB(40,45,36); b.BackgroundColor3=(n==currentCard and Color3.fromRGB(255,221,45) or Color3.fromRGB(245,241,218)); b.Parent=cards; corner(b,14)
   b.Activated:Connect(function() if not busy and n~=currentCard then setActions(false); switchCard:FireServer(n) end end); table.insert(cardButtons,b)
  end
 end
end
attack.Activated:Connect(function() if not busy then setActions(false); battleAction:FireServer("Attack") end end)
skill.Activated:Connect(function() if not busy then setActions(false); battleAction:FireServer("Skill") end end)
guard.Activated:Connect(function() if not busy then setActions(false); battleAction:FireServer("Guard") end end)
close.Activated:Connect(function() cancelBattle:FireServer(); screen.Enabled=false; restoreCamera() end)
startBattle.OnClientEvent:Connect(function(enemy,starter) screen.Enabled=true; currentCard=starter; enemyName.Text=enemy; playerName.Text=starter; message.Text=starter.." is ready!"; rebuildCards(); setActions(false); cameraFor(enemy,"player"); task.wait(.55); if screen.Enabled then setActions(true) end end)
battleUpdate.OnClientEvent:Connect(function(s)
 enemyBar.Size=UDim2.fromScale(math.clamp(s.EnemyHP/s.EnemyMaxHP,0,1),1); playerBar.Size=UDim2.fromScale(math.clamp(s.PlayerHP/s.PlayerMaxHP,0,1),1)
 enemyName.Text=s.EnemyName.."   "..s.EnemyHP.."/"..s.EnemyMaxHP; playerName.Text=s.PlayerName.."   "..s.PlayerHP.."/"..s.PlayerMaxHP
 if s.PlayerName~=currentCard then currentCard=s.PlayerName; rebuildCards() end
 attack.Text=s.PlayerAttackName or "Basic Hit"; skill.Text=s.PlayerSkillName or "Special"; guard.Text=s.PlayerGuardName or "Defend"; message.Text=s.Message~="" and s.Message or ""
 if s.Phase=="EnemyAttack" then cameraFor(s.EnemyName,"enemy") elseif s.Phase=="Player" or s.Phase=="PlayerAttack" or s.Phase=="Switch" then cameraFor(s.EnemyName,"player") end
 setActions(s.CanAct==true)
end)
battleEnd.OnClientEvent:Connect(function(won,enemy) setActions(false); message.Text=won and ("VICTORY! "..enemy.." CARD + SEED") or "DEFEATED"; task.wait(1.4); screen.Enabled=false; restoreCamera() end)