local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local ProximityPromptService=game:GetService("ProximityPromptService")
local DataStoreService=game:GetService("DataStoreService")
local BattleDefinitions=require(ReplicatedStorage:WaitForChild("BattleDefinitions"))
local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes"; remotes.Parent=ReplicatedStorage
local function remote(n) local r=remotes:FindFirstChild(n) or Instance.new("RemoteEvent"); r.Name=n; r.Parent=remotes; return r end
local startBattle=remote("StartBattle"); local battleAction=remote("BattleAction"); local battleUpdate=remote("BattleUpdate"); local battleEnd=remote("BattleEnd"); local switchCard=remote("SwitchBattleCard"); local cancelBattle=remote("CancelBattle"); local deckUpdate=remote("DeckUpdate")
local collectionStore=DataStoreService:GetDataStore("GrowAVerity_Collection_v1")
local deckStore=DataStoreService:GetDataStore("GrowAVerity_Deck_v1")
local active={}; local decks={}
local GuardianStats={Verity={HP=105,Attack=18,Defense=18},Falsity={HP=105,Attack=21,Defense=15},Lovity={HP=110,Attack=17,Defense=19},Cruelty={HP=125,Attack=24,Defense=17}}

local function loadPlayer(p)
 local ok,data=pcall(function() return collectionStore:GetAsync("p_"..p.UserId) end)
 if ok and type(data)=="table" then for n,v in pairs(data) do if v==true and BattleDefinitions[n] then p:SetAttribute("Variety_"..n,true); p:SetAttribute("Seed_"..n,true) end end end
 local ok2,d=pcall(function() return deckStore:GetAsync("p_"..p.UserId) end)
 local deck={}
 if ok2 and type(d)=="table" then for _,n in ipairs(d) do if type(n)=="string" and BattleDefinitions[n] and p:GetAttribute("Variety_"..n) then table.insert(deck,n) end end end
 if #deck==0 then local starter=p:GetAttribute("StarterVariety"); if starter and BattleDefinitions[starter] then deck={starter} end end
 decks[p]=deck
end
local function saveCollection(p)
 local data={}
 for n in pairs(BattleDefinitions) do if p:GetAttribute("Variety_"..n) then data[n]=true end end
 pcall(function() collectionStore:SetAsync("p_"..p.UserId,data) end)
end
local function saveDeck(p)
 local d=decks[p] or {}
 pcall(function() deckStore:SetAsync("p_"..p.UserId,d) end)
end
Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(p) active[p]=nil; saveCollection(p); saveDeck(p); decks[p]=nil end)

local function owned(p,n) return p:GetAttribute("Variety_"..n)==true or p:GetAttribute("StarterVariety")==n end
local function validDeck(p,d)
 if type(d)~="table" or #d<1 or #d>6 then return false end
 local seen={}
 for _,n in ipairs(d) do if type(n)~="string" or not BattleDefinitions[n] or seen[n] or not owned(p,n) then return false end; seen[n]=true end
 return true
end
deckUpdate.OnServerEvent:Connect(function(p,d)
 if validDeck(p,d) then decks[p]=d; saveDeck(p); deckUpdate:FireClient(p,d) end
end)
Players.PlayerAdded:Connect(function(p) task.delay(1,function() if p.Parent then deckUpdate:FireClient(p,decks[p] or {}) end end) end)

local function distanceOk(p,m)
 local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 return root and m and m.PrimaryPart and (root.Position-m.PrimaryPart.Position).Magnitude<=16
