local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

return function(parent, text, minVal, maxVal, defaultVal, step, suffix, Theme, trackConn, callback)
	local value = defaultVal or minVal
	step = step or 1
	suffix = suffix or ""
	local initRel = (value - minVal) / (maxVal - minVal)

	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 62)
	box.BackgroundTransparency = 0.14
	Theme.Bind(box, "BackgroundColor3", "Card")
	box.Parent = parent
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.86
	Theme.Bind(st, "Color", "Glow")
	st.Parent = box

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, 10)
	lbl.Size = UDim2.new(1, -90, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "Text")
	lbl.Parent = box

	-- 値を表示するピル型バッジ
	local valLbl = Instance.new("TextLabel")
	valLbl.AnchorPoint = Vector2.new(1, 0)
	valLbl.Position = UDim2.new(1, -12, 0, 9)
	valLbl.Size = UDim2.fromOffset(0, 20)
	valLbl.AutomaticSize = Enum.AutomaticSize.X
	valLbl.BackgroundTransparency = 0.35
	valLbl.Font = Enum.Font.GothamBold
	valLbl.Text = tostring(value) .. suffix
	valLbl.TextSize = 11
	Theme.Bind(valLbl, "BackgroundColor3", "Tile")
	Theme.Bind(valLbl, "TextColor3", "Accent")
	valLbl.Parent = box
	Instance.new("UICorner", valLbl).CornerRadius = UDim.new(1, 0)

	local vPad = Instance.new("UIPadding")
	vPad.PaddingLeft = UDim.new(0, 8)
	vPad.PaddingRight = UDim.new(0, 8)
	vPad.Parent = valLbl

	-- 掴みやすい当たり判定
	local hitArea = Instance.new("Frame")
	hitArea.Position = UDim2.new(0, 14, 0, 32)
	hitArea.Size = UDim2.new(1, -28, 0, 22)
	hitArea.BackgroundTransparency = 1
	hitArea.Parent = box

	local trackBar = Instance.new("Frame")
	trackBar.AnchorPoint = Vector2.new(0, 0.5)
	trackBar.Position = UDim2.fromScale(0, 0.5)
	trackBar.Size = UDim2.new(1, 0, 0, 5)
	trackBar.BackgroundColor3 = Color3.fromRGB(42, 46, 60)
	trackBar.BorderSizePixel = 0
	trackBar.Parent = hitArea
	Instance.new("UICorner", trackBar).CornerRadius = UDim.new(1, 0)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(initRel, 1)
	fill.BorderSizePixel = 0
	Theme.Bind(fill, "BackgroundColor3", "Accent")
	fill.Parent = trackBar
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	-- 丸いつまみ（Thumb）
	local thumb = Instance.new("Frame")
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.new(initRel, 0, 0.5, 0)
	thumb.Size = UDim2.fromOffset(13, 13)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 4
	thumb.Parent = trackBar
	Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

	local thumbScale = Instance.new("UIScale", thumb)

	local sliding = false
	local function update(inputX)
		local rel = math.clamp((inputX - trackBar.AbsolutePosition.X) / math.max(trackBar.AbsoluteSize.X, 1), 0, 1)
		local raw = minVal + (maxVal - minVal) * rel
		value = math.clamp(math.floor((raw / step) + 0.5) * step, minVal, maxVal)
		local snappedRel = (value - minVal) / (maxVal - minVal)
		local disp = step < 1 and string.format("%.2f", value) or tostring(math.floor(value))
		valLbl.Text = disp .. suffix
		fill.Size = UDim2.fromScale(snappedRel, 1)
		thumb.Position = UDim2.new(snappedRel, 0, 0.5, 0)
		if callback then callback(value) end
	end

	trackConn(hitArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			TweenService:Create(thumbScale, TweenInfo.new(0.15, Enum.EasingStyle.Back), { Scale = 1.32 }):Play()
			TweenService:Create(st, TweenInfo.new(0.15), { Transparency = 0.5 }):Play()
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
			TweenService:Create(thumbScale, TweenInfo.new(0.15), { Scale = 1 }):Play()
			TweenService:Create(st, TweenInfo.new(0.15), { Transparency = 0.86 }):Play()
		end
	end))

	return box
end