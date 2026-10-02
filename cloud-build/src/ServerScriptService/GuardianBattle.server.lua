local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ProximityPromptService=game:GetService("ProximityPromptService")
local DataStoreService=game:GetService("DataStoreService")
local BattleDefinitions=require(ReplicatedStorage:WaitForChild("BattleDefinitions"))
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes" remotes.Parent=ReplicatedStorage
local function remote(n) local r=remotes:FindFirstChild(n) or Instance.new("RemoteEvent") r.Name=n r.Parent=remotes return r end
local startBattle=remote("StartBattle"); local battleAction=remote("BattleAction"); local battleUpdate=remote("BattleUpdate"); local battleEnd=remote("BattleEnd"); local switchCard=remote("SwitchBattleCard"); local cancelBattle=remote("CancelBattle")
local collectionStore=DataStoreService:GetDataStore("GrowAVerity_Collection_v1")
local active={}
local GuardianStats={
 Verity={HP=105,Attack=18,Defense=18}, Falsity={HP=105,Attack=21,Defense=15}, Lovity={HP=110,Attack=17,Defense=19},
}
local function loadCollection(p)
 local ok,data=pcall(function() return collectionStore:GetAsync("p_"..p.UserId) end)
 if ok and type(data)=="table" then for name,owned in pairs(data) do if owned==true and BattleDefinitions[name] then p:SetAttribute("Variety_"..name,true); p:SetAttribute("Seed_"..name,true) end end end
end
local function saveCollection(p)
 local data={}
 for name in pairs(BattleDefinitions) do if p:GetAttribute("Variety_"..name) then data[name]=true end end
 pcall(function() collectionStore:SetAsync("p_"..p.UserId,data) end)
end
Players.PlayerAdded:Connect(loadCollection)
Players.PlayerRemoving:Connect(function(p) active[p]=nil saveCollection(p) end)
local function distanceOk(p,model)
 local c=p.Character local root=c and c:FindFirstChild("HumanoidRootPart") local target=model and model.PrimaryPart
 return root and target and (root.Position-target.Position).Magnitude<=16
end
local function sendState(p,phase,message,damage)
 local s=active[p] if not s then return end
 battleUpdate:FireClient(p,{
  PlayerHP=s.PlayerHP,PlayerMaxHP=s.PlayerMaxHP,EnemyHP=s.EnemyHP,EnemyMaxHP=s.EnemyMaxHP,
  EnemyName=s.EnemyName,PlayerName=s.CardName,CanAct=s.CanAct,Phase=phase or "Player",
  Message=message or "",Damage=damage or 0,PlayerGuard=s.Guard,PlayerAttackName=s.Def.AttackName,
  PlayerSkillName=s.Def.SkillName,PlayerGuardName=s.Def.GuardName,
 })
end
local function endBattle(p,won)
 local s=active[p] if not s then return end active[p]=nil
 if won then
  local n=s.EnemyName p:SetAttribute("Variety_"..n,true) p:SetAttribute("Seed_"..n,true)
  task.spawn(function() saveCollection(p) end)
 end
 battleEnd:FireClient(p,won,s.EnemyName)
end
local function setupCard(s,name)
 local d=BattleDefinitions[name]
 s.CardName=name;s.Def=d;s.PlayerHP=d.HP;s.PlayerMaxHP=d.HP;s.PlayerAttack=d.Attack;s.PlayerDefense=d.Defense;s.Role=d.Role;s.Guard=false
end
local function beginBattle(p,guardianModel)
 if active[p] or not p:GetAttribute("StarterChosen") or not distanceOk(p,guardianModel) then return end
 local name=guardianModel:GetAttribute("VarietyName"); local enemy=name and GuardianStats[name]
 local starter=p:GetAttribute("StarterVariety"); local d=starter and BattleDefinitions[starter]
 if not enemy or not d then return end
 active[p]={EnemyName=name,EnemyHP=enemy.HP,EnemyMaxHP=enemy.HP,EnemyAttack=enemy.Attack,EnemyDefense=enemy.Defense,CanAct=false}
 setupCard(active[p],starter)
 startBattle:FireClient(p,name,starter)
 task.wait(.35)
 local s=active[p] if not s then return end s.CanAct=true sendState(p,"Player",starter.." entered the battle!",0)
end
ProximityPromptService.PromptTriggered:Connect(function(prompt,p)
 if prompt.Name=="BattlePrompt" then local g=prompt:FindFirstAncestorOfClass("Model") if g then beginBattle(p,g) end end
end)
cancelBattle.OnServerEvent:Connect(function(p) active[p]=nil end)
switchCard.OnServerEvent:Connect(function(p,name)
 local s=active[p] if not s or not s.CanAct or type(name)~="string" or not BattleDefinitions[name] or not p:GetAttribute("Variety_"..name) then return end
 if s.CardName==name then return end
 setupCard(s,name); s.CanAct=false; sendState(p,"Switch",p.Name.." switched to "..name.."!",0)
 task.wait(.65)
 if active[p]~=s then return end
 local damage=math.max(4,math.floor(s.EnemyAttack-s.PlayerDefense*.3))
 s.PlayerHP=math.max(0,s.PlayerHP-damage)
 if s.PlayerHP<=0 then endBattle(p,false) return end
 s.CanAct=true sendState(p,"Player",name.." is ready!",damage)
end)
battleAction.OnServerEvent:Connect(function(p,action)
 local s=active[p] if not s or not s.CanAct then return end
 local d=s.Def
 if action~="Attack" and action~="Skill" and action~="Guard" then return end
 s.CanAct=false
 local damage=0
 if action=="Attack" then
  damage=math.max(5,math.floor(s.PlayerAttack-s.EnemyDefense*.35)); s.EnemyHP=math.max(0,s.EnemyHP-damage)
  sendState(p,"PlayerAttack",s.CardName.." used "..d.AttackName.."!",damage)
 elseif action=="Skill" then
  if s.Role=="Guardian" then s.Guard=true; sendState(p,"PlayerAttack",s.CardName.." used "..d.SkillName.."!",0)
  elseif s.Role=="Striker" then damage=math.max(8,math.floor(s.PlayerAttack+10-s.EnemyDefense*.25)); s.EnemyHP=math.max(0,s.EnemyHP-damage); sendState(p,"PlayerAttack",s.CardName.." used "..d.SkillName.."!",damage)
  else s.PlayerHP=math.min(s.PlayerMaxHP,s.PlayerHP+24); sendState(p,"PlayerAttack",s.CardName.." used "..d.SkillName.."!",0) end
 elseif action=="Guard" then s.Guard=true; sendState(p,"PlayerAttack",s.CardName.." used "..d.GuardName.."!",0) end
 if s.EnemyHP<=0 then task.wait(.55); endBattle(p,true) return end
 task.wait(.8)
 if active[p]~=s then return end
 local enemyDamage=math.max(4,math.floor(s.EnemyAttack-s.PlayerDefense*.3))
 if s.Guard then enemyDamage=math.floor(enemyDamage*.45); s.Guard=false end
 s.PlayerHP=math.max(0,s.PlayerHP-enemyDamage)
 if s.PlayerHP<=0 then sendState(p,"EnemyAttack",s.EnemyName.." attacked "..s.CardName.." for "..enemyDamage.."!",enemyDamage); task.wait(.75); endBattle(p,false); return end
 sendState(p,"EnemyAttack",s.EnemyName.." attacked "..s.CardName.." for "..enemyDamage.."!",enemyDamage)
 task.wait(.85)
 if active[p]==s then s.CanAct=true; sendState(p,"Player",s.CardName.." is ready!",0) end
end)