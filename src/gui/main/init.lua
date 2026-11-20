local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local function initMainGui(CatWare)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local Theme = CatWare.Theme
	local Notify = CatWare.Notify
	local Shadow = CatWare.Import("src/utils/shadow.lua")
	local Icons = CatWare.Import("src/gui/main/icons.lua")
	local createComponents = CatWare.Import("src/gui/main/components/init.lua")
	local Components = createComponents(CatWare)
	local createDock = CatWare.Import("src/gui/main/dock.lua")

	if playerGui:FindFirstChild("CatWareGui") then
		playerGui.CatWareGui:Destroy()
	end
	if Lighting:FindFirstChild("CatWareBlur") then
		Lighting.CatWareBlur:Destroy()
	end

	local logoAsset = CatWare.Assets.Get("cw.png")
	local shadowAsset = CatWare.Assets.Get("shadow.png")
	local stageBgAsset = CatWare.Assets.Get("stage_bg.png")
	local stageGlassAsset = CatWare.Assets.Get("stage_glass.png")
	local stageAuroraAsset = CatWare.Assets.Get("stage_aurora.png")
	local stageShadowAsset = CatWare.Assets.Get("stage_shadow.png")

	local connections = {}
	local function track(conn)
		table.insert(connections, conn)
		return conn
	end

	local blur = Instance.new("BlurEffect")
	blur.Name = "CatWareBlur"
	blur.Size = 0
	blur.Parent = Lighting

	local blurTarget = 16
	local baseScale = 1
	local isOpen = true

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CatWareGui"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 500
	screenGui.Parent = playerGui

	Notify.Init(screenGui, logoAsset, Theme)

	-- 控えめな空間暗転（背景ぼかしが綺麗に透ける明るさ）
	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 1
	dim.ZIndex = 1
	dim.Parent = screenGui

	-- ステージ＋下部ドック全体をまとめるコンテナ
	local root = Instance.new("Frame")
	root.Name = "SpatialRoot"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(540, 402)
	root.BackgroundTransparency = 1
	root.ZIndex = 10
	root.Parent = screenGui

	local rootScale = Instance.new("UIScale")
	rootScale.Scale = 0.92
	rootScale.Parent = root

	-- ==========================================
	-- VisionOS リキッドグラス・ステージ（540 x 312）
	-- ==========================================
	local stageWrap = Instance.new("Frame")
	stageWrap.Name = "GlassStage"
	stageWrap.Position = UDim2.fromOffset(0, 0)
	stageWrap.Size = UDim2.fromOffset(540, 312)
	stageWrap.BackgroundTransparency = 1
	stageWrap.ZIndex = 5
	stageWrap.Parent = root

	-- 専用ドロップシャドウ
	local stageShadow = Instance.new("ImageLabel")
	stageShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	stageShadow.Position = UDim2.new(0.5, 0, 0.5, 10)
	stageShadow.Size = UDim2.fromOffset(540 + 60, 312 + 60)
	stageShadow.BackgroundTransparency = 1
	stageShadow.Image = stageShadowAsset
	stageShadow.ImageTransparency = 0.36
	stageShadow.ZIndex = 1
	stageShadow.Parent = stageWrap

	-- 半透明ガラスベース（背景がうっすら透けるVision Pro質感）
	local stageBg = Instance.new("ImageLabel")
	stageBg.Name = "StageBg"
	stageBg.Size = UDim2.fromScale(1, 1)
	stageBg.BackgroundTransparency = 1
	stageBg.Image = stageBgAsset
	stageBg.ImageTransparency = 0.26
	stageBg.ZIndex = 2
	Theme.Bind(stageBg, "ImageColor3", "Tile")
	stageBg.Parent = stageWrap

	-- 自然な光の反射（ネオン感を消して薄く）
	local stageAurora = Instance.new("ImageLabel")
	stageAurora.Size = UDim2.fromScale(1, 1)
	stageAurora.BackgroundTransparency = 1
	stageAurora.Image = stageAuroraAsset
	stageAurora.ImageTransparency = 0.62
	stageAurora.ZIndex = 3
	Theme.Bind(stageAurora, "ImageColor3", "Glow")
	stageAurora.Parent = stageWrap

	-- 上面がキラッと光る光学ガラスリム（クリックを邪魔しないZIndex=4）
	local stageGlass = Instance.new("ImageLabel")
	stageGlass.Size = UDim2.fromScale(1, 1)
	stageGlass.BackgroundTransparency = 1
	stageGlass.Image = stageGlassAsset
	stageGlass.ImageTransparency = 0.08
	stageGlass.ZIndex = 4
	stageGlass.Parent = stageWrap

	-- ヘッダー（ドラッグ領域）
	local header = Instance.new("TextButton")
	header.Name = "StageHeader"
	header.Size = UDim2.new(1, 0, 0, 62)
	header.BackgroundTransparency = 1
	header.Text = ""
	header.AutoButtonColor = false
	header.Active = true
	header.ZIndex = 12
	header.Parent = stageWrap

	-- VisionOS ドラッグ用グリップバー
	local grip = Instance.new("Frame")
	grip.AnchorPoint = Vector2.new(0.5, 0)
	grip.Position = UDim2.new(0.5, 0, 0, 7)
	grip.Size = UDim2.fromOffset(38, 3)
	grip.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	grip.BackgroundTransparency = 0.72
	grip.BorderSizePixel = 0
	grip.ZIndex = 13
	grip.Parent = header
	Instance.new("UICorner", grip).CornerRadius = UDim.new(1, 0)

	header.MouseEnter:Connect(function()
		TweenService:Create(grip, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(54, 3),
			BackgroundTransparency = 0.35,
		}):Play()
	end)
	header.MouseLeave:Connect(function()
		TweenService:Create(grip, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(38, 3),
			BackgroundTransparency = 0.72,
		}):Play()
	end)

	-- 滑らかTweenドラッグ処理（慣性追従＋掴み演出）
	local dragging = false
	local dragStartMouse, startPos, lastDelta
	local dragTweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	local function stopDrag()
		if not dragging then return end
		dragging = false
		TweenService:Create(rootScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			Scale = baseScale,
		}):Play()
		TweenService:Create(grip, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(38, 3),
			BackgroundTransparency = 0.72,
		}):Play()
	end

	track(header.MouseButton1Down:Connect(function()
		dragging = true
		dragStartMouse = UserInputService:GetMouseLocation()
		startPos = root.Position
		lastDelta = nil
		TweenService:Create(rootScale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Scale = baseScale * 1.012,
		}):Play()
		TweenService:Create(grip, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
			Size = UDim2.fromOffset(64, 3),
			BackgroundTransparency = 0.15,
		}):Play()
	end))

	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			stopDrag()
		end
	end))

	track(RunService.RenderStepped:Connect(function()
		if not dragging then return end
		if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			stopDrag()
			return
		end
		local d = UserInputService:GetMouseLocation() - dragStartMouse
		if d == lastDelta then return end
		lastDelta = d

		local targetPos = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + d.X,
			startPos.Y.Scale, startPos.Y.Offset + d.Y
		)
		TweenService:Create(root, dragTweenInfo, { Position = targetPos }):Play()
	end))

	-- ヘッダー左：クリーンな白透けガラス丸バッジ＋タイトル
	local orb = Instance.new("Frame")
	orb.AnchorPoint = Vector2.new(0, 0.5)
	orb.Position = UDim2.new(0, 20, 0.5, 2)
	orb.Size = UDim2.fromOffset(36, 36)
	orb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	orb.BackgroundTransparency = 0.88
	orb.ZIndex = 13
	orb.Parent = header
	Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)

