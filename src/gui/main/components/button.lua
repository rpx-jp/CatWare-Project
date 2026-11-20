local TweenService = game:GetService("TweenService")

return function(parent, text, subtext, isDanger, Theme, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, subtext and 52 or 42)
	btn.BackgroundTransparency = 0.14
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent

	if isDanger then
		btn.BackgroundColor3 = Color3.fromRGB(56, 22, 28)
	else
		Theme.Bind(btn, "BackgroundColor3", "Card")
	end

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.86
	Theme.Bind(st, "Color", isDanger and "Danger" or "Glow")
	st.Parent = btn

	local sc = Instance.new("UIScale", btn)

	-- 角丸にフィットするガラス光沢
	local sheen = Instance.new("Frame")
	sheen.Size = UDim2.fromScale(1, 1)
	sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sheen.BackgroundTransparency = 1
	sheen.BorderSizePixel = 0
	sheen.Parent = btn
	Instance.new("UICorner", sheen).CornerRadius = UDim.new(0, 12)

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, subtext and 8 or 0)
	lbl.Size = UDim2.new(1, -46, 0, subtext and 18 or 42)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = text
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", isDanger and "Danger" or "Text")
	lbl.Parent = btn

	if subtext then
		local sub = Instance.new("TextLabel")
		sub.Position = UDim2.fromOffset(14, 27)
		sub.Size = UDim2.new(1, -46, 0, 16)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.Text = subtext
		sub.TextSize = 11
		sub.TextXAlignment = Enum.TextXAlignment.Left
		Theme.Bind(sub, "TextColor3", "SubText")
		sub.Parent = btn
	end

	local chev = Instance.new("TextLabel")
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -14, 0.5, 0)
	chev.Size = UDim2.fromOffset(16, 20)
	chev.BackgroundTransparency = 1
	chev.Font = Enum.Font.GothamBold
	chev.Text = "›"
	chev.TextSize = 18
	chev.TextTransparency = 0.5
	Theme.Bind(chev, "TextColor3", isDanger and "Danger" or "SubText")
	chev.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(sheen, TweenInfo.new(0.16), { BackgroundTransparency = 0.93 }):Play()
		TweenService:Create(st, TweenInfo.new(0.16), { Transparency = 0.55 }):Play()
		TweenService:Create(chev, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = UDim2.new(1, -10, 0.5, 0),
			TextTransparency = 0,
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(sheen, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(st, TweenInfo.new(0.16), { Transparency = 0.86 }):Play()
		TweenService:Create(chev, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Position = UDim2.new(1, -14, 0.5, 0),
			TextTransparency = 0.5,
		}):Play()
	end)
	btn.MouseButton1Down:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.08), { Scale = 0.985 }):Play()
	end)
	btn.MouseButton1Up:Connect(function()
		TweenService:Create(sc, TweenInfo.new(0.14, Enum.EasingStyle.Back), { Scale = 1 }):Play()
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	return btn
end