end
local function findIndex(d,n) for i,v in ipairs(d) do if v==n then return i end end end
local function send(p,phase,msg,damage)
 local s=active[p]; if not s then return end
 battleUpdate:FireClient(p,{
  PlayerHP=s.PlayerHP,PlayerMaxHP=s.PlayerMaxHP,EnemyHP=s.EnemyHP,EnemyMaxHP=s.EnemyHPMax,
  EnemyName=s.EnemyName,PlayerName=s.CardName,CanAct=s.CanAct,Phase=phase or "Player",Message=msg or "",Damage=damage or 0,
  PlayerGuard=s.Guard,PlayerAttackName=s.Def.AttackName,PlayerSkillName=s.Def.SkillName,PlayerGuardName=s.Def.GuardName,
  Energy=s.Energy,MaxEnergy=s.MaxEnergy,Turn=s.Turn,TurnOwner=s.TurnOwner,Status=s.Status or "",EnemyStatus=s.EnemyStatus or "",
  Deck=s.Deck,ActiveIndex=s.ActiveIndex,SkillCost=s.Def.SkillCost
 })
end
local function endBattle(p,won)
 local s=active[p]; if not s then return end; active[p]=nil
 if won then local n=s.EnemyName; p:SetAttribute("Variety_"..n,true); p:SetAttribute("Seed_"..n,true); task.spawn(function() saveCollection(p) end) end
 battleEnd:FireClient(p,won,s.EnemyName)
end
local function setup(s,n)
 local d=BattleDefinitions[n]; s.CardName=n; s.Def=d; s.PlayerHP=d.HP; s.PlayerMaxHP=d.HP; s.PlayerAttack=d.Attack; s.PlayerDefense=d.Defense
 s.Energy=d.Energy; s.MaxEnergy=d.MaxEnergy; s.Guard=false; s.Status=""; s.StatusTurns=0
end
local function begin(p,g)
 if active[p] or not p:GetAttribute("StarterChosen") or not distanceOk(p,g) then return end
 local n=g:GetAttribute("VarietyName"); local e=n and GuardianStats[n]; local starter=p:GetAttribute("StarterVariety"); local d=BattleDefinitions[starter]
 if not e or not d then return end
 local deck=decks[p] or {starter}; if #deck==0 then deck={starter} end
 active[p]={EnemyName=n,EnemyHP=e.HP,EnemyHPMax=e.HP,EnemyAttack=e.Attack,EnemyDefense=e.Defense,EnemyStatus="",EnemyStatusTurns=0,CanAct=false,Deck=deck,ActiveIndex=findIndex(deck,starter) or 1,Turn=1,TurnOwner="Player"}
 setup(active[p],deck[findIndex(deck,starter) or 1]); startBattle:FireClient(p,n,active[p].CardName,deck)
 task.wait(.4); local s=active[p]; if not s then return end; s.CanAct=true; send(p,"Player",s.CardName.." entered the battle!",0)
end
ProximityPromptService.PromptTriggered:Connect(function(prompt,p) if prompt.Name=="BattlePrompt" then local g=prompt:FindFirstAncestorOfClass("Model"); if g then begin(p,g) end end end)
cancelBattle.OnServerEvent:Connect(function(p) active[p]=nil end)

local function tickStatus(s)
 if s.Status=="BLEED" and s.StatusTurns>0 then
  local d=5; s.PlayerHP=math.max(0,s.PlayerHP-d); s.StatusTurns-=1; return d,"Bleed dealt "..d.." damage!"
 end
 return 0,nil
end
local function enemyStatusTick(s)
 if s.EnemyStatus=="BLEED" and s.EnemyStatusTurns>0 then local d=5; s.EnemyHP=math.max(0,s.EnemyHP-d); s.EnemyStatusTurns-=1; return d,"Bleed dealt "..d.." damage to "..s.EnemyName.."!" end
 return 0,nil
end
local function enemyTurn(p,s)
 local dmg=math.max(4,math.floor(s.EnemyAttack-s.PlayerDefense*.3))
 if s.Guard then dmg=math.floor(dmg*.4); s.Guard=false end
 s.PlayerHP=math.max(0,s.PlayerHP-dmg); s.Energy=math.min(s.MaxEnergy,s.Energy+1); s.Turn+=1; s.TurnOwner="Player"
 if s.PlayerHP<=0 then send(p,"EnemyAttack",s.EnemyName.." attacked "..s.CardName.." for "..dmg.."!",dmg); task.wait(.65); endBattle(p,false); return false end
 send(p,"EnemyAttack",s.EnemyName.." attacked "..s.CardName.." for "..dmg.."!",dmg); task.wait(.7)
 local sd,sm=tickStatus(s); if sd>0 then if s.PlayerHP<=0 then endBattle(p,false); return false end; send(p,"Status",sm,sd); task.wait(.45) end
 s.CanAct=true; send(p,"Player",s.CardName.." is ready!",0); return true