-- 既存の local orbStroke = ... の5行をこの1行に差し替え
	Theme.GlassStroke(orb, { Thickness = 1, Transparency = 0.20 })

	local headerIcon = Instance.new("ImageLabel")
	headerIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	headerIcon.Position = UDim2.fromScale(0.5, 0.5)
	headerIcon.Size = UDim2.fromOffset(18, 18)
	headerIcon.BackgroundTransparency = 1
	headerIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	headerIcon.ScaleType = Enum.ScaleType.Fit
	headerIcon.ZIndex = 14
	headerIcon.Parent = orb

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Position = UDim2.fromOffset(68, 14)
	headerTitle.Size = UDim2.new(0, 240, 0, 22)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Font = Enum.Font.GothamBold
	headerTitle.Text = "Home"
	headerTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	headerTitle.TextSize = 17
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.ZIndex = 13
	headerTitle.Parent = header

	local headerSub = Instance.new("TextLabel")
	headerSub.Position = UDim2.fromOffset(68, 36)
	headerSub.Size = UDim2.new(0, 280, 0, 14)
	headerSub.BackgroundTransparency = 1
	headerSub.Font = Enum.Font.Gotham
	headerSub.Text = "Overview"
	headerSub.TextColor3 = Color3.fromRGB(255, 255, 255)
	headerSub.TextTransparency = 0.45
	headerSub.TextSize = 11
	headerSub.TextXAlignment = Enum.TextXAlignment.Left
	headerSub.ZIndex = 13
	headerSub.Parent = header

