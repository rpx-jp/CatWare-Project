local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knife = {}

Knife.Weapons = { "Butterfly", "Karambit", "Katana" }

Knife.Skins = {
	{
		name = "Emerald",
		blade = Color3.fromRGB(0, 178, 102),
		bladeDark = Color3.fromRGB(0, 134, 76),
		edge = Color3.fromRGB(238, 250, 244),
		handle = Color3.fromRGB(24, 26, 30),
	},
	{
		name = "Crimson",
		blade = Color3.fromRGB(205, 36, 54),
		bladeDark = Color3.fromRGB(145, 20, 34),
		edge = Color3.fromRGB(252, 234, 236),
		handle = Color3.fromRGB(22, 22, 26),
	},
	{
		name = "Sapphire",
		blade = Color3.fromRGB(32, 138, 240),
		bladeDark = Color3.fromRGB(20, 92, 182),
		edge = Color3.fromRGB(234, 246, 255),
		handle = Color3.fromRGB(22, 25, 32),
	},
	{
		name = "Titanium",
		blade = Color3.fromRGB(142, 148, 158),
		bladeDark = Color3.fromRGB(88, 94, 104),
		edge = Color3.fromRGB(244, 248, 252),
		handle = Color3.fromRGB(28, 30, 35),
	},
	{
		name = "Gold",
		blade = Color3.fromRGB(234, 184, 54),
		bladeDark = Color3.fromRGB(178, 134, 28),
		edge = Color3.fromRGB(255, 250, 226),
		handle = Color3.fromRGB(24, 24, 28),
	},
}

local enabled = false
local weaponIdx = 1
local skinIdx = 1
local knifeScale = 1.0
local offsetZ = -1.66

local model = nil
local partsList = {}
local renderConn = nil
local inputConn = nil

local animMode = "idle"
local animTime = 0
local lastCameraCF = nil

-- 2次スプリング物理（重み・慣性・着地ショック用）
local swayPos = Vector2.zero
local swayVel = Vector2.zero
local airY = 0
local airVel = 0
local walkPhase = 0
local walkBlend = 0

