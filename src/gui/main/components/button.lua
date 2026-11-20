local TweenService = game:GetService("TweenService")

return function(parent, text, subtext, isDanger, Theme, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, subtext and 52 or 40)
	btn.BackgroundTransparency = 0.1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = parent

	if isDanger then
		btn.BackgroundColor3 = Color3.fromRGB(56, 22, 28)
	else
		Theme.Bind(btn, "BackgroundColor3", "Card")
	end

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 11)
	c.Parent = btn

	local st = Instance.new("UIStroke")
	st.Thickness = 1
	st.Transparency = 0.85
	Theme.Bind(st, "Color", isDanger and "Danger" or "Glow")
	st.Parent = btn

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(14, subtext and 8 or 0)
	lbl.Size = UDim2.new(1, -44, 0, subtext and 18 or 40)
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
		sub.Size = UDim2.new(1, -44, 0, 16)
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
			BackgroundColor3 = isDanger and Color3.fromRGB(78, 28, 36) or Theme.Current.CardHover,
		}):Play()
		TweenService:Create(st, TweenInfo.new(0.15), { Transparency = 0.55 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = isDanger and Color3.fromRGB(56, 22, 28) or Theme.Current.Card,
		}):Play()
		TweenService:Create(st, TweenInfo.new(0.15), { Transparency = 0.85 }):Play()
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return btn
end