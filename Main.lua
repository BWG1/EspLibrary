local ESP_SETTINGS = {
    ChamsColor = Color3.fromRGB(255, 152, 220),
    Teamcheck = false,
    playerChams = false,
    glowChamsEnabled = false,
    boxEspEnabled = false,
}

local function isValidSurface(part)
    return part:IsA("BasePart") and
           part.Name ~= "HumanoidRootPart" and
           part.Parent ~= game.Players.LocalPlayer.Character
end

local function destroyBoxHandleAdornment(part)
	if not isValidSurface(part) then
		return
	end

	if part:FindFirstChild("BoxHandleAdornment") and part:FindFirstChild("BoxHandleAdornment").Name ~= "InvisGlowChams" and part:FindFirstChild("BoxHandleAdornment").Name ~= "GlowChams" then
		part.BoxHandleAdornment:Destroy()
	end
end

local function createBoxHandleAdornment(part)
    if not isValidSurface(part) then
        return
    end

    local boxHandleAdornment = Instance.new("BoxHandleAdornment")
    boxHandleAdornment.Size = part.Size + Vector3.new(0.01, 0.01, 0.01)
    boxHandleAdornment.Color3 = ESP_SETTINGS.ChamsColor
    boxHandleAdornment.AlwaysOnTop = true
    boxHandleAdornment.Adornee = part
    boxHandleAdornment.ZIndex = 10
    boxHandleAdornment.Parent = part
end

local function applyChams()
    while true do
		wait(1)
		if ESP_SETTINGS.playerChams then
			for _, player in pairs(game.Players:GetPlayers()) do
				if player then
					if player.Character then
						if ESP_SETTINGS.Teamcheck and player.Team == game.Players.LocalPlayer.Team then
							continue
						end
						for _, part in pairs(player.Character:GetChildren()) do
                            if not part:FindFirstChild("BoxHandleAdornment") then
                               	createBoxHandleAdornment(part)
                            end
						end
					end
				end
			end
		else
			for _, player in pairs(game.Players:GetPlayers()) do
				if player then
					if player.Character then
						for _, part in pairs(player.Character:GetChildren()) do
							destroyBoxHandleAdornment(part)
						end
					end
				end
			end
		end
	end
end

coroutine.wrap(applyChams)()

