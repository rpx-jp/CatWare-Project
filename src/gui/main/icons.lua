local Icons = {}

-- Lucide Icons (Roblox Asset ID)
Icons.List = {
	visuals  = "rbxassetid://10734966248", -- lucide-star
	models   = "rbxassetid://10709782497", -- lucide-box
	settings = "rbxassetid://10734950309", -- lucide-settings
	themes   = "rbxassetid://10734910187", -- lucide-paintbrush
}

function Icons.Get(id)
	return Icons.List[id] or ""
end

function Icons.Create(id, parent, Theme)
	local img = Instance.new("ImageLabel")
	img.Name = "LucideIcon"
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.new(0.5, 0, 0.41, 0)
	img.Size = UDim2.fromOffset(40, 40)
	img.BackgroundTransparency = 1
	img.Image = Icons.Get(id)
	img.ImageTransparency = 0.15
	img.ScaleType = Enum.ScaleType.Fit
	img.ZIndex = 7
	Theme.Bind(img, "ImageColor3", "Accent")
	img.Parent = parent
	return img
end

return Icons