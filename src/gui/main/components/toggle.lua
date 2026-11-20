local TweenService = game:GetService("TweenService")

return function(parent, text, default, Theme, callback)
	local state = default or false

	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 44)
	row.BackgroundTransparency = 0.1
	row.Text = ""
	row.AutoButtonColor = false
	Theme.Bind(row, "BackgroundColor3", "Card")
	row.Parent = parent

	local rc = Instance.new("UICorner")
	rc.CornerRadius = UDim.new(0, 11)
	rc.Parent = row

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.85
	Theme.Bind(st, "Color", "Glow")
	st.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.Size = UDim2.new(1, -74, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "Text")
	lbl.Parent = row

	local pill = Instance.new("Frame")
	pill.AnchorPoint = Vector2.new(1, 0.5)
	pill.Position = UDim2.new(1, -12, 0.5, 0)
	pill.Size = UDim2.fromOffset(42, 22)
	pill.BackgroundColor3 = state and Theme.Current.Accent or Color3.fromRGB(48, 52, 66)
	pill.Parent = row

	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(1, 0)
	pc.Parent = pill

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = state and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.BackgroundColor3 = state and Color3.fromRGB(16, 18, 24) or Color3.fromRGB(240, 244, 255)
	knob.Parent = pill

	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob

	row.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(pill, TweenInfo.new(0.18), {
			BackgroundColor3 = state and Theme.Current.Accent or Color3.fromRGB(48, 52, 66),
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = state and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = state and Color3.fromRGB(16, 18, 24) or Color3.fromRGB(240, 244, 255),
		}):Play()
		if callback then
			callback(state)
		end
	end)

	return row
end