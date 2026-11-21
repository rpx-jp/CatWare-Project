return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme

	if ctx.CatWare.SwitchUi then
		C.Section(page, "UI Style")

		if ctx.CatWare.ActiveUi == "modern" then
			C.Button(page, "従来のUI (Hub) に切り替え", "BentoDeck スタイルの旧UIに切り替えます", false, Theme, function()
				ctx.Notify.Send("UI", "従来のUIに切り替えています...", 2)
				ctx.CatWare.SwitchUi("classic")
			end)
		else
			C.Button(page, "新しいUI (VisionOS) に切り替え", "リキッドガラスUIに切り替えます", false, Theme, function()
				ctx.Notify.Send("UI", "新しいUIに切り替えています...", 2)
				ctx.CatWare.SwitchUi("modern")
			end)
		end
	end

	C.Section(page, "Interface")

	C.Slider(page, "UI スケール", 0.75, 1.25, 1.0, 0.05, "x", Theme, ctx.Track, function(val)
		ctx.SetBaseScale(val)
	end)

	C.Button(page, "ミニアイコンに格納", "画面左に cw.png ボタンとして待機します", false, Theme, function()
		ctx.Minimize()
	end)

	C.Section(page, "Cache & System")

	C.Button(page, "画像キャッシュを削除", "次回起動時に cw.png を再ダウンロードします", false, Theme, function()
		ctx.CatWare.Assets.ClearCache()
		ctx.Notify.Send("Cache", "画像キャッシュを削除しました", 2.5)
	end)

	C.Button(page, "CatWare を終了 (Unload)", "GUI・ぼかし・イベントをすべて破棄します", true, Theme, function()
		ctx.Unload()
	end)
end