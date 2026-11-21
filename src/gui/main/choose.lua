local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- 初回起動時のUI選択画面。onChoose(name) に "modern" / "classic" を渡す
return function(CatWare, onChoose)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local Theme = CatWare.Theme
	local Notify = CatWare.Notify
	local Shadow = CatWare.Import("src/utils/shadow.lua")

	if playerGui:FindFirstChild("CatWareGui") then
		playerGui.CatWareGui:Destroy()
	end
	if Lighting:FindFirstChild("CatWareBlur") then
		Lighting.CatWareBlur:Destroy()
	end

	local logoAsset = CatWare.Assets.Get("cw.png")
	local shadowAsset = CatWare.Assets.Get("shadow.png")
	local modernPreview = CatWare.Assets.Get("ui_modern.png")
	local classicPreview = CatWare.Assets.Get("ui_classic.png")

	local blur = Instance.new("BlurEffect")
	blur.Name = "CatWareBlur"
	blur.Size = 0
	blur.Parent = Lighting

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CatWareChooser"
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 600
	screenGui.Parent = playerGui

	Notify.Init(screenGui, logoAsset, Theme)

	local dim = Instance.new("Frame")
	dim.Size = UDim2.fromScale(1, 1)
	dim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	dim.BackgroundTransparency = 1
	dim.ZIndex = 1
	dim.Parent = screenGui

	local root = Instance.new("Frame")
	root.Name = "ChooserRoot"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.Size = UDim2.fromOffset(720, 432)
	root.BackgroundTransparency = 1
	root.ZIndex = 10
	root.Parent = screenGui

	local rootScale = Instance.new("UIScale")
	rootScale.Scale = 0.9
	rootScale.Parent = root

	Shadow.Create(root, shadowAsset, {
		Padding = 30,
		OffsetY = 10,
		Transparency = 0.42,
		ZIndex = 1,
	})

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(1, 1)
	panel.BackgroundTransparency = 0.06
	panel.ClipsDescendants = true
	panel.ZIndex = 2
	Theme.Bind(panel, "BackgroundColor3", "Tile")
	panel.Parent = root
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 22)

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Thickness = 1.2
	panelStroke.Transparency = 0.8
	Theme.Bind(panelStroke, "Color", "Glow")
	panelStroke.Parent = panel

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 26)
	title.Size = UDim2.fromOffset(400, 30)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "使うUIを選択"
	title.TextSize = 21
	Theme.Bind(title, "TextColor3", "Text")
	title.ZIndex = 3
	title.Parent = panel

	local subtitle = Instance.new("TextLabel")
	subtitle.AnchorPoint = Vector2.new(0.5, 0)
	subtitle.Position = UDim2.new(0.5, 0, 0, 60)
	subtitle.Size = UDim2.fromOffset(480, 18)
	subtitle.BackgroundTransparency = 1
	subtitle.Font = Enum.Font.Gotham
	subtitle.Text = "あとで Settings からいつでも切り替えられます"
	subtitle.TextSize = 12
	Theme.Bind(subtitle, "TextColor3", "SubText")
	subtitle.TextTransparency = 0.2
	subtitle.ZIndex = 3
	subtitle.Parent = panel

	local options = {
		{
			id = "modern",
			preview = modernPreview,
			label = "新しいUI (VisionOS)",
			sub = "リキッドガラス + ドック",
			x = 24,
		},
		{
			id = "classic",
			preview = classicPreview,
			label = "従来のUI (Hub)",
			sub = "BentoDeck スタイル",
			x = 372,
		},
	}

	local hoverIn = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local hoverOut = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	for _, opt in ipairs(options) do
		local card = Instance.new("TextButton")
		card.Name = "Option_" .. opt.id
		card.Position = UDim2.fromOffset(opt.x, 96)
		card.Size = UDim2.fromOffset(324, 312)
		card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		card.BackgroundTransparency = 0.88
		card.Text = ""
		card.AutoButtonColor = false
		card.ClipsDescendants = true
		card.ZIndex = 3
		Theme.Bind(card, "BackgroundColor3", "Card")
		card.Parent = panel
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 18)

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1.4
		stroke.Transparency = 0.82
		Theme.Bind(stroke, "Color", "Glow")
		stroke.Parent = card

		local scale = Instance.new("UIScale")
		scale.Scale = 1
		scale.Parent = card

		local preview = Instance.new("ImageLabel")
		preview.AnchorPoint = Vector2.new(0.5, 0)
		preview.Position = UDim2.new(0.5, 0, 0, 16)
		preview.Size = UDim2.fromOffset(296, 204)
		preview.BackgroundTransparency = 1
		preview.Image = opt.preview
		preview.ScaleType = Enum.ScaleType.Fit
		preview.ZIndex = 4
		preview.Parent = card

		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0)
		label.Position = UDim2.new(0.5, 0, 0, 232)
		label.Size = UDim2.fromOffset(300, 24)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.Text = opt.label
		label.TextSize = 15
		Theme.Bind(label, "TextColor3", "Text")
		label.ZIndex = 4
		label.Parent = card

		local sub = Instance.new("TextLabel")
		sub.AnchorPoint = Vector2.new(0.5, 0)
		sub.Position = UDim2.new(0.5, 0, 0, 260)
		sub.Size = UDim2.fromOffset(300, 18)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.Text = opt.sub
		sub.TextSize = 11
		Theme.Bind(sub, "TextColor3", "SubText")
		sub.TextTransparency = 0.2
		sub.ZIndex = 4
		sub.Parent = card

		local sheen = Instance.new("Frame")
		sheen.Size = UDim2.fromScale(1, 1)
		sheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sheen.BackgroundTransparency = 1
		sheen.BorderSizePixel = 0
		sheen.ZIndex = 5
		sheen.Parent = card
		Instance.new("UICorner", sheen).CornerRadius = UDim.new(0, 18)

		card.MouseEnter:Connect(function()
			TweenService:Create(scale, hoverIn, { Scale = 1.025 }):Play()
			TweenService:Create(sheen, hoverIn, { BackgroundTransparency = 0.92 }):Play()
			TweenService:Create(stroke, hoverIn, { Transparency = 0.3 }):Play()
		end)
		card.MouseLeave:Connect(function()
			TweenService:Create(scale, hoverOut, { Scale = 1 }):Play()
			TweenService:Create(sheen, hoverOut, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(stroke, hoverOut, { Transparency = 0.82 }):Play()
		end)

		card.MouseButton1Click:Connect(function()
			TweenService:Create(blur, TweenInfo.new(0.2), { Size = 0 }):Play()
			TweenService:Create(dim, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(rootScale, TweenInfo.new(0.18), { Scale = 0.9 }):Play()
			task.delay(0.18, function()
				if onChoose then
					onChoose(opt.id)
				end
				blur:Destroy()
				screenGui:Destroy()
			end)
		end)
	end

	-- 選択画面の登場アニメーション
	TweenService:Create(blur, TweenInfo.new(0.3), { Size = 16 }):Play()
	TweenService:Create(dim, TweenInfo.new(0.3), { BackgroundTransparency = 0.45 }):Play()
	TweenService:Create(rootScale, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1,
	}):Play()
end