end
switchCard.OnServerEvent:Connect(function(p,name)
 local s=active[p]; if not s or not s.CanAct or not validDeck(p,{name}) then return end
 local idx=findIndex(s.Deck,name); if not idx or idx==s.ActiveIndex then return end
 s.ActiveIndex=idx; setup(s,name); s.CanAct=false; s.TurnOwner="Enemy"; send(p,"Switch",p.Name.." switched to "..name.."!",0); task.wait(.55); if active[p]~=s then return end; enemyTurn(p,s)
end)
battleAction.OnServerEvent:Connect(function(p,action)
 local s=active[p]; if not s or not s.CanAct or s.TurnOwner~="Player" then return end
 local d=s.Def; if action~="Attack" and action~="Skill" and action~="Guard" then return end
 s.CanAct=false; local damage=0
 if action=="Attack" then
  damage=math.max(5,math.floor(s.PlayerAttack-s.EnemyDefense*.35)); s.EnemyHP=math.max(0,s.EnemyHP-damage); send(p,"PlayerAttack",s.CardName.." used "..d.AttackName.."!",damage)
 elseif action=="Skill" then
  if s.Energy<d.SkillCost then s.CanAct=true; send(p,"Player","Not enough Energy for "..d.SkillName.."!",0); return end
  s.Energy-=d.SkillCost
  if d.SkillType=="BARRIER" then s.Guard=true; send(p,"PlayerAttack",s.CardName.." used "..d.SkillName.."! Barrier up.",0)
  elseif d.SkillType=="CONTROL" then damage=math.max(8,math.floor(s.PlayerAttack+10-s.EnemyDefense*.25)); s.EnemyHP=math.max(0,s.EnemyHP-damage); s.EnemyStatus="DAZE"; s.EnemyStatusTurns=1; send(p,"PlayerAttack",s.CardName.." used "..d.SkillName.."! "..s.EnemyName.." is Dazed.",damage)
  elseif d.SkillType=="HEAL" then s.PlayerHP=math.min(s.PlayerMaxHP,s.PlayerHP+26); s.Status=""; s.StatusTurns=0; send(p,"PlayerAttack",s.CardName.." used "..d.SkillName.."! +26 HP.",0)
  elseif d.SkillType=="DOT" then damage=math.max(10,math.floor(s.PlayerAttack+5-s.EnemyDefense*.2)); s.EnemyHP=math.max(0,s.EnemyHP-damage); s.EnemyStatus="BLEED"; s.EnemyStatusTurns=3; send(p,"PlayerAttack",s.CardName.." used "..d.SkillName.."! Bleed applied.",damage) end
 elseif action=="Guard" then s.Guard=true; send(p,"PlayerAttack",s.CardName.." used "..d.GuardName.."!",0) end
 if s.EnemyHP<=0 then task.wait(.65); endBattle(p,true); return end
 task.wait(.75); if active[p]~=s then return end
 local ed,em=enemyStatusTick(s); if ed>0 then send(p,"Status",em,ed); task.wait(.45); if s.EnemyHP<=0 then endBattle(p,true); return end end
 if s.EnemyStatus=="DAZE" then s.EnemyStatus=""; s.EnemyStatusTurns=0; s.Turn+=1; s.Energy=math.min(s.MaxEnergy,s.Energy+1); s.CanAct=true; send(p,"Player",s.EnemyName.." is Dazed — your turn!",0); return end
 s.TurnOwner="Enemy"; enemyTurn(p,s)
end)