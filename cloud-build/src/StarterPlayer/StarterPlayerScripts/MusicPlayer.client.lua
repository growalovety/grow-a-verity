local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local Players=game:GetService("Players")
local player=Players.LocalPlayer
local s=SoundService:FindFirstChild("FarmlandMusic") or Instance.new("Sound")
s.Name="FarmlandMusic"
s.SoundId="rbxassetid://1837849285"
s.Volume=tonumber(player:GetAttribute("MusicVolume")) or .25
s.Looped=true
s.Parent=SoundService
pcall(function() ContentProvider:PreloadAsync({s}) end)
local function apply()
 s.Volume=math.clamp(tonumber(player:GetAttribute("MusicVolume")) or .25,0,1)
end
player:GetAttributeChangedSignal("MusicVolume"):Connect(apply)
apply()
if s.IsLoaded then s:Play() else task.spawn(function() s.Loaded:Wait(); s:Play() end) end