local function addHighlight(model)
	if model then
		local highlight = Instance.new("Highlight")
		highlight.FillColor = Color3.fromRGB(239, 21, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineColor = Color3.fromRGB(215, 147, 255)
		highlight.OutlineTransparency = 0.5
		highlight.Parent = model
	end
end

local function removeHighlight(model)
	if model then
		if model:FindFirstChild("Highlight") then
			model.Highlight:Destroy()
		end
	end
end

local function addItemEsp(part, name)
	if part then
		local billboard = Instance.new("BillboardGui")
		billboard.AlwaysOnTop = true
		billboard.Name = "ItemEsp"
		billboard.Parent = part
		billboard.Size = UDim2.new(1, 0, 1, 0)
		local textLabel = Instance.new("TextLabel")
		textLabel.BackgroundTransparency = 1
		textLabel.RichText = true
		textLabel.TextSize = 8
		textLabel.TextColor3 = Color3.fromRGB(255, 170, 33)
		textLabel.Text = part.Name
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Parent = billboard

		if name and name ~= nil then
			textLabel.Text = tostring(name)
		end
	end
end

local function removeItemEsp(model)
	if model then
		if model:FindFirstChild("ItemEsp") then
			model.ItemEsp:Destroy()
		end
	end
end

local function addNpcName(model, name)
	if model then
		if model:FindFirstChild("Head") then
			local billboard = Instance.new("BillboardGui")
			billboard.AlwaysOnTop = true
			billboard.StudsOffset = Vector3.new(0, 1.25, 0)
			billboard.Size = UDim2.new(1, 0, 1, 0)
			billboard.Name = "NameEsp"
			billboard.Parent = model.Head
			local textLabel = Instance.new("TextLabel")
			textLabel.BackgroundTransparency = 1
			textLabel.RichText = true
			textLabel.TextSize = 14
			textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			textLabel.Font = Enum.Font.Highway
			textLabel.Size = UDim2.new(1, 0, 0.2, 0)
			textLabel.TextStrokeTransparency = 0
			textLabel.TextStrokeColor3 = Color3.fromRGB(255, 0, 200)
			textLabel.TextScaled = false
			textLabel.Parent = billboard

			if name and name ~= nil then
			     textLabel.Text = name
			else
			     textLabel.Text = model.Name
			end

			if model:FindFirstChild("Humanoid") then
				model.Humanoid.HealthDisplayDistance = 0
				model.Humanoid.DisplayDistanceType = "None"
			end
		else
			warn("No Head Part Found For: " .. model.Name)
		end
	end
end

local function removeNpcName(model)
	if model then
		if model:FindFirstChild("Head") then
			if model:FindFirstChild("Head"):FindFirstChild("NameEsp") then
				model.Head.NameEsp:Destroy()
			end
		end
	end
end

local function addNpcChams(model)
	if model then
		for _, part in pairs(model:GetChildren()) do
			if isValidSurface(part) and not part:FindFirstChild("BoxHandleAdornment") then
				createBoxHandleAdornment(part)
			end
		end
	end
end

local function removeNpcChams(model)
	if model then
		for _, part in pairs(model:GetChildren()) do
			if isValidSurface(part) then
				if part:FindFirstChild("BoxHandleAdornment") then
					part.BoxHandleAdornment:Destroy()
				end
			end
		end
	end
end

local activeBoxes = {}

local function updateBoxes()
	while true do
		wait(0.15)
		for model, boxes in pairs(activeBoxes) do
			for _, box in pairs(boxes) do
				if box and box.Parent and game.Workspace.CurrentCamera then
					local part = box.Adornee
					local rayDirection = (part.Position - game.Workspace.CurrentCamera.CFrame.Position).unit * 1000

					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
					raycastParams.FilterType = Enum.RaycastFilterType.Exclude

					local raycastResult = game.Workspace:Raycast(game.Workspace.CurrentCamera.CFrame.Position, rayDirection, raycastParams)

					if raycastResult and raycastResult.Instance:IsDescendantOf(model) then
						box.Transparency = 1
					else
						box.Transparency = 0
					end
				end
			end
		end
	end
end

local activeGlowChams = {}

local function addGlowChams(model)
	for _, part in pairs(model:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			local glowPart = Instance.new("Part")

			if part.Name == "Handle" then
				continue
			end
			
			if part.Name ~= "Head" then
				glowPart.Size = part.Size * 1.15
				glowPart.CFrame = part.CFrame
				glowPart.Transparency = 0.2
				glowPart.Material = Enum.Material.Neon
				glowPart.Color = Color3.fromRGB(255, 255, 255)
				glowPart.Anchored = false
				glowPart.CanCollide = false
				glowPart.Name = "GlowCHams"
				glowPart.Parent = part
				
				local outline = Instance.new("BoxHandleAdornment")
				outline.Size = part.Size
				outline.Transparency = 0.4
				outline.Color3 = Color3.fromRGB(103, 89, 255)
				outline.Name = "Outline"
				outline.Parent = part
				outline.ZIndex = 10
				outline.Adornee = part
				outline.AlwaysOnTop = true
				table.insert(activeGlowChams, glowPart)
			end

			if part.Name == "Head" then
				local outline = Instance.new("CylinderHandleAdornment")
				outline.Transparency = 0.4
				outline.Color3 = Color3.fromRGB(103, 89, 255)
				outline.Name = "Outline"
				outline.ZIndex = 10
				outline.Adornee = part
				outline.AlwaysOnTop = true
				outline.Height = 1.15
				outline.CFrame = CFrame.Angles(math.rad(90), 0, 0)
				outline.Radius = 0.6
				outline.Parent = part
				
				glowPart.Shape = "Cylinder"
				glowPart.Size = Vector3.new(1.4, 1.4, 1.4)
				glowPart.CFrame = part.CFrame * CFrame.Angles(math.rad(90), math.rad(90), 0)
				glowPart.Transparency = 0.2
				glowPart.Material = Enum.Material.Neon
				glowPart.Color = Color3.fromRGB(255, 255, 255)
				glowPart.Anchored = false
				glowPart.CanCollide = false
				glowPart.Name = "GlowChams"
				glowPart.Parent = part
				table.insert(activeGlowChams, glowPart)
			end

			local weld = Instance.new("WeldConstraint")
			weld.Part0 = glowPart
			weld.Part1 = part
			weld.Parent = glowPart
			table.insert(activeGlowChams, weld)
		end
	end
end

local function removeGlowChams()
	for _, part in pairs(activeGlowChams) do
		if part and part ~= nil then
			part:Destroy()
			activeGlowChams[part] = nil
		end
	end
end

local function addVisChams(model)
	local boxes = {}
		
	for _, part in pairs(model:GetDescendants()) do
		if model == game.Players.LocalPlayer.Character then
			continue
		end
	
		if part:IsA("Accessory") then
			part:Destroy()
			continue
		end
			
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			local glowPart = Instance.new("Part")
	
			if part.Name == "Handle" then
				continue
			end
	
			glowPart.Size = part.Size * 1.05
			glowPart.CFrame = part.CFrame
			glowPart.Transparency = 0.2
			glowPart.Material = Enum.Material.Neon
			glowPart.Color = Color3.fromRGB(200, 133, 255)
			glowPart.Anchored = false
			glowPart.CanCollide = false
			glowPart.Name = "GlowChams"
			glowPart.Parent = model
	
			if part.Name == "Head" then
				glowPart.Shape = "Ball"
				glowPart.Size = Vector3.new(1.5, 1.5, 1.5)
			end
	
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = glowPart
			weld.Part1 = part
			weld.Parent = glowPart
	
			local box = Instance.new("BoxHandleAdornment")
			box.ZIndex = 10
			box.AlwaysOnTop = true
			box.Color3 = Color3.fromRGB(7, 255, 3)
			box.Size = part.Size
			box.Adornee = part
			box.Name = "InvisGlowChams"
			box.Parent = part
	
			table.insert(boxes, box)
		end
	end

	activeBoxes[model] = boxes
end

local function removeVisChams()
	for model, boxes in pairs(activeBoxes) do
		for _, box in pairs(boxes) do
			if box then
				box:Destroy()
			end
		end
		activeBoxes[model] = nil

		for _, part in pairs(model:GetDescendants()) do
			if part:IsA("BasePart") and part.Name == "GlowChams" then
				part:Destroy()
			end
		end
	end
end

coroutine.wrap(updateBoxes)()

local function addPointLight(model)
	if model.PrimaryPart then
		local pointlight = Instance.new("PointLight")
		pointlight.Brightness = 8
		pointlight.Color = Color3.fromRGB(8, 255, 234)
		pointlight.Parent = model.PrimaryPart
	end
end

local espBillboards = {}

local function destroyBoxESP()
	for _, billboard in pairs(espBillboards) do
		billboard:Destroy()
	end
	espBillboards = {}
end

local function createBillboardGui(rootPart)
	local camera = game.Workspace.CurrentCamera
	local hrp2D = camera:WorldToViewportPoint(rootPart.Position)
	local distance = (camera.CFrame.Position - rootPart.Position).magnitude

	-- Calculate box size based on distance
	local scale = math.clamp(distance / 200, 1, 2) -- Adjust the divisor and multiplier to fit your needs

	-- Get the size of the player from the BillboardGui's perspective
	local charSize = (camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y - camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2.6, 0)).Y)
	local boxSize = Vector2.new(math.floor(charSize * scale), math.floor(charSize * scale * 1.1))

	-- Create the BillboardGui
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Adornee = rootPart
	billboardGui.Size = UDim2.new(0, boxSize.X, 0, boxSize.Y)
	billboardGui.StudsOffset = Vector3.new(0, -0.5, 0) -- Center the box vertically
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = rootPart

	local function createLine(position, size, color)
		local frame = Instance.new("Frame")
		frame.Position = position
		frame.Size = size
		frame.BackgroundColor3 = color
		frame.BorderSizePixel = 0
		frame.Parent = billboardGui
		return frame
	end

	local cornerColor = Color3.new(1, 1, 1) -- Example color (white)
	local lineLength = math.max(boxSize.X / 5, 5) -- Ensure line length is not too small
	local lineThickness = math.max(boxSize.Y / 25, 1) -- Ensure line thickness is not too small

	-- Top-left corner
	createLine(UDim2.new(0, 0, 0, 0), UDim2.new(0, lineLength, 0, lineThickness), cornerColor) -- Horizontal line
	createLine(UDim2.new(0, 0, 0, 0), UDim2.new(0, lineThickness, 0, lineLength), cornerColor) -- Vertical line

	-- Top-right corner
	createLine(UDim2.new(1, -lineLength, 0, 0), UDim2.new(0, lineLength, 0, lineThickness), cornerColor) -- Horizontal line
	createLine(UDim2.new(1, -lineThickness, 0, 0), UDim2.new(0, lineThickness, 0, lineLength), cornerColor) -- Vertical line

	-- Bottom-left corner
	createLine(UDim2.new(0, 0, 1, -lineThickness), UDim2.new(0, lineLength, 0, lineThickness), cornerColor) -- Horizontal line
	createLine(UDim2.new(0, 0, 1, -lineLength), UDim2.new(0, lineThickness, 0, lineLength), cornerColor) -- Vertical line

	-- Bottom-right corner
	createLine(UDim2.new(1, -lineLength, 1, -lineThickness), UDim2.new(0, lineLength, 0, lineThickness), cornerColor) -- Horizontal line
	createLine(UDim2.new(1, -lineThickness, 1, -lineLength), UDim2.new(0, lineThickness, 0, lineLength), cornerColor) -- Vertical line

	table.insert(espBillboards, billboardGui)
end

local cornerBoxes = {}

local function addCornerBox(model)
	table.insert(cornerBoxes, model)
end

local function applyBoxESP()
	while true do
		wait()
		destroyBoxESP()
		if boxEspEnabled then
			for _, enemy in pairs(enemyteam:GetChildren()) do
				if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") then
					createBillboardGui(enemy.HumanoidRootPart)
				end
			end
		end
	end
end

coroutine.wrap(applyBoxESP)()

local function applyCornersToModels()
	destroyBoxESP()
	
	if ESP_SETTINGS.boxEspEnabled then
		for _, enemy in pairs(cornerBoxes) do
			if enemy and enemy ~= nil and enemy:IsA("Model") and enemy.PrimaryPart then
				createBillboardGui(enemy.PrimaryPart)
			end
		end
	end
end

game:GetService("RunService").Heartbeat:Connect(applyCornersToModels)

return {
	ESP_SETTINGS = ESP_SETTINGS,
	addHighlight = addHighlight,
	removeHighlight = removeHighlight,
	addItemEsp = addItemEsp,
	removeItemEsp = removeItemEsp,
	addNpcChams = addNpcChams,
	removeNpcChams = removeNpcChams,
	addNpcName = addNpcName,
	removeNpcName = removeNpcName,
	addGlowChams = addGlowChams,
	removeGlowChams = removeGlowChams,
	addVisChams = addVisChams,
	removeVisChams = removeVisChams,
	addPointLight = addPointLight,
	addCornerBox = addCornerBox,
}
