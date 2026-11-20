return function(page, ctx)
	local C = ctx.Components
	local Theme = ctx.Theme

	C.Section(page, "Color Presets")

	local order = {
		{ key = "Obsidian", desc = "黒ガラス × ホワイト発光" },
		{ key = "IceFrost", desc = "cw.png に合わせたアイスブルー" },
		{ key = "Sakura",   desc = "ダーク × サクラピンク発光" },
		{ key = "Violet",   desc = "ミッドナイト × バイオレット" },
	}

	local badges = {}
	local function refreshBadges()
		for k, b in pairs(badges) do
			b.Visible = (Theme.Current == Theme.Presets[k])
		end
	end

	for _, item in ipairs(order) do
		local preset = Theme.Presets[item.key]
		local btn = C.Button(page, preset.Name, item.desc, false, Theme, function()
			Theme.SetPreset(item.key)
			refreshBadges()
			ctx.Notify.Send("Theme", preset.Name .. " に切り替えました", 2)
		end)

		-- 3色ミニパレット（右矢印 › と重ならない位置）
		local palette = { preset.Tile, preset.CardHover, preset.Accent }
		for i, col in ipairs(palette) do
			local dot = Instance.new("Frame")
			dot.AnchorPoint = Vector2.new(1, 0.5)
			dot.Position = UDim2.new(1, -34 - (3 - i) * 14, 0.5, 0)
			dot.Size = UDim2.fromOffset(11, 11)
			dot.BackgroundColor3 = col
			dot.BorderSizePixel = 0
			dot.Parent = btn
			Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
		end

		-- 選択中バッジ
		local activeBadge = Instance.new("TextLabel")
		activeBadge.AnchorPoint = Vector2.new(1, 0.5)
		activeBadge.Position = UDim2.new(1, -80, 0.5, 0)
		activeBadge.Size = UDim2.fromOffset(48, 18)
		activeBadge.BackgroundColor3 = preset.Accent
		activeBadge.BackgroundTransparency = 0.82
		activeBadge.Font = Enum.Font.GothamBold
		activeBadge.Text = "ACTIVE"
		activeBadge.TextColor3 = preset.Accent
		activeBadge.TextSize = 9
		activeBadge.Parent = btn
		Instance.new("UICorner", activeBadge).CornerRadius = UDim.new(1, 0)

		badges[item.key] = activeBadge
	end

	refreshBadges()
end