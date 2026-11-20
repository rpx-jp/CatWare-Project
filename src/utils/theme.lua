local TweenService = game:GetService("TweenService")

local Theme = {}

Theme.Presets = {
	Obsidian = {
		Name = "Obsidian",
		Bg = Color3.fromRGB(10, 11, 14),
		Tile = Color3.fromRGB(12, 13, 17),
		Card = Color3.fromRGB(20, 22, 28),
		CardHover = Color3.fromRGB(30, 33, 42),
		Text = Color3.fromRGB(245, 247, 252),
		SubText = Color3.fromRGB(150, 158, 172),
		Accent = Color3.fromRGB(235, 240, 255),
		Glow = Color3.fromRGB(255, 255, 255),
		Danger = Color3.fromRGB(235, 85, 100),
	},
	IceFrost = {
		Name = "Ice Frost",
		Bg = Color3.fromRGB(12, 16, 24),
		Tile = Color3.fromRGB(15, 21, 32),
		Card = Color3.fromRGB(22, 30, 44),
		CardHover = Color3.fromRGB(30, 42, 62),
		Text = Color3.fromRGB(240, 248, 255),
		SubText = Color3.fromRGB(142, 170, 200),
		Accent = Color3.fromRGB(130, 205, 255),
		Glow = Color3.fromRGB(150, 215, 255),
		Danger = Color3.fromRGB(235, 90, 105),
	},
	Sakura = {
		Name = "Sakura",
		Bg = Color3.fromRGB(16, 12, 18),
		Tile = Color3.fromRGB(20, 15, 24),
		Card = Color3.fromRGB(30, 22, 36),
		CardHover = Color3.fromRGB(42, 30, 50),
		Text = Color3.fromRGB(255, 244, 250),
		SubText = Color3.fromRGB(185, 150, 172),
		Accent = Color3.fromRGB(255, 145, 195),
		Glow = Color3.fromRGB(255, 175, 215),
		Danger = Color3.fromRGB(240, 85, 100),
	},
	Violet = {
		Name = "Violet",
		Bg = Color3.fromRGB(13, 12, 20),
		Tile = Color3.fromRGB(17, 15, 28),
		Card = Color3.fromRGB(26, 23, 42),
		CardHover = Color3.fromRGB(36, 32, 58),
		Text = Color3.fromRGB(244, 242, 255),
		SubText = Color3.fromRGB(160, 152, 195),
		Accent = Color3.fromRGB(175, 145, 255),
		Glow = Color3.fromRGB(190, 165, 255),
		Danger = Color3.fromRGB(235, 85, 105),
	},
}

Theme.Current = Theme.Presets.Obsidian
local bindings = {}

function Theme.Bind(obj, prop, key)
	table.insert(bindings, { obj = obj, prop = prop, key = key })
	obj[prop] = Theme.Current[key]
end

function Theme.SetPreset(presetName)
	local preset = Theme.Presets[presetName]
	if not preset then
		return
	end
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

return Theme