return function(parent, text, Theme)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 20)
	row.BackgroundTransparency = 1
	row.Parent = parent

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0, 0.5)
	bar.Position = UDim2.new(0, 0, 0.5, 0)
	bar.Size = UDim2.fromOffset(3, 11)
	bar.BorderSizePixel = 0
	Theme.Bind(bar, "BackgroundColor3", "Accent")
	bar.Parent = row
	Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

	local lbl = Instance.new("TextLabel")
	lbl.Position = UDim2.fromOffset(9, 0)
	lbl.Size = UDim2.new(0, 0, 1, 0)
	lbl.AutomaticSize = Enum.AutomaticSize.X
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = string.upper(text)
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "SubText")
	lbl.Parent = row

	local line = Instance.new("Frame")
	line.AnchorPoint = Vector2.new(1, 0.5)
	line.Position = UDim2.new(1, 0, 0.5, 0)
	line.Size = UDim2.new(1, -145, 0, 1)
	line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	line.BackgroundTransparency = 0.86
	line.BorderSizePixel = 0
	line.Parent = row

	local lg = Instance.new("UIGradient")
	lg.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	lg.Parent = line

	return row
end