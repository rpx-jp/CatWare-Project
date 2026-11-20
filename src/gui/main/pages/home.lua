local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

return function(page, ctx)
	local player = Players.LocalPlayer
	local Theme = ctx.Theme
	local C = ctx.Components

	-- クリーンなガラスプロフィールカード
	local hero = Instance.new("Frame")
	hero.Size = UDim2.new(1, 0, 0, 68)
	hero.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hero.BackgroundTransparency = 0.91
	hero.Parent = page
	Instance.new("UICorner", hero).CornerRadius = UDim.new(0, 16)

	local hStroke = Instance.new("UIStroke")
	hStroke.Color = Color3.fromRGB(255, 255, 255)
	hStroke.Thickness = 1
	hStroke.Transparency = 0.90
	hStroke.Parent = hero

	local avatar = Instance.new("ImageLabel")
	avatar.AnchorPoint = Vector2.new(0, 0.5)
	avatar.Position = UDim2.new(0, 14, 0.5, 0)
	avatar.Size = UDim2.fromOffset(44, 44)
	avatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	avatar.BackgroundTransparency = 0.85
	avatar.Parent = hero
	Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and thumb then avatar.Image = thumb end
	end)

	local disp = Instance.new("TextLabel")
	disp.Position = UDim2.fromOffset(70, 15)
	disp.Size = UDim2.new(1, -86, 0, 20)
	disp.BackgroundTransparency = 1
	disp.Font = Enum.Font.GothamBold
	disp.Text = player.DisplayName
	disp.TextColor3 = Color3.fromRGB(255, 255, 255)
	disp.TextSize = 15
	disp.TextXAlignment = Enum.TextXAlignment.Left
	disp.Parent = hero

	local uname = Instance.new("TextLabel")
	uname.Position = UDim2.fromOffset(70, 36)
	uname.Size = UDim2.new(1, -86, 0, 16)
	uname.BackgroundTransparency = 1
	uname.Font = Enum.Font.Gotham
	uname.Text = "@" .. player.Name
	uname.TextColor3 = Color3.fromRGB(255, 255, 255)
	uname.TextTransparency = 0.45
	uname.TextSize = 12
	uname.TextXAlignment = Enum.TextXAlignment.Left
	uname.Parent = hero

	-- 静かなガラス数値カード（ネオンなし・純白）
	local statsRow = Instance.new("Frame")
	statsRow.Size = UDim2.new(1, 0, 0, 62)
	statsRow.BackgroundTransparency = 1
	statsRow.Parent = page

	local function makeMetric(label, unit, xScale, xOff)
		local box = Instance.new("Frame")
		box.Position = UDim2.new(xScale, xOff, 0, 0)
		box.Size = UDim2.new(0.5, -5, 1, 0)
		box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		box.BackgroundTransparency = 0.91
		box.Parent = statsRow
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)

		local st = Instance.new("UIStroke")
		st.Color = Color3.fromRGB(255, 255, 25