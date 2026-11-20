local TweenService = game:GetService("TweenService")

return function(parent, text, default, Theme, callback)
	local state = default or false

	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 44)
	row.BackgroundTransparency = 0.14
	row.Text = ""
	row.AutoButtonColor = false
	Theme.Bind(row, "BackgroundColor3", "Card")
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 12)

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.86
	Theme.Bind(st, "Color", "Glow")
	st.Parent = row

	local sheen = Instance.new("Frame")
	sheen.Size = UDim2.fromScale(1, 1)
	sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sheen.BackgroundTransparency = 1
	sheen.BorderSizePixel = 0
	sheen.Parent = row
	Instance.new("UICorner", sheen).CornerRadius = UDim.new(0, 12)

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, 0)
	lbl.Size = UDim2.new(1, -110, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "Text")
	lbl.Parent = row

	local stateLbl = Instance.new("TextLabel")
	stateLbl.AnchorPoint = Vector2.new(1, 0.5)
	stateLbl.Position = UDim2.new(1, -62, 0.5, 0)
	stateLbl.Size = UDim2.fromOffset(30, 16)
	stateLbl.BackgroundTransparency = 1
	stateLbl.Font = Enum.Font.GothamBold
	stateLbl.Text = state and "ON" or "OFF"
	stateLbl.TextSize = 10
	stateLbl.TextXAlignment = Enum.TextXAlignment.Right
	stateLbl.TextColor3 = state and Theme.Current.Accent or Theme.Current.SubText
	stateLbl.Parent = row

	local pill = Instance.new("Frame")
	pill.AnchorPoint = Vector2.new(1, 0.5)
	pill.Position = UDim2.new(1, -12, 0.5, 0)
	pill.Size = UDim2.fromOffset(42, 22)
	pill.BackgroundColor3 = state and Theme.Current.Accent or Color3.fromRGB(48, 52, 66)
	pill.Parent = row
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = state and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	knob.Size = UDim2.fromOffset(16, 16)
	knob.BackgroundColor3 = state and Color3.fromRGB(16, 18, 24) or Color3.fromRGB(240, 244, 255)
	knob.Parent = pill
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	row.MouseEnter:Connect(function()
		TweenService:Create(sheen, TweenInfo.new(0.16), { BackgroundTransparency = 0.94 }):Play()
		TweenService:Create(st, TweenInfo.new(0.16), { Transparency = 0.58 }):Play()
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(sheen, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(st, TweenInfo.new(0.16), { Transparency = 0.86 }):Play()
	end)

	row.MouseButton1Click:Connect(function()
		state = not state
		stateLbl.Text = state and "ON" or "OFF"
		TweenService:Create(stateLbl, TweenInfo.new(0.18), {
			TextColor3 = state and Theme.Current.Accent or Theme.Current.SubText,
		}):Play()
		TweenService:Create(pill, TweenInfo.new(0.18), {
			BackgroundColor3 = state and Theme.Current.Accent or Color3.fromRGB(48, 52, 66),
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = state and UDim2.new(0, 23, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = state and Color3.fromRGB(16, 18, 24) or Color3.fromRGB(240, 244, 255),
		}):Play()
		if callback then callback(state) end
	end)

	return row
end