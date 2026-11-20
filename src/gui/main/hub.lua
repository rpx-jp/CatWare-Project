local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local function createHub(parent, CatWare, Theme, onSelectPage, trackConn, onClose)
	local player = Players.LocalPlayer
	local logoAsset = CatWare.Assets.Get("cw.png")
	local shadowAsset = CatWare.Assets.Get("shadow.png")
	local glowAsset = CatWare.Assets.Get("glow.png")
	if glowAsset == "" then
		glowAsset = "rbxassetid://10822615828"
	end

	local Icons = CatWare.Import("src/gui/main/icons.lua")
	local Shadow = CatWare.Import("src/utils/shadow.lua")

	local hub = Instance.new("Frame")
	hub.Name = "BentoDeck"
	hub.AnchorPoint = Vector2.new(0.5, 0.5)
	hub.Position = UDim2.fromScale(0.5, 0.5)
	hub.Size = UDim2.fromOffset(476, 374)
	hub.BackgroundTransparency = 1
	hub.ZIndex = 10
	hub.Parent = parent

	local hubScale = Instance.new("UIScale")
	hubScale.Scale = 0.92
	hubScale.Parent = hub

	local tiles = {}
	local hoverIn = TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local hoverOut = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	-- 共通のガラスカード土台を作る関数
	local function makeCardHolder(name, cx, cy, w, h, cornerRadius)
		local holder = Instance.new("Frame")
		holder.Name = name .. "_Holder"
		holder.AnchorPoint = Vector2.new(0.5, 0.5)
		holder.Position = UDim2.fromOffset(cx, cy)
		holder.Size = UDim2.fromOffset(w, h)
		holder.BackgroundTransparency = 1
		holder.ZIndex = 5
		holder.Parent = hub

		local sc = Instance.new("UIScale")
		sc.Scale = 1
		sc.Parent = holder

		Shadow.Create(holder, shadowAsset, {
			Padding = 22,
			OffsetY = 6,
			Transparency = 0.48,
			ZIndex = 1,
		})

		local card = Instance.new("TextButton")
		card.Name = name
		card.Size = UDim2.fromScale(1, 1)
		card.BackgroundTransparency = 0.12
		card.Text = ""
		card.AutoButtonColor = false
		card.ClipsDescendants = true
		card.ZIndex = 2
		Theme.Bind(card, "BackgroundColor3", "Tile")
		card.Parent = holder

		Instance.new("UICorner", card).CornerRadius = UDim.new(0, cornerRadius or 16)

		-- 上からほのかに光るガラスグラデーション
		local grad = Instance.new("UIGradient")
		grad.Rotation = 90
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(205, 212, 224)),
		})
		grad.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.2
		stroke.Transparency = 0.84
		Theme.Bind(stroke, "Color", "Glow")
		stroke.Parent = card

		-- ホバー時に明るく光らせる白いガラス光沢（絶対に黒くならない）
		local sheen = Instance.new("Frame")
		sheen.Name = "HoverSheen"
		sheen.Size = UDim2.fromScale(1, 1)
		sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sheen.BackgroundTransparency = 1
		sheen.BorderSizePixel = 0
		sheen.ZIndex = 3
		sheen.Parent = card

		table.insert(tiles, card)
		return holder, card, sc, stroke, sheen
	end

	-- ==========================================
	-- 1. 上部フローティングバー（476 x 42）
	-- ==========================================
	local _, topBar = makeCardHolder("TopBar", 238, 21, 476, 42, 13)
	topBar.Active = false

	local barLogo = Instance.new("ImageLabel")
	barLogo.AnchorPoint = Vector2.new(0, 0.5)
	barLogo.Position = UDim2.new(0, 10, 0.5, 0)
	barLogo.Size = UDim2.fromOffset(24, 24)
	barLogo.BackgroundTransparency = 1
	barLogo.Image = logoAsset
	barLogo.ScaleType = Enum.ScaleType.Fit
	barLogo.ZIndex = 5
	barLogo.Parent = topBar

	local barTitle = Instance.new("TextLabel")
	barTitle.Position = UDim2.fromOffset(42, 0)
	barTitle.Size = UDim2.new(0, 82, 1, 0)
	barTitle.BackgroundTransparency = 1
	barTitle.Font = Enum.Font.GothamBold
	barTitle.Text = "CatWare"
	barTitle.TextSize = 14
	barTitle.TextXAlignment = Enum.TextXAlignment.Left
	barTitle.ZIndex = 5
	Theme.Bind(barTitle, "TextColor3", "Text")
	barTitle.Parent = topBar

	local verBadge = Instance.new("TextLabel")
	verBadge.AnchorPoint = Vector2.new(0, 0.5)
	verBadge.Position = UDim2.new(0, 112, 0.5, 0)
	verBadge.Size = UDim2.fromOffset(38, 18)
	verBadge.BackgroundTransparency = 0.2
	verBadge.Font = Enum.Font.GothamBold
	verBadge.Text = "v" .. CatWare.Version
	verBadge.TextSize = 10
	verBadge.ZIndex = 5
	Theme.Bind(verBadge, "BackgroundColor3", "Card")
	Theme.Bind(verBadge, "TextColor3", "Accent")
	verBadge.Parent = topBar
	Instance.new("UICorner", verBadge).CornerRadius = UDim.new(1, 0)

	-- ライブ FPS / Ping 表示
	local liveDot = Instance.new("Frame")
	liveDot.AnchorPoint = Vector2.new(0, 0.5)
	liveDot.Position = UDim2.new(0, 232, 0.5, 0)
	liveDot.Size = UDim2.fromOffset(6, 6)
	liveDot.BackgroundColor3 = Color3.fromRGB(90, 235, 160)
	liveDot.BorderSizePixel = 0
	liveDot.ZIndex = 5
	liveDot.Parent = topBar
	Instance.new("UICorner", liveDot).CornerRadius = UDim.new(1, 0)

	local liveStats = Instance.new("TextLabel")
	liveStats.Position = UDim2.fromOffset(245, 0)
	liveStats.Size = UDim2.new(0, 150, 1, 0)
	liveStats.BackgroundTransparency = 1
	liveStats.Font = Enum.Font.GothamMedium
	liveStats.Text = "-- FPS  •  -- ms"
	liveStats.TextSize = 11
	liveStats.TextXAlignment = Enum.TextXAlignment.Left
	liveStats.ZIndex = 5
	Theme.Bind(liveStats, "TextColor3", "SubText")
	liveStats.Parent = topBar

	local fCount, fLast = 0, os.clock()
	if trackConn then
		trackConn(RunService.RenderStepped:Connect(function()
			if not hub.Visible then
				return
			end
			fCount += 1
			local now = os.clock()
			if now - fLast >= 0.5 then
				local fps = math.floor(fCount / (now - fLast) + 0.5)
				fCount, fLast = 0, now
				local ok, ping = pcall(function()
					return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
				end)
				liveStats.Text = tostring(fps) .. " FPS  •  " .. (ok and tostring(ping) or "--") .. " ms"
			end
		end))
	end

	-- 右端の最小化・閉じるボタン
	local function makeTopAction(symbol, offsetX, isClose, cb)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Position = UDim2.new(1, offsetX, 0.5, 0)
		b.Size = UDim2.fromOffset(26, 26)
		b.BackgroundTransparency = 0.25
		b.Font = Enum.Font.GothamBold
		b.Text = symbol
		b.TextSize = 13
		b.AutoButtonColor = false
		b.ZIndex = 6
		Theme.Bind(b, "BackgroundColor3", "Card")
		Theme.Bind(b, "TextColor3", "SubText")
		b.Parent = topBar
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

		b.MouseEnter:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.15), {
				BackgroundColor3 = isClose and Theme.Current.Danger or Theme.Current.CardHover,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(b, TweenInfo.new(0.15), {
				BackgroundColor3 = Theme.Current.Card,
				TextColor3 = Theme.Current.SubText,
			}):Play()
		end)
		b.MouseButton1Click:Connect(cb)
	end

	makeTopAction("—", -38, false, function()
		if onClose then onClose(true) end
	end)
	makeTopAction("×", -8, true, function()
		if onClose then onClose(false) end
	end)

	-- ==========================================
	-- 2. 左上：プロフィールヒーローカード（200 x 172）
	-- ==========================================
	local _, profCard = makeCardHolder("ProfileCard", 100, 140, 200, 172, 16)
	profCard.Active = false

	-- 上部グロー演出
	local profGlow = Instance.new("ImageLabel")
	profGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	profGlow.Position = UDim2.new(0.5, 0, 0.15, 0)
	profGlow.Size = UDim2.fromOffset(180, 140)
	profGlow.BackgroundTransparency = 1
	profGlow.Image = glowAsset
	profGlow.ImageTransparency = 0.78
	profGlow.ZIndex = 4
	Theme.Bind(profGlow, "ImageColor3", "Glow")
	profGlow.Parent = profCard

	-- 右下の透かし cw.png
	local profMark = Instance.new("ImageLabel")
	profMark.AnchorPoint = Vector2.new(1, 1)
	profMark.Position = UDim2.new(1, 10, 1, 10)
	profMark.Size = UDim2.fromOffset(78, 78)
	profMark.BackgroundTransparency = 1
	profMark.Image = logoAsset
	profMark.ImageTransparency = 0.88
	profMark.ScaleType = Enum.ScaleType.Fit
	profMark.ZIndex = 4
	profMark.Parent = profCard

	local avatar = Instance.new("ImageLabel")
	avatar.AnchorPoint = Vector2.new(0.5, 0)
	avatar.Position = UDim2.new(0.5, 0, 0, 20)
	avatar.Size = UDim2.fromOffset(56, 56)
	avatar.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
	avatar.ZIndex = 6
	avatar.Parent = profCard
	Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

	local avStroke = Instance.new("UIStroke")
	avStroke.Thickness = 1.6
	avStroke.Transparency = 0.55
	Theme.Bind(avStroke, "Color", "Accent")
	avStroke.Parent = avatar

	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and thumb then
			avatar.Image = thumb
		end
	end)

	local dispLbl = Instance.new("TextLabel")
	dispLbl.AnchorPoint = Vector2.new(0.5, 0)
	dispLbl.Position = UDim2.new(0.5, 0, 0, 84)
	dispLbl.Size = UDim2.new(1, -20, 0, 20)
	dispLbl.BackgroundTransparency = 1
	dispLbl.Font = Enum.Font.GothamBold
	dispLbl.Text = player.DisplayName
	dispLbl.TextSize = 15
	dispLbl.TextTruncate = Enum.TextTruncate.AtEnd
	dispLbl.ZIndex = 6
	Theme.Bind(dispLbl, "TextColor3", "Text")
	dispLbl.Parent = profCard

	local userLbl = Instance.new("TextLabel")
	userLbl.AnchorPoint = Vector2.new(0.5, 0)
	userLbl.Position = UDim2.new(0.5, 0, 0, 105)
	userLbl.Size = UDim2.new(1, -20, 0, 16)
	userLbl.BackgroundTransparency = 1
	userLbl.Font = Enum.Font.Gotham
	userLbl.Text = "@" .. player.Name
	userLbl.TextSize = 11
	userLbl.TextTruncate = Enum.TextTruncate.AtEnd
	userLbl.ZIndex = 6
	Theme.Bind(userLbl, "TextColor3", "SubText")
	userLbl.Parent = profCard

	-- 下部のオンラインバッジ
	local sessionPill = Instance.new("Frame")
	sessionPill.AnchorPoint = Vector2.new(0.5, 1)
	sessionPill.Position = UDim2.new(0.5, 0, 1, -14)
	sessionPill.Size = UDim2.fromOffset(106, 22)
	sessionPill.BackgroundTransparency = 0.25
	sessionPill.ZIndex = 6
	Theme.Bind(sessionPill, "BackgroundColor3", "Card")
	sessionPill.Parent = profCard
	Instance.new("UICorner", sessionPill).CornerRadius = UDim.new(1, 0)

	local sDot = Instance.new("Frame")
	sDot.AnchorPoint = Vector2.new(0, 0.5)
	sDot.Position = UDim2.new(0, 10, 0.5, 0)
	sDot.Size = UDim2.fromOffset(6, 6)
	sDot.BackgroundColor3 = Color3.fromRGB(90, 235, 160)
	sDot.BorderSizePixel = 0
	sDot.Parent = sessionPill
	Instance.new("UICorner", sDot).CornerRadius = UDim.new(1, 0)

	local sTxt = Instance.new("TextLabel")
	sTxt.Position = UDim2.fromOffset(22, 0)
	sTxt.Size = UDim2.new(1, -26, 1, 0)
	sTxt.BackgroundTransparency = 1
	sTxt.Font = Enum.Font.GothamMedium
	sTxt.Text = "Active Session"
	sTxt.TextSize = 10
	sTxt.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(sTxt, "TextColor3", "Text")
	sTxt.Parent = sessionPill

	-- ==========================================
	-- 3. クリック可能なメニュータイル生成関数
	-- ==========================================
	local function addBentoTile(cfg)
		local _, card, sc, stroke, sheen = makeCardHolder(cfg.id, cfg.cx, cfg.cy, cfg.w, cfg.h, 16)

		local glow = Instance.new("ImageLabel")
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Position = cfg.glowPos
		glow.Size = UDim2.fromOffset(cfg.glowBase, cfg.glowBase)
		glow.BackgroundTransparency = 1
		glow.Image = glowAsset
		glow.ImageTransparency = 0.72
		glow.ScaleType = Enum.ScaleType.Fit
		glow.ZIndex = 4
		Theme.Bind(glow, "ImageColor3", "Glow")
		glow.Parent = card

		local icon = Icons.Create(cfg.id, card, Theme)
		icon.Position = cfg.iconPos
		icon.Size = UDim2.fromOffset(cfg.iconBase, cfg.iconBase)
		icon.ImageTransparency = 0.1
		icon.ZIndex = 6

		local title = Instance.new("TextLabel")
		title.AnchorPoint = cfg.centered and Vector2.new(0.5, 0) or Vector2.new(0, 0)
		title.Position = cfg.titlePos
		title.Size = cfg.centered and UDim2.new(1, -16, 0, 22) or UDim2.new(1, -36, 0, 22)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.Text = cfg.label
		title.TextSize = cfg.titleSize or 16
		title.TextXAlignment = cfg.centered and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
		title.ZIndex = 6
		Theme.Bind(title, "TextColor3", "Text")
		title.Parent = card

		if cfg.sub then
			local sub = Instance.new("TextLabel")
			sub.Position = UDim2.new(cfg.titlePos.X.Scale, cfg.titlePos.X.Offset, cfg.titlePos.Y.Scale, cfg.titlePos.Y.Offset + 23)
			sub.Size = UDim2.new(1, -36, 0, 16)
			sub.BackgroundTransparency = 1
			sub.Font = Enum.Font.Gotham
			sub.Text = cfg.sub
			sub.TextSize = 11
			sub.TextXAlignment = Enum.TextXAlignment.Left
			sub.ZIndex = 6
			Theme.Bind(sub, "TextColor3", "SubText")
			sub.Parent = card
		end

		local arrow
		if not cfg.centered then
			arrow = Instance.new("TextLabel")
			arrow.AnchorPoint = Vector2.new(1, 1)
			arrow.Position = UDim2.new(1, -16, 1, -14)
			arrow.Size = UDim2.fromOffset(20, 20)
			arrow.BackgroundTransparency = 1
			arrow.Font = Enum.Font.GothamBold
			arrow.Text = "→"
			arrow.TextSize = 15
			arrow.TextTransparency = 0.45
			arrow.ZIndex = 6
			Theme.Bind(arrow, "TextColor3", "Accent")
			arrow.Parent = card
		end

		-- ホバー：黒くならず、白いガラス光沢＋光＆アイコンが明るく拡大！
		card.MouseEnter:Connect(function()
			TweenService:Create(sc, hoverIn, { Scale = 1.032 }):Play()
			TweenService:Create(sheen, hoverIn, { BackgroundTransparency = 0.91 }):Play()
			TweenService:Create(stroke, hoverIn, { Transparency = 0.28 }):Play()
			TweenService:Create(glow, hoverIn, {
				Size = UDim2.fromOffset(cfg.glowHover, cfg.glowHover),
				ImageTransparency = 0.34,
			}):Play()
			TweenService:Create(icon, hoverIn, {
				Size = UDim2.fromOffset(cfg.iconBase + 8, cfg.iconBase + 8),
				ImageTransparency = 0,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
			if arrow then
				TweenService:Create(arrow, hoverIn, {
					Position = UDim2.new(1, -11, 1, -14),
					TextTransparency = 0,
				}):Play()
			end
		end)

		card.MouseLeave:Connect(function()
			TweenService:Create(sc, hoverOut, { Scale = 1 }):Play()
			TweenService:Create(sheen, hoverOut, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(stroke, hoverOut, { Transparency = 0.84 }):Play()
			TweenService:Create(glow, hoverOut, {
				Size = UDim2.fromOffset(cfg.glowBase, cfg.glowBase),
				ImageTransparency = 0.72,
			}):Play()
			TweenService:Create(icon, hoverOut, {
				Size = UDim2.fromOffset(cfg.iconBase, cfg.iconBase),
				ImageTransparency = 0.1,
				ImageColor3 = Theme.Current.Accent,
			}):Play()
			if arrow then
				TweenService:Create(arrow, hoverOut, {
					Position = UDim2.new(1, -16, 1, -14),
					TextTransparency = 0.45,
				}):Play()
			end
		end)

		card.MouseButton1Click:Connect(function()
			onSelectPage(cfg.id, cfg.label)
		end)

		return card
	end

	-- 右上：Visuals（大きめメインタイル 264 x 172）
	local visualsCard = addBentoTile({
		id = "visuals",
		label = "Visuals",
		sub = "Atmosphere, Blur & Camera",
		cx = 344, cy = 140, w = 264, h = 172,
		glowPos = UDim2.new(0.24, 0, 0.34, 0),
		iconPos = UDim2.new(0, 42, 0, 46),
		titlePos = UDim2.new(0, 20, 1, -56),
		titleSize = 18,
		iconBase = 38,
		glowBase = 145,
		glowHover = 210,
	})

	local featTag = Instance.new("TextLabel")
	featTag.AnchorPoint = Vector2.new(1, 0)
	featTag.Position = UDim2.new(1, -14, 0, 14)
	featTag.Size = UDim2.fromOffset(62, 20)
	featTag.BackgroundTransparency = 0.25
	featTag.Font = Enum.Font.GothamBold
	featTag.Text = "VISUAL"
	featTag.TextSize = 10
	featTag.ZIndex = 6
	Theme.Bind(featTag, "BackgroundColor3", "Card")
	Theme.Bind(featTag, "TextColor3", "Accent")
	featTag.Parent = visualsCard
	Instance.new("UICorner", featTag).CornerRadius = UDim.new(1, 0)

	-- 左下：3D Models（200 x 136）
	addBentoTile({
		id = "models",
		label = "3D Models",
		sub = "HUD & Overlays",
		cx = 100, cy = 306, w = 200, h = 136,
		glowPos = UDim2.new(0.24, 0, 0.34, 0),
		iconPos = UDim2.new(0, 38, 0, 38),
		titlePos = UDim2.new(0, 18, 1, -52),
		titleSize = 15,
		iconBase = 32,
		glowBase = 120,
		glowHover = 175,
	})

	-- 右下左：Settings（126 x 136）
	addBentoTile({
		id = "settings",
		label = "Settings",
		cx = 275, cy = 306, w = 126, h = 136,
		centered = true,
		glowPos = UDim2.new(0.5, 0, 0.42, 0),
		iconPos = UDim2.new(0.5, 0, 0.40, 0),
		titlePos = UDim2.new(0.5, 0, 0.67, 0),
		titleSize = 14,
		iconBase = 32,
		glowBase = 110,
		glowHover = 160,
	})

	-- 右下右：Themes（126 x 136）
	local themesCard = addBentoTile({
		id = "themes",
		label = "Themes",
		cx = 413, cy = 306, w = 126, h = 136,
		centered = true,
		glowPos = UDim2.new(0.5, 0, 0.42, 0),
		iconPos = UDim2.new(0.5, 0, 0.40, 0),
		titlePos = UDim2.new(0.5, 0, 0.67, 0),
		titleSize = 14,
		iconBase = 32,
		glowBase = 110,
		glowHover = 160,
	})

	-- Themes カード右上のミニカラープレビュードット
	local dotColors = {
		Color3.fromRGB(130, 205, 255),
		Color3.fromRGB(255, 145, 195),
		Color3.fromRGB(175, 145, 255),
	}
	for i, col in ipairs(dotColors) do
		local d = Instance.new("Frame")
		d.AnchorPoint = Vector2.new(1, 0)
		d.Position = UDim2.new(1, -10 - (i - 1) * 10, 0, 11)
		d.Size = UDim2.fromOffset(7, 7)
		d.BackgroundColor3 = col
		d.BorderSizePixel = 0
		d.ZIndex = 6
		d.Parent = themesCard
		Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
	end

	-- 下部の操作ヒント
	local hint = Instance.new("TextLabel")
	hint.AnchorPoint = Vector2.new(0.5, 0)
	hint.Position = UDim2.new(0.5, 0, 1, 14)
	hint.Size = UDim2.fromOffset(300, 18)
	hint.BackgroundTransparency = 1
	hint.Font = Enum.Font.Gotham
	hint.Text = "RightShift で開閉  •  Backspace で戻る"
	hint.TextSize = 11
	hint.TextTransparency = 0.22
	Theme.Bind(hint, "TextColor3", "SubText")
	hint.Parent = hub

	return {
		Frame = hub,
		Scale = hubScale,
		Tiles = tiles,
	}
end

return createHub