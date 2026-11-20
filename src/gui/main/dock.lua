local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function createDock(parent, CatWare, Theme, navItems, onSelect, onClose)
	local player = Players.LocalPlayer
	local dockBgAsset = CatWare.Assets.Get("dock_bg.png")
	local dockGlassAsset = CatWare.Assets.Get("dock_glass.png")
	local dockShadowAsset = CatWare.Assets.Get("dock_shadow.png")
	local dockPillAsset = CatWare.Assets.Get("dock_pill.png")
	local glowAsset = CatWare.Assets.Get("glow.png")
	if glowAsset == "" then
		glowAsset = "rbxassetid://10822615828"
	end

	local Icons = CatWare.Import("src/gui/main/icons.lua")

	local dockWrap = Instance.new("Frame")
	dockWrap.Name = "FloatingDock"
	dockWrap.AnchorPoint = Vector2.new(0.5, 1)
	dockWrap.Position = UDim2.new(0.5, 0, 1, 0)
	dockWrap.Size = UDim2.fromOffset(428, 62)
	dockWrap.BackgroundTransparency = 1
	dockWrap.ZIndex = 15
	dockWrap.Parent = parent

	local dockShadow = Instance.new("ImageLabel")
	dockShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	dockShadow.Position = UDim2.new(0.5, 0, 0.5, 8)
	dockShadow.Size = UDim2.fromOffset(428 + 56, 62 + 56)
	dockShadow.BackgroundTransparency = 1
	dockShadow.Image = dockShadowAsset
	dockShadow.ImageTransparency = 0.35
	dockShadow.ZIndex = 1
	dockShadow.Parent = dockWrap

	local dockBg = Instance.new("ImageLabel")
	dockBg.Name = "DockBg"
	dockBg.Size = UDim2.fromScale(1, 1)
	dockBg.BackgroundTransparency = 1
	dockBg.Image = dockBgAsset
	dockBg.ImageTransparency = 0.14
	dockBg.ZIndex = 2
	Theme.Bind(dockBg, "ImageColor3", "Tile")
	dockBg.Parent = dockWrap

	local dockGlass = Instance.new("ImageLabel")
	dockGlass.Size = UDim2.fromScale(1, 1)
	dockGlass.BackgroundTransparency = 1
	dockGlass.Image = dockGlassAsset
	dockGlass.ImageTransparency = 0.08
	dockGlass.ZIndex = 10
	dockGlass.Parent = dockWrap

	-- 滑らかな高解像度ガラスピル
	local activePill = Instance.new("ImageLabel")
	activePill.Name = "ActivePill"
	activePill.AnchorPoint = Vector2.new(0.5, 0.5)
	activePill.Position = UDim2.fromOffset(40, 29)
	activePill.Size = UDim2.fromOffset(48, 44)
	activePill.BackgroundTransparency = 1
	activePill.Image = dockPillAsset
	activePill.ImageTransparency = 0.05
	activePill.ZIndex = 4
	Theme.Bind(activePill, "ImageColor3", "Accent")
	activePill.Parent = dockWrap

	-- ドック最下部の発光インジケーターバー
	local activeBar = Instance.new("Frame")
	activeBar.Name = "ActiveBar"
	activeBar.AnchorPoint = Vector2.new(0.5, 1)
	activeBar.Position = UDim2.new(0, 40, 1, -4)
	activeBar.Size = UDim2.fromOffset(16, 3)
	activeBar.BorderSizePixel = 0
	activeBar.ZIndex = 11
	Theme.Bind(activeBar, "BackgroundColor3", "Accent")
	activeBar.Parent = dockWrap
	Instance.new("UICorner", activeBar).CornerRadius = UDim.new(1, 0)

	local barGlow = Instance.new("ImageLabel")
	barGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	barGlow.Position = UDim2.fromScale(0.5, 0.5)
	barGlow.Size = UDim2.fromOffset(36, 14)
	barGlow.BackgroundTransparency = 1
	barGlow.Image = glowAsset
	barGlow.ImageTransparency = 0.5
	barGlow.ZIndex = 10
	Theme.Bind(barGlow, "ImageColor3", "Glow")
	barGlow.Parent = activeBar

	local buttons = {}
	local activeId = nil
	local hoverIn = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local hoverOut = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	for idx, item in ipairs(navItems) do
		local centerX = 40 + (idx - 1) * 58

		local btn = Instance.new("TextButton")
		btn.Name = item.id
		btn.AnchorPoint = Vector2.new(0.5, 0.5)
		btn.Position = UDim2.fromOffset(centerX, 29)
		btn.Size = UDim2.fromOffset(48, 44)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 6
		btn.Parent = dockWrap

		-- スマートツールチップ
		local tip = Instance.new("TextLabel")
		tip.AnchorPoint = Vector2.new(0.5, 1)
		tip.Position = UDim2.new(0.5, 0, 0, -10)
		tip.Size = UDim2.fromOffset(0, 22)
		tip.AutomaticSize = Enum.AutomaticSize.X
		tip.BackgroundTransparency = 1
		tip.Font = Enum.Font.GothamBold
		tip.Text = item.label
		tip.TextSize = 11
		tip.TextTransparency = 1
		tip.ZIndex = 20
		Theme.Bind(tip, "BackgroundColor3", "Card")
		Theme.Bind(tip, "TextColor3", "Text")
		tip.Parent = btn
		Instance.new("UICorner", tip).CornerRadius = UDim.new(1, 0)

		local tipPad = Instance.new("UIPadding")
		tipPad.PaddingLeft = UDim.new(0, 10)
		tipPad.PaddingRight = UDim.new(0, 10)
		tipPad.Parent = tip

		local tipStroke = Instance.new("UIStroke")
		tipStroke.Thickness = 1
		tipStroke.Transparency = 1
		Theme.Bind(tipStroke, "Color", "Glow")
		tipStroke.Parent = tip

		-- 中央の柔らかい丸い光
		local aura = Instance.new("ImageLabel")
		aura.AnchorPoint = Vector2.new(0.5, 0.5)
		aura.Position = UDim2.fromScale(0.5, 0.5)
		aura.Size = UDim2.fromOffset(34, 34)
		aura.BackgroundTransparency = 1
		aura.Image = glowAsset
		aura.ImageTransparency = 1
		aura.ZIndex = 5
		Theme