-- ヘッダー右：上面光沢ガラスピル（FPS • ms）
	local statPill = Instance.new("TextLabel")
	statPill.AnchorPoint = Vector2.new(1, 0.5)
	statPill.Position = UDim2.new(1, -20, 0.5, 2)
	statPill.Size = UDim2.fromOffset(0, 26)
	statPill.AutomaticSize = Enum.AutomaticSize.X
	statPill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	statPill.BackgroundTransparency = 0.90
	statPill.Font = Enum.Font.GothamMedium
	statPill.Text = "-- fps • -- ms"
	statPill.TextColor3 = Color3.fromRGB(255, 255, 255)
	statPill.TextTransparency = 0.15
	statPill.TextSize = 11
	statPill.ZIndex = 13
	statPill.Parent = header
	Instance.new("UICorner", statPill).CornerRadius = UDim.new(1, 0)

	local spPad = Instance.new("UIPadding")
	spPad.PaddingLeft = UDim.new(0, 12)
	spPad.PaddingRight = UDim.new(0, 12)
	spPad.Parent = statPill

	Theme.GlassStroke(statPill, {
		Thickness = 1,
		Transparency = 0.22,
	})
	local fc, fl = 0, os.clock()
	track(RunService.RenderStepped:Connect(function()
		if not root.Visible then return end
		fc += 1
		local now = os.clock()
		if now - fl >= 0.5 then
			local fps = math.floor(fc / (now - fl) + 0.5)
			fc, fl = 0, now
			local ok, ping = pcall(function()
				return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			statPill.Text = tostring(fps) .. " fps • " .. (ok and tostring(ping) or "--") .. " ms"
		end
	end))

	-- 繊細なホワイトの区切り線
	local div = Instance.new("Frame")
	div.Position = UDim2.fromOffset(20, 62)
	div.Size = UDim2.new(1, -40, 0, 1)
	div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	div.BackgroundTransparency = 0.86
	div.BorderSizePixel = 0
	div.ZIndex = 6
	div.Parent = stageWrap

	local divGrad = Instance.new("UIGradient")
	divGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.12, 0),
		NumberSequenceKeypoint.new(0.88, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	divGrad.Parent = div

	-- ページ切り替え領域
	local pageHolder = Instance.new("Frame")
	pageHolder.Position = UDim2.fromOffset(0, 64)
	pageHolder.Size = UDim2.new(1, 0, 1, -74)
	pageHolder.BackgroundTransparency = 1
	pageHolder.ClipsDescendants = true
	pageHolder.ZIndex = 6
	pageHolder.Parent = stageWrap

	-- 最小化アイコン
	local miniWrap = Instance.new("Frame")
	miniWrap.AnchorPoint = Vector2.new(0, 0.5)
	miniWrap.Position = UDim2.new(0, 18, 0.5, 0)
	miniWrap.Size = UDim2.fromOffset(48, 48)
	miniWrap.BackgroundTransparency = 1
	miniWrap.Visible = false
	miniWrap.ZIndex = 30
	miniWrap.Parent = screenGui

	Shadow.Create(miniWrap, shadowAsset, { Padding = 18, OffsetY = 5, Transparency = 0.4, ZIndex = 1 })

	local miniBtn = Instance.new("ImageButton")
	miniBtn.Size = UDim2.fromScale(1, 1)
	miniBtn.BackgroundTransparency = 0.22
	miniBtn.Image = logoAsset
	miniBtn.ScaleType = Enum.ScaleType.Fit
	miniBtn.ZIndex = 2
	Theme.Bind(miniBtn, "BackgroundColor3", "Tile")
	miniBtn.Parent = miniWrap
	Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 14)

