local TweenService = game:GetService("TweenService")

local Notify = {}
local holder = nil
local logoAsset = ""
local ThemeRef = nil

function Notify.Init(screenGui, logo, Theme)
	logoAsset = logo or ""
	ThemeRef = Theme

	holder = Instance.new("Frame")
	holder.Name = "Notifications"
	holder.AnchorPoint = Vector2.new(1, 1)
	holder.Position = UDim2.new(1, -18, 1, -18)
	holder.Size = UDim2.new(0, 265, 1, -36)
	holder.BackgroundTransparency = 1
	holder.ZIndex = 50
	holder.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Padding = UDim.new(0, 8)
	layout.Parent = holder
end

function Notify.Send(titleText, bodyText, duration)
	if not holder or not holder.Parent then
		return
	end
	duration = duration or 3
	local cur = ThemeRef.Current

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(1, 0, 0, 56)
	toast.BackgroundColor3 = cur.Tile
	toast.BackgroundTransparency = 0.08
	toast.ClipsDescendants = true
	toast.ZIndex = 51
	toast.Parent = holder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Color = cur.Glow
	stroke.Thickness = 1
	stroke.Transparency = 0.8
	stroke.Parent = toast

	local icon = Instance.new("ImageLabel")
	icon.Position = UDim2.fromOffset(10, 11)
	icon.Size = UDim2.fromOffset(32, 32)
	icon.BackgroundTransparency = 1
	icon.Image = logoAsset
	icon.ScaleType = Enum.ScaleType.Fit
	icon.ZIndex = 52
	icon.Parent = toast

	local tTitle = Instance.new("TextLabel")
	tTitle.Position = UDim2.fromOffset(50, 9)
	tTitle.Size = UDim2.new(1, -60, 0, 18)
	tTitle.BackgroundTransparency = 1
	tTitle.Font = Enum.Font.GothamBold
	tTitle.Text = titleText
	tTitle.TextColor3 = cur.Text
	tTitle.TextSize = 13
	tTitle.TextXAlignment = Enum.TextXAlignment.Left
	tTitle.ZIndex = 52
	tTitle.Parent = toast

	local tBody = Instance.new("TextLabel")
	tBody.Position = UDim2.fromOffset(50, 27)
	tBody.Size = UDim2.new(1, -60, 0, 16)
	tBody.BackgroundTransparency = 1
	tBody.Font = Enum.Font.Gotham
	tBody.Text = bodyText
	tBody.TextColor3 = cur.SubText
	tBody.TextSize = 11
	tBody.TextXAlignment = Enum.TextXAlignment.Left
	tBody.TextTruncate = Enum.TextTruncate.AtEnd
	tBody.ZIndex = 52
	tBody.Parent = toast

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0, 1)
	bar.Position = UDim2.fromScale(0, 1)
	bar.Size = UDim2.new(1, 0, 0, 2)
	bar.BackgroundColor3 = cur.Accent
	bar.BorderSizePixel = 0
	bar.ZIndex = 52
	bar.Parent = toast

	local sc = Instance.new("UIScale")
	sc.Scale = 0.9
	sc.Parent = toast

	TweenService:Create(sc, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
	TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) }):Play()

	task.delay(duration, function()
		if toast.Parent then
			TweenService:Create(toast, TweenInfo.new(0.22), { BackgroundTransparency = 1 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.22), { Transparency = 1 }):Play()
			TweenService:Create(sc, TweenInfo.new(0.22), { Scale = 0.9 }):Play()
			task.wait(0.24)
			toast:Destroy()
		end
	end)
end

return Notify