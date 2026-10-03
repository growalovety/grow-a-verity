local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local player=Players.LocalPlayer
local remote=ReplicatedStorage:WaitForChild("GameRemotes"):WaitForChild("ExploreEvent")
local gui=Instance.new("ScreenGui"); gui.Name="ExploreEventsUI"; gui.IgnoreGuiInset=true; gui.ResetOnSpawn=false; gui.DisplayOrder=28; gui.Parent=player:WaitForChild("PlayerGui")
local card=Instance.new("Frame"); card.Size=UDim2.fromOffset(430,72); card.Position=UDim2.new(.5,-215,0,168); card.BackgroundColor3=Color3.fromRGB(25,33,44); card.BackgroundTransparency=1; card.Visible=false; card.Parent=gui
local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(0,14); corner.Parent=card
local stroke=Instance.new("UIStroke"); stroke.Color=Color3.fromRGB(239,193,78); stroke.Transparency=.25; stroke.Thickness=1.5; stroke.Parent=card
local title=Instance.new("TextLabel"); title.Size=UDim2.new(1,-24,0,28); title.Position=UDim2.fromOffset(12,8); title.BackgroundTransparency=1; title.TextColor3=Color3.fromRGB(239,193,78); title.Font=Enum.Font.GothamBlack; title.TextScaled=true; title.Parent=card
local body=Instance.new("TextLabel"); body.Size=UDim2.new(1,-24,0,26); body.Position=UDim2.fromOffset(12,37); body.BackgroundTransparency=1; body.TextColor3=Color3.fromRGB(238,244,252); body.Font=Enum.Font.GothamBold; body.TextScaled=true; body.Parent=card
remote.OnClientEvent:Connect(function(t,b)
    title.Text=t or "EVENT"; body.Text=b or ""; card.Visible=true; card.BackgroundTransparency=1
    TweenService:Create(card,TweenInfo.new(.18),{BackgroundTransparency=.08}):Play()
    task.delay(4,function() if card.Visible then local tw=TweenService:Create(card,TweenInfo.new(.25),{BackgroundTransparency=1}); tw:Play(); tw.Completed:Wait(); card.Visible=false end end)
end)
