local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local SoundService=game:GetService("SoundService")
local sfxGroup=SoundService:FindFirstChild("GrowAVeritySFX") or Instance.new("SoundGroup")
sfxGroup.Name="GrowAVeritySFX"
sfxGroup.Parent=SoundService
local clickSound=SoundService:FindFirstChild("GrowAVerityClick") or Instance.new("Sound")
clickSound.Name="GrowAVerityClick"
clickSound.SoundId="rbxassetid://9120386436"
clickSound.Volume=.18
clickSound.SoundGroup=sfxGroup
clickSound.Parent=SoundService
local player=Players.LocalPlayer
local remotes=ReplicatedStorage:WaitForChild("GameRemotes")
local redeem=remotes:WaitForChild("RedeemCode")
local settingsUpdate=remotes:WaitForChild("SettingsUpdate")

local gui=Instance.new("ScreenGui")
gui.Name="SettingsUI"
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=25
gui.Parent=player:WaitForChild("PlayerGui")

local BG=Color3.fromRGB(17,23,31)
local PANEL=Color3.fromRGB(25,33,44)
local GREEN=Color3.fromRGB(76,199,139)
local DARK=Color3.fromRGB(238,244,252)
local MUTED=Color3.fromRGB(154,170,193)
local LINE=Color3.fromRGB(90,112,139)

local function corner(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r); c.Parent=o end
local function stroke(o,c,t,w) local s=Instance.new("UIStroke"); s.Color=c; s.Transparency=t or 0; s.Thickness=w or 1; s.Parent=o end
local function label(parent,text,size,pos,color,font)
 local l=Instance.new("TextLabel"); l.Size=size; l.Position=pos; l.BackgroundTransparency=1; l.Text=text; l.TextColor3=color; l.Font=font or Enum.Font.GothamBold; l.TextScaled=true; l.Parent=parent; return l
end
local function button(parent,text,size,pos,bg)
 local b=Instance.new("TextButton"); b.Size=size; b.Position=pos; b.BackgroundColor3=bg or PANEL; b.TextColor3=DARK; b.Text=text; b.Font=Enum.Font.GothamBold; b.TextScaled=true; b.AutoButtonColor=true; b.Parent=parent; corner(b,10); stroke(b,LINE,.15,1); return b
end

local panel=Instance.new("Frame")
panel.Size=UDim2.fromOffset(620,430)
panel.Position=UDim2.new(.5,-310,.5,-215)
panel.BackgroundColor3=BG
panel.Visible=false
panel.Parent=gui
corner(panel,18)
stroke(panel,GREEN,.15,2)

label(panel,"SETTINGS",UDim2.new(.7,0,0,48),UDim2.fromOffset(24,18),DARK,Enum.Font.GothamBlack)
local close=button(panel,"×",UDim2.fromOffset(42,42),UDim2.new(1,-58,0,18),Color3.fromRGB(34,44,58))

local musicValue=label(panel,"25%",UDim2.fromOffset(72,34),UDim2.fromOffset(500,86),DARK,Enum.Font.GothamBlack)
local sfxValue=label(panel,"80%",UDim2.fromOffset(72,34),UDim2.fromOffset(500,146),DARK,Enum.Font.GothamBlack)
label(panel,"MUSIC",UDim2.fromOffset(180,34),UDim2.fromOffset(28,86),DARK,Enum.Font.GothamBlack)
label(panel,"SOUND EFFECTS",UDim2.fromOffset(220,34),UDim2.fromOffset(28,146),DARK,Enum.Font.GothamBlack)

local musicMinus=button(panel,"−",UDim2.fromOffset(42,34),UDim2.fromOffset(390,86),Color3.fromRGB(235,226,199))
local musicPlus=button(panel,"+",UDim2.fromOffset(42,34),UDim2.fromOffset(560,86),Color3.fromRGB(48,76,58))
local sfxMinus=button(panel,"−",UDim2.fromOffset(42,34),UDim2.fromOffset(390,146),Color3.fromRGB(235,226,199))
local sfxPlus=button(panel,"+",UDim2.fromOffset(42,34),UDim2.fromOffset(560,146),Color3.fromRGB(222,239,218))

label(panel,"REDEEM CODE",UDim2.fromOffset(220,34),UDim2.fromOffset(28,216),DARK,Enum.Font.GothamBlack)
local codeBox=Instance.new("TextBox"); codeBox.Size=UDim2.fromOffset(350,44); codeBox.Position=UDim2.fromOffset(28,258); codeBox.BackgroundColor3=PANEL; codeBox.PlaceholderText="ENTER CODE"; codeBox.Text=""; codeBox.TextColor3=DARK; codeBox.PlaceholderColor3=MUTED; codeBox.Font=Enum.Font.GothamBold; codeBox.TextScaled=true; codeBox.ClearTextOnFocus=false; codeBox.Parent=panel; corner(codeBox,10); stroke(codeBox,LINE,.15,1)
local claim=button(panel,"CLAIM",UDim2.fromOffset(150,44),UDim2.fromOffset(402,258),GREEN); claim.TextColor3=Color3.new(1,1,1)
local result=label(panel,"",UDim2.new(.92,0,0,38),UDim2.fromOffset(28,315),MUTED,Enum.Font.GothamBold); result.TextXAlignment=Enum.TextXAlignment.Left

local function get(name,default)
 return math.clamp(tonumber(player:GetAttribute(name)) or default,0,1)
end
local function apply()
 local music=get("MusicVolume",.25)
 local sfx=get("SFXVolume",.8)
 musicValue.Text=math.floor(music*100+0.5).."%"
 sfxValue.Text=math.floor(sfx*100+0.5).."%"
 SoundService:SetAttribute("MusicVolume",music)
 SoundService:SetAttribute("SFXVolume",sfx)\n sfxGroup.Volume=sfx
end
local function setVolume(attr,delta)
 local value=math.clamp(get(attr,0)+delta,0,1)
 player:SetAttribute(attr,value)
 settingsUpdate:FireServer(attr=="MusicVolume" and value or nil,attr=="SFXVolume" and value or nil)
 apply()
end

musicMinus.Activated:Connect(function() setVolume("MusicVolume",-0.05) end)
musicPlus.Activated:Connect(function() setVolume("MusicVolume",0.05) end)
sfxMinus.Activated:Connect(function() setVolume("SFXVolume",-0.05) end)
sfxPlus.Activated:Connect(function() setVolume("SFXVolume",0.05) end)
close.Activated:Connect(function() panel.Visible=false end)
claim.Activated:Connect(function()
 result.Text="Checking code..."
 redeem:FireServer(codeBox.Text)
end)
redeem.OnClientEvent:Connect(function(ok,msg)
 result.Text=msg
 result.TextColor3=ok and GREEN or Color3.fromRGB(245,103,112)
 if ok then codeBox.Text="" end
end)

player:GetAttributeChangedSignal("MusicVolume"):Connect(apply)
player:GetAttributeChangedSignal("SFXVolume"):Connect(apply)
apply()

_G.GrowAVerityOpenSettings=function()
 panel.Visible=true
end


local wired={}
local function wireButton(obj)
 if not obj:IsA("GuiButton") or wired[obj] then return end
 wired[obj]=true
 obj.Activated:Connect(function()
  if sfxGroup.Volume<=0 then return end
  clickSound:Play()
 end)
end
for _,obj in ipairs(player:WaitForChild("PlayerGui"):GetDescendants()) do wireButton(obj) end
player.PlayerGui.DescendantAdded:Connect(wireButton)
