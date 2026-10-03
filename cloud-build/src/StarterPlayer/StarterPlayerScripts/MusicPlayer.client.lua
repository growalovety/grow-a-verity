local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local group=SoundService:FindFirstChild("GrowAVerityMusic") or Instance.new("SoundGroup"); group.Name="GrowAVerityMusic"; group.Parent=SoundService
local tracks={
 Farm={Id="rbxassetid://1837169004",Volume=.22},
 Explore={Id="rbxassetid://1844986119",Volume=.18},
 Battle={Id="rbxassetid://117734156401874",Volume=.24},
}
local sounds={}
for name,data in pairs(tracks) do
 local s=SoundService:FindFirstChild("GrowAVerityMusic_"..name) or Instance.new("Sound")
 s.Name="GrowAVerityMusic_"..name; s.SoundId=data.Id; s.Volume=data.Volume; s.Looped=true; s.SoundGroup=group; s.Parent=SoundService; sounds[name]=s
end
pcall(function() ContentProvider:PreloadAsync({sounds.Farm,sounds.Explore,sounds.Battle}) end)
local function musicVolume() return math.clamp(tonumber(player:GetAttribute("MusicVolume")) or .25,0,1) end
local function setVolumes()
 local v=musicVolume(); group.Volume=1
 for _,s in pairs(sounds) do s.Volume=(tracks[string.match(s.Name,"([^_]+)$")] and tracks[string.match(s.Name,"([^_]+)$")].Volume or .2)*v/.25 end
end
local function playOnly(name)
 for n,s in pairs(sounds) do if n==name then if not s.IsPlaying then s:Play() end else if s.IsPlaying then s:Stop() end end end
end
local function targetTrack()
 local pg=player:FindFirstChild("PlayerGui"); local battle=pg and pg:FindFirstChild("BattleUI")
 if battle and battle.Enabled then return "Battle" end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if root and root.Position.Z>760 then return "Explore" end
 return "Farm"
end
player:GetAttributeChangedSignal("MusicVolume"):Connect(setVolumes)
player.CharacterAdded:Connect(function(char) char:WaitForChild("HumanoidRootPart"); task.wait(.2); playOnly(targetTrack()) end)
setVolumes(); task.spawn(function() while true do task.wait(.5); playOnly(targetTrack()) end end)