-- 既存の local ms = ... の5行をこの1行に差し替え
	Theme.GlassStroke(miniBtn, { Thickness = 1.2, Transparency = 0.15 })

	-- ページ定義
	local navItems = {
		{ id = "home",     label = "Home",      sub = "Overview & Status",        path = "src/gui/main/pages/home.lua",     isAvatar = true },
		{ id = "visuals",  label = "Visuals",   sub = "Display, Blur & Camera",   path = "src/gui/main/pages/visuals.lua" },
		{ id = "models",   label = "3D Models", sub = "HUD & Overlays",           path = "src/gui/main/pages/models.lua" },
		{ id = "settings", label = "Settings",  sub = "Interface & System",       path = "src/gui/main/pages/settings.lua" },
		{ id = "themes",   label = "Themes",    sub = "Glass Materials",          path = "src/gui/main/pages/themes.lua" },
	}

	local pageFrames = {}
	local itemById = {}
	for _, item in ipairs(navItems) do
		itemById[item.id] = item
		local sf = Instance.new("ScrollingFrame")
		sf.Name = item.id
		sf.Size = UDim2.fromScale(1, 1)
		sf.BackgroundTransparency = 1
		sf.BorderSizePixel = 0
		sf.ScrollBarThickness = 3
		sf.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
		sf.ScrollBarImageTransparency = 0.65
		sf.CanvasSize = UDim2.new(0, 0, 0, 0)
		sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
		sf.Visible = false
		sf.Parent = pageHolder

		local list = Instance.new("UIListLayout")
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Padding = UDim.new(0, 10)
		list.Parent = sf

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 12)
		pad.PaddingBottom = UDim.new(0, 16)
		pad.PaddingLeft = UDim.new(0, 20)
		pad.PaddingRight = UDim.new(0, 20)
		pad.Parent = sf

		pageFrames[item.id] = sf
	end

	local dock
	local setOpen

	local function selectPage(id)
		local info = itemById[id]
		if not info then return end

		headerTitle.Text = info.label
		headerSub.Text = info.sub
		headerIcon.Image = Icons.Get(id)

		for k, sf in pairs(pageFrames) do
			if k == id then
				sf.Visible = true
				sf.Position = UDim2.fromOffset(16, 0)
				TweenService:Create(sf, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
					Position = UDim2.fromOffset(0, 0),
				}):Play()
			else
				sf.Visible = false
			end
		end

		if dock then
			dock.SetActive(id)
		end
	end

	dock = createDock(root, CatWare, Theme, navItems, selectPage, function(showMini)
		setOpen(false, showMini)
		if not showMini then
			Notify.Send("CatWare", "RightShift キーで再表示できます", 2.5)
		end
	end)
	dock.Bg.ImageTransparency = 0.24

	function setOpen(state, showMini)
		isOpen = state
		if state then
			miniWrap.Visible = false
			dim.Visible = true
			root.Visible = true
			rootScale.Scale = baseScale * 0.92
			TweenService:Create(blur, TweenInfo.new(0.28), { Size = blurTarget }):Play()
			TweenService:Create(dim, TweenInfo.new(0.28), { BackgroundTransparency = 0.42 }):Play()
			TweenService:Create(rootScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = baseScale,
			}):Play()
		else
			TweenService:Create(blur, TweenInfo.new(0.2), { Size = 0 }):Play()
			TweenService:Create(dim, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(rootScale, TweenInfo.new(0.18), { Scale = baseScale * 0.92 }):Play()
			task.delay(0.2, function()
				if not isOpen then
					root.Visible = false
					dim.Visible = false
					if showMini then
						miniWrap.Visible = true
					end
				end
			end)
		end
	end

	miniBtn.MouseButton1Click:Connect(function()
		setOpen(true, false)
	end)

	local function unload()
		for _, c in ipairs(connections) do
			pcall(function() c:Disconnect() end)
		end
		blur:Destroy()
		screenGui:Destroy()
	end

	local ctx = {
		CatWare = CatWare,
		Theme = Theme,
		Notify = Notify,
		Components = Components,
		ScreenGui = screenGui,
		Hub = { Tiles = { stageBg, dock.Bg } },
		PagePanel = stageBg,
		LogoAsset = logoAsset,
		Track = track,
		SetBlurTarget = function(val)
			blurTarget = val
			if isOpen then
				blur.Size = val
			end
		end,
		SetBaseScale = function(val)
			baseScale = val
			rootScale.Scale = val
		end,
		Minimize = function()
			setOpen(false, true)
		end,
		Unload = unload,
	}

	for _, item in ipairs(navItems) do
		local builder = CatWare.Import(item.path)
		if type(builder) == "function" then
			builder(pageFrames[item.id], ctx)
		end
	end

	track(UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			setOpen(not isOpen, false)
		end
	end))

	selectPage("home")
	setOpen(true, false)
	Notify.Send("CatWare", "CatWare VisionOS 起動完了", 2.5)
end

return initMainGui