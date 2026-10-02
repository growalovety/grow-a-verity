-- Verity Builder Studio Plugin
-- Install as a local Studio plugin.
-- The plugin only consumes the explicit local bridge command protocol.

local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local toolbar = plugin:CreateToolbar("Verity Builder")
local button = toolbar:CreateButton(
	"Verity Builder",
	"Open the local Verity AI builder",
	""
)

local bridgeUrl = "http://127.0.0.1:47821"
local running = false

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	true,
	false,
	420,
	560,
	320,
	420
)

local widget = plugin:CreateDockWidgetPluginGui("VerityBuilder", widgetInfo)
widget.Title = "VERITY BUILDER"

local function mk(className, props, parent)
	local instance = Instance.new(className)
	for key, value in pairs(props or {}) do
		instance[key] = value
	end
	instance.Parent = parent
	return instance
end

local root = mk("Frame", {
	BackgroundColor3 = Color3.fromRGB(20, 22, 28),
	Size = UDim2.fromScale(1, 1),
}, widget)

mk("UIPadding", {
	PaddingTop = UDim.new(0, 12),
	PaddingBottom = UDim.new(0, 12),
	PaddingLeft = UDim.new(0, 12),
	PaddingRight = UDim.new(0, 12),
}, root)

mk("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 30),
	Text = "VERITY BUILDER",
	TextColor3 = Color3.fromRGB(245, 245, 250),
	TextSize = 20,
	Font = Enum.Font.GothamBold,
}, root)

local status = mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 36),
	Size = UDim2.new(1, 0, 0, 24),
	Text = "DISCONNECTED",
	TextColor3 = Color3.fromRGB(230, 100, 100),
	TextSize = 13,
	Font = Enum.Font.GothamMedium,
}, root)

local urlBox = mk("TextBox", {
	Position = UDim2.new(0, 0, 0, 70),
	Size = UDim2.new(1, 0, 0, 34),
	Text = bridgeUrl,
	PlaceholderText = "Bridge URL",
	ClearTextOnFocus = false,
	TextColor3 = Color3.new(1, 1, 1),
	BackgroundColor3 = Color3.fromRGB(35, 38, 48),
	Font = Enum.Font.Code,
	TextSize = 13,
}, root)

local testBtn = mk("TextButton", {
	Position = UDim2.new(0, 0, 0, 112),
	Size = UDim2.new(0.48, -4, 0, 34),
	Text = "TEST CONNECTION",
	BackgroundColor3 = Color3.fromRGB(55, 65, 85),
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 11,
}, root)

local pollBtn = mk("TextButton", {
	Position = UDim2.new(0.52, 4, 0, 112),
	Size = UDim2.new(0.48, -4, 0, 34),
	Text = "START LISTENING",
	BackgroundColor3 = Color3.fromRGB(55, 95, 70),
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 11,
}, root)

local log = mk("TextLabel", {
	Position = UDim2.new(0, 0, 0, 156),
	Size = UDim2.new(1, 0, 1, -156),
	BackgroundColor3 = Color3.fromRGB(14, 16, 21),
	Text = "Ready.\n",
	TextColor3 = Color3.fromRGB(205, 210, 220),
	TextSize = 12,
	Font = Enum.Font.Code,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, root)

local function append(message)
	log.Text = (log.Text .. tostring(message) .. "\n"):sub(-8000)
end

local function request(path, method, data)
	local requestOptions = {
		Url = bridgeUrl .. path,
		Method = method or "GET",
		Headers = {
			["Content-Type"] = "application/json",
		},
	}

	if data then
		requestOptions.Body = HttpService:JSONEncode(data)
	end

	return HttpService:RequestAsync(requestOptions)
end

local function ensure(parent, className, name)
	local existing = parent:FindFirstChild(name)
	if existing then
		return existing
	end

	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function buildVerity(command)
	local generatedWorld = ensure(workspace, "Folder", "GeneratedWorld")

	local old = generatedWorld:FindFirstChild(command.name or "Verity")
	if old then
		old:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = command.name or "Verity"
	model.Parent = generatedWorld

	local size = command.size or 4

	local rootPart = Instance.new("Part")
	rootPart.Name = "Root"
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.Shape = Enum.PartType.Ball
	rootPart.Size = Vector3.new(size, size, size)
	rootPart.Position = Vector3.new(0, size / 2, 0)
	rootPart.Color = Color3.fromRGB(255, 221, 45)
	rootPart.Material = Enum.Material.SmoothPlastic
	rootPart.TopSurface = Enum.SurfaceType.Smooth
	rootPart.BottomSurface = Enum.SurfaceType.Smooth
	rootPart.Parent = model

	-- Classic Verity: clean yellow body, no stem and no floating stud-text label.
	ChangeHistoryService:SetWaypoint("Verity Builder: BUILD_VERITY")
	Selection:Set({ model })
end

local function execute(command)
	if command.command == "BUILD_VERITY" then
		buildVerity(command)
		return "built " .. tostring(command.name)
	elseif command.command == "CREATE_FOLDER" then
		local folder = Instance.new("Folder")
		folder.Name = command.name or "GeneratedFolder"
		folder.Parent = workspace
		return "created folder"
	elseif command.command == "CREATE_PART" then
		local part = Instance.new("Part")
		part.Name = command.name or "GeneratedPart"
		part.Anchored = true
		part.Parent = workspace
		return "created part"
	elseif command.command == "DELETE_OBJECT" then
		local object = workspace:FindFirstChild(command.name or "")
		if object then
			object:Destroy()
			return "deleted"
		end
		return "not found"
	elseif command.command == "GET_GAME_STATE" then
		return "state requests are read-only in this plugin build"
	end

	return "command acknowledged: " .. tostring(command.command)
end

testBtn.MouseButton1Click:Connect(function()
	bridgeUrl = urlBox.Text

	local ok, response = pcall(function()
		return request("/health", "GET")
	end)

	if ok and response.Success then
		status.Text = "CONNECTED"
		status.TextColor3 = Color3.fromRGB(100, 220, 130)
		append("Connection OK")
	else
		status.Text = "ERROR"
		status.TextColor3 = Color3.fromRGB(240, 120, 90)
		append("Connection failed")
	end
end)

pollBtn.MouseButton1Click:Connect(function()
	running = not running
	pollBtn.Text = running and "STOP LISTENING" or "START LISTENING"
	append(running and "Listening..." or "Stopped")
end)

task.spawn(function()
	while true do
		task.wait(0.5)

		if running then
			local ok, response = pcall(function()
				return request("/next", "GET")
			end)

			if ok and response.Success then
				local decoded = HttpService:JSONDecode(response.Body)

				if decoded.item and decoded.item.command then
					local executeOk, message = pcall(execute, decoded.item.command)

					if executeOk then
						append("PASS " .. tostring(message))
					else
						append("FAIL " .. tostring(message))
					end
				end
			end
		end
	end
end)

button.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

widget.Enabled = true
