local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Components = {}

function Components.Section(parent, text, Theme)
	Theme = Theme or Components.Theme -- ← この1行を追加
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = string.upper(text)
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "SubText")
	lbl.Parent = parent
end

function Components.Button(parent, text, subtext, isDanger, Theme, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, subtext and 50 or 40)
	btn.BackgroundTransparency = 0.15
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent

	if isDanger then
		btn.BackgroundColor3 = Color3.fromRGB(52, 22, 28)
	else
		Theme.Bind(btn, "BackgroundColor3", "Card")
	end

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 11)
	c.Parent = btn

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.88
	Theme.Bind(st, "Color", isDanger and "Danger" or "Glow")
	st.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, subtext and 7 or 0)
	lbl.Size = UDim2.new(1, -28, 0, subtext and 18 or 40)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.Text = text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", isDanger and "Danger" or "Text")
	lbl.Parent = btn

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.Position = UDim2.fromOffset(14, 26)
		sub.Size = UDim2.new(1, -28, 0, 16)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.Text = subtext
		sub.TextSize = 11
		sub.TextXAlignment = Enum.TextXAlignment.Left
		Theme.Bind(sub, "TextColor3", "SubText")
		sub.Parent = btn
	end

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isDanger and Color3.fromRGB(72, 28, 36) or Theme.Current.CardHover,
		}):Play()
		TweenService:Create(st, TweenInfo.new(0.15), { Transparency = 0.65 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isDanger and Color3.fromRGB(52, 22, 28) or Theme.Current.Card,
		}):Play()
		TweenService:Create(st, TweenInfo.new(0.15), { Transparency = 0.88 }):Play()
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return btn
end

function Components.Toggle(parent, text, default, Theme, callback)
	local state = default or false

	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundTransparency = 0.15
	row.Text = ""
	row.AutoButtonColor = false
	Theme.Bind(row, "BackgroundColor3", "Card")
	row.Parent = parent

	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(0, 11)
	rc.Parent = row

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.88
	Theme.Bind(st, "Color", "Glow")
	st.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.Size = UDim2.new(1, -74, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.Text = text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "Text")
	lbl.Parent = row

	local pill = Instance.new("Frame")
	pill.AnchorPoint = Vector2.new(1, 0.5)
	pill.Position = UDim2.new(1, -12, 0.5, 0)
	pill.Size = UDim2.fromOffset(40, 22)
	pill.BackgroundColor3 = state and Theme.Current.Accent or Color3.fromRGB(42, 46, 58)
	pill.Parent = row

	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(1, 0)
	pc.Parent = pill

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.BackgroundColor3 = state and Color3.fromRGB(16, 18, 24) or Color3.fromRGB(235, 240, 250)
	knob.Parent = pill

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	row.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(pill, TweenInfo.new(0.18), {
			BackgroundColor3 = state and Theme.Current.Accent or Color3.fromRGB(42, 46, 58),
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = state and Color3.fromRGB(16, 18, 24) or Color3.fromRGB(235, 240, 250),
		}):Play()
		if callback then
			callback(state)
		end
	end)
end

function Components.Slider(parent, text, minVal, maxVal, defaultVal, step, suffix, Theme, trackConn, callback)
	local value = defaultVal or minVal
	step = step or 1
	suffix = suffix or ""

	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 58)
	box.BackgroundTransparency = 0.15
	Theme.Bind(box, "BackgroundColor3", "Card")
	box.Parent = parent

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 11)
	bc.Parent = box

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.88
	Theme.Bind(st, "Color", "Glow")
	st.Parent = box

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, 9)
	lbl.Size = UDim2.new(1, -84, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
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
	trackBar.Position = UDim2.new(0, 14, 0, 38)
	trackBar.Size = UDim2.new(1, -28, 0, 6)
	trackBar.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
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
end

return Components