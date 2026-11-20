local TweenService = game:GetService("TweenService")

return function(parent, text, default, Theme, callback)
	local state = default or false
	local APPLE_GREEN = Color3.fromRGB(52, 199, 89)
	local OFF_BG = Color3.fromRGB(255, 255, 255)

	local row = Instance.new("TextButton")
	row.Size = UDim2.new(1, 0, 0, 46)
	row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	row.BackgroundTransparency = 0.91
	row.Text = ""
	row.AutoButtonColor = false
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 14)

	local st = Theme.GlassStroke(row, { Transparency = 0.25 })

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(16, 0)
	lbl.Size = UDim2.new(1, -82, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local pill = Instance.new("Frame")
	pill.AnchorPoint = Vector2.new(1, 0.5)
	pill.Position = UDim2.new(1, -14, 0.5, 0)
	pill.Size = UDim2.fromOffset(46, 26)
	pill.BackgroundColor3 = state and APPLE_GREEN or OFF_BG
	pill.BackgroundTransparency = state and 0 or 0.78
	pill.BorderSizePixel = 0
	pill.Parent = row
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.AnchorPoint = Vector2.new(0, 0.5)
	knob.Position = state and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
	knob.Size = UDim2.fromOffset(22, 22)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = pill
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	row.MouseEnter:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.18), { BackgroundTransparency = 0.85 }):Play()
		TweenService:Create(st, TweenInfo.new(0.18), { Transparency = 0 }):Play()
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.18), { BackgroundTransparency = 0.91 }):Play()
		TweenService:Create(st, TweenInfo.new(0.18), { Transparency = 0.25 }):Play()
	end)

	row.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(pill, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
			BackgroundColor3 = state and APPLE_GREEN or OFF_BG,
			BackgroundTransparency = state and 0 or 0.78,
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
			Position = state and UDim2.new(0, 22, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		}):Play()
		if callback then callback(state) end
	end)

	return row
end