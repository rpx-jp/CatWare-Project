return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme
	local Knife = ctx.CatWare.Import("src/features/visuals/knife.lua")

	-- Unload時にナイフも確実に掃除
	ctx.ScreenGui.Destroying:Connect(function()
		Knife.SetEnabled(false)
	end)

	C.Section(page, "Butterfly Knife")

	C.Toggle(page, "Butterfly Knife Viewmodel", false, Theme, function(on)
		Knife.SetEnabled(on)
		ctx.Notify.Send("Visuals", on and "Knife を装備しました (F: 回す / 左クリック: 斬る)" or "Knife を非表示にしました", 2.5)
	end)

	C.Button(page, "Inspect / ナイフを回す (Fキー)", "バタフライナイフのトリックを再生します", false, Theme, function()
		Knife.TriggerInspect()
	end)

	local skinBtn
	skinBtn = C.Button(page, "スキン変更: " .. Knife.GetSkinName(), "クリックでカラーを切り替え", false, Theme, function()
		local name = Knife.CycleSkin()
		for _, ch in ipairs(skinBtn:GetChildren()) do
			if ch:IsA("TextLabel") and ch.Position.Y.Offset == 8 then
				ch.Text = "スキン変更: " .. name
				break
			end
		end
		ctx.Notify.Send("Knife Skin", name .. " に変更しました", 1.8, "check")
	end)

	C.Slider(page, "ナイフ サイズ", 0.6, 1.4, 1.0, 0.05, "x", Theme, ctx.Track, function(val)
		Knife.SetScale(val)
	end)

	C.Slider(page, "前後距離 (Z)", -2.2, -1.0, -1.55, 0.05, "", Theme, ctx.Track, function(val)
		Knife.SetOffsetZ(val)
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

	C.Section(page, "Reset")
	C.Button(page, "カメラ FOV をデフォルト (70) に戻す", nil, false, Theme, function()
		if workspace.CurrentCamera then
			workspace.CurrentCamera.FieldOfView = 70
		end
		ctx.Notify.Send("Visuals", "FOV を 70 に戻しました", 2, "check")
	end)
end