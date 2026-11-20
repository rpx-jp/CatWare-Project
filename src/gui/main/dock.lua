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

	-- 滑らかな高解像度ガラスピル（ギザギザUIStrokeを廃止）
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

	-- ドック最下部に独立配置した発光インジケーターバー（アイコンと干渉ゼロ）
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

		-- 文字幅に合わせて自動調整されるスマートツールチップ
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
		Theme.Bind(aura, "ImageColor3", "Glow")
		aura.Parent = btn

		local visualObj
		local visualScale = Instance.new("UIScale")
		visualScale.Scale = 1

		if item.isAvatar then
			local av = Instance.new("ImageLabel")
			av.AnchorPoint = Vector2.new(0.5, 0.5)
			av.Position = UDim2.fromScale(0.5, 0.5)
			av.Size = UDim2.fromOffset(26, 26)
			av.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
			av.ZIndex = 7
			av.Parent = btn
			Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
			visualScale.Parent = av

			-- 縁にぶつからない控えめな白リング
			local avs = Instance.new("UIStroke")
			avs.Color = Color3.fromRGB(255, 255, 255)
			avs.Thickness = 1.2
			avs.Transparency = 0.65
			avs.Parent = av

			task.spawn(function()
				local ok, thumb = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if ok and thumb then
					av.Image = thumb
				end
			end)
			visualObj = av
		else
			local ic = Icons.Create(item.id, btn, Theme, 21)
			ic.ImageTransparency = 0.32
			ic.ZIndex = 7
			visualScale.Parent = ic
			visualObj = ic
		end

		buttons[item.id] = {
			x = centerX,
			visual = visualObj,
			scale = visualScale,
			isAvatar = item.isAvatar,
			aura = aura,
		}

		btn.MouseEnter:Connect(function()
			TweenService:Create(visualScale, hoverIn, { Scale = item.isAvatar and 1.12 or 1.18 }):Play()
			TweenService:Create(visualObj, hoverIn, { Position = UDim2.new(0.5, 0, 0.5, -3) }):Play()
			if not item.isAvatar then
				TweenService:Create(visualObj, hoverIn, {
					ImageTransparency = 0,
					ImageColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
			end
			TweenService:Create(aura, hoverIn, {
				Size = UDim2.fromOffset(50, 50),
				ImageTransparency = 0.48,
			}):Play()
			TweenService:Create(tip, hoverIn, {
				Position = UDim2.new(0.5, 0, 0, -18),
				BackgroundTransparency = 0.1,
				TextTransparency = 0,
			}):Play()
			TweenService:Create(tipStroke, hoverIn, { Transparency = 0.72 }):Play()
		end)

		btn.MouseLeave:Connect(function()
			local isAct = (activeId == item.id)
			TweenService:Create(visualScale, hoverOut, { Scale = isAct and 1.04 or 1 }):Play()
			TweenService:Create(visualObj, hoverOut, { Position = UDim2.fromScale(0.5, 0.5) }):Play()
			if not item.isAvatar then
				TweenService:Create(visualObj, hoverOut, {
					ImageTransparency = isAct and 0 or 0.32,
					ImageColor3 = isAct and Color3.fromRGB(255, 255, 255) or Theme.Current.Accent,
				}):Play()
			end
			TweenService:Create(aura, hoverOut, {
				Size = UDim2.fromOffset(34, 34),
				ImageTransparency = isAct and 0.72 or 1,
			}):Play()
			TweenService:Create(tip, hoverOut, {
				Position = UDim2.new(0.5, 0, 0, -10),
				BackgroundTransparency = 1,
				TextTransparency = 1,
			}):Play()
			TweenService:Create(tipStroke, hoverOut, { Transparency = 1 }):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			onSelect(item.id)
		end)
	end

	-- フェードする縦仕切り線
	local sep = Instance.new("Frame")
	sep.AnchorPoint = Vector2.new(0.5, 0.5)
	sep.Position = UDim2.fromOffset(314, 31)
	sep.Size = UDim2.fromOffset(1, 28)
	sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sep.BackgroundTransparency = 0.8
	sep.BorderSizePixel = 0
	sep.ZIndex = 6
	sep.Parent = dockWrap

	local sepGrad = Instance.new("UIGradient")
	sepGrad.Rotation = 90
	sepGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(0.7, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	sepGrad.Parent = sep

	local function makeCtrl(symbol, cx, isClose, cb)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Position = UDim2.fromOffset(cx, 31)
		b.Size = UDim2.fromOffset(34, 34)
		b.BackgroundTransparency = 0.38
		b.Font = Enum.Font.GothamBold
		b.Text = symbol
		b.TextSize = 14
		b.AutoButtonColor = false
		b.ZIndex = 7
		Theme.Bind(b, "BackgroundColor3", "Card")
		Theme.Bind(b, "TextColor3", "SubText")
		b.Parent = dockWrap
		Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

		local sc = Instance.new("UIScale", b)
		b.MouseEnter:Connect(function()
			TweenService:Create(sc, hoverIn, { Scale = 1.12 }):Play()
			TweenService:Create(b, hoverIn, {
				BackgroundColor3 = isClose and Theme.Current.Danger or Theme.Current.CardHover,
				BackgroundTransparency = 0.1,
				TextColor3 = Color3.fromRGB(255, 255, 255),
			}):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(sc, hoverOut, { Scale = 1 }):Play()
			TweenService:Create(b, hoverOut, {
				BackgroundColor3 = Theme.Current.Card,
				BackgroundTransparency = 0.38,
				TextColor3 = Theme.Current.SubText,
			}):Play()
		end)
		b.MouseButton1Click:Connect(cb)
	end

	makeCtrl("—", 349, false, function() onClose(true) end)
	makeCtrl("×", 395, true, function() onClose(false) end)

	local function setActive(id)
		activeId = id
		local target = buttons[id]
		if not target then return end

		local slideInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		TweenService:Create(activePill, slideInfo, { Position = UDim2.fromOffset(target.x, 29) }):Play()
		TweenService:Create(activeBar, slideInfo, { Position = UDim2.new(0, target.x, 1, -4) }):Play()

		for k, info in pairs(buttons) do
			local isMe = (k == id)
			TweenService:Create(info.scale, hoverOut, { Scale = isMe and 1.04 or 1 }):Play()
			if not info.isAvatar then
				TweenService:Create(info.visual, hoverOut, {
					ImageTransparency = isMe and 0 or 0.32,
					ImageColor3 = isMe and Color3.fromRGB(255, 255, 255) or Theme.Current.Accent,
				}):Play()
			end
			TweenService:Create(info.aura, hoverOut, {
				ImageTransparency = isMe and 0.72 or 1,
			}):Play()
		end
	end

	return {
		Frame = dockWrap,
		Bg = dockBg,
		SetActive = setActive,
	}
end

return createDock