local TweenService = game:GetService("TweenService")

return function(parent, text, subtext, isDanger, Theme, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, subtext and 52 or 44)
	btn.BackgroundColor3 = isDanger and Color3.fromRGB(255, 75, 70) or Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = isDanger and 0.84 or 0.91
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 14)

	local st = Theme.GlassStroke(btn, {
		Color = isDanger and Color3.fromRGB(255, 110, 105) or Color3.fromRGB(255, 255, 255),
		Transparency = 0.25,
	})

	local sc = Instance.new("UIScale", btn)

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(16, subtext and 8 or 0)
	lbl.Size = UDim2.new(1, -48, 0, subtext and 18 or 44)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.Text = text
	lbl.TextColor3 = isDanger and Color3.fromRGB(255, 130, 125) or Color3.fromRGB(255, 255, 255)
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = btn

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.Position = UDim2.fromOffset(16, 27)
		sub.Size = UDim2.new(1, -48, 0, 16)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.Text = subtext
		sub.TextColor3 = Color3.fromRGB(255, 255, 255)
		sub.TextTransparency = 0.48
		sub.TextSize = 11
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Parent = btn
	end

	local chev = Instance.new("TextLabel")
	chev.Name = "Chevron"
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -14, 0.5, 0)
	chev.Size = UDim2.fromOffset(16, 20)
	chev.BackgroundTransparency = 1
	chev.Font = Enum.Font.GothamMedium
	chev.Text = "›"
	chev.TextColor3 = Color3.fromRGB(255, 255, 255)
	chev.TextTransparency = 0.55
	chev.TextSize = 18
	chev.Parent = btn

	local baseAlpha = isDanger and 0.84 or 0.91
	local hoverAlpha = isDanger and 0.74 or 0.84

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = hoverAlpha }):Play()
		TweenService:Create(st, TweenInfo.new(0.18), { Transparency = 0 }):Play()
		TweenService:Create(chev, TweenInfo.new(0.18), { TextTransparency = 0.15 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.18), { BackgroundTransparency = baseAlpha }):Play()
		TweenService:Create(st, TweenInfo.new(0.18), { Transparency = 0.25 }):Play()
		TweenService:Create(chev, TweenInfo.new(0.18), { TextTransparency = 0.55 }):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.08), { Scale = 0.985 }):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.15, Enum.EasingStyle.Quint), { Scale = 1 }):Play()
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	return btn
end