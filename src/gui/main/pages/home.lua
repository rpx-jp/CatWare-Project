local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

return function(page, ctx)
	local player = Players.LocalPlayer
	local Theme = ctx.Theme
	local C = ctx.Components

	local hero = Instance.new("Frame")
	hero.Size = UDim2.new(1, 0, 0, 68)
	hero.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	hero.BackgroundTransparency = 0.91
	hero.Parent = page
	Instance.new("UICorner", hero).CornerRadius = UDim.new(0, 16)
	Theme.GlassStroke(hero, { Transparency = 0.22 })

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
		Theme.GlassStroke(box, { Transparency = 0.22 })

		local t = Instance.new("TextLabel")
		t.Position = UDim2.fromOffset(16, 10)
		t.Size = UDim2.new(1, -32, 0, 14)
		t.BackgroundTransparency = 1
		t.Font = Enum.Font.GothamMedium
		t.Text = label
		t.TextColor3 = Color3.fromRGB(255, 255, 255)
		t.TextTransparency = 0.48
		t.TextSize = 11
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.Parent = box

		local v = Instance.new("TextLabel")
		v.Position = UDim2.fromOffset(16, 26)
		v.Size = UDim2.new(1, -32, 0, 26)
		v.BackgroundTransparency = 1
		v.Font = Enum.Font.GothamBold
		v.RichText = true
		v.Text = '-- <font size="12" transparency="0.45">' .. unit .. "</font>"
		v.TextColor3 = Color3.fromRGB(255, 255, 255)
		v.TextSize = 21
		v.TextXAlignment = Enum.TextXAlignment.Left
		v.Parent = box
		return v
	end

	local fpsVal = makeMetric("Frame Rate", "fps", 0, 0)
	local pingVal = makeMetric("Latency", "ms", 0.5, 5)

	local fc, fl = 0, os.clock()
	ctx.Track(RunService.RenderStepped:Connect(function()
		fc += 1
		local now = os.clock()
		if now - fl >= 0.5 then
			local fps = math.floor(fc / (now - fl) + 0.5)
			fc, fl = 0, now
			fpsVal.Text = tostring(fps) .. ' <font size="12" transparency="0.45">fps</font>'

			local ok, ping = pcall(function()
				return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			pingVal.Text = (ok and tostring(ping) or "--") .. ' <font size="12" transparency="0.45">ms</font>'
		end
	end))

	C.Button(page, "テスト通知を表示", "右下にガラス通知を表示します", false, Theme, function()
		ctx.Notify.Send("CatWare", "VisionOS ガラスUI 動作中", 2.5)
	end)
end