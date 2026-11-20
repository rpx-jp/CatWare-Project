local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function createDock(parent, CatWare, Theme, navItems, onSelect, onClose)
	local player = Players.LocalPlayer
	local dockBgAsset = CatWare.Assets.Get("dock_bg.png")
	local dockGlassAsset = CatWare.Assets.Get("dock_glass.png")
	local dockShadowAsset = CatWare.Assets.Get("dock_shadow.png")
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
	dockWrap.ZIndex = 20
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
	dockBg.ImageTransparency = 0.24
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

	-- スライドするアクティブ背景ピル
	local activePill = Instance.new("Frame")
	activePill.Name = "ActivePill"
	activePill.AnchorPoint = Vector2.new(0.5, 0.5)
	activePill.Position = UDim2.fromOffset(40, 29)
	activePill.Size = UDim2.fromOffset(44, 40)
	activePill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	activePill.BackgroundTransparency = 0.88
	activePill.BorderSizePixel = 0
	activePill.ZIndex = 4
	activePill.Parent = dockWrap
	Instance.new("UICorner", activePill).CornerRadius = UDim.new(0, 14)

	-- ドック最下部の発光インジケーターバー
	local activeBar = Instance.new("Frame")
	activeBar.Name = "ActiveBar"
	activeBar.AnchorPoint = Vector2.new(0.5, 1)
	activeBar.Position = UDim2.new(0, 40, 1, -4)
	activeBar.Size = UDim2.fromOffset(16, 2.5)
	activeBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	activeBar.BorderSizePixel = 0
	activeBar.ZIndex = 11
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

		-- 高さを抑えてステージと重ならないスマートツールチップ
		local tip = Instance.new("TextLabel")
		tip.AnchorPoint = Vector2.new(0.5, 1)
		tip.Position = UDim2.new(0.5, 0, 0, -5)
		tip.Size = UDim2.fromOffset(0, 20)
		tip.AutomaticSize = Enum.AutomaticSize.X
		tip.BackgroundColor3 = Theme.Current.Tile
		tip.BackgroundTransparency = 1
		tip.Font = Enum.Font.GothamBold
		tip.Text = item.label
		tip.TextColor3 = Color3.fromRGB(255, 255, 255)
		tip.TextSize = 11
		tip.TextTransparency = 1
		tip.ZIndex = 20
		tip.Parent = btn
		Instance.new("UICorner", tip).CornerRadius = UDim.new(1, 0)

		local tipPad = Instance.new("UIPadding")
		tipPad.PaddingLeft = UDim.new(0, 10)
		tipPad.PaddingRight = UDim.new(0, 10)
		tipPad.Parent = tip

		local tipStroke = Theme.GlassStroke(tip, { Transparency = 1 })

		-- 中央の柔らかい丸い光
		local aura = Instance.new("ImageLabel")
		aura.AnchorPoint = Vector2.new(0.5, 0.5)
		aura.Position = UDim2.fromScale(0.5, 0.5)
		aura.Size = UDim2.fromOffset(34, 34)
		aura.BackgroundTransparency = 1
		aura.Image = glowAsset
		aura.ImageColor3 = Color3.fromRGB(255, 255, 255)
		aura.ImageTransparency = 1
		aura.ZIndex = 5
		aura.Parent = btn

		local visualObj
		local visualScale = Instance.new("UIScale")
		visualScale.Scale = 1

		if item.isAvatar then
			local ring = Instance.new("Frame")
			ring.AnchorPoint = Vector2.new(0.5, 0.5)
			ring.Position = UDim2.fromScale(0.5, 0.5)
			ring.Size = UDim2.fromOffset(30, 30)
			ring.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ring.BackgroundTransparency = 0.65
			ring.BorderSizePixel = 0
			ring.ZIndex = 7
			ring.Parent = btn
			Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
			visualScale.Parent = ring

			local av = Instance.new("ImageLabel")
			av.AnchorPoint = Vector2.new(0.5, 0.5)
			av.Position = UDim2.fromScale(0.5, 0.5)
			av.Size = UDim2.fromOffset(26, 26)
			av.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
			av.ZIndex = 8
			av.Parent = ring
			Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)

			task.spawn(function()
				local ok, thumb = pcall(function()
					return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if ok and thumb then
					av.Image = thumb
				end
			end)
			visualObj = ring
		else
			local ic = Icons.Create(item.id, btn, Theme, 21)
			ic.ImageColor3 = Color3.fromRGB(255, 255, 255)
			ic.ImageTransparency = 0.35
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
				TweenService:Create(visualObj, hoverIn, { ImageTransparency = 0 }):Play()
			else
				TweenService:Create(visualObj, hoverIn, { BackgroundTransparency = 0.25 }):Play()
			end
			TweenService:Create(aura, hoverIn, {
				Size = UDim2.fromOffset(48, 48),
				ImageTransparency = 0.58,
			}):Play()
			tip.BackgroundColor3 = Theme.Current.Tile
			TweenService:Create(tip, hoverIn, {
				Position = UDim2.new(0.5, 0, 0, -11),
				BackgroundTransparency = 0.16,
				TextTransparency = 0,
			}):Play()
			TweenService:Create(tipStroke, hoverIn, { Transparency = 0.15 }):Play()
		end)

		btn.MouseLeave:Connect(function()
			local isAct = (activeId == item.id)
			TweenService:Create(visualScale, hoverOut, { Scale = isAct and 1.04 or 1 }):Play()
			TweenService:Create(visualObj, hoverOut, { Position = UDim2.fromScale(0.5, 0.5) }):Play()
			if not item.isAvatar then
				TweenService:Create(visualObj, hoverOut, {
					ImageTransparency = isAct and 0 or 0.35,
				}):Play()
			else
				TweenService:Create(visualObj, hoverOut, {
					BackgroundTransparency = isAct and 0.35 or 0.65,
				}):Play()
			end
			TweenService:Create(aura, hoverOut, {
				Size = UDim2.fromOffset(34, 34),
				ImageTransparency = isAct and 0.78 or 1,
			}):Play()
			TweenService:Create(tip, hoverOut, {
				Position = UDim2.new(0.5, 0, 0, -5),
				BackgroundTransparency = 1,
				TextTransparency = 1,
			}):Play()
			TweenService:Create(tipStroke, hoverOut, { Transparency = 1 }):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			TweenService:Create(visualScale, TweenInfo.new(0.07), { Scale = 0.92 }):Play()
			task.delay(0.07, function()
				TweenService:Create(visualScale, hoverIn, { Scale = 1.12 }):Play()
			end)
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

	-- 右側の丸ガラスボタン（最小化・非表示）
	local function makeCtrl(iconId, cx, isClose, cb)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Position = UDim2.fromOffset(cx, 31)
		b.Size = UDim2.fromOffset(34, 34)
		b.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		b.BackgroundTransparency = 0.90
		b.Text = ""
		b.AutoButtonColor = false
		b.ZIndex = 7
		b.Parent = dockWrap
		Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

		local st = Theme.GlassStroke(b, {
			Thickness = 1,
			Transparency = 0.22,
		})

		local ic = Instance.new("ImageLabel")
		ic.AnchorPoint = Vector2.new(0.5, 0.5)
		ic.Position = UDim2.fromScale(0.5, 0.5)
		ic.Size = UDim2.fromOffset(16, 16)
		ic.BackgroundTransparency = 1
		ic.Image = Icons.Get(iconId)
		ic.ImageColor3 = Color3.fromRGB(255, 255, 255)
		ic.ImageTransparency = 0.25
		ic.ScaleType = Enum.ScaleType.Fit
		ic.ZIndex = 8
		ic.Parent = b

		local sc = Instance.new("UIScale", b)
		b.MouseEnter:Connect(function()
			TweenService:Create(sc, hoverIn, { Scale = 1.12 }):Play()
			TweenService:Create(ic, hoverIn, {
				ImageTransparency = 0,
				ImageColor3 = isClose and Color3.fromRGB(255, 195, 190) or Color3.fromRGB(255, 255, 255),
				Rotation = isClose and 90 or 0,
			}):Play()
			TweenService:Create(st, hoverIn, {
				Transparency = 0,
				Color = isClose and Color3.fromRGB(255, 150, 145) or Color3.fromRGB(255, 255, 255),
			}):Play()
			TweenService:Create(b, hoverIn, {
				BackgroundColor3 = isClose and Color3.fromRGB(255, 100, 95) or Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = isClose and 0.72 or 0.78,
			}):Play()
		end)
		b.MouseLeave:Connect(function()
			TweenService:Create(sc, hoverOut, { Scale = 1 }):Play()
			TweenService:Create(ic, hoverOut, {
				ImageTransparency = 0.25,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				Rotation = 0,
			}):Play()
			TweenService:Create(st, hoverOut, {
				Transparency = 0.22,
				Color = Color3.fromRGB(255, 255, 255),
			}):Play()
			TweenService:Create(b, hoverOut, {
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.90,
			}):Play()
		end)
		b.MouseButton1Click:Connect(cb)
	end

	makeCtrl("minus", 349, false, function() onClose(true) end)
	makeCtrl("close", 395, true, function() onClose(false) end)

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
					ImageTransparency = isMe and 0 or 0.35,
				}):Play()
			else
				TweenService:Create(info.visual, hoverOut, {
					BackgroundTransparency = isMe and 0.35 or 0.65,
				}):Play()
			end
			TweenService:Create(info.aura, hoverOut, {
				ImageTransparency = isMe and 0.78 or 1,
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