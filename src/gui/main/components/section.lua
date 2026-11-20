return function(parent, text, Theme)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = string.upper(text)
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(lbl, "TextColor3", "SubText")
	lbl.Parent = parent
	return lbl
end