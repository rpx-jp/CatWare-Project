return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme

	C.Section(page, "Atmosphere & Camera")

	C.Slider(page, "背景ぼかし強度 (Blur)", 0, 24, 14, 1, "px", Theme, ctx.Track, function(val)
		ctx.SetBlurTarget(val)
	end)

	C.Slider(page, "カメラ FOV", 50, 120, 70, 1, "°", Theme, ctx.Track, function(val)
		if workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = val
		end
	end)

C.Slider(page, "タイルの透過度", 0, 45, 14, 1, "%", Theme, ctx.Track, function(val)
		local alpha = val / 100
		for _, t in ipairs(ctx.Hub.Tiles) do
			t.ImageTransparency = alpha -- ← BackgroundTransparency から変更
		end
		ctx.PagePanel.BackgroundTransparency = math.clamp(alpha - 0.04, 0, 0.5)
	end)
	C.Section(page, "Reset")
	C.Button(page, "カメラ FOV をデフォルト (70) に戻す", nil, false, Theme, function()
		if workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = 70
		end
		ctx.Notify.Send("Visuals", "FOV を 70 に戻しました", 2)
	end)
end