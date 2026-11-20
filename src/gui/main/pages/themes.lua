return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme

	C.Section(page, "Color Presets")

	local order = {
		{ key = "Obsidian", desc = "黒ガラス × ホワイト発光（デフォルト）" },
		{ key = "IceFrost", desc = "cw.png に合わせたアイスブルー" },
		{ key = "Sakura",   desc = "ダーク × サクラピンク発光" },
		{ key = "Violet",   desc = "ミッドナイト × バイオレット" },
	}

	for _, item in ipairs(order) do
		local preset = Theme.Presets[item.key]
		local btn = C.Button(page, preset.Name, item.desc, false, Theme, function()
			Theme.SetPreset(item.key)
			ctx.Notify.Send("Theme", preset.Name .. " に切り替えました", 2)
		end)

		local dot = Instance.new("Frame")
		dot.AnchorPoint = Vector2.new(1, 0.5)
		dot.Position = UDim2.new(1, -14, 0.5, 0)
		dot.Size = UDim2.fromOffset(18, 18)
		dot.BackgroundColor3 = preset.Accent
		dot.Parent = btn

		local dc = Instance.new("UICorner")
		dc.CornerRadius = UDim.new(1, 0)
		dc.Parent = dot
	end
end