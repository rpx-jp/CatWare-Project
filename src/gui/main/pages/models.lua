local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme

	-- ミニ FPS/Ping オーバーレイ（トグルで表示）
	local hud = Instance.new("Frame")
	hud.Name = "CatWareMiniHud"
	hud.Position = UDim2.fromOffset(18, 18)
	hud.Size = UDim2.fromOffset(170, 34)
	hud.BackgroundTransparency = 0.15
	hud.Visible = false
	hud.ZIndex = 40
	Theme.Bind(hud, "BackgroundColor3", "Tile")
	hud.Parent = ctx.ScreenGui

	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(0, 10)
	hc.Parent = hud

	local hs = Instance.new("UIStroke")
	hs.Thickness = 1
	hs.Transparency = 0.78
	Theme.Bind(hs, "Color", "Glow")
	hs.Parent = hud

	local hLogo = Instance.new("ImageLabel")
	hLogo.Position = UDim2.fromOffset(7, 5)
	hLogo.Size = UDim2.fromOffset(24, 24)
	hLogo.BackgroundTransparency = 1
	hLogo.Image = ctx.LogoAsset
	hLogo.ScaleType = Enum.ScaleType.Fit
	hLogo.ZIndex = 41
	hLogo.Parent = hud

	local hLbl = Instance.new("TextLabel")
	hLbl.Position = UDim2.fromOffset(38, 0)
	hLbl.Size = UDim2.new(1, -44, 1, 0)
	hLbl.BackgroundTransparency = 1
	hLbl.Font = Enum.Font.GothamBold
	hLbl.Text = "-- FPS  |  -- ms"
	hLbl.TextSize = 12
	hLbl.TextXAlignment = Enum.TextXAlignment.Left
	hLbl.ZIndex = 41
	Theme.Bind(hLbl, "TextColor3", "Text")
	hLbl.Parent = hud

	local frames, last = 0, os.clock()
	ctx.Track(RunService.RenderStepped:Connect(function()
		if not hud.Visible then
			return
		end
		frames += 1
		local now = os.clock()
		if now - last >= 0.5 then
			local fps = math.floor(frames / (now - last) + 0.5)
			frames, last = 0, now
			local ok, ping = pcall(function()
				return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			end)
			hLbl.Text = tostring(fps) .. " FPS  |  " .. (ok and tostring(ping) or "--") .. " ms"
		end
	end))

	C.Section(page, "Overlay & Display")

	C.Toggle(page, "FPS / Ping オーバーレイを表示", false, Theme, function(on)
		hud.Visible = on
		ctx.Notify.Send("HUD", on and "オーバーレイを表示しました" or "非表示にしました", 2)
	end)

	C.Section(page, "Utilities")

	C.Button(page, "テスト通知を送信", "右下にトースト通知を表示します", false, Theme, function()
		ctx.Notify.Send("CatWare", "3D Models ページから通知しました！", 2.5)
	end)
end