local function makePart(parent, name, className, size, color, material, reflectance, shape)
	local p = Instance.new(className or "Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Reflectance = reflectance or 0
	if p:IsA("Part") and shape then
		p.Shape = shape
	end
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function regPart(group, role, size, color, localCF, opts)
	opts = opts or {}
	local p = makePart(
		model,
		group .. "_" .. role,
		opts.className,
		size * knifeScale,
		color,
		opts.material or Enum.Material.SmoothPlastic,
		opts.reflectance or 0,
		opts.shape
	)
	table.insert(partsList, {
		part = p,
		baseSize = size,
		group = group,
		role = role,
		localCF = localCF,
	})
	return p
end

local function addArcSegment(group, role, p1, p2, w, thickZ, color, reflectance, capStart, capEnd)
	local delta = p2 - p1
	local len = delta.Magnitude
	local mid = (p1 + p2) * 0.5
	local ang = math.atan2(delta.Y, delta.X) - math.rad(90)

	regPart(group, role, Vector3.new(w, len, thickZ), color,
		CFrame.new(mid.X, mid.Y, 0) * CFrame.Angles(0, 0, ang), { reflectance = reflectance })

	if capStart then
		regPart(group, role, Vector3.new(thickZ, w, w), color,
			CFrame.new(p1.X, p1.Y, 0) * CFrame.Angles(0, math.rad(90), 0),
			{ shape = Enum.PartType.Cylinder, reflectance = reflectance })
	end
	if capEnd then
		regPart(group, role, Vector3.new(thickZ, w, w), color,
			CFrame.new(p2.X, p2.Y, 0) * CFrame.Angles(0, math.rad(90), 0),
			{ shape = Enum.PartType.Cylinder, reflectance = reflectance })
	end
end

local function addWedgeXY(group, role, x, y, widthX, heightY, thickZ, angleDeg, flipLeft, color, reflectance)
	local yaw = flipLeft and math.rad(-90) or math.rad(90)
	regPart(group, role, Vector3.new(thickZ, heightY, widthX), color,
		CFrame.new(x, y, 0) * CFrame.Angles(0, 0, math.rad(angleDeg)) * CFrame.Angles(0, yaw, 0),
		{ className = "WedgePart", reflectance = reflectance })
end

-- ==========================================================
-- モデル1: バタフライナイフ（Emerald 等）
-- ==========================================================
local function buildButterflyHandle(group, dirX, sk)
	local PIN_WHITE = Color3.fromRGB(242, 246, 250)
	local PIN_RING = Color3.fromRGB(48, 52, 60)
	local thickZ = 0.056

	regPart(group, "handle", Vector3.new(thickZ, 0.155, 0.155), sk.handle,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0),
		{ shape = Enum.PartType.Cylinder, reflectance = 0.03 })

	local pts = {
		Vector2.new(0.000 * dirX,  0.000),
		Vector2.new(-0.015 * dirX, -0.170),
		Vector2.new(-0.048 * dirX, -0.360),
		Vector2.new(-0.102 * dirX, -0.555),
		Vector2.new(-0.175 * dirX, -0.740),
		Vector2.new(-0.245 * dirX, -0.875),
	}
	local widths = { 0.122, 0.114, 0.108, 0.112, 0.132 }
	for i = 1, #pts - 1 do
		addArcSegment(group, "handle", pts[i], pts[i + 1], widths[i], thickZ,
			sk.handle, 0.03, i > 1, i == (#pts - 1))
	end

	local tail = pts[#pts]
	local prev = pts[#pts - 1]
	local tailAng = math.atan2(tail.Y - prev.Y, tail.X - prev.X) - math.rad(90)
	regPart(group, "handle", Vector3.new(0.155, 0.065, thickZ), sk.handle,
		CFrame.new(tail.X - 0.01 * dirX, tail.Y - 0.015, 0) * CFrame.Angles(0, 0, tailAng),
		{ reflectance = 0.03 })

	local inlayPts = {
		Vector2.new(-0.024 * dirX, -0.220),
		Vector2.new(-0.056 * dirX, -0.385),
		Vector2.new(-0.106 * dirX, -0.565),
		Vector2.new(-0.156 * dirX, -0.695),
	}
	for i = 1, #inlayPts - 1 do
		addArcSegment(group, "inlay", inlayPts[i], inlayPts[i + 1], 0.046, thickZ + 0.006,
			sk.blade, 0.06, i == 1, true)
	end

	regPart(group, "pinRing", Vector3.new(thickZ + 0.004, 0.088, 0.088), PIN_RING,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0), { shape = Enum.PartType.Cylinder })
	regPart(group, "pin", Vector3.new(0.050, 0.050, thickZ + 0.010), PIN_WHITE,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(45)), { reflectance = 0.25 })
	regPart(group, "pin", Vector3.new(0.038, 0.038, thickZ + 0.008), PIN_WHITE,
		CFrame.new(tail.X + 0.005 * dirX, tail.Y + 0.008, 0) * CFrame.Angles(0, 0, math.rad(45)),
		{ reflectance = 0.25 })
end

local function buildButterfly(sk)
	local thickZ = 0.026
	local edgeZ = 0.028

	regPart("blade", "bladeDark", Vector3.new(0.20, 0.16, thickZ + 0.006), sk.bladeDark,
		CFrame.new(0.075, -0.02, 0) * CFrame.Angles(0, 0, math.rad(-10)), { reflectance = 0.05 })
	regPart("blade", "bladeDark", Vector3.new(0.16, 0.16, thickZ + 0.006), sk.bladeDark,
		CFrame.new(0.075, -0.02, 0) * CFrame.Angles(0, 0, math.rad(35)), { reflectance = 0.05 })
	addWedgeXY("blade", "blade", -0.055, 0.095, 0.085, 0.055, thickZ, 78, true, sk.blade, 0.06)
	addWedgeXY("blade", "blade", -0.095, 0.082, 0.055, 0.036, thickZ, 118, true, sk.blade, 0.06)

	local spinePts = {
		Vector2.new(0.085, 0.04),
		Vector2.new(0.095, 0.22),
		Vector2.new(0.118, 0.42),
		Vector2.new(0.155, 0.62),
		Vector2.new(0.205, 0.79),
	}
	local widths = { 0.14, 0.175, 0.195, 0.170 }
	for i = 1, #spinePts - 1 do
		addArcSegment("blade", "blade", spinePts[i], spinePts[i + 1], widths[i], thickZ,
			sk.blade, 0.08, i > 1, i == (#spinePts - 1))
	end

	local darkPts = {
		Vector2.new(0.125, 0.16),
		Vector2.new(0.155, 0.38),
		Vector2.new(0.192, 0.58),
	}
	for i = 1, #darkPts - 1 do
		addArcSegment("blade", "bladeDark", darkPts[i], darkPts[i + 1], 0.055, thickZ + 0.002,
			sk.bladeDark, 0.06, i == 1, true)
	end

	addWedgeXY("blade", "blade", 0.232, 0.69, 0.075, 0.14, thickZ, -22, false, sk.blade, 0.08)
	addWedgeXY("blade", "blade", 0.228, 0.89, 0.155, 0.26, thickZ, -32, false, sk.blade, 0.08)
	addWedgeXY("blade", "blade", 0.308, 1.00, 0.085, 0.17, thickZ, -52, false, sk.blade, 0.08)

	local edgePts = {
		Vector2.new(0.032, 0.24),
		Vector2.new(0.045, 0.44),
		Vector2.new(0.078, 0.64),
		Vector2.new(0.132, 0.82),
		Vector2.new(0.215, 0.96),
	}
	for i = 1, #edgePts - 1 do
		addArcSegment("blade", "edge", edgePts[i], edgePts[i + 1], 0.024, edgeZ,
			sk.edge, 0.22, i == 1, i == (#edgePts - 1))
	end
	addWedgeXY("blade", "edge", 0.285, 1.015, 0.022, 0.14, edgeZ, -54, false, sk.edge, 0.25)

	buildButterflyHandle("safe", 1, sk)
	buildButterflyHandle("bite", -1, sk)
end

-- ==========================================================
-- モデル2: カランビット（中空リング＋指溝＋鉤爪ブレード）
-- ==========================================================
local function buildKarambit(sk)
	local thickZ = 0.064
	local bladeZ = 0.028

	-- 1. 本当に向こう側が透ける中空フィンガーリング（14セグメント）
	local segs = 14
	local ringR = 0.082
	for i = 1, segs do
		local a = (i / segs) * math.pi * 2
		local rx = math.cos(a) * ringR
		local ry = math.sin(a) * ringR
		regPart("blade", "handle", Vector3.new(0.032, 0.042, thickZ * 0.88), sk.handle,
			CFrame.new(rx, ry, 0) * CFrame.Angles(0, 0, a), { reflectance = 0.04 })
	end

	-- 2. 指溝付きカーブグリップ（リングの下へ伸びる）
	local gripPts = {
		Vector2.new(0.01, -0.09),
		Vector2.new(0.03, -0.24),
		Vector2.new(0.01, -0.40),
		Vector2.new(-0.04, -0.54),
	}
	local gripW = { 0.13, 0.135, 0.13 }
	for i = 1, #gripPts - 1 do
		addArcSegment("blade", "handle", gripPts[i], gripPts[i + 1], gripW[i], thickZ,
			sk.handle, 0.03, true, i == (#gripPts - 1))
	end
	-- 背中の3つの指溝突起
	for _, gy in ipairs({ -0.17, -0.30, -0.43 }) do
		regPart("blade", "handle", Vector3.new(0.05, 0.055, thickZ + 0.004), sk.handle,
			CFrame.new(0.075, gy, 0) * CFrame.Angles(0, 0, math.rad(45)))
	end

	-- 3. 鉤爪ブレード（左下へ向かって鋭く湾曲）
	local clawPts = {
		Vector2.new(-0.06, -0.54),
		Vector2.new(-0.18, -0.66),
		Vector2.new(-0.34, -0.74),
		Vector2.new(-0.54, -0.76),
		Vector2.new(-0.74, -0.70),
	}
	local clawW = { 0.17, 0.16, 0.135, 0.095 }
	for i = 1, #clawPts - 1 do
		addArcSegment("blade", "blade", clawPts[i], clawPts[i + 1], clawW[i], bladeZ,
			sk.blade, 0.12, true, i == (#clawPts - 1))
	end
	-- 先端の鋭い爪
	addWedgeXY("blade", "blade", -0.85, -0.62, 0.078, 0.22, bladeZ, 66, false, sk.blade, 0.14)

	-- カランビット特有の背中の暗い面＆内側銀白エッジ
	local edgePts = {
		Vector2.new(-0.12, -0.57),
		Vector2.new(-0.26, -0.64),
		Vector2.new(-0.44, -0.67),
		Vector2.new(-0.64, -0.65),
		Vector2.new(-0.82, -0.59),
	}
	for i = 1, #edgePts - 1 do
		addArcSegment("blade", "edge", edgePts[i], edgePts[i + 1], 0.022, bladeZ + 0.002,
			sk.edge, 0.25, i == 1, true)
	end
end

-- ==========================================================
-- モデル3: カタナ（鍔＋柄巻き＋長刀）
-- ==========================================================
local function buildKatana(sk)
	local bladeZ = 0.024
	local gripZ = 0.062

	-- 柄（Tsuka）
	regPart("blade", "handle", Vector3.new(0.088, 0.66, gripZ), sk.handle,
		CFrame.new(0, -0.22, 0), { reflectance = 0.02 })
	regPart("blade", "bladeDark", Vector3.new(0.094, 0.055, gripZ + 0.006), sk.bladeDark,
		CFrame.new(0, -0.56, 0), { reflectance = 0.1 })
	-- 柄糸のダイヤ模様
	for y = -0.45, 0.03, 0.12 do
		regPart("blade", "inlay", Vector3.new(0.055, 0.055, gripZ + 0.005), sk.blade,
			CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.rad(45)))
	end

	-- 鍔（Tsuba）＋ ハバキ
	regPart("blade", "bladeDark", Vector3.new(0.030, 0.23, 0.23), Color3.fromRGB(36, 40, 48),
		CFrame.new(0, 0.12, 0) * CFrame.Angles(0, 0, math.rad(90)),
		{ shape = Enum.PartType.Cylinder, reflectance = 0.2 })
	regPart("blade", "inlay", Vector3.new(0.082, 0.06, 0.044), sk.blade,
		CFrame.new(0, 0.16, 0), { reflectance = 0.18 })

	-- 緩やかな反りのある刀身（Nagasa）
	local bladePts = {
		Vector2.new(0.000, 0.18),
		Vector2.new(-0.012, 0.56),
		Vector2.new(-0.040, 0.96),
		Vector2.new(-0.085, 1.36),
		Vector2.new(-0.145, 1.74),
	}
	local bw = { 0.082, 0.078, 0.072, 0.064 }
	for i = 1, #bladePts - 1 do
		addArcSegment("blade", "blade", bladePts[i], bladePts[i + 1], bw[i], bladeZ,
			sk.blade, 0.16, i > 1, i == (#bladePts - 1))
	end
	-- 切先（Kissaki）
	addWedgeXY("blade", "blade", -0.185, 1.88, 0.060, 0.28, bladeZ, 14, true, sk.blade, 0.18)

	-- 白銀の刃文（Hamon）
	local hamonPts = {
		Vector2.new(0.034, 0.20),
		Vector2.new(0.022, 0.58),
		Vector2.new(-0.006, 0.97),
		Vector2.new(-0.052, 1.37),
		Vector2.new(-0.114, 1.74),
	}
	for i = 1, #hamonPts - 1 do
		addArcSegment("blade", "edge", hamonPts[i], hamonPts[i + 1], 0.018, bladeZ + 0.002,
			sk.edge, 0.28, i == 1, true)
	end
end

local function applySkin()
	local sk = Knife.Skins[skinIdx]
	for _, item in ipairs(partsList) do
		if item.role == "blade" or item.role == "inlay" then
			item.part.Color = sk.blade
		elseif item.role == "bladeDark" then
			item.part.Color = sk.bladeDark
		elseif item.role == "edge" then
			item.part.Color = sk.edge
		elseif item.role == "handle" then
			item.part.Color = sk.handle
		end
	end
end

local function buildModel()
	if model then model:Destroy() end
	partsList = {}

	model = Instance.new("Model")
	model.Name = "CatWare_KnifeViewmodel"

	local sk = Knife.Skins[skinIdx]
	local wName = Knife.Weapons[weaponIdx]

	if wName == "Butterfly" then
		buildButterfly(sk)
	elseif wName == "Karambit" then
		buildKarambit(sk)
	else
		buildKatana(sk)
	end

	-- 腕のビューモデル
	regPart("arm", "arm", Vector3.new(0.42, 0.42, 1.65), Color3.fromRGB(20, 22, 26),
		CFrame.new(0.24, -0.44, 0.72) * CFrame.Angles(math.rad(-14), math.rad(22), math.rad(-16)))

	model.Parent = workspace.CurrentCamera
end

-- ==========================================================
-- 多段階キーフレーム補間エンジン（緩急＋オーバーシュート対応）
-- ==========================================================
local function easeValue(u, mode)
	if mode == "in" then
		return u * u * u
	elseif mode == "out" then
		return 1 - (1 - u) ^ 3
	elseif mode == "snap" then
		local c = 1.70158
		return 1 + (c + 1) * (u - 1) ^ 3 + c * (u - 1) ^ 2
	else
		return u < 0.5 and (4 * u * u * u) or (1 - (-2 * u + 2) ^ 3 / 2)
	end
end

local function evalKeyframes(keys, t)
	if t <= keys[1].t then return keys[1] end
	if t >= keys[#keys].t then return keys[#keys] end
	for i = 1, #keys - 1 do
		local a, b = keys[i], keys[i + 1]
		if t >= a.t and t <= b.t then
			local u = easeValue((t - a.t) / math.max(b.t - a.t, 0.0001), b.ease or "inout")
			return {
				pos = a.pos:Lerp(b.pos, u),
				rot = a.rot:Lerp(b.rot, u),
				blade = a.blade + (b.blade - a.blade) * u,
				safe = a.safe + (b.safe - a.safe) * u,
				bite = a.bite + (b.bite - a.bite) * u,
			}
		end
	end
	return keys[#keys]
end

-- バタフライナイフのキーフレーム定義
local KF_BF_EQUIP = {
	{ t = 0.00, pos = Vector3.new(0.10, -0.45, 0.25), rot = Vector3.new(-42, 18, -28), blade = -180, safe = 180, bite = 160 },
	{ t = 0.28, pos = Vector3.new(-0.08, 0.06, -0.06), rot = Vector3.new(12, 14, 24),   blade = -45,  safe = 95,  bite = -110, ease = "out" },
	{ t = 0.52, pos = Vector3.new(0.02, -0.04, 0.02),  rot = Vector3.new(-8, -6, -12),  blade = -18,  safe = 38,  bite = 8,    ease = "inout" },
	{ t = 0.72, pos = Vector3.zero,                    rot = Vector3.zero,              blade = -24,  safe = 46,  bite = -2,   ease = "snap" },
}

local KF_BF_INSPECT = {
	{ t = 0.00, pos = Vector3.zero,                    rot = Vector3.zero,              blade = -24,  safe = 46,   bite = -2 },
	{ t = 0.14, pos = Vector3.new(0.05, -0.10, 0.05),  rot = Vector3.new(-16, 6, -16),  blade = -6,   safe = 18,   bite = 28,   ease = "in" },
	{ t = 0.42, pos = Vector3.new(-0.10, 0.10, -0.08), rot = Vector3.new(18, 24, 28),   blade = 128,  safe = -110, bite = 185,  ease = "inout" },
	{ t = 0.76, pos = Vector3.new(-0.16, 0.15, -0.04), rot = Vector3.new(26, 36, 46),   blade = 290,  safe = -240, bite = 335,  ease = "inout" },
	{ t = 1.06, pos = Vector3.new(-0.08, 0.05, 0.02),  rot = Vector3.new(6, 12, -20),   blade = 415,  safe = -345, bite = 435,  ease = "inout" },
	{ t = 1.38, pos = Vector3.new(0.03, -0.06, 0.03),  rot = Vector3.new(-14, -6, -14), blade = 330,  safe = -304, bite = 348,  ease = "out" },
	{ t = 1.56, pos = Vector3.new(0.01, -0.02, 0.01),  rot = Vector3.new(-4, -2, -6),   blade = 342,  safe = -320, bite = 365,  ease = "out" },
	{ t = 1.80, pos = Vector3.zero,                    rot = Vector3.zero,              blade = 336,  safe = -314, bite = 358,  ease = "snap" },
}

local KF_BF_SLASH = {
	{ t = 0.00, pos = Vector3.zero,                    rot = Vector3.zero,              blade = -24, safe = 46, bite = -2 },
	{ t = 0.10, pos = Vector3.new(0.14, 0.08, 0.06),   rot = Vector3.new(14, -18, -22), blade = -18, safe = 42, bite = -4,  ease = "in" },
	{ t = 0.24, pos = Vector3.new(-0.56, -0.06, -0.26),rot = Vector3.new(-32, 48, 38),  blade = -30, safe = 24, bite = -12, ease = "out" },
	{ t = 0.44, pos = Vector3.zero,                    rot = Vector3.zero,              blade = -24, safe = 46, bite = -2,  ease = "snap" },
}

-- カランビット：フィンガーリング・スピン
local KF_KARAMBIT_INSPECT = {
	{ t = 0.00, pos = Vector3.zero,                    rot = Vector3.zero,              blade = 0,   safe = 0, bite = 0 },
	{ t = 0.16, pos = Vector3.new(-0.08, 0.06, -0.04), rot = Vector3.new(10, 14, -18),  blade = -35, safe = 0, bite = 0, ease = "in" },
	{ t = 0.55, pos = Vector3.new(-0.14, 0.12, -0.06), rot = Vector3.new(18, 28, -28),  blade = 385, safe = 0, bite = 0, ease = "inout" },
	{ t = 1.00, pos = Vector3.new(-0.06, 0.04, -0.02), rot = Vector3.new(8, 12, -10),   blade = 738, safe = 0, bite = 0, ease = "out" },
	{ t = 1.25, pos = Vector3.zero,                    rot = Vector3.zero,              blade = 720, safe = 0, bite = 0, ease = "snap" },
}

-- カタナ：居合回し
local KF_KATANA_INSPECT = {
	{ t = 0.00, pos = Vector3.zero,                    rot = Vector3.zero,              blade = 0,   safe = 0, bite = 0 },
	{ t = 0.25, pos = Vector3.new(-0.18, 0.08, -0.10), rot = Vector3.new(18, 28, 32),   blade = -25, safe = 0, bite = 0, ease = "in" },
	{ t = 0.72, pos = Vector3.new(-0.24, 0.16, -0.04), rot = Vector3.new(32, 46, 120),  blade = 190, safe = 0, bite = 0, ease = "inout" },
	{ t = 1.15, pos = Vector3.new(-0.08, -0.04, 0.04), rot = Vector3.new(-12, 10, -24), blade = 372, safe = 0, bite = 0, ease = "out" },
	{ t = 1.45, pos = Vector3.zero,                    rot = Vector3.zero,              blade = 360, safe = 0, bite = 0, ease = "snap" },
}

local function isPointerOverGui()
	local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not pg then return false end
	local pos = UserInputService:GetMouseLocation()
	local objs = pg:GetGuiObjectsAtPosition(pos.X, pos.Y)
	for _, obj in ipairs(objs) do
		if obj:IsDescendantOf(pg:FindFirstChild("CatWareGui") or pg) and obj.Visible then
			if obj:IsA("GuiButton") or obj.Name == "GlassStage" or obj.Name == "FloatingDock" then
				return true
			end
		end
	end
	return false
end

local function updateFrame(dt)
	if not enabled or not model then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	if model.Parent ~= cam then model.Parent = cam end

	local safeDt = math.clamp(dt, 0.001, 0.05)

	-- カメラ回転によるスプリングスウェイ（重みのある遅れと収束）
	local targetSway = Vector2.zero
	if lastCameraCF then
		local rel = lastCameraCF:ToObjectSpace(cam.CFrame)
		local _, ry, rx = rel:ToEulerAnglesYXZ()
		targetSway = Vector2.new(math.clamp(ry * 3.2, -0.14, 0.14), math.clamp(rx * 3.2, -0.12, 0.12))
	end
	lastCameraCF = cam.CFrame

	local stiffness, damping = 180, 16
	swayVel += (targetSway - swayPos) * stiffness * safeDt
	swayVel *= math.exp(-damping * safeDt)
	swayPos += swayVel * safeDt

	-- 歩行＆ジャンプ落下スプリング
	local char = Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local rootPart = char and char:FindFirstChild("HumanoidRootPart")
	local moving = (hum and hum.MoveDirection.Magnitude > 0.05) and 1 or 0
	walkBlend += (moving - walkBlend) * math.clamp(safeDt * 10, 0, 1)
	if walkBlend > 0.01 then
		walkPhase += safeDt * 9.5
	end

	local velY = rootPart and math.clamp(-rootPart.AssemblyLinearVelocity.Y * 0.003, -0.10, 0.10) or 0
	airVel += (velY - airY) * 140 * safeDt
	airVel *= math.exp(-14 * safeDt)
	airY += airVel * safeDt

	local bobX = math.cos(walkPhase) * 0.022 * walkBlend
	local bobY = math.abs(math.sin(walkPhase)) * 0.024 * walkBlend
	local breath = math.sin(os.clock() * 1.8) * 0.005

	-- キーフレームポーズ評価
	animTime += safeDt
	local wName = Knife.Weapons[weaponIdx]
	local pose = { pos = Vector3.zero, rot = Vector3.zero, blade = -24, safe = 46, bite = -2 }
	if wName ~= "Butterfly" then
		pose.blade, pose.safe, pose.bite = 0, 0, 0
	end

	if animMode ~= "idle" then
		local kf
		if wName == "Butterfly" then
			kf = (animMode == "equip" and KF_BF_EQUIP) or (animMode == "inspect" and KF_BF_INSPECT) or KF_BF_SLASH
		elseif wName == "Karambit" then
			kf = (animMode == "inspect" and KF_KARAMBIT_INSPECT) or KF_BF_SLASH
		else
			kf = (animMode == "inspect" and KF_KATANA_INSPECT) or KF_BF_SLASH
		end

		local maxT = kf[#kf].t
		pose = evalKeyframes(kf, animTime)
		if animTime >= maxT then
			animMode = "idle"
		end
	end

	-- 武器種ごとの基本構え
	local baseOffset, baseAngles
	if wName == "Karambit" then
		baseOffset = Vector3.new(0.66, -0.14, offsetZ + 0.14)
		baseAngles = CFrame.Angles(math.rad(-14), math.rad(-26), math.rad(-16))
	elseif wName == "Katana" then
		baseOffset = Vector3.new(0.56, -0.52, offsetZ - 0.10)
		baseAngles = CFrame.Angles(math.rad(-22), math.rad(-20), math.rad(14))
	else
		baseOffset = Vector3.new(0.58, -0.20, offsetZ)
		baseAngles = CFrame.Angles(math.rad(-6), math.rad(-18), math.rad(-10))
	end

	local handCamCF = CFrame.new(baseOffset.X + swayPos.X + bobX + pose.pos.X, baseOffset.Y + swayPos.Y - bobY + breath + airY + pose.pos.Y, baseOffset.Z + pose.pos.Z)
		* baseAngles
		* CFrame.Angles(math.rad(pose.rot.X), math.rad(pose.rot.Y), math.rad(pose.rot.Z))

	local handRoot = cam.CFrame * handCamCF
	local bladeRoot = handRoot * CFrame.Angles(0, 0, math.rad(pose.blade))
	local safeRoot = handRoot * CFrame.Angles(0, 0, math.rad(pose.safe))
	local biteRoot = bladeRoot * CFrame.new(0.15 * knifeScale, 0, 0) * CFrame.Angles(0, 0, math.rad(pose.bite))

	local roots = {
		blade = bladeRoot,
		safe = safeRoot,
		bite = biteRoot,
		arm = handRoot,
	}

	for _, item in ipairs(partsList) do
		local r = roots[item.group]
		if r then
			local p = item.localCF.Position * knifeScale
			local rot = item.localCF - item.localCF.Position
			item.part.CFrame = r * CFrame.new(p) * rot
		end
	end
end

function Knife.TriggerInspect()
	if not enabled then return end
	animMode = "inspect"
	animTime = 0
end

function Knife.TriggerSlash()
	if not enabled then return end
	animMode = "slash"
	animTime = 0
end

function Knife.CycleWeapon()
	weaponIdx = (weaponIdx % #Knife.Weapons) + 1
	if enabled then
		buildModel()
		animMode = "equip"
		animTime = 0
	end
	return Knife.Weapons[weaponIdx]
end

function Knife.GetWeaponName()
	return Knife.Weapons[weaponIdx]
end

function Knife.CycleSkin()
	skinIdx = (skinIdx % #Knife.Skins) + 1
	applySkin()
	return Knife.Skins[skinIdx].name
end

function Knife.GetSkinName()
	return Knife.Skins[skinIdx].name
end

function Knife.SetScale(val)
	knifeScale = val
	for _, item in ipairs(partsList) do
		item.part.Size = item.baseSize * knifeScale
	end
end

function Knife.SetOffsetZ(val)
	offsetZ = val
end

function Knife.SetEnabled(state)
	enabled = state
	if state then
		lastCameraCF = workspace.CurrentCamera and workspace.CurrentCamera.CFrame or nil
		buildModel()
		animMode = "equip"
		animTime = 0

		if not renderConn then
			renderConn = RunService.RenderStepped:Connect(updateFrame)
		end
		if not inputConn then
			inputConn = UserInputService.InputBegan:Connect(function(input, gp)
				if gp or not enabled then return end
				if UserInputService:GetFocusedTextBox() then return end

				if input.KeyCode == Enum.KeyCode.F then
					Knife.TriggerInspect()
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
					if not isPointerOverGui() then
						Knife.TriggerSlash()
					end
				end
			end)
		end
	else
		if renderConn then renderConn:Disconnect(); renderConn = nil end
		if inputConn then inputConn:Disconnect(); inputConn = nil end
		if model then model:Destroy(); model = nil end
		partsList = {}
	end
end

return Knife