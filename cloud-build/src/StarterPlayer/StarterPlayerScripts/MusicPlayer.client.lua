local SoundService=game:GetService("SoundService")
local s=SoundService:FindFirstChild("FarmlandMusic") or Instance.new("Sound")
s.Name="FarmlandMusic" s.SoundId="rbxassetid://1837849285" s.Volume=.16 s.Looped=true s.Parent=SoundService
if not s.IsPlaying then s:Play() end