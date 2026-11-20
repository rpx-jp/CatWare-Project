local Shadow = {}

function Shadow.Create(parent, asset, opts)
	opts = opts or {}
	local pad = opts.Padding or 26
	local offsetY = opts.OffsetY or 8
	local transparency = opts.Transparency or 0.35

	local img = Instance.new("ImageLabel")
	img.Name = opts.Name or "DropShadow"
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = opts.Position or UDim2.new(0.5, 0, 0.5, offsetY)
	img.Size = opts.Size or UDim2.new(1, pad * 2, 1, pad * 2)
	img.BackgroundTransparency = 1
	img.Image = asset
	img.ImageTransparency = transparency
	img.ScaleType = Enum.ScaleType.Slice
	img.SliceCenter = Rect.new(48, 48, 80, 80)
	img.ZIndex = opts.ZIndex or 1
	img.Parent = parent

	return img
end

return Shadow