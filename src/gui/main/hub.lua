local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function createHub(parent, CatWare, Theme, onSelectPage)
	local player = Players.LocalPlayer
	local logoAsset = CatWare.Assets.Get("cw.png")
	local glowAsset = CatWare.Assets.Get("glow.png")
	if glowAsset == "" then
		glowAsset = "rbxassetid://10822615828" -- 万が一のフォールバック光テクスチャ
	end

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

	local hoverIn = TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local hoverOut = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

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

		-- 滑らかな丸い光（ラジアルグロー）
		local glow = Instance.new("ImageLabel")
		glow.Name = "SoftGlow"
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Position = UDim2.new(0.5, 0, 0.42, 0)
		glow.Size = UDim2.fromOffset(145, 145)
		glow.BackgroundTransparency = 1
		glow.Image = glowAsset
		glow.ImageTransparency = 0.72
		glow.ScaleType = Enum.ScaleType.Fit
		glow.ZIndex = 6
		Theme.Bind(glow, "ImageColor3", "Glow")
		glow.Parent = tile

		-- Lucide アイコン
		local icon = Icons.Create(def.id, tile, Theme)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.AnchorPoint = Vector2.new(0.5, 0)
		nameLbl.Position = UDim2.new(0.5, 0, 0.62, 0)
		nameLbl.Size = UDim2.new(1, -24, 0, 24)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.Text = def.label
		nameLbl.TextSize = 16
		nameLbl.TextTransparency = 0.12
		nameLbl.ZIndex = 7
		Theme.Bind(nameLbl, "TextColor3", "Text")
		nameLbl.Parent = tile

		-- ホバー：明るく発光 ＋ サイズ拡大Tween
		tile.MouseEnter:Connect(function()
			TweenService:Create(tScale, hoverIn, { Scale = 1.045 }):Play()
			TweenService:Create(tile, hoverIn, { BackgroundColor3 = Theme.Current.CardHover }):Play()
			TweenService:Create(stroke, hoverIn, { Transparency = 0.35 }):Play()
			TweenService:Create(glow, hoverIn, {
				Size = UDim2.fromOffset(225, 225),
				ImageTransparency = 0.35,
			}):Play()
			TweenService:Create(icon, hoverIn, {
				Size = UDim2.fromOffset(48, 48),
				ImageTransparency = 0,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
			TweenService:Create(nameLbl, hoverIn, { TextTransparency = 0 }):Play()
		end)

		tile.MouseLeave:Connect(function()
			TweenService:Create(tScale, hoverOut, { Scale = 1 }):Play()
			TweenService:Create(tile, hoverOut, { BackgroundColor3 = Theme.Current.Tile }):Play()
			TweenService:Create(stroke, hoverOut, { Transparency = 0.84 }):Play()
			TweenService:Create(glow, hoverOut, {
				Size = UDim2.fromOffset(145, 145),
				ImageTransparency = 0.72,
			}):Play()
			TweenService:Create(icon, hoverOut, {
				Size = UDim2.fromOffset(40, 40),
				ImageTransparency = 0.15,
				ImageColor3 = Theme.Current.Accent,
			}):Play()
			TweenService:Create(nameLbl, hoverOut, { TextTransparency = 0.12 }):Play()
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