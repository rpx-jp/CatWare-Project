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
	dockWrap.ZIndex = 15
	dockWrap.Parent = parent

	-- ドック専用ドロップシャドウ
	local dockShadow = Instance.new("ImageLabel")
	dockShadow.AnchorPoint = Vector2.new(0.5, 0.5)
	dockShadow.Position = UDim2.new(0.5, 0, 0.5, 8)
	dockShadow.Size = UDim2.fromOffset(428 + 56, 62 + 56)
	dockShadow.BackgroundTransparency = 1
	dockShadow.Image = dockShadowAsset
	dockShadow.ImageTransparency = 0.35
	dockShadow.ZIndex = 1
	dockShadow.Parent = dockWrap

	-- カプセル背景
	local dockBg = Instance.new("ImageLabel")
	dockBg.Name = "DockBg"
	dockBg.Size = UDim2.fromScale(1, 1)
	dockBg.BackgroundTransparency = 1
	dockBg.Image = dockBgAsset
	dockBg.ImageTransparency = 0.14
	dockBg.ZIndex = 2
	Theme.Bind(dockBg, "ImageColor3", "Tile")
	dockBg.Parent = dockWrap

	-- リキッドグラス反射リム
	local dockGlass = Instance.new("ImageLabel")
	dockGlass.Size = UDim2.fromScale(1, 1)
	dockGlass.BackgroundTransparency = 1
	dockGlass.Image = dockGlassAsset
	dockGlass.ImageTransparency = 0.08
	dockGlass.ZIndex = 10
	dockGlass.Parent = dockWrap

	-- スライドするアクティブ・インジケーターピル
	local activePill = Instance.new("Frame")
	activePill.Name = "ActivePill"
	activePill.AnchorPoint = Vector2.new(0.5, 0.5)
	activePill.Position = UDim2.fromOffset(40, 31)
	activePill.Size = UDim2.fromOffset(44, 44)
	activePill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	activePill.BackgroundTransparency = 0.90
	activePill.ZIndex = 4
	activePill.Parent = dockWrap
	Instance.new("UICorner", activePill).CornerRadius = UDim.new(0, 15)

	local apStroke = Instance.new("UIStroke")
	apStroke.Thickness = 1.1
	apStroke.Transparency = 0.55
	Theme.Bind(apStroke, "Color", "Accent")
	apStroke.Parent = activePill

	local activeDot = Instance.new("Frame")
	activeDot.AnchorPoint = Vector2.new(0.5, 1)
	activeDot.Position = UDim2.new(0.5, 0, 1, -3)
	activeDot.Size = UDim2.fromOffset(14, 3)
	activeDot.BorderSizePixel = 0
	activeDot.ZIndex = 6
	Theme.Bind(activeDot, "BackgroundColor3", "Accent")
	activeDot.Parent = activePill
	Instance.new("UICorner", activeDot).CornerRadius = UDim.new(1, 0)

	local buttons = {}
	local activeId = nil
	local hoverIn = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local hoverOut = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	for idx, item in ipairs(navItems) do
		local centerX = 40 + (idx - 1) * 58

		local btn = Instance.new("TextButton")
		btn.Name = item.id
		btn.AnchorPoint = Vector2.new(0.5, 0.5)
		btn.Position = UDim2.fromOffset(centerX, 31)
		btn.Size = UDim2.fromOffset(48, 48)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 6
		btn.Parent = dockWrap

		-- 浮かび上がるツールチップ（ホバー時だけ上に表示）
		local tip = Instance.new("TextLabel")
		tip.AnchorPoint = Vector2.new(0.5, 1)
		tip.Position = UDim2.new(0.5, 0, 0, -6)
		tip.Size = UDim2.fromOffset(78, 22)
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

		local tipStroke = Instance.new("UIStroke")
		tipStroke.Thickness = 1
		tipStroke.Transparency = 1
		Theme.Bind(tipStroke, "Color", "Glow")
		tipStroke.Parent = tip

		-- アイコン中央の丸い光（角丸にクリップされない中央配置）
		local aura = Instance.new("ImageLabel")
		aura.AnchorPoint = Vector2.new(0.5, 0.5)
		aura.Position = UDim2.fromScale(0.5, 0.5)
		aura.Size = UDim2.fromOffset(36, 36)
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
			av.Size = UDim2.fromOffset(30, 30)
			av.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
			av.ZIndex = 7
			av.Parent = btn
			Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
			visualScale.Parent = av

			local avs = Instance.new("UIStroke")
			avs.Thickness = 1.4
			avs.Transparency = 0.4
			Theme.Bind(avs, "Color", "Accent")
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
			local ic = Icons.Create(item.id, btn, Theme, 22)
			ic.ImageTransparency = 0.3
			ic.ZIndex = 7
			visualScale.Parent = ic
			visualObj = ic
		end

		buttons[item.id] = {
			x = centerX,
			visual = visualObj,
			isAvatar = item.isAvatar,
			aura = aura,
		}

		btn.MouseEnter:Connect(function()
			TweenService:Create(visualScale, hoverIn, { Scale = 1.2 }):Play()
			TweenService:Create(visualObj, hoverIn, { Position = UDim2.new(0.5, 0, 0.5, -5) }):Play()
			if not item.isAvatar then
				TweenService:Create(visualObj, hoverIn, {
					ImageTransparency = 0,
					ImageColor3 = Color3.fromRGB(255, 255, 255),
				}):Play()
			end
			TweenService:Create(aura, hoverIn, {
				Size = UDim2.fromOffset(56, 56),
				ImageTransparency = 0.45,
			}):Play()
			TweenService:Create(tip, hoverIn, {
				Position = UDim2.new(0.5, 0, 0, -14),
				BackgroundTransparency = 0.12,
				TextTransparency = 0,
			}):Play()
			TweenService:Create(tipStroke, hoverIn, { Transparency = 0.72 }):Play()
		end)

		btn.MouseLeave:Connect(function()
			local isAct = (activeId == item.id)
			TweenService:Create(visualScale, hoverOut, { Scale = isAct and 1.06 or 1 }):Play()
			TweenService:Create(visualObj, hoverOut, { Position = UDim2.fromScale(0.5, 0.5) }):Play()
			if not item.isAvatar then
				TweenService:Create(visualObj, hoverOut, {
					ImageTransparency = isAct and 0 or 0.32,
					ImageColor3 = isAct and Color3.fromRGB(255, 255, 255) or Theme.Current.Accent,
				}):Play()
			end
			TweenService:Create(aura, hoverOut, {
				Size = UDim2.fromOffset(36, 36),
				ImageTransparency = isAct and 0.68 or 1,
			}):Play()
			TweenService:Create(tip, hoverOut, {
				Position = UDim2.new(0.5, 0, 0, -6),
				BackgroundTransparency = 1,
				TextTransparency = 1,
			}):Play()
			TweenService:Create(tipStroke, hoverOut, { Transparency = 1 }):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			onSelect(item.id)
		end)
	end

	-- 仕切り線
	local sep = Instance.new("Frame")
	sep.AnchorPoint = Vector2.new(0.5, 0.5)
	sep.Position = UDim2.fromOffset(314, 31)
	sep.Size = UDim2.fromOffset(1, 26)
	sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sep.BackgroundTransparency = 0.85
	sep.BorderSizePixel = 0
	sep.ZIndex = 6
	sep.Parent = dockWrap

	-- 右側の最小化・非表示ボタン
	local function makeCtrl(symbol, cx, isClose, cb)
		local b = Instance.new("TextButton")
		b.AnchorPoint = Vector2.new(0.5, 0.5)
		b.Position = UDim2.fromOffset(cx, 31)
		b.Size = UDim2.fromOffset(34, 34)
		b.BackgroundTransparency = 0.35
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
				BackgroundTransparency = 0.35,
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
		if not target then
			return
		end
		TweenService:Create(activePill, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.fromOffset(target.x, 31),
		}):Play()

		for k, info in pairs(buttons) do
			local isMe = (k == id)
			if not info.isAvatar then
				TweenService:Create(info.visual, hoverOut, {
					ImageTransparency = isMe and 0 or 0.32,
					ImageColor3 = isMe and Color3.fromRGB(255, 255, 255) or Theme.Current.Accent,
				}):Play()
			end
			TweenService:Create(info.aura, hoverOut, {
				ImageTransparency = isMe and 0.68 or 1,
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