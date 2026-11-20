local UserInputService = game:GetService("UserInputService")

return function(parent, text, minVal, maxVal, defaultVal, step, suffix, Theme, trackConn, callback)
	local value = defaultVal or minVal
	step = step or 1
	suffix = suffix or ""

	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 60)
	box.BackgroundTransparency = 0.1
	Theme.Bind(box, "BackgroundColor3", "Card")
	box.Parent = parent

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 11)
	bc.Parent = box

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.85
	Theme.Bind(st, "Color", "Glow")
	st.Parent = box

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, 9)
	lbl.Size = UDim2.new(1, -84, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "Text")
	lbl.Parent = box

	local valLbl = Instance.new("TextLabel")
	valLbl.AnchorPoint = Vector2.new(1, 0)
	valLbl.Position = UDim2.new(1, -14, 0, 9)
	valLbl.Size = UDim2.fromOffset(70, 18)
	valLbl.BackgroundTransparency = 1
	valLbl.Font = Enum.Font.GothamBold
	valLbl.Text = tostring(value) .. suffix
	valLbl.TextSize = 12
	valLbl.TextXAlignment = Enum.TextXAlignment.Right
	Theme.Bind(valLbl, "TextColor3", "Accent")
	valLbl.Parent = box

	local trackBar = Instance.new("Frame")
	trackBar.Position = UDim2.new(0, 14, 0, 39)
	trackBar.Size = UDim2.new(1, -28, 0, 6)
	trackBar.BackgroundColor3 = Color3.fromRGB(42, 46, 60)
	trackBar.BorderSizePixel = 0
	trackBar.Parent = box

	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(1, 0)
	tc.Parent = trackBar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((value - minVal) / (maxVal - minVal), 1)
	fill.BorderSizePixel = 0
	Theme.Bind(fill, "BackgroundColor3", "Accent")
	fill.Parent = trackBar

	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(1, 0)
	fc.Parent = fill

	local sliding = false
	local function update(inputX)
		local rel = math.clamp((inputX - trackBar.AbsolutePosition.X) / math.max(trackBar.AbsoluteSize.X, 1), 0, 1)
		local raw = minVal + (maxVal - minVal) * rel
		value = math.clamp(math.floor((raw / step) + 0.5) * step, minVal, maxVal)
		local disp = step < 1 and string.format("%.2f", value) or tostring(math.floor(value))
		valLbl.Text = disp .. suffix
		fill.Size = UDim2.fromScale((value - minVal) / (maxVal - minVal), 1)
		if callback then
			callback(value)
		end
	end

	trackConn(trackBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			update(input.Position.X)
		end
	end))
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end))

	return box
end