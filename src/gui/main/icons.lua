local Icons = {}

Icons.List = {
	home     = "rbxassetid://10723407389", -- lucide-home
	visuals  = "rbxassetid://10734966248", -- lucide-star
	models   = "rbxassetid://10709782497", -- lucide-box
	settings = "rbxassetid://10734950309", -- lucide-settings
	themes   = "rbxassetid://10734910187", -- lucide-paintbrush
	minus    = "rbxassetid://10734896206", -- lucide-minus
	close    = "rbxassetid://10747384394", -- lucide-x
	check    = "rbxassetid://10709790644", -- lucide-check
}

function Icons.Get(id)
	return Icons.List[id] or ""
end

function Icons.Create(id, parent, Theme, size)
	local s = size or 22
	local img = Instance.new("ImageLabel")
	img.Name = "LucideIcon"
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.Size = UDim2.fromOffset(s, s)
	img.BackgroundTransparency = 1
	img.Image = Icons.Get(id)
	img.ScaleType = Enum.ScaleType.Fit
	Theme.Bind(img, "ImageColor3", "Accent")
	img.Parent = parent
	return img
end

return Icons