local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function createHub(parent, CatWare, Theme, onSelectPage)
	local player = Players.LocalPlayer
	local logoAsset = CatWare.Assets.Get("cw.png")
	local Icons = CatWare.Import("src/gui/main/icons.lua")

	local hub = Instance.new("Frame")
	hub.Name = "BentoHub"
	hub.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.Position = UDim2.fromScale(0.5, 0.5)
	hub.Size = UDim2.fromOffset(456, 408)
	hub.BackgroundTransparency = 1
	hub.ZIndex = 10
	hub.Parent = parent

	local hubScale = Instance.new("UIScale")
	hubScale.Scale = 0.92
	hubScale.Parent = hub

	-- 背後の透かしロゴ
	local watermark = Instance.new("ImageLabel")
	watermark.AnchorPoint = Vector2.new(0.5, 0.5)
	watermark.Position = UDim2.fromScale(0.5, 0.5)
	watermark.Size = UDim2.fromOffset(310, 310)
	watermark.BackgroundTransparency = 1
	watermark.Image = logoAsset
	watermark.ImageTransparency = 0.88
	watermark.ScaleType = Enum.ScaleType.Fit
	watermark.ZIndex = 1
	watermark.Parent = hub

	local tiles = {}
	local tileDefs = {
		{ id = "visuals",  label = "Visuals",   pos = UDim2.fromOffset(0, 0) },
		{ id = "models",   label = "3D Models", pos = UDim2.fromOffset(236, 0) },
		{ id = "settings", label = "Settings",  pos = UDim2.fromOffset(0, 212) },
		{ id = "themes",   label = "Themes",    pos = UDim2.fromOffset(236, 212) },
	}

	for _, def in ipairs(tileDefs) do
		local tile = Instance.new("TextButton")
		tile.Name = def.id
		tile.Position = def.pos
		tile.Size = UDim2.fromOffset(220, 196)
		tile.BackgroundTransparency = 0.14
		tile.Text = ""
		tile.AutoButtonColor = false
		tile.ClipsDescendants = true
		tile.ZIndex = 5
		Theme.Bind(tile, "BackgroundColor3", "Tile")
		tile.Parent = hub

		table.insert(tiles, tile)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 16)
		corner.Parent = tile

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.2
		stroke.Transparency = 0.84
		Theme.Bind(stroke, "Color", "Glow")
		stroke.Parent = tile

		local tScale = Instance.new("UIScale")
		tScale.Scale = 1
		tScale.Parent = tile

		-- 発光グロー（3層）
		local glows = {}
		for _, gc in ipairs({
			{ size = 128, base = 0.94, hover = 0.88 },
			{ size = 82,  base = 0.90, hover = 0.82 },
			{ size = 46,  base = 0.86, hover = 0.76 },
		}) do
			local g = Instance.new("Frame")
			g.AnchorPoint = Vector2.new(0.5, 0.5)
			g.Position = UDim2.new(0.5, 0, 0.42, 0)
			g.Size = UDim2.fromOffset(gc.size, gc.size)
			g.BackgroundTransparency = gc.base
			g.BorderSizePixel = 0
			g.ZIndex = 6
			Theme.Bind(g, "BackgroundColor3", "Glow")
			g.Parent = tile
			Instance.new("UICorner", g).CornerRadius = UDim.new(1, 0)
			table.insert(glows, { frame = g, base = gc.base, hover = gc.hover })
		end

		-- 図形アイコン（文字化けなし）
		Icons.Create(def.id, tile, Theme)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.AnchorPoint = Vector2.new(0.5, 0)
		nameLbl.Position = UDim2.new(0.5, 0, 0.62, 0)
		nameLbl.Size = UDim2.new(1, -24, 0, 24)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.Text = def.label
		nameLbl.TextSize = 16
		nameLbl.ZIndex = 7
		Theme.Bind(nameLbl, "TextColor3", "Text")
		nameLbl.Parent = tile

		tile.MouseEnter:Connect(function()
			TweenService:Create(tScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Scale = 1.03 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0.5 }):Play()
			for _, g in ipairs(glows) do
				TweenService:Create(g.frame, TweenInfo.new(0.2), { BackgroundTransparency = g.hover }):Play()
			end
		end)
		tile.MouseLeave:Connect(function()
			TweenService:Create(tScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint), { Scale = 1 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 0.84 }):Play()
			for _, g in ipairs(glows) do
				TweenService:Create(g.frame, TweenInfo.new(0.2), { BackgroundTransparency = g.base }):Play()
			end
		end)
		tile.MouseButton1Click:Connect(function()
			onSelectPage(def.id, def.label)
		end)
	end

	-- 中央のくり抜き枠＋プロフィールカード
	local cutout = Instance.new("Frame")
	cutout.AnchorPoint = Vector2.new(0.5, 0.5)
	cutout.Position = UDim2.fromScale(0.5, 0.5)
	cutout.Size = UDim2.fromOffset(128, 128)
	cutout.BackgroundColor3 = Color3.fromRGB(4, 5, 8)
	cutout.BackgroundTransparency = 0.25
	cutout.ZIndex = 15
	cutout.Parent = hub
	Instance.new("UICorner", cutout).CornerRadius = UDim.new(0, 20)

	local profile = Instance.new("Frame")
	profile.AnchorPoint = Vector2.new(0.5, 0.5)
	profile.Position = UDim2.fromScale(0.5, 0.5)
	profile.Size = UDim2.fromOffset(112, 112)
	profile.BackgroundTransparency = 0.08
	profile.ZIndex = 20
	Theme.Bind(profile, "BackgroundColor3", "Card")
	profile.Parent = hub
	Instance.new("UICorner", profile).CornerRadius = UDim.new(0, 15)

	local pStroke = Instance.new("UIStroke")
	pStroke.Thickness = 1.2
	pStroke.Transparency = 0.72
	Theme.Bind(pStroke, "Color", "Glow")
	pStroke.Parent = profile

	local avatar = Instance.new("ImageLabel")
	avatar.AnchorPoint = Vector2.new(0.5, 0)
	avatar.Position = UDim2.new(0.5, 0, 0, 14)
	avatar.Size = UDim2.fromOffset(44, 44)
	avatar.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
	avatar.Parent = profile
	Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and thumb then
			avatar.Image = thumb
		end
	end)

	local dispName = Instance.new("TextLabel")
	dispName.AnchorPoint = Vector2.new(0.5, 0)
	dispName.Position = UDim2.new(0.5, 0, 0, 64)
	dispName.Size = UDim2.new(1, -12, 0, 18)
	dispName.BackgroundTransparency = 1
	dispName.Font = Enum.Font.GothamBold
	dispName.Text = player.DisplayName
	dispName.TextSize = 12
	dispName.TextTruncate = Enum.TextTruncate.AtEnd
	Theme.Bind(dispName, "TextColor3", "Text")
	dispName.Parent = profile

	local userName = Instance.new("TextLabel")
	userName.AnchorPoint = Vector2.new(0.5, 0)
	userName.Position = UDim2.new(0.5, 0, 0, 82)
	userName.Size = UDim2.new(1, -12, 0, 14)
	userName.BackgroundTransparency = 1
	userName.Font = Enum.Font.Gotham
	userName.Text = "@" .. player.Name
	userName.TextSize = 10
	userName.TextTruncate = Enum.TextTruncate.AtEnd
	Theme.Bind(userName, "TextColor3", "SubText")
	userName.Parent = profile

	local hint = Instance.new("TextLabel")
	hint.AnchorPoint = Vector2.new(0.5, 0)
	hint.Position = UDim2.new(0.5, 0, 1, 14)
	hint.Size = UDim2.fromOffset(300, 18)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.Gotham
	hint.Text = "CatWare v" .. CatWare.Version .. "  •  RightShift で開閉"
	hint.TextSize = 12
	hint.TextTransparency = 0.2
	Theme.Bind(hint, "TextColor3", "SubText")
	hint.Parent = hub

	return {
		Frame = hub,
		Scale = hubScale,
		Tiles = tiles,
	}
end

return createHub