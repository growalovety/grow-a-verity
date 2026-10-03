local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local pg=player:WaitForChild("PlayerGui")
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local startBattle=remotes:WaitForChild("StartBattle"); local battleAction=remotes:WaitForChild("BattleAction"); local battleUpdate=remotes:WaitForChild("BattleUpdate"); local battleEnd=remotes:WaitForChild("BattleEnd"); local switchCard=remotes:WaitForChild("SwitchBattleCard"); local cancelBattle=remotes:WaitForChild("CancelBattle"); local deckUpdate=remotes:WaitForChild("DeckUpdate")
local screen=Instance.new("ScreenGui"); screen.Name="BattleUI"; screen.IgnoreGuiInset=true; screen.ResetOnSpawn=false; screen.DisplayOrder=60; screen.Enabled=false; screen.Parent=pg
local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local dim=Instance.new("Frame"); dim.Size=UDim2.fromScale(1,1); dim.BackgroundColor3=Color3.fromRGB(40,60,48); dim.BackgroundTransparency=.72; dim.BorderSizePixel=0; dim.Parent=screen
local enemyCard=Instance.new("Frame"); enemyCard.Size=UDim2.fromOffset(300,92); enemyCard.Position=UDim2.new(1,-330,0,34); enemyCard.BackgroundColor3=Color3.fromRGB(245,241,218); enemyCard.Parent=screen; corner(enemyCard,18)
local playerCard=enemyCard:Clone(); playerCard.Size=UDim2.fromOffset(330,105); playerCard.Position=UDim2.new(0,26,1,-285); playerCard.Parent=screen
local function txt(parent,size,pos,color,font) local x=Instance.new("TextLabel"); x.Size=size; x.Position=pos; x.BackgroundTransparency=1; x.TextColor3=color; x.TextScaled=true; x.Font=font or Enum.Font.GothamBold; x.Parent=parent; return x end
local enemyName=txt(enemyCard,UDim2.fromScale(.88,.3),UDim2.fromScale(.06,.06),Color3.fromRGB(45,52,40),Enum.Font.GothamBlack)
local playerName=txt(playerCard,UDim2.fromScale(.88,.28),UDim2.fromScale(.06,.05),Color3.fromRGB(45,52,40),Enum.Font.GothamBlack)
local function bar(parent,y) local t=Instance.new("Frame"); t.Size=UDim2.fromScale(.88,.14); t.Position=UDim2.fromScale(.06,y); t.BackgroundColor3=Color3.fromRGB(55,61,50); t.BorderSizePixel=0; t.Parent=parent; corner(t,8); local f=Instance.new("Frame"); f.Size=UDim2.fromScale(1,1); f.BackgroundColor3=Color3.fromRGB(101,205,116); f.BorderSizePixel=0; f.Parent=t; corner(f,8); return f end
local enemyBar=bar(enemyCard,.55); local playerBar=bar(playerCard,.47)
local energyBack=Instance.new("Frame"); energyBack.Size=UDim2.fromScale(.88,.12); energyBack.Position=UDim2.fromScale(.06,.68); energyBack.BackgroundColor3=Color3.fromRGB(55,61,50); energyBack.BorderSizePixel=0; energyBack.Parent=playerCard; corner(energyBack,8)
local energyFill=Instance.new("Frame"); energyFill.Size=UDim2.fromScale(1,1); energyFill.BackgroundColor3=Color3.fromRGB(72,150,235); energyFill.BorderSizePixel=0; energyFill.Parent=energyBack; corner(energyFill,8)
local energyText=txt(playerCard,UDim2.fromScale(.88,.12),UDim2.fromScale(.06,.82),Color3.fromRGB(45,52,40),Enum.Font.GothamBold)
local turn=txt(screen,UDim2.fromScale(.24,.065),UDim2.fromScale(.38,.035),Color3.fromRGB(255,255,255),Enum.Font.GothamBlack); turn.BackgroundColor3=Color3.fromRGB(55,75,60); turn.BackgroundTransparency=.08; corner(turn,14)
local status=txt(screen,UDim2.fromScale(.32,.05),UDim2.fromScale(.34,.41),Color3.fromRGB(255,255,255),Enum.Font.GothamBold)
local message=txt(screen,UDim2.fromScale(.62,.1),UDim2.fromScale(.19,.49),Color3.fromRGB(47,53,42),Enum.Font.GothamBlack); message.BackgroundColor3=Color3.fromRGB(245,241,218); message.BackgroundTransparency=.04; corner(message,16)
local close=Instance.new("TextButton"); close.Size=UDim2.fromOffset(48,48); close.Position=UDim2.new(1,-62,0,10); close.Text="×"; close.TextScaled=true; close.Font=Enum.Font.GothamBlack; close.TextColor3=Color3.fromRGB(50,54,40); close.BackgroundColor3=Color3.fromRGB(245,241,218); close.Parent=screen; corner(close,14)
local actionBox=Instance.new("Frame"); actionBox.Size=UDim2.fromOffset(540,92); actionBox.Position=UDim2.new(.5,-270,1,-112); actionBox.BackgroundColor3=Color3.fromRGB(245,241,218); actionBox.Parent=screen; corner(actionBox,20)
local layout=Instance.new("UIListLayout"); layout.FillDirection=Enum.FillDirection.Horizontal; layout.HorizontalAlignment=Enum.HorizontalAlignment.Center; layout.VerticalAlignment=Enum.VerticalAlignment.Center; layout.Padding=UDim.new(0,10); layout.Parent=actionBox
local function actionButton(bg) local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(165,58); b.BackgroundColor3=bg; b.TextColor3=Color3.fromRGB(28,31,26); b.TextScaled=true; b.Font=Enum.Font.GothamBlack; b.AutoButtonColor=false; b.Parent=actionBox; corner(b,14); return b end
local attack=actionButton(Color3.fromRGB(244,114,86)); local skill=actionButton(Color3.fromRGB(86,157,235)); local guard=actionButton(Color3.fromRGB(160,176,154))
local cards=Instance.new("Frame"); cards.Size=UDim2.new(1,-60,0,68); cards.Position=UDim2.new(0,30,1,-190); cards.BackgroundTransparency=1; cards.Parent=screen
local cardLayout=Instance.new("UIListLayout"); cardLayout.FillDirection=Enum.FillDirection.Horizontal; cardLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left; cardLayout.VerticalAlignment=Enum.VerticalAlignment.Center; cardLayout.Padding=UDim.new(0,8); cardLayout.Parent=cards
local cardButtons={}; local currentCard=""; local busy=true
local function findGuardian(name) for _,m in ipairs(workspace:GetDescendants()) do if m:IsA("Model") and m:GetAttribute("VarietyName")==name and m.PrimaryPart then return m end end end
local function cameraFor(enemyName,side)
 local cam=workspace.CurrentCamera; local char=player.Character; local root=char and char:FindFirstChild("HumanoidRootPart"); local g=findGuardian(enemyName); if not root or not g then return end
 local target=g.PrimaryPart.Position+Vector3.new(0,2.5,0)
 local base=side=="enemy" and g.PrimaryPart.Position or root.Position
 local offset=side=="enemy" and Vector3.new(0,4.5,13) or Vector3.new(0,3.5,11)
 TweenService:Create(cam,TweenInfo.new(.55,Enum.EasingStyle.Quart,Enum.EasingDirection.InOut),{CFrame=CFrame.lookAt(base+offset,target)}):Play(); cam.CameraType=Enum.CameraType.Scriptable
