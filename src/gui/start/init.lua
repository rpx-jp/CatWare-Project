local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function playStartAnim(CatWare)
	local logoAsset = CatWare.Assets.Get("cw.png")
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CatWareStartAnim"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 1000
	screenGui.Parent = playerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(6, 7, 10)
	backdrop.BackgroundTransparency = 1
	backdrop.Parent = screenGui

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(290, 180)
	card.BackgroundColor3 = Color3.fromRGB(12, 13, 17)
	card.BackgroundTransparency = 1
	card.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1.2
	stroke.Transparency = 1
	stroke.Parent = card

	local scale = Instance.new("UIScale")
	scale.Scale = 0.88
	scale.Parent = card

	local logo = Instance.new("ImageLabel")
	logo.AnchorPoint = Vector2.new(0.5, 0)
	logo.Position = UDim2.new(0.5, 0, 0, 22)
	logo.Size = UDim2.fromOffset(70, 70)
	logo.BackgroundTransparency = 1
	logo.Image = logoAsset
	logo.ImageTransparency = 1
	logo.ScaleType = Enum.ScaleType.Fit
	logo.Parent = card

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.Position = UDim2.new(0.5, 0, 0, 100)
	title.Size = UDim2.new(1, -24, 0, 22)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.GothamBold
	title.Text = "CatWare"
	title.TextColor3 = Color3.fromRGB(245, 247, 252)
	title.TextSize = 19
	title.TextTransparency = 1
	title.Parent = card

	local status = Instance.new("TextLabel")
	status.AnchorPoint = Vector2.new(0.5, 0)
	status.Position = UDim2.new(0.5, 0, 0, 124)
	status.Size = UDim2.new(1, -24, 0, 16)
	status.BackgroundTransparency = 1
	status.Font = Enum.Font.Gotham
	status.Text = "Loading CatWare..."
	status.TextColor3 = Color3.fromRGB(150, 158, 172)
	status.TextSize = 11
	status.TextTransparency = 1
	status.Parent = card

	local barBg = Instance.new("Frame")
	barBg.AnchorPoint = Vector2.new(0.5, 0)
	barBg.Position = UDim2.new(0.5, 0, 0, 150)
	barBg.Size = UDim2.new(1, -56, 0, 4)
	barBg.BackgroundColor3 = Color3.fromRGB(32, 35, 44)
	barBg.BackgroundTransparency = 1
	barBg.BorderSizePixel = 0
	barBg.Parent = card

	local bgc = Instance.new("UICorner")
	bgc.CornerRadius = UDim.new(1, 0)
	bgc.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.BackgroundColor3 = Color3.fromRGB(240, 244, 255)
	barFill.BorderSizePixel = 0
	barFill.Parent = barBg

	local bfc = Instance.new("UICorner")
	bfc.CornerRadius = UDim.new(1, 0)
	bfc.Parent = barFill

	local inInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	TweenService:Create(backdrop, inInfo, { BackgroundTransparency = 0.5 }):Play()
	TweenService:Create(card, inInfo, { BackgroundTransparency = 0.1 }):Play()
	TweenService:Create(stroke, inInfo, { Transparency = 0.8 }):Play()
	TweenService:Create(scale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	TweenService:Create(logo, inInfo, { ImageTransparency = 0 }):Play()
	TweenService:Create(title, inInfo, { TextTransparency = 0 }):Play()
	TweenService:Create(status, inInfo, { TextTransparency = 0 }):Play()
	TweenService:Create(barBg, inInfo, { BackgroundTransparency = 0.2 }):Play()

	task.wait(0.25)
	TweenService:Create(barFill, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(1, 1),
	}):Play()
	task.wait(0.85)

	status.Text = "Ready"
	task.wait(0.2)

	local outInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	TweenService:Create(backdrop, outInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(card, outInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(stroke, outInfo, { Transparency = 1 }):Play()
	TweenService:Create(scale, outInfo, { Scale = 0.92 }):Play()
	TweenService:Create(logo, outInfo, { ImageTransparency = 1 }):Play()
	TweenService:Create(title, outInfo, { TextTransparency = 1 }):Play()
	TweenService:Create(status, outInfo, { TextTransparency = 1 }):Play()
	TweenService:Create(barBg, outInfo, { BackgroundTransparency = 1 }):Play()
	TweenService:Create(barFill, outInfo, { BackgroundTransparency = 1 }):Play()

	task.wait(0.38)
	screenGui:Destroy()
end

return playStartAnim