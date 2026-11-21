return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme
	local Shockwave = ctx.CatWare.Import("src/features/visuals/shockwave.lua")
	local BlockOutline = ctx.CatWare.Import("src/features/visuals/blockoutline.lua")

	ctx.ScreenGui.Destroying:Connect(function()
		Shockwave.SetEnabled(false)
		BlockOutline.SetEnabled(false)
		BlockOutline.SetTint(false)
	end)

	C.Section(page, "Atmosphere & Camera")

	C.Slider(page, "背景ぼかし強度 (Blur)", 0, 24, 16, 1, "px", Theme, ctx.Track, function(val)
		ctx.SetBlurTarget(val)
	end)

	C.Slider(page, "カメラ FOV", 50, 120, 70, 1, "°", Theme, ctx.Track, function(val)
		if workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = val
		end
	end)

	C.Slider(page, "ガラスパネル透過度", 0, 45, 26, 1, "%", Theme, ctx.Track, function(val)
		local alpha = val / 100
		for _, t in ipairs(ctx.Hub.Tiles) do
			if t:IsA("ImageLabel") or t:IsA("ImageButton") then
				t.ImageTransparency = alpha
			else
				t.BackgroundTransparency = alpha
			end
		end
	end)

	C.Section(page, "BLOCK OUTLINE")

	C.Toggle(page, "Block Outline (ピンクの縁)", false, Theme, function(on)
		BlockOutline.SetEnabled(on)
		ctx.Notify.Send("Visuals", on and ("Block Outline 有効 (" .. BlockOutline.Count() .. " ブロック)") or "Block Outline をオフにしました", 2.5, "check")
	end)

	C.Toggle(page, "Block Pink Tint (ブロックをピンクに)", false, Theme, function(on)
		BlockOutline.SetTint(on)
		ctx.Notify.Send("Visuals", on and ("ピンクティント有効 (" .. BlockOutline.TintCount() .. " ブロック)") or "ティントを解除しました", 2.5, "check")
	end)

	C.Slider(page, "縁の太さ", 0.01, 0.12, 0.035, 0.005, "", Theme, ctx.Track, function(val)
		BlockOutline.SetThickness(val)
	end)

	C.Section(page, "SHOCKWAVES")

	C.Toggle(page, "Jump Shockwave", false, Theme, function(on)
		Shockwave.SetEnabled(on)
		ctx.Notify.Send("Visuals", on and "SHOCKWAVES 有効 (ジャンプで衝撃波)" or "SHOCKWAVES をオフにしました", 2.5, "check")
	end)

	C.Slider(page, "衝撃波の規模", 0.6, 2.0, 1.0, 0.05, "x", Theme, ctx.Track, function(val)
		Shockwave.SetScale(val)
	end)

	C.Section(page, "Reset")
	C.Button(page, "カメラ FOV をデフォルト (70) に戻す", nil, false, Theme, function()
		if workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = 70
		end
		ctx.Notify.Send("Visuals", "FOV を 70 に戻しました", 2, "check")
	end)
end