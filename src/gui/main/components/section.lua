return function(parent, text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.GothamMedium
	lbl.Text = "  " .. text
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextTransparency = 0.45
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = parent
	return lbl
end