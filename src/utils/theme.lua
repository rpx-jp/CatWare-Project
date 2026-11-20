local TweenService = game:GetService("TweenService")

local Theme = {}

Theme.Presets = {
	SpatialGlass = {
		Name = "Spatial Glass",
		Bg = Color3.fromRGB(36, 40, 48),
		Tile = Color3.fromRGB(46, 50, 58),
		Card = Color3.fromRGB(64, 68, 78),
		CardHover = Color3.fromRGB(82, 88, 100),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(195, 200, 210),
		Accent = Color3.fromRGB(255, 255, 255),
		Glow = Color3.fromRGB(255, 255, 255),
		Danger = Color3.fromRGB(255, 95, 90),
	},
	FrostedMist = {
		Name = "Frosted Mist",
		Bg = Color3.fromRGB(42, 52, 66),
		Tile = Color3.fromRGB(54, 66, 82),
		Card = Color3.fromRGB(74, 88, 106),
		CardHover = Color3.fromRGB(92, 108, 128),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(205, 218, 232),
		Accent = Color3.fromRGB(220, 240, 255),
		Glow = Color3.fromRGB(235, 246, 255),
		Danger = Color3.fromRGB(255, 95, 90),
	},
	WarmTitanium = {
		Name = "Warm Titanium",
		Bg = Color3.fromRGB(46, 44, 42),
		Tile = Color3.fromRGB(58, 55, 52),
		Card = Color3.fromRGB(76, 72, 68),
		CardHover = Color3.fromRGB(94, 90, 85),
		Text = Color3.fromRGB(255, 252, 248),
		SubText = Color3.fromRGB(205, 200, 194),
		Accent = Color3.fromRGB(255, 250, 242),
		Glow = Color3.fromRGB(255, 250, 244),
		Danger = Color3.fromRGB(255, 95, 90),
	},
	Midnight = {
		Name = "Midnight Glass",
		Bg = Color3.fromRGB(20, 22, 26),
		Tile = Color3.fromRGB(26, 28, 34),
		Card = Color3.fromRGB(42, 46, 54),
		CardHover = Color3.fromRGB(58, 62, 74),
		Text = Color3.fromRGB(255, 255, 255),
		SubText = Color3.fromRGB(178, 184, 196),
		Accent = Color3.fromRGB(255, 255, 255),
		Glow = Color3.fromRGB(255, 255, 255),
		Danger = Color3.fromRGB(255, 95, 90),
	},
}

Theme.Current = Theme.Presets.SpatialGlass
local bindings = {}

function Theme.Bind(obj, prop, key)
	table.insert(bindings, { obj = obj, prop = prop, key = key })
	obj[prop] = Theme.Current[key]
end

function Theme.SetPreset(presetName)
	local preset = Theme.Presets[presetName]
	if not preset then return end
	Theme.Current = preset

	local alive = {}
	for _, b in ipairs(bindings) do
		if b.obj and b.obj.Parent then
			table.insert(alive, b)
			TweenService:Create(b.obj, TweenInfo.new(0.25), {
				[b.prop] = preset[b.key],
			}):Play()
		end
	end
	bindings = alive
end

-- Vision Pro 風の上面がキラッと光る光学ガラス縁
function Theme.GlassStroke(parent, opts)
	opts = opts or {}
	local stroke = Instance.new("UIStroke")
	stroke.Color = opts.Color or Color3.fromRGB(255, 255, 255)
	stroke.Thickness = opts.Thickness or 1.2
	stroke.Transparency = opts.Transparency or 0.22
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent

	local grad = Instance.new("UIGradient")
	grad.Rotation = 90
	grad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.30),    -- 上辺：一番キラッと光る
		NumberSequenceKeypoint.new(0.22, 0.76), -- 角から側面へスッと溶ける
		NumberSequenceKeypoint.new(0.85, 0.86), -- 側面：繊細な縁
		NumberSequenceKeypoint.new(1, 0.68),    -- 下辺：ほんのり底面反射
	})
	grad.Parent = stroke

	return stroke
end
return Theme