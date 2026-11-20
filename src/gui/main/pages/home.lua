local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

return function(page, ctx)
	local player = Players.LocalPlayer
	local Theme = ctx.Theme
	local C = ctx.Components

	local hero = Instance.new("Frame")
	hero.Size = UDim2.new(1, 0, 0, 76)
	hero.BackgroundTransparency = 0.14
	Theme.Bind(hero, "BackgroundColor3", "Card")
	hero.Parent = page
	Instance.new("UICorner", hero).CornerRadius = UDim.new(0, 14)

	local hStroke = Instance.new("UIStroke")
	hStroke.Thickness = 1
	hStroke.Transparency = 0.84
	Theme.Bind(hStroke, "Color", "Glow")
	hStroke.Parent = hero

	-- ギザギザにならない滑らかな二重丸アバター枠
	local ring = Instance.new("Frame")
	ring.AnchorPoint = Vector2.new(0, 0.5)
	ring.Position = UDim2.new(0, 14, 0.5, 0)
	ring.Size = UDim2.fromOffset(52, 52)
	ring.BackgroundTransparency = 0.45
	ring.BorderSizePixel = 0
	Theme.Bind(ring, "BackgroundColor3", "Accent")
	ring.Parent = hero
	Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)

	local avatar = Instance.new("ImageLabel")
	avatar.AnchorPoint = Vector2.new(0.5, 0.5)
	avatar.Position = UDim2.fromScale(0.5, 0.5)
	avatar.Size = UDim2.fromOffset(48, 48)
	avatar.BackgroundColor3 = Color3.fromRGB(28, 32, 44)
	avatar.Parent = ring
	Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

	task.spawn(function()
		local ok, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and thumb then avatar.Image = thumb end
	end)

	local disp = Instance.new("TextLabel")
	disp.Position = UDim2.fromOffset(78, 17)
	disp.Size = UDim2.new(1, -96, 0, 22)
	disp.BackgroundTransparency = 1
	disp.Font = Enum.Font.GothamBold
	disp.Text = player.DisplayName
	disp.TextSize = 16
	disp.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(disp, "TextColor3", "Text")
	disp.Parent = hero

	local uname = Instance.new("TextLabel")
	uname.Position = UDim2.fromOffset(78, 41)
	uname.Size = UDim2.new(1, -96, 0, 16)
	uname.BackgroundTransparency = 1
	uname.Font = Enum.Font.Gotham
	uname.Text = "@" .. player.Name .. "  •  CatWare v" .. ctx.CatWare.Version
	uname.TextSize = 12
	uname.TextXAlignment = Enum.TextXAlignment.Left
	Theme.Bind(uname, "TextColor3", "SubText")
	uname.Parent = hero

	-- FPS / Ping カード（ミニゲージバー付き）
	local statsRow = Instance.new("Frame")
	statsRow.Size = UDim2.new(1, 0, 0, 74)
	statsRow.BackgroundTransparency = 1
	statsRow.Parent = page

	local function makeMetric(label, xScale, xOff)
		local box = Instance.new("Frame")
		box.Position = UDim2.new(xScale, xOff, 0, 0)
		box.Size = UDim2.new(0.5, -5, 1, 0)
		box.BackgroundTransparency = 0.14
		Theme.Bind(box, "BackgroundColor3", "Card")
		box.Parent = statsRow
		Instance.new("UICorner", box).CornerRadius = UDim.new(0, 12)

		local st = Instance.new("UIStroke")
		st.Thickness = 1
		st.Transparency = 0.86
		Theme.Bind(st, "Color", "Glow")
		st.Parent = box

		local t = Instance.new("TextLabel")
		t.Position = UDim2.fromOffset(14, 10)
		t.Size = UDim2.new(1, -28, 0, 14)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamBold
		t.Text = label
		t.TextSize = 10
		t.TextXAlignment = Enum.TextXAlignment.Left
		Theme.Bind(t, "TextColor3", "SubText")
		t.Parent = box

		local v = Instance.new("TextLabel")
		v.Position = UDim2.fromOffset(14, 26)
		v.Size = UDim2.new(1, -28, 0, 24)
		v.BackgroundTransparency = 1
		v.Font = Enum.Font.GothamBold
		v.Text = "--"
		v.TextSize = 20
		v.TextXAlignment = Enum.TextXAlignment.Left
		Theme.Bind(v, "TextColor3", "Accent")
		v.Parent = box

		local gBg = Instance.new("Frame")
		gBg.AnchorPoint = Vector2.new(0, 1)
		gBg.Position = UDim2.new(0, 14, 1, -10)
		gBg.Size = UDim2.new(1, -28, 0, 3)
		gBg.BackgroundColor3 = Color3.fromRGB(40, 44, 58)
		gBg.BorderSizePixel = 0
		gBg.Parent = box
		Instance.new("UICorner", gBg).CornerRadius = UDim.new(1, 0)

		local gFill = Instance.new("Frame")
		gFill.Size = UDim2.fromScale(0.2, 1)
		gFill.BorderSizePixel = 0
		Theme.Bind(gFill, "BackgroundColor3", "Accent")
		gFill.Parent = gBg
		Instance.new("UICorner", gFill).CornerRadius = UDim.new(1, 0)

		return v, gFill
	end

	local fpsVal, fpsBar = makeMetric("FRAME RATE", 0, 0)
	local pingVal, pingBar = makeMetric("NETWORK PING", 0.5, 5)

	local fc, fl = 0, os.clock()
	ctx.Track(RunService.RenderStepped:Connect(function()
		fc += 1
		local now = os.clock()
		if now - fl >= 0.5 then
			local fps = math.floor(fc / (now - fl) + 0.5)
			fc, fl = 0, now
			fpsVal.Text = tostring(fps) .. " FPS"
			TweenService:Create(fpsBar, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
				Size = UDim2.fromScale(math.clamp(fps / 120, 0.08, 1), 1),
			}):Play()

			local ok, ping = pcall(function()
				return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			pingVal.Text = ok and (tostring(ping) .. " ms") or "-- ms"
			if ok then
				TweenService:Create(pingBar, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {
					Size = UDim2.fromScale(math.clamp(1 - (ping / 220), 0.1, 1), 1),
				}):Play()
			end
		end
	end))

	C.Section(page, "Quick Actions")
	C.Button(page, "テスト通知を表示", "右下にフロスト通知を出します", false, Theme, function()
		ctx.Notify.Send("CatWare", "Spatial Glass v3 動作中！", 2.5)
	end)
end