end
local function restoreCamera() local cam=workspace.CurrentCamera; cam.CameraType=Enum.CameraType.Custom; local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid"); if hum then cam.CameraSubject=hum end end
local function setActions(on) busy=not on; for _,b in ipairs({attack,skill,guard}) do b.Active=on; b.AutoButtonColor=on end end
local function vfx(enemyName,phase,damage,accent)
 local g=findGuardian(enemyName); local root=g and g.PrimaryPart
 if phase=="PlayerAttack" and root then
  local p=Instance.new("Part"); p.Anchored=true; p.CanCollide=false; p.Shape=Enum.PartType.Ball; p.Material=Enum.Material.Neon; p.Color=accent or Color3.new(1,1,1); p.Size=Vector3.new(.8,.8,.8); p.CFrame=root.CFrame*CFrame.new(0,1.5,-5); p.Parent=workspace
  TweenService:Create(p,TweenInfo.new(.28,Enum.EasingStyle.Quad),{CFrame=root.CFrame*CFrame.new(0,1.5,0),Size=Vector3.new(4,4,4),Transparency=.85}):Play(); Debris:AddItem(p,.35)
 elseif phase=="EnemyAttack" and root then
  local char=player.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart")
  if hrp then
   local flash=Instance.new("Part"); flash.Anchored=true; flash.CanCollide=false; flash.Shape=Enum.PartType.Ball; flash.Material=Enum.Material.Neon; flash.Color=Color3.fromRGB(255,85,85); flash.Size=Vector3.new(1,1,1); flash.CFrame=hrp.CFrame; flash.Parent=workspace
   TweenService:Create(flash,TweenInfo.new(.2),{Size=Vector3.new(4,4,4),Transparency=1}):Play(); Debris:AddItem(flash,.25)
  end
 end
 if damage and damage>0 then
  local d=txt(screen,UDim2.fromOffset(180,70),UDim2.new(.5,-90,.42,0),Color3.fromRGB(255,90,70),Enum.Font.GothamBlack); d.BackgroundTransparency=1; d.Text="-"..damage; d.TextStrokeTransparency=.35
  TweenService:Create(d,TweenInfo.new(.65,Enum.EasingStyle.Back),{Position=UDim2.new(.5,-90,.32,0),TextTransparency=1}):Play(); Debris:AddItem(d,.7)
 end
end
local function rebuildCards(deck)
 for _,b in ipairs(cardButtons) do b:Destroy() end; cardButtons={}
 for i,n in ipairs(deck or {}) do
  local b=Instance.new("TextButton"); b.Size=UDim2.fromOffset(112,58); b.Text=n; b.TextScaled=true; b.Font=Enum.Font.GothamBlack; b.TextColor3=Color3.fromRGB(40,45,36); b.BackgroundColor3=(n==currentCard and Color3.fromRGB(255,221,45) or Color3.fromRGB(245,241,218)); b.Parent=cards; corner(b,14)
  b.Activated:Connect(function() if not busy and n~=currentCard then setActions(false); switchCard:FireServer(n) end end); table.insert(cardButtons,b)
 end
end
attack.Activated:Connect(function() if not busy then setActions(false); battleAction:FireServer("Attack") end end)
skill.Activated:Connect(function() if not busy then setActions(false); battleAction:FireServer("Skill") end end)
guard.Activated:Connect(function() if not busy then setActions(false); battleAction:FireServer("Guard") end end)
close.Activated:Connect(function() cancelBattle:FireServer(); screen.Enabled=false; restoreCamera() end)
startBattle.OnClientEvent:Connect(function(enemy,starter,deck)
 screen.Enabled=true; currentCard=starter; enemyName.Text=enemy; playerName.Text=starter; message.Text=starter.." entered the battle!"; turn.Text="TURN 1  •  YOUR MOVE"; status.Text=""; rebuildCards(deck); setActions(false); cameraFor(enemy,"player"); task.wait(.6); if screen.Enabled then setActions(true) end
end)
battleUpdate.OnClientEvent:Connect(function(s)
 enemyBar.Size=UDim2.fromScale(math.clamp(s.EnemyHP/s.EnemyMaxHP,0,1),1); playerBar.Size=UDim2.fromScale(math.clamp(s.PlayerHP/s.PlayerMaxHP,0,1),1)
 playerName.Text=s.PlayerName.."  "..s.PlayerHP.."/"..s.PlayerMaxHP; enemyName.Text=s.EnemyName.."  "..s.EnemyHP.."/"..s.EnemyMaxHP
 energyFill.Size=UDim2.fromScale(math.clamp((s.Energy or 0)/(s.MaxEnergy or 5),0,1),1); energyText.Text="ENERGY  "..tostring(s.Energy or 0).."/"..tostring(s.MaxEnergy or 5)
 currentCard=s.PlayerName; rebuildCards(s.Deck or {})
 attack.Text=s.PlayerAttackName or "Attack"; skill.Text=(s.PlayerSkillName or "Skill").."  ["..tostring(s.SkillCost or 2).."]"; guard.Text=s.PlayerGuardName or "Guard"
 message.Text=s.Message or ""; turn.Text=(s.TurnOwner=="Enemy" and "TURN "..tostring(s.Turn or 1).."  •  GUARDIAN MOVE" or "TURN "..tostring(s.Turn or 1).."  •  YOUR MOVE")
 status.Text=(s.Status~="" and "STATUS: "..s.Status or "")..((s.EnemyStatus~="" and "     ENEMY: "..s.EnemyStatus) or "")
 cameraFor(s.EnemyName,(s.Phase=="EnemyAttack" and "enemy" or "player")); vfx(s.EnemyName,s.Phase,s.Damage)
 setActions(s.CanAct==true)
end)
battleEnd.OnClientEvent:Connect(function(won,enemy) setActions(false); message.Text=won and ("VICTORY  •  "..enemy.." CARD + SEED") or "DEFEATED"; turn.Text="BATTLE COMPLETE"; task.wait(1.5); screen.Enabled=false; restoreCamera() end)
deckUpdate.OnClientEvent:Connect(function(d) if screen.Enabled then rebuildCards(d) end end)