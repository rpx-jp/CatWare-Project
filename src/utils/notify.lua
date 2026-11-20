local TweenService = game:GetService("TweenService")

local Notify = {}
local holder = nil
local ThemeRef = nil

local ICONS = {
	bell  = "rbxassetid://10709775704", -- lucide-bell
	check = "rbxassetid://10709790644", -- lucide-check
	info  = "rbxassetid://10723415903", -- lucide-info
}

function Notify.Init(screenGui, _logo, Theme)
	ThemeRef = Theme

	holder = Instance.new("Frame")
	holder.Name = "Notifications"
	holder.AnchorPoint = Vector2.new(1, 1)
	holder.Position = UDim2.new(1, -20, 1, -20)
	holder.Size = UDim2.new(0, 276, 1, -40)
	holder.BackgroundTransparency = 1
	holder.ZIndex = 50
	holder.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Padding = UDim.new(0, 10)
	layout.Parent = holder
end

function Notify.Send(titleText, bodyText, duration, iconKey)
	if not holder or not holder.Parent then
		return
	end
	duration = duration or 3
	local cur = ThemeRef.Current

	local toast = Instance.new("TextButton")
	toast.Size = UDim2.new(1, 0, 0, 58)
	toast.BackgroundColor3 = cur.Tile
	toast.BackgroundTransparency = 1
	toast.Text = ""
	toast.AutoButtonColor = false
	toast.ZIndex = 51
	toast.Parent = holder
	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 18)

local stroke = ThemeRef.GlassStroke(toast, { Transparency = 1 })

	-- Lucide アイコン用の白透け丸ガラスオーブ
	local orb = Instance.new("Frame")
	orb.AnchorPoint = Vector2.new(0, 0.5)
	orb.Position = UDim2.new(0, 12, 0.5, 0)
	orb.Size = UDim2.fromOffset(34, 34)
	orb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	orb.BackgroundTransparency = 1
	orb.BorderSizePixel = 0
	orb.ZIndex = 52
	orb.Parent = toast
	Instance.new("UICorner", orb).CornerRadius = UDim.new(1, 0)

	local icon = Instance.new("ImageLabel")
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.fromOffset(17, 17)
	icon.BackgroundTransparency = 1
	icon.Image = ICONS[iconKey] or ICONS.bell
	icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	icon.ImageTransparency = 1
	icon.ScaleType = Enum.ScaleType.Fit
	icon.ZIndex = 53
	icon.Parent = orb

	local tTitle = Instance.new("TextLabel")
	tTitle.Position = UDim2.fromOffset(56, 11)
	tTitle.Size = UDim2.new(1, -68, 0, 18)
	tTitle.BackgroundTransparency = 1
	tTitle.Font = Enum.Font.GothamBold
	tTitle.Text = titleText
	tTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	tTitle.TextTransparency = 1
	tTitle.TextSize = 13
	tTitle.TextXAlignment = Enum.TextXAlignment.Left
	tTitle.ZIndex = 52
	tTitle.Parent = toast

	local tBody = Instance.new("TextLabel")
	tBody.Position = UDim2.fromOffset(56, 30)
	tBody.Size = UDim2.new(1, -68, 0, 16)
	tBody.BackgroundTransparency = 1
	tBody.Font = Enum.Font.Gotham
	tBody.Text = bodyText
	tBody.TextColor3 = Color3.fromRGB(255, 255, 255)
	tBody.TextTransparency = 1
	tBody.TextSize = 11
	tBody.TextXAlignment = Enum.TextXAlignment.Left
	tBody.TextTruncate = Enum.TextTruncate.AtEnd
	tBody.ZIndex = 52
	tBody.Parent = toast

	local sc = Instance.new("UIScale")
	sc.Scale = 0.90
	sc.Parent = toast

	-- ふわっと出現
	local inInfo = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local fadeIn = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	TweenService:Create(sc, inInfo, { Scale = 1 }):Play()
	TweenService:Create(toast, fadeIn, { BackgroundTransparency = 0.22 }):Play()
	TweenService:Create(stroke, fadeIn, { Transparency = 0.82 }):Play()
	TweenService:Create(orb, fadeIn, { BackgroundTransparency = 0.88 }):Play()
	TweenService:Create(icon, fadeIn, { ImageTransparency = 0.05 }):Play()
	TweenService:Create(tTitle, fadeIn, { TextTransparency = 0 }):Play()
	TweenService:Create(tBody, fadeIn, { TextTransparency = 0.35 }):Play()

	local dismissed = false
	local function dismiss()
		if dismissed or not toast.Parent then return end
		dismissed = true
		local outInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		TweenService:Create(sc, outInfo, { Scale = 0.92 }):Play()
		TweenService:Create(toast, outInfo, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(stroke, outInfo, { Transparency = 1 }):Play()
		TweenService:Create(orb, outInfo, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(icon, outInfo, { ImageTransparency = 1 }):Play()
		TweenService:Create(tTitle, outInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(tBody, outInfo, { TextTransparency = 1 }):Play()
		task.delay(0.26, function()
			if toast.Parent then toast:Destroy() end
		end)
	end

	toast.MouseButton1Click:Connect(dismiss)
	task.delay(duration, dismiss)
end

return Notify