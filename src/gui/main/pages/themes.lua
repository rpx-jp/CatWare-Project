return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme
	local Icons = ctx.CatWare.Import("src/gui/main/icons.lua")

	C.Section(page, "Glass Material")

	local order = {
		{ key = "SpatialGlass", desc = "Vision Pro 標準のニュートラルガラス" },
		{ key = "FrostedMist",  desc = "淡い氷ブルーのフロストガラス" },
		{ key = "WarmTitanium", desc = "温かみのあるチタニウムガラス" },
		{ key = "Midnight",     desc = "映画鑑賞向けの落ち着いた暗めガラス" },
	}

	local checks = {}
	local function refresh()
		for k, c in pairs(checks) do
			c.Visible = (Theme.Current == Theme.Presets[k])
		end
	end

	for _, item in ipairs(order) do
		local preset = Theme.Presets[item.key]
		local btn = C.Button(page, preset.Name, item.desc, false, Theme, function()
			Theme.SetPreset(item.key)
			refresh()
		end)

		local chev = btn:FindFirstChild("Chevron")
		if chev then chev.Visible = false end

		local swatch = Instance.new("Frame")
		swatch.AnchorPoint = Vector2.new(1, 0.5)
		swatch.Position = UDim2.new(1, -16, 0.5, 0)
		swatch.Size = UDim2.fromOffset(22, 22)
		swatch.BackgroundColor3 = preset.Tile
		swatch.Parent = btn
		Instance.new("UICorner", swatch).CornerRadius = UDim.new(1, 0)

		local swStroke = Instance.new("UIStroke")
		swStroke.Color = Color3.fromRGB(255, 255, 255)
		swStroke.Thickness = 1
		swStroke.Transparency = 0.65
		swStroke.Parent = swatch

		-- Lucide check アイコン
		local check = Instance.new("ImageLabel")
		check.AnchorPoint = Vector2.new(1, 0.5)
		check.Position = UDim2.new(1, -48, 0.5, 0)
		check.Size = UDim2.fromOffset(16, 16)
		check.BackgroundTransparency = 1
		check.Image = Icons.Get("check")
		check.ImageColor3 = Color3.fromRGB(255, 255, 255)
		check.ScaleType = Enum.ScaleType.Fit
		check.Parent = btn

		checks[item.key] = check
	end

	refresh()
end