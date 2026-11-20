local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

return function(parent, text, minVal, maxVal, defaultVal, step, suffix, Theme, trackConn, callback)
	local value = defaultVal or minVal
	step = step or 1
	suffix = suffix or ""
	local initRel = (value - minVal) / (maxVal - minVal)

	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 62)
	box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	box.BackgroundTransparency = 0.91
	box.Parent = parent
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)

	local st = Theme.GlassStroke(box, { Transparency = 0.25 })

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(16, 10)
	lbl.Size = UDim2.new(1, -90, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = box

	local valLbl = Instance.new("TextLabel")
	valLbl.AnchorPoint = Vector2.new(1, 0)
	valLbl.Position = UDim2.new(1, -16, 0, 10)
	valLbl.Size = UDim2.fromOffset(70, 18)
	valLbl.BackgroundTransparency = 1
	valLbl.Font = Enum.Font.GothamMedium
	valLbl.Text = tostring(value) .. suffix
	valLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	valLbl.TextTransparency = 0.35
	valLbl.TextSize = 12
	valLbl.TextXAlignment = Enum.TextXAlignment.Right
	valLbl.Parent = box

	local hitArea = Instance.new("Frame")
	hitArea.Position = UDim2.new(0, 16, 0, 32)
	hitArea.Size = UDim2.new(1, -32, 0, 22)
	hitArea.BackgroundTransparency = 1
	hitArea.Parent = box

	local trackBar = Instance.new("Frame")
	trackBar.AnchorPoint = Vector2.new(0, 0.5)
	trackBar.Position = UDim2.fromScale(0, 0.5)
	trackBar.Size = UDim2.new(1, 0, 0, 9)
	trackBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	trackBar.BackgroundTransparency = 0.84
	trackBar.ClipsDescendants = true
	trackBar.BorderSizePixel = 0
	trackBar.Parent = hitArea
	Instance.new("UICorner", trackBar).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(initRel, 1)
	fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	fill.BackgroundTransparency = 0.08
	fill.BorderSizePixel = 0
	fill.Parent = trackBar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local sliding = false
	local function update(inputX)
		local rel = math.clamp((inputX - trackBar.AbsolutePosition.X) / math.max(trackBar.AbsoluteSize.X, 1), 0, 1)
		local raw = minVal + (maxVal - minVal) * rel
		value = math.clamp(math.floor((raw / step) + 0.5) * step, minVal, maxVal)
		local snappedRel = (value - minVal) / (maxVal - minVal)
		local disp = step < 1 and string.format("%.2f", value) or tostring(math.floor(value))
		valLbl.Text = disp .. suffix
		fill.Size = UDim2.fromScale(snappedRel, 1)
		if callback then callback(value) end
	end

	trackConn(hitArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			TweenService:Create(trackBar, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Size = UDim2.new(1, 0, 0, 13) }):Play()
			TweenService:Create(st, TweenInfo.new(0.18), { Transparency = 0 }):Play()
			TweenService:Create(valLbl, TweenInfo.new(0.18), { TextTransparency = 0 }):Play()
			update(input.Position.X)
		end
	end))
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			sliding = false
			TweenService:Create(trackBar, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Size = UDim2.new(1, 0, 0, 9) }):Play()
			TweenService:Create(st, TweenInfo.new(0.2), { Transparency = 0.25 }):Play()
			TweenService:Create(valLbl, TweenInfo.new(0.2), { TextTransparency = 0.35 }):Play()
		end
	end))

	return box
end