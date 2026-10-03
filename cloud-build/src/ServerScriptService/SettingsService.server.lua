local Players=game:GetService("Players")
local DataStoreService=game:GetService("DataStoreService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")

local remotes=ReplicatedStorage:FindFirstChild("GameRemotes") or Instance.new("Folder")
remotes.Name="GameRemotes"
remotes.Parent=ReplicatedStorage

local redeem=remotes:FindFirstChild("RedeemCode") or Instance.new("RemoteEvent")
redeem.Name="RedeemCode"
redeem.Parent=remotes

local settingsUpdate=remotes:FindFirstChild("SettingsUpdate") or Instance.new("RemoteEvent")
settingsUpdate.Name="SettingsUpdate"
settingsUpdate.Parent=remotes

local store=DataStoreService:GetDataStore("GrowAVerity_Settings_v1")
local playerStore=DataStoreService:GetDataStore("GrowAVerity_Player_v1")

local DEFAULT_MUSIC=.25
local DEFAULT_SFX=.8

local CODES={
 VERITY={Reward=250},
 GARDEN={Reward=500},
 BLOOM={Reward=750},
}

local function load(player)
 local ok,data=pcall(function() return store:GetAsync("p_"..player.UserId) end)
 data=ok and type(data)=="table" and data or {}
 player:SetAttribute("MusicVolume",math.clamp(tonumber(data.MusicVolume) or DEFAULT_MUSIC,0,1))
 player:SetAttribute("SFXVolume",math.clamp(tonumber(data.SFXVolume) or DEFAULT_SFX,0,1))
end

local function save(player)
 local music=math.clamp(tonumber(player:GetAttribute("MusicVolume")) or DEFAULT_MUSIC,0,1)
 local sfx=math.clamp(tonumber(player:GetAttribute("SFXVolume")) or DEFAULT_SFX,0,1)
 pcall(function()
  store:UpdateAsync("p_"..player.UserId,function(old)
   old=type(old)=="table" and old or {}
   old.MusicVolume=music
   old.SFXVolume=sfx
   old.Redeemed=type(old.Redeemed)=="table" and old.Redeemed or {}
   return old
  end)
 end)
end

local function grantCash(player,amount)
 local newCash=(tonumber(player:GetAttribute("Cash")) or 0)+amount
 player:SetAttribute("Cash",newCash)
 pcall(function()
  playerStore:UpdateAsync("p_"..player.UserId,function(old)
   old=type(old)=="table" and old or {}
   old.Cash=newCash
   return old
  end)
 end)
end

Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(save)

settingsUpdate.OnServerEvent:Connect(function(player,music,sfx)
 local changed=false
 if type(music)=="number" then player:SetAttribute("MusicVolume",math.clamp(music,0,1)); changed=true end
 if type(sfx)=="number" then player:SetAttribute("SFXVolume",math.clamp(sfx,0,1)); changed=true end
 if changed then task.spawn(save,player) end
end)

redeem.OnServerEvent:Connect(function(player,raw)
 if type(raw)~="string" then return end
 local code=string.upper((raw:gsub("^%s+",""):gsub("%s+$","")))
 local def=CODES[code]
 if not def then redeem:FireClient(player,false,"Invalid code."); return end
 local ok,data=pcall(function() return store:GetAsync("p_"..player.UserId) end)
 data=ok and type(data)=="table" and data or {}
 data.Redeemed=type(data.Redeemed)=="table" and data.Redeemed or {}
 if data.Redeemed[code] then redeem:FireClient(player,false,"Code already redeemed."); return end
 data.Redeemed[code]=true
 local saved=pcall(function()
  store:UpdateAsync("p_"..player.UserId,function(old)
   old=type(old)=="table" and old or {}
   old.MusicVolume=math.clamp(tonumber(player:GetAttribute("MusicVolume")) or DEFAULT_MUSIC,0,1)
   old.SFXVolume=math.clamp(tonumber(player:GetAttribute("SFXVolume")) or DEFAULT_SFX,0,1)
   old.Redeemed=type(old.Redeemed)=="table" and old.Redeemed or {}
   if old.Redeemed[code] then return old end
   old.Redeemed[code]=true
   return old
  end)
 end)
 if not saved then redeem:FireClient(player,false,"Try again in a moment."); return end
 grantCash(player,def.Reward)
 redeem:FireClient(player,true,"+"..def.Reward.." Cash")
end)
