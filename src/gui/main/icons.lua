local Icons = {}

local function makeBox(parent, size)
	local f = Instance.new("Frame")
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	f.Position = UDim2.new(0.5, 0, 0.41, 0)
	f.Size = UDim2.fromOffset(size or 42, size or 42)
	f.BackgroundTransparency = 1
	f.ZIndex = 7
	f.Parent = parent
	return f
end

function Icons.Create(id, parent, Theme)
	local box = makeBox(parent, 42)

	if id == "visuals" then
		-- ダイヤスター（Visuals）
		local outer = Instance.new("Frame")
		outer.AnchorPoint = Vector2.new(0.5, 0.5)
		outer.Position = UDim2.fromScale(0.5, 0.5)
		outer.Size = UDim2.fromOffset(24, 24)
		outer.Rotation = 45
		outer.BackgroundTransparency = 1
		outer.Parent = box
		Instance.new("UICorner", outer).CornerRadius = UDim.new(0, 5)
		local st = Instance.new("UIStroke", outer)
		st.Thickness = 2.4
		Theme.Bind(st, "Color", "Accent")

		local dot = Instance.new("Frame")
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.Position = UDim2.fromScale(0.5, 0.5)
		dot.Size = UDim2.fromOffset(8, 8)
		dot.BorderSizePixel = 0
		Theme.Bind(dot, "BackgroundColor3", "Accent")
		dot.Parent = box
		Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

	elseif id == "models" then
		-- 3Dキューブ（3D Models）
		local back = Instance.new("Frame")
		back.AnchorPoint = Vector2.new(0.5, 0.5)
		back.Position = UDim2.new(0.5, 5, 0.5, -5)
		back.Size = UDim2.fromOffset(20, 20)
		back.BackgroundTransparency = 1
		back.Parent = box
		Instance.new("UICorner", back).CornerRadius = UDim.new(0, 4)
		local st1 = Instance.new("UIStroke", back)
		st1.Thickness = 2
		st1.Transparency = 0.45
		Theme.Bind(st1, "Color", "Accent")

		local front = Instance.new("Frame")
		front.AnchorPoint = Vector2.new(0.5, 0.5)
		front.Position = UDim2.new(0.5, -4, 0.5, 4)
		front.Size = UDim2.fromOffset(20, 20)
		front.BackgroundTransparency = 1
		front.Parent = box
		Instance.new("UICorner", front).CornerRadius = UDim.new(0, 4)
		local st2 = Instance.new("UIStroke", front)
		st2.Thickness = 2.4
		Theme.Bind(st2, "Color", "Accent")

	elseif id == "settings" then
		-- スライダー3本（Settings）
		local knobs = { 0.32, 0.72, 0.45 }
		for i, kx in ipairs(knobs) do
			local y = 9 + (i - 1) * 12
			local line = Instance.new("Frame")
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Position = UDim2.new(0.5, 0, 0, y)
			line.Size = UDim2.fromOffset(28, 2)
			line.BorderSizePixel = 0
			Theme.Bind(line, "BackgroundColor3", "Accent")
			line.Parent = box
			Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)

			local k = Instance.new("Frame")
			k.AnchorPoint = Vector2.new(0.5, 0.5)
			k.Position = UDim2.new(kx, 0, 0, y)
			k.Size = UDim2.fromOffset(8, 8)
			k.BorderSizePixel = 0
			Theme.Bind(k, "BackgroundColor3", "Accent")
			k.Parent = box
			Instance.new("UICorner", k).CornerRadius = UDim.new(1, 0)
		end

	elseif id == "themes" then
		-- 重なるカラーカード（Themes）
		local c1 = Instance.new("Frame")
		c1.AnchorPoint = Vector2.new(0.5, 0.5)
		c1.Position = UDim2.new(0.5, -5, 0.5, 1)
		c1.Size = UDim2.fromOffset(16, 24)
		c1.Rotation = -16
		c1.BackgroundTransparency = 1
		c1.Parent = box
		Instance.new("UICorner", c1).CornerRadius = UDim.new(0, 4)
		local s1 = Instance.new("UIStroke", c1)
		s1.Thickness = 2
		s1.Transparency = 0.45
		Theme.Bind(s1, "Color", "Accent")

		local c2 = Instance.new("Frame")
		c2.AnchorPoint = Vector2.new(0.5, 0.5)
		c2.Position = UDim2.new(0.5, 5, 0.5, -1)
		c2.Size = UDim2.fromOffset(16, 24)
		c2.Rotation = 14
		c2.BackgroundTransparency = 1
		c2.Parent = box
		Instance.new("UICorner", c2).CornerRadius = UDim.new(0, 4)
		local s2 = Instance.new("UIStroke", c2)
		s2.Thickness = 2.4
		Theme.Bind(s2, "Color", "Accent")
	end

	return box
end

return Icons