local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local function initMainGui(CatWare)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- 二重起動防止
	local old = playerGui:FindFirstChild("CatWareGui")
	if old then
		old:Destroy()
	end

	local logoAsset = ""
	if CatWare and CatWare.Assets then
		logoAsset = CatWare.Assets.Get("cwmini.png")
	end

	local connections = {}
	local function track(conn)
		table.insert(connections, conn)
		return conn
	end

	-- テーマカラー管理
	local Theme = {
		Bg = Color3.fromRGB(16, 20, 29),
		Sidebar = Color3.fromRGB(12, 16, 24),
		Card = Color3.fromRGB(24, 30, 44),
		CardHover = Color3.fromRGB(32, 40, 58),
		Text = Color3.fromRGB(240, 246, 255),
		SubText = Color3.fromRGB(142, 164, 192),
		Accent = Color3.fromRGB(125, 200, 255),
		Danger = Color3.fromRGB(235, 95, 110),
	}

	local accentObjects = {} -- アクセント色変更時に一括更新
	local function bindAccent(obj, prop)
		table.insert(accentObjects, { obj = obj, prop = prop })
		obj[prop] = Theme.Accent
	end

	local function setAccent(newColor)
		Theme.Accent = newColor
		for _, item in ipairs(accentObjects) do
			if item.obj and item.obj.Parent then
				TweenService:Create(item.obj, TweenInfo.new(0.25), { [item.prop] = newColor }):Play()
			end
		end
	end

	-- ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CatWareGui"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 500
	screenGui.Parent = playerGui

	-- 通知コンテナ（右下）
	local notifyHolder = Instance.new("Frame")
	notifyHolder.Name = "Notifications"
	notifyHolder.AnchorPoint = Vector2.new(1, 1)
	notifyHolder.Position = UDim2.new(1, -18, 1, -18)
	notifyHolder.Size = UDim2.new(0, 270, 1, -36)
	notifyHolder.BackgroundTransparency = 1
	notifyHolder.Parent = screenGui

	local notifyLayout = Instance.new("UIListLayout")
	notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notifyLayout.Padding = UDim.new(0, 8)
	notifyLayout.Parent = notifyHolder

	local function notify(titleText, bodyText, duration)
		duration = duration or 3

		local toast = Instance.new("Frame")
		toast.Size = UDim2.new(1, 0, 0, 58)
		toast.BackgroundColor3 = Theme.Bg
		toast.BackgroundTransparency = 0.08
		toast.ClipsDescendants = true
		toast.Parent = notifyHolder

		local tc = Instance.new("UICorner")
		tc.CornerRadius = UDim.new(0, 12)
		tc.Parent = toast

		local ts = Instance.new("UIStroke")
		ts.Thickness = 1
		ts.Transparency = 0.7
		bindAccent(ts, "Color")
		ts.Parent = toast

		local icon = Instance.new("ImageLabel")
		icon.Position = UDim2.fromOffset(10, 11)
		icon.Size = UDim2.fromOffset(34, 34)
		icon.BackgroundTransparency = 1
		icon.Image = logoAsset
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Parent = toast

		local tTitle = Instance.new("TextLabel")
		tTitle.Position = UDim2.fromOffset(52, 9)
		tTitle.Size = UDim2.new(1, -62, 0, 18)
		tTitle.BackgroundTransparency = 1
		tTitle.Font = Enum.Font.GothamBold
		tTitle.Text = titleText
		tTitle.TextColor3 = Theme.Text
		tTitle.TextSize = 13
		tTitle.TextXAlignment = Enum.TextXAlignment.Left
		tTitle.Parent = toast

		local tBody = Instance.new("TextLabel")
		tBody.Position = UDim2.fromOffset(52, 27)
		tBody.Size = UDim2.new(1, -62, 0, 18)
		tBody.BackgroundTransparency = 1
		tBody.Font = Enum.Font.Gotham
		tBody.Text = bodyText
		tBody.TextColor3 = Theme.SubText
		tBody.TextSize = 12
		tBody.TextXAlignment = Enum.TextXAlignment.Left
		tBody.TextTruncate = Enum.TextTruncate.AtEnd
		tBody.Parent = toast

		local timerBar = Instance.new("Frame")
		timerBar.AnchorPoint = Vector2.new(0, 1)
		timerBar.Position = UDim2.fromScale(0, 1)
		timerBar.Size = UDim2.new(1, 0, 0, 2)
		timerBar.BorderSizePixel = 0
		bindAccent(timerBar, "BackgroundColor3")
		timerBar.Parent = toast

		local toastScale = Instance.new("UIScale")
		toastScale.Scale = 0.9
		toastScale.Parent = toast
		TweenService:Create(toastScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
		TweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

		task.delay(duration, function()
			if toast.Parent then
				TweenService:Create(toast, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
				TweenService:Create(ts, TweenInfo.new(0.25), { Transparency = 1 }):Play()
				TweenService:Create(toastScale, TweenInfo.new(0.25), { Scale = 0.9 }):Play()
				task.wait(0.26)
				toast:Destroy()
			end
		end)
	end

	-- ドラッグ共通関数
	local function makeDraggable(handle, target, onClick)
		local dragging = false
		local moved = false
		local dragStart, startPos

		track(handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				moved = false
				dragStart = input.Position
				startPos = target.Position
			end
		end))

		track(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				if delta.Magnitude > 5 then
					moved = true
				end
				target.Position = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y
				)
			end
		end))

		track(UserInputService.InputEnded:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
				dragging = false
				if not moved and onClick then
					onClick()
				end
			end
		end))
	end

	-- メインウィンドウ
	local main = Instance.new("Frame")
	main.Name = "MainWindow"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.Size = UDim2.fromOffset(560, 360)
	main.BackgroundColor3 = Theme.Bg
	main.BackgroundTransparency = 0.08
	main.ClipsDescendants = true
	main.Parent = screenGui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 16)
	mainCorner.Parent = main

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Thickness = 1.2
	mainStroke.Transparency = 0.72
	bindAccent(mainStroke, "Color")
	mainStroke.Parent = main

	local baseScale = 1
	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0.92
	mainScale.Parent = main

	-- 最小化時のフローティングアイコン
	local miniBtn = Instance.new("ImageButton")
	miniBtn.Name = "MiniIcon"
	miniBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	miniBtn.Position = UDim2.new(0, 48, 0.5, 0)
	miniBtn.Size = UDim2.fromOffset(50, 50)
	miniBtn.BackgroundColor3 = Theme.Bg
	miniBtn.BackgroundTransparency = 0.1
	miniBtn.Image = logoAsset
	miniBtn.ScaleType = Enum.ScaleType.Fit
	miniBtn.AutoButtonColor = false
	miniBtn.Visible = false
	miniBtn.Parent = screenGui

	local miniCorner = Instance.new("UICorner")
	miniCorner.CornerRadius = UDim.new(0, 14)
	miniCorner.Parent = miniBtn

	local miniStroke = Instance.new("UIStroke")
	miniStroke.Thickness = 1.4
	miniStroke.Transparency = 0.55
	bindAccent(miniStroke, "Color")
	miniStroke.Parent = miniBtn

	-- 開閉アニメーション関数
	local isOpen = true
	local function setOpen(state, showMini)
		isOpen = state
		if state then
			miniBtn.Visible = false
			main.Visible = true
			mainScale.Scale = baseScale * 0.92
			TweenService:Create(mainScale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = baseScale,
			}):Play()
		else
			local tw = TweenService:Create(mainScale, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Scale = baseScale * 0.92,
			})
			tw:Play()
			tw.Completed:Once(function()
				if not isOpen then
					main.Visible = false
					if showMini then
						miniBtn.Visible = true
					end
				end
			end)
		end
	end

	makeDraggable(miniBtn, miniBtn, function()
		setOpen(true, false)
	end)

	-- ヘッダー（ドラッグ領域）
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundColor3 = Theme.Sidebar
	header.BackgroundTransparency = 0.2
	header.BorderSizePixel = 0
	header.Parent = main

	makeDraggable(header, main)

	local headerLine = Instance.new("Frame")
	headerLine.AnchorPoint = Vector2.new(0, 1)
	headerLine.Position = UDim2.fromScale(0, 1)
	headerLine.Size = UDim2.new(1, 0, 0, 1)
	headerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	headerLine.BackgroundTransparency = 0.92
	headerLine.BorderSizePixel = 0
	headerLine.Parent = header

	local headerLogo = Instance.new("ImageLabel")
	headerLogo.Position = UDim2.fromOffset(14, 9)
	headerLogo.Size = UDim2.fromOffset(28, 28)
	headerLogo.BackgroundTransparency = 1
	headerLogo.Image = logoAsset
	headerLogo.ScaleType = Enum.ScaleType.Fit
	headerLogo.Parent = header

	local headerTitle = Instance.new("TextLabel")
	headerTitle.Position = UDim2.fromOffset(50, 0)
	headerTitle.Size = UDim2.new(0, 120, 1, 0)
	headerTitle.BackgroundTransparency = 1
	headerTitle.Font = Enum.Font.GothamBold
	headerTitle.Text = "CatWare"
	headerTitle.TextColor3 = Theme.Text
	headerTitle.TextSize = 15
	headerTitle.TextXAlignment = Enum.TextXAlignment.Left
	headerTitle.Parent = header

	local versionPill = Instance.new("TextLabel")
	versionPill.Position = UDim2.fromOffset(122, 14)
	versionPill.Size = UDim2.fromOffset(44, 18)
	versionPill.BackgroundColor3 = Theme.Card
	versionPill.Font = Enum.Font.GothamMedium
	versionPill.Text = "v" .. ((CatWare and CatWare.Version) or "1.0")
	versionPill.TextSize = 11
	bindAccent(versionPill, "TextColor3")
	versionPill.Parent = header

	local vpCorner = Instance.new("UICorner")
	vpCorner.CornerRadius = UDim.new(1, 0)
	vpCorner.Parent = versionPill

	-- ヘッダー右ボタン（最小化・非表示）
	local function makeHeaderBtn(text, offsetX, hoverColor, callback)
		local btn = Instance.new("TextButton")
		btn.AnchorPoint = Vector2.new(1, 0.5)
		btn.Position = UDim2.new(1, offsetX, 0.5, 0)
		btn.Size = UDim2.fromOffset(28, 28)
		btn.BackgroundColor3 = Theme.Card
		btn.BackgroundTransparency = 0.4
		btn.Font = Enum.Font.GothamBold
		btn.Text = text
		btn.TextColor3 = Theme.SubText
		btn.TextSize = 14
		btn.AutoButtonColor = false
		btn.Parent = header

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 8)
		c.Parent = btn

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = hoverColor, TextColor3 = Theme.Text }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Card, TextColor3 = Theme.SubText }):Play()
		end)
		btn.MouseButton1Click:Connect(callback)
		return btn
	end

	makeHeaderBtn("—", -46, Theme.CardHover, function()
		setOpen(false, true)
	end)
	makeHeaderBtn("×", -12, Theme.Danger, function()
		setOpen(false, false)
		notify("CatWare", "RightShift キーで再表示できます", 3)
	end)

	-- サイドバー
	local sidebar = Instance.new("Frame")
	sidebar.Position = UDim2.fromOffset(0, 46)
	sidebar.Size = UDim2.new(0, 140, 1, -46)
	sidebar.BackgroundColor3 = Theme.Sidebar
	sidebar.BackgroundTransparency = 0.25
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main

	local sideList = Instance.new("UIListLayout")
	sideList.SortOrder = Enum.SortOrder.LayoutOrder
	sideList.Padding = UDim.new(0, 6)
	sideList.Parent = sidebar

	local sidePad = Instance.new("UIPadding")
	sidePad.PaddingTop = UDim.new(0, 12)
	sidePad.PaddingLeft = UDim.new(0, 10)
	sidePad.PaddingRight = UDim.new(0, 10)
	sidePad.Parent = sidebar

	local sideHint = Instance.new("TextLabel")
	sideHint.AnchorPoint = Vector2.new(0, 1)
	sideHint.Position = UDim2.new(0, 0, 1, -10)
	sideHint.Size = UDim2.new(0, 140, 0, 18)
	sideHint.BackgroundTransparency = 1
	sideHint.Font = Enum.Font.Gotham
	sideHint.Text = "RightShift: Toggle"
	sideHint.TextColor3 = Theme.SubText
	sideHint.TextTransparency = 0.35
	sideHint.TextSize = 11
	sideHint.Parent = main

	-- コンテンツ領域
	local contentArea = Instance.new("Frame")
	contentArea.Position = UDim2.fromOffset(140, 46)
	contentArea.Size = UDim2.new(1, -140, 1, -46)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = main

	-- タブシステム
	local tabs = {}
	local activeTab = nil

	local function createTab(name)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 34)
		btn.BackgroundColor3 = Theme.Card
		btn.BackgroundTransparency = 1
		btn.Font = Enum.Font.GothamMedium
		btn.Text = "   " .. name
		btn.TextColor3 = Theme.SubText
		btn.TextSize = 13
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		btn.Parent = sidebar

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 9)
		bc.Parent = btn

		local indicator = Instance.new("Frame")
		indicator.AnchorPoint = Vector2.new(0, 0.5)
		indicator.Position = UDim2.new(0, 0, 0.5, 0)
		indicator.Size = UDim2.fromOffset(3, 0)
		indicator.BorderSizePixel = 0
		bindAccent(indicator, "BackgroundColor3")
		indicator.Parent = btn

		local ic = Instance.new("UICorner")
		ic.CornerRadius = UDim.new(1, 0)
		ic.Parent = indicator

		local page = Instance.new("ScrollingFrame")
		page.Name = name
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = Theme.SubText
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = contentArea

		local pLayout = Instance.new("UIListLayout")
		pLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pLayout.Padding = UDim.new(0, 8)
		pLayout.Parent = page

		local pPad = Instance.new("UIPadding")
		pPad.PaddingTop = UDim.new(0, 12)
		pPad.PaddingBottom = UDim.new(0, 14)
		pPad.PaddingLeft = UDim.new(0, 14)
		pPad.PaddingRight = UDim.new(0, 14)
		pPad.Parent = page

		local tabObj = { btn = btn, indicator = indicator, page = page }
		table.insert(tabs, tabObj)

		local function selectTab()
			activeTab = tabObj
			for _, t in ipairs(tabs) do
				local isMe = (t == tabObj)
				t.page.Visible = isMe
				TweenService:Create(t.btn, TweenInfo.new(0.18), {
					BackgroundTransparency = isMe and 0.25 or 1,
					TextColor3 = isMe and Theme.Text or Theme.SubText,
				}):Play()
				TweenService:Create(t.indicator, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
					Size = isMe and UDim2.fromOffset(3, 18) or UDim2.fromOffset(3, 0),
				}):Play()
			end
		end

		btn.MouseButton1Click:Connect(selectTab)
		if not activeTab then
			selectTab()
		end

		return page
	end

	-- === 再利用可能なUIパーツ生成関数 ===
	local function addSection(parent, text)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 18)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamBold
		lbl.Text = string.upper(text)
		lbl.TextColor3 = Theme.SubText
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = parent
	end

	local function addButton(parent, text, subtext, isDanger, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, subtext and 48 or 38)
		btn.BackgroundColor3 = isDanger and Color3.fromRGB(55, 26, 34) or Theme.Card
		btn.BackgroundTransparency = 0.15
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Parent = parent

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = btn

		local lbl = Instance.new("TextLabel")
		lbl.Position = UDim2.fromOffset(12, subtext and 7 or 0)
		lbl.Size = UDim2.new(1, -24, 0, subtext and 18 or 38)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = text
		lbl.TextColor3 = isDanger and Theme.Danger or Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = btn

		if subtext then
			local sub = Instance.new("TextLabel")
			sub.Position = UDim2.fromOffset(12, 25)
			sub.Size = UDim2.new(1, -24, 0, 16)
			sub.BackgroundTransparency = 1
			sub.Font = Enum.Font.Gotham
			sub.Text = subtext
			sub.TextColor3 = Theme.SubText
			sub.TextSize = 11
			sub.TextXAlignment = Enum.TextXAlignment.Left
			sub.Parent = btn
		end

		local baseCol = btn.BackgroundColor3
		local hoverCol = isDanger and Color3.fromRGB(78, 32, 42) or Theme.CardHover
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = hoverCol }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = baseCol }):Play()
		end)
		btn.MouseButton1Click:Connect(function()
			if callback then
				callback()
			end
		end)
	end

	local function addToggle(parent, text, default, callback)
		local state = default or false

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 40)
		row.BackgroundColor3 = Theme.Card
		row.BackgroundTransparency = 0.15
		row.Text = ""
		row.AutoButtonColor = false
		row.Parent = parent

		local rc = Instance.new("UICorner")
		rc.CornerRadius = UDim.new(0, 10)
		rc.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Position = UDim2.fromOffset(12, 0)
		lbl.Size = UDim2.new(1, -72, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = text
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local pill = Instance.new("Frame")
		pill.AnchorPoint = Vector2.new(1, 0.5)
		pill.Position = UDim2.new(1, -12, 0.5, 0)
		pill.Size = UDim2.fromOffset(40, 22)
		pill.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 55, 72)
		pill.Parent = row

		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(1, 0)
		pc.Parent = pill

		local knob = Instance.new("Frame")
		knob.AnchorPoint = Vector2.new(0, 0.5)
		knob.Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		knob.Size = UDim2.fromOffset(16, 16)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Parent = pill

		local kc = Instance.new("UICorner")
		kc.CornerRadius = UDim.new(1, 0)
		kc.Parent = knob

		row.MouseButton1Click:Connect(function()
			state = not state
			TweenService:Create(pill, TweenInfo.new(0.18), {
				BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(45, 55, 72),
			}):Play()
			TweenService:Create(knob, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {
				Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			}):Play()
			if callback then
				callback(state)
			end
		end)
	end

	local function addSlider(parent, text, minVal, maxVal, defaultVal, step, suffix, callback)
		local value = defaultVal or minVal
		step = step or 1
		suffix = suffix or ""

		local box = Instance.new("Frame")
		box.Size = UDim2.new(1, 0, 0, 56)
		box.BackgroundColor3 = Theme.Card
		box.BackgroundTransparency = 0.15
		box.Parent = parent

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 10)
		bc.Parent = box

		local lbl = Instance.new("TextLabel")
		lbl.Position = UDim2.fromOffset(12, 8)
		lbl.Size = UDim2.new(1, -80, 0, 18)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = text
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = box

		local valLbl = Instance.new("TextLabel")
		valLbl.AnchorPoint = Vector2.new(1, 0)
		valLbl.Position = UDim2.new(1, -12, 0, 8)
		valLbl.Size = UDim2.fromOffset(70, 18)
		valLbl.BackgroundTransparency = 1
		valLbl.Font = Enum.Font.GothamBold
		valLbl.Text = tostring(value) .. suffix
		valLbl.TextSize = 12
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		bindAccent(valLbl, "TextColor3")
		valLbl.Parent = box

		local trackBar = Instance.new("Frame")
		trackBar.Position = UDim2.new(0, 12, 0, 36)
		trackBar.Size = UDim2.new(1, -24, 0, 6)
		trackBar.BackgroundColor3 = Color3.fromRGB(40, 50, 68)
		trackBar.BorderSizePixel = 0
		trackBar.Parent = box

		local tc = Instance.new("UICorner")
		tc.CornerRadius = UDim.new(1, 0)
		tc.Parent = trackBar

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale((value - minVal) / (maxVal - minVal), 1)
		fill.BorderSizePixel = 0
		bindAccent(fill, "BackgroundColor3")
		fill.Parent = trackBar

		local fc = Instance.new("UICorner")
		fc.CornerRadius = UDim.new(1, 0)
		fc.Parent = fill

		local sliding = false
		local function updateSlider(inputX)
			local rel = math.clamp((inputX - trackBar.AbsolutePosition.X) / math.max(trackBar.AbsoluteSize.X, 1), 0, 1)
			local raw = minVal + (maxVal - minVal) * rel
			value = math.floor((raw / step) + 0.5) * step
			value = math.clamp(value, minVal, maxVal)
			local display = step < 1 and string.format("%.2f", value) or tostring(math.floor(value))
			valLbl.Text = display .. suffix
			fill.Size = UDim2.fromScale((value - minVal) / (maxVal - minVal), 1)
			if callback then
				callback(value)
			end
		end

		track(trackBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = true
				updateSlider(input.Position.X)
			end
		end))
		track(UserInputService.InputChanged:Connect(function(input)
			if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateSlider(input.Position.X)
			end
		end))
		track(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliding = false
			end
		end))
	end

	-- ==========================================
	-- タブ1: Home
	-- ==========================================
	local homeTab = createTab("Home")

	-- プロフィールカード
	local profileCard = Instance.new("Frame")
	profileCard.Size = UDim2.new(1, 0, 0, 68)
	profileCard.BackgroundColor3 = Theme.Card
	profileCard.BackgroundTransparency = 0.15
	profileCard.Parent = homeTab

	local pcCorner = Instance.new("UICorner")
	pcCorner.CornerRadius = UDim.new(0, 12)
	pcCorner.Parent = profileCard

	local avatar = Instance.new("ImageLabel")
	avatar.Position = UDim2.fromOffset(12, 11)
	avatar.Size = UDim2.fromOffset(46, 46)
	avatar.BackgroundColor3 = Theme.Sidebar
	avatar.Parent = profileCard

	local avCorner = Instance.new("UICorner")
	avCorner.CornerRadius = UDim.new(1, 0)
	avCorner.Parent = avatar

	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and thumb then
			avatar.Image = thumb
		end
	end)

	local welcomeLbl = Instance.new("TextLabel")
	welcomeLbl.Position = UDim2.fromOffset(70, 14)
	welcomeLbl.Size = UDim2.new(1, -84, 0, 20)
	welcomeLbl.BackgroundTransparency = 1
	welcomeLbl.Font = Enum.Font.GothamBold
	welcomeLbl.Text = "Welcome, " .. player.DisplayName
	welcomeLbl.TextColor3 = Theme.Text
	welcomeLbl.TextSize = 14
	welcomeLbl.TextXAlignment = Enum.TextXAlignment.Left
	welcomeLbl.Parent = profileCard

	local userLbl = Instance.new("TextLabel")
	userLbl.Position = UDim2.fromOffset(70, 35)
	userLbl.Size = UDim2.new(1, -84, 0, 16)
	userLbl.BackgroundTransparency = 1
	userLbl.Font = Enum.Font.Gotham
	userLbl.Text = "@" .. player.Name .. "  •  CatWare Project"
	userLbl.TextColor3 = Theme.SubText
	userLbl.TextSize = 12
	userLbl.TextXAlignment = Enum.TextXAlignment.Left
	userLbl.Parent = profileCard

	-- FPS & Ping ステータスカード
	local statsRow = Instance.new("Frame")
	statsRow.Size = UDim2.new(1, 0, 0, 60)
	statsRow.BackgroundTransparency = 1
	statsRow.Parent = homeTab

	local function makeStatBox(titleText, xScale, xOffset)
		local box = Instance.new("Frame")
		box.Position = UDim2.new(xScale, xOffset, 0, 0)
		box.Size = UDim2.new(0.5, -4, 1, 0)
		box.BackgroundColor3 = Theme.Card
		box.BackgroundTransparency = 0.15
		box.Parent = statsRow

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = box

		local t = Instance.new("TextLabel")
		t.Position = UDim2.fromOffset(12, 8)
		t.Size = UDim2.new(1, -24, 0, 16)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.Gotham
		t.Text = titleText
		t.TextColor3 = Theme.SubText
		t.TextSize = 11
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = box

		local v = Instance.new("TextLabel")
		v.Position = UDim2.fromOffset(12, 26)
		v.Size = UDim2.new(1, -24, 0, 24)
		v.BackgroundTransparency = 1
		v.Font = Enum.Font.GothamBold
		v.Text = "--"
		v.TextSize = 18
		v.TextXAlignment = Enum.TextXAlignment.Left
		bindAccent(v, "TextColor3")
		v.Parent = box

		return v
	end

	local fpsValue = makeStatBox("FPS", 0, 0)
	local pingValue = makeStatBox("PING", 0.5, 4)

	local frameCount = 0
	local lastTick = os.clock()
	track(RunService.RenderStepped:Connect(function()
		frameCount += 1
		local now = os.clock()
		if now - lastTick >= 0.5 then
			local fps = math.floor(frameCount / (now - lastTick) + 0.5)
			fpsValue.Text = tostring(fps) .. " FPS"
			frameCount = 0
			lastTick = now

			local ok, ping = pcall(function()
				return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			pingValue.Text = ok and (tostring(ping) .. " ms") or "-- ms"
		end
	end))

	addSection(homeTab, "Quick Actions")
	addButton(homeTab, "テスト通知を表示", "右下にフロスト通知を出します", false, function()
		notify("CatWare", "UIは正常に動作しています！", 3)
	end)

	-- ==========================================
	-- タブ2: Components（今後の機能追加のベース）
	-- ==========================================
	local compTab = createTab("Components")

	addSection(compTab, "UI Elements Demo")
	addToggle(compTab, "サンプル トグルスイッチ", false, function(on)
		notify("Toggle", on and "ON になりました" or "OFF になりました", 2)
	end)

	addSlider(compTab, "背景の透過度", 0, 45, 8, 1, "%", function(val)
		main.BackgroundTransparency = val / 100
	end)

	addSection(compTab, "Accent Theme")
	local colorRow = Instance.new("Frame")
	colorRow.Size = UDim2.new(1, 0, 0, 36)
	colorRow.BackgroundTransparency = 1
	colorRow.Parent = compTab

	local colorList = Instance.new("UIListLayout")
	colorList.FillDirection = Enum.FillDirection.Horizontal
	colorList.Padding = UDim.new(0, 8)
	colorList.Parent = colorRow

	local presets = {
		{ "Ice", Color3.fromRGB(125, 200, 255) },
		{ "Sakura", Color3.fromRGB(255, 145, 195) },
		{ "Mint", Color3.fromRGB(115, 235, 185) },
		{ "Violet", Color3.fromRGB(175, 145, 255) },
	}
	for _, p in ipairs(presets) do
		local cb = Instance.new("TextButton")
		cb.Size = UDim2.new(0.25, -6, 1, 0)
		cb.BackgroundColor3 = Theme.Card
		cb.BackgroundTransparency = 0.15
		cb.Font = Enum.Font.GothamMedium
		cb.Text = p[1]
		cb.TextColor3 = p[2]
		cb.TextSize = 12
		cb.Parent = colorRow

		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(0, 8)
		cc.Parent = cb

		cb.MouseButton1Click:Connect(function()
			setAccent(p[2])
			notify("Theme", p[1] .. " カラーに変更しました", 2)
		end)
	end

	-- ==========================================
	-- タブ3: Settings
	-- ==========================================
	local setTab = createTab("Settings")

	addSection(setTab, "Window")
	addSlider(setTab, "UI スケール", 0.8, 1.25, 1.0, 0.05, "x", function(val)
		baseScale = val
		mainScale.Scale = val
	end)

	addButton(setTab, "ウィンドウ位置を中央に戻す", nil, false, function()
		TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
			Position = UDim2.fromScale(0.5, 0.5),
		}):Play()
	end)

	addSection(setTab, "System")
	addButton(setTab, "CatWare を終了 (Unload)", "GUIとイベントをすべて破棄します", true, function()
		for _, c in ipairs(connections) do
			pcall(function()
				c:Disconnect()
			end)
		end
		screenGui:Destroy()
	end)

	-- RightShift で開閉
	track(UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.RightShift then
			setOpen(not isOpen, false)
		end
	end))

	-- 起動時のポップイン＆歓迎通知
	setOpen(true, false)
	notify("CatWare", "読み込み完了 (RightShift で開閉)", 3.5)
end

return initMainGui