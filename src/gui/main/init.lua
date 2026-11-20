local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local function initMainGui(CatWare)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local Theme = CatWare.Theme
	local Notify = CatWare.Notify
    local Components = CatWare.Import("src/gui/main/components.lua")
	Components.Theme = Theme
	
	local createHub = CatWare.Import("src/gui/main/hub.lua")

	-- 二重起動の掃除
	if playerGui:FindFirstChild("CatWareGui") then
		playerGui.CatWareGui:Destroy()
	end
	if Lighting:FindFirstChild("CatWareBlur") then
		Lighting.CatWareBlur:Destroy()
	end

	local logoAsset = CatWare.Assets.Get("cw.png")
	local connections = {}
	local function track(conn)
		table.insert(connections, conn)
		return conn
	end

	-- 背景ぼかし（BlurEffect）
	local blur = Instance.new("BlurEffect")
	blur.Name = "CatWareBlur"
	blur.Size = 0
	blur.Parent = Lighting

	local blurTarget = 14
	local baseScale = 1
	local isOpen = true
	local currentPageId = nil

	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CatWareGui"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 500
	screenGui.Parent = playerGui

	Notify.Init(screenGui, logoAsset, Theme)

	-- 画面暗転オーバーレイ
	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 1
	dim.ZIndex = 1
	dim.Parent = screenGui

	-- 詳細ページパネル（2×2タイルをクリックした時に開く）
	local pagePanel = Instance.new("Frame")
	pagePanel.Name = "DetailPanel"
	pagePanel.AnchorPoint = Vector2.new(0.5, 0.5)
	pagePanel.Position = UDim2.fromScale(0.5, 0.5)
	pagePanel.Size = UDim2.fromOffset(456, 408)
	pagePanel.BackgroundTransparency = 0.1
	pagePanel.Visible = false
	pagePanel.ClipsDescendants = true
	pagePanel.ZIndex = 10
	Theme.Bind(pagePanel, "BackgroundColor3", "Tile")
	pagePanel.Parent = screenGui

	local ppCorner = Instance.new("UICorner")
	ppCorner.CornerRadius = UDim.new(0, 16)
	ppCorner.Parent = pagePanel

	local ppStroke = Instance.new("UIStroke")
	ppStroke.Thickness = 1.2
	ppStroke.Transparency = 0.82
	Theme.Bind(ppStroke, "Color", "Glow")
	ppStroke.Parent = pagePanel

	local pageScale = Instance.new("UIScale")
	pageScale.Scale = 0.92
	pageScale.Parent = pagePanel

	-- 詳細ページヘッダー
	local pHeader = Instance.new("Frame")
	pHeader.Size = UDim2.new(1, 0, 0, 52)
	pHeader.BackgroundTransparency = 1
	pHeader.Parent = pagePanel

	local backBtn = Instance.new("TextButton")
	backBtn.AnchorPoint = Vector2.new(0, 0.5)
	backBtn.Position = UDim2.new(0, 14, 0.5, 0)
	backBtn.Size = UDim2.fromOffset(74, 30)
	backBtn.BackgroundTransparency = 0.15
	backBtn.Font = Enum.Font.GothamMedium
	backBtn.Text = "← Back"
	backBtn.TextSize = 12
	Theme.Bind(backBtn, "BackgroundColor3", "Card")
	Theme.Bind(backBtn, "TextColor3", "Text")
	backBtn.Parent = pHeader

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 9)
	bc.Parent = backBtn

	local pageTitle = Instance.new("TextLabel")
	pageTitle.AnchorPoint = Vector2.new(0.5, 0.5)
	pageTitle.Position = UDim2.fromScale(0.5, 0.5)
	pageTitle.Size = UDim2.fromOffset(220, 24)
	pageTitle.BackgroundTransparency = 1
	pageTitle.Font = Enum.Font.GothamBold
	pageTitle.Text = ""
	pageTitle.TextSize = 16
	Theme.Bind(pageTitle, "TextColor3", "Text")
	pageTitle.Parent = pHeader

	local hLogo = Instance.new("ImageLabel")
	hLogo.AnchorPoint = Vector2.new(1, 0.5)
	hLogo.Position = UDim2.new(1, -14, 0.5, 0)
	hLogo.Size = UDim2.fromOffset(26, 26)
	hLogo.BackgroundTransparency = 1
	hLogo.Image = logoAsset
	hLogo.ScaleType = Enum.ScaleType.Fit
	hLogo.Parent = pHeader

	local div = Instance.new("Frame")
	div.Position = UDim2.fromOffset(0, 52)
	div.Size = UDim2.new(1, 0, 0, 1)
	div.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	div.BackgroundTransparency = 0.92
	div.BorderSizePixel = 0
	div.Parent = pagePanel

	-- 各ページ格納用 ScrollingFrame
	local pageFrames = {}
	local function makePageContainer(id)
		local sf = Instance.new("ScrollingFrame")
		sf.Name = id
		sf.Position = UDim2.fromOffset(0, 54)
		sf.Size = UDim2.new(1, 0, 1, -54)
		sf.BackgroundTransparency = 1
		sf.BorderSizePixel = 0
		sf.ScrollBarThickness = 3
		sf.CanvasSize = UDim2.new(0, 0, 0, 0)
		sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
		sf.Visible = false
		sf.Parent = pagePanel

		local list = Instance.new("UIListLayout")
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Padding = UDim.new(0, 8)
		list.Parent = sf

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 12)
		pad.PaddingBottom = UDim.new(0, 14)
		pad.PaddingLeft = UDim.new(0, 16)
		pad.PaddingRight = UDim.new(0, 16)
		pad.Parent = sf

		pageFrames[id] = sf
		return sf
	end

	-- 最小化アイコン
	local miniBtn = Instance.new("ImageButton")
	miniBtn.AnchorPoint = Vector2.new(0, 0.5)
	miniBtn.Position = UDim2.new(0, 18, 0.5, 0)
	miniBtn.Size = UDim2.fromOffset(48, 48)
	miniBtn.BackgroundTransparency = 0.12
	miniBtn.Image = logoAsset
	miniBtn.ScaleType = Enum.ScaleType.Fit
	miniBtn.Visible = false
	miniBtn.ZIndex = 30
	Theme.Bind(miniBtn, "BackgroundColor3", "Tile")
	miniBtn.Parent = screenGui

	local mc = Instance.new("UICorner")
	mc.CornerRadius = UDim.new(0, 14)
	mc.Parent = miniBtn

	local ms = Instance.new("UIStroke")
	ms.Thickness = 1.2
	ms.Transparency = 0.65
	Theme.Bind(ms, "Color", "Glow")
	ms.Parent = miniBtn

	-- Hub 生成
	local hub
	local function openPage(id, label, icon)
		currentPageId = id
		pageTitle.Text = icon .. "  " .. label
		for k, f in pairs(pageFrames) do
			f.Visible = (k == id)
		end

		TweenService:Create(hub.Scale, TweenInfo.new(0.18, Enum.EasingStyle.Quint), { Scale = baseScale * 0.92 }):Play()
		task.delay(0.15, function()
			if currentPageId then
				hub.Frame.Visible = false
				pagePanel.Visible = true
				pageScale.Scale = baseScale * 0.92
				TweenService:Create(pageScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = baseScale,
				}):Play()
			end
		end)
	end

	local function backToHub()
		currentPageId = nil
		TweenService:Create(pageScale, TweenInfo.new(0.16, Enum.EasingStyle.Quint), { Scale = baseScale * 0.92 }):Play()
		task.delay(0.14, function()
			if not currentPageId and isOpen then
				pagePanel.Visible = false
				hub.Frame.Visible = true
				hub.Scale.Scale = baseScale * 0.92
				TweenService:Create(hub.Scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = baseScale,
				}):Play()
			end
		end)
	end

	backBtn.MouseButton1Click:Connect(backToHub)

	hub = createHub(screenGui, CatWare, Theme, openPage)

	-- 全体の開閉
	local function setOpen(state, showMini)
		isOpen = state
		if state then
			miniBtn.Visible = false
			dim.Visible = true
			TweenService:Create(blur, TweenInfo.new(0.28), { Size = blurTarget }):Play()
			TweenService:Create(dim, TweenInfo.new(0.28), { BackgroundTransparency = 0.58 }):Play()
			if currentPageId then
				pagePanel.Visible = true
				pageScale.Scale = baseScale * 0.92
				TweenService:Create(pageScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = baseScale }):Play()
			else
				hub.Frame.Visible = true
				hub.Scale.Scale = baseScale * 0.92
				TweenService:Create(hub.Scale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = baseScale }):Play()
			end
		else
			TweenService:Create(blur, TweenInfo.new(0.2), { Size = 0 }):Play()
			TweenService:Create(dim, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(hub.Scale, TweenInfo.new(0.18), { Scale = baseScale * 0.92 }):Play()
			TweenService:Create(pageScale, TweenInfo.new(0.18), { Scale = baseScale * 0.92 }):Play()
			task.delay(0.2, function()
				if not isOpen then
					hub.Frame.Visible = false
					pagePanel.Visible = false
					dim.Visible = false
					if showMini then
						miniBtn.Visible = true
					end
				end
			end)
		end
	end

	miniBtn.MouseButton1Click:Connect(function()
		setOpen(true, false)
	end)

	-- Unload 関数
	local function unload()
		for _, c in ipairs(connections) do
			pcall(function()
				c:Disconnect()
			end)
		end
		blur:Destroy()
		screenGui:Destroy()
	end

	-- 各ページに共有するコンテキスト
	local ctx = {
		CatWare = CatWare,
		Theme = Theme,
		Notify = Notify,
		Components = Components,
		ScreenGui = screenGui,
		Hub = hub,
		PagePanel = pagePanel,
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
			hub.Scale.Scale = val
			pageScale.Scale = val
		end,
		Minimize = function()
			setOpen(false, true)
		end,
		Unload = unload,
	}

	-- 4ページを読み込んで構築
	local pageList = {
		{ id = "visuals",  path = "src/gui/main/pages/visuals.lua" },
		{ id = "models",   path = "src/gui/main/pages/models.lua" },
		{ id = "settings", path = "src/gui/main/pages/settings.lua" },
		{ id = "themes",   path = "src/gui/main/pages/themes.lua" },
	}
	for _, p in ipairs(pageList) do
		local container = makePageContainer(p.id)
		local builder = CatWare.Import(p.path)
		if type(builder) == "function" then
			builder(container, ctx)
		end
	end

	-- キーバインド（RightShiftで開閉 / Backspaceで戻る）
	track(UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.RightShift then
			setOpen(not isOpen, false)
		elseif input.KeyCode == Enum.KeyCode.Backspace and isOpen and currentPageId then
			backToHub()
		end
	end))

	setOpen(true, false)
	Notify.Send("CatWare", "起動完了 (RightShift で開閉)", 3)
end

return initMainGui