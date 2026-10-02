local SoundService=game:GetService("SoundService")
local ContentProvider=game:GetService("ContentProvider")
local s=SoundService:FindFirstChild("FarmlandMusic") or Instance.new("Sound")
s.Name="FarmlandMusic"; s.SoundId="rbxassetid://1837849285"; s.Volume=.25; s.Looped=true; s.Parent=SoundService
pcall(function() ContentProvider:PreloadAsync({s}) end)
if s.IsLoaded then s:Play() else task.spawn(function() s.Loaded:Wait(); s:Play() end) end