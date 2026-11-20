local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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

local AssetsRef = nil
local enabled = false
local weaponIdx = 2 -- デフォルトを Karambit にしてすぐ試せるように
local skinIdx = 1
local knifeScale = 1.0
local offsetZ = -1.56

local model = nil
local partsList = {}
local renderConn = nil
local inputConn = nil
local lastCameraCF = nil

-- 2次スプリング物理
local swayPos = Vector2.zero
local swayVel = Vector2.zero
local airY = 0
local airVel = 0
local walkPhase = 0
local walkBlend = 0

-- TweenService 駆動アニメ変数
local vPos, vRot, vBlade, vSafe, vBite
local seqId = 0
local activeTweens = {}

function Knife.SetAssets(assetsModule)
	AssetsRef = assetsModule
end

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
-- 外部 .rbxm モデル読み込み（Studio保存ファイル用）
-- ==========================================================
local function tryBuildFromRbxm(fileName, targetLength)
	if not AssetsRef then return false end
	local assetUrl = AssetsRef.Get(fileName)
	if not assetUrl or assetUrl == "" then return false end

	local ok, objs = pcall(function()
		return game:GetObjects(assetUrl)
	end)
	if not ok or not objs or #objs == 0 then
		return false
	end

	local rootObj = objs[1]
	local tempModel = Instance.new("Model")
	if rootObj:IsA("Model") then
		for _, ch in ipairs(rootObj:GetChildren()) do
			ch.Parent = tempModel
		end
		rootObj:Destroy()
	else
		rootObj.Parent = tempModel
	end

	-- もし RingPivot パーツがあればリング中心として使う
	local customPivotPos = nil
	local ringMarker = tempModel:FindFirstChild("RingPivot", true)
	if ringMarker and ringMarker:IsA("BasePart") then
		customPivotPos = ringMarker.Position
		ringMarker:Destroy()
	end

	local boxCF, boxSize = tempModel:GetBoundingBox()
	local maxDim = math.max(boxSize.X, boxSize.Y, boxSize.Z)
	if maxDim <= 0.001 then
		tempModel:Destroy()
		return false
	end

	local normScale = (targetLength or 1.25) / maxDim

	-- 一番長い軸が X に来るように自動整列（Karambit はリングが右奥、刃が左前へ）
	local alignCF
	if boxSize.Z > boxSize.X then
		-- Z が最長なら Y90° で X 軸に揃える
		alignCF = CFrame.Angles(0, math.rad(90), 0)
	else
		-- 画像通り X が最長でリングが左(-X)・刃が右(+X)なら 180° 反転して手前にリングを置く
		alignCF = CFrame.Angles(0, math.rad(180), math.rad(-14))
	end

	local pivotWorldPos = customPivotPos or (
		boxCF.Position
		- boxCF.RightVector * (boxSize.X * 0.36)
		- boxCF.UpVector * (boxSize.Y * 0.08)
	)
	local pivotFrame = CFrame.new(pivotWorldPos)

	for _, desc in ipairs(tempModel:GetDescendants()) do
		if desc:IsA("JointInstance") or desc:IsA("Constraint") then
			desc:Destroy()
		elseif desc:IsA("BasePart") then
			desc.Anchored = true
			desc.CanCollide = false
			desc.CanTouch = false
			desc.CanQuery = false
			desc.CastShadow = false

			local relCF = pivotFrame:ToObjectSpace(desc.CFrame)
			local scaledRel = CFrame.new(relCF.Position * normScale) * (relCF - relCF.Position)
			local finalLocalCF = alignCF * scaledRel
			local baseSz = desc.Size * normScale

			desc.Size = baseSz * knifeScale
			desc.Parent = model

			table.insert(partsList, {
				part = desc,
				baseSize = baseSz,
				group = "blade",
				role = "imported",
				localCF = finalLocalCF,
			})
		end
	end

	tempModel:Destroy()
	return #partsList > 0
end

-- ==========================================================
-- フォールバック用コード生成モデル
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
		Vector2.new(0.085, 0.04), Vector2.new(0.095, 0.22), Vector2.new(0.118, 0.42),
		Vector2.new(0.155, 0.62), Vector2.new(0.205, 0.79),
	}
	local widths = { 0.14, 0.175, 0.195, 0.170 }
	for i = 1, #spinePts - 1 do
		addArcSegment("blade", "blade", spinePts[i], spinePts[i + 1], widths[i], thickZ,
			sk.blade, 0.08, i > 1, i == (#spinePts - 1))
	end

	local darkPts = { Vector2.new(0.125, 0.16), Vector2.new(0.155, 0.38), Vector2.new(0.192, 0.58) }
	for i = 1, #darkPts - 1 do
		addArcSegment("blade", "bladeDark", darkPts[i], darkPts[i + 1], 0.055, thickZ + 0.002,
			sk.bladeDark, 0.06, i == 1, true)
	end

	addWedgeXY("blade", "blade", 0.232, 0.69, 0.075, 0.14, thickZ, -22, false, sk.blade, 0.08)
	addWedgeXY("blade", "blade", 0.228, 0.89, 0.155, 0.26, thickZ, -32, false, sk.blade, 0.08)
	addWedgeXY("blade", "blade", 0.308, 1.00, 0.085, 0.17, thickZ, -52, false, sk.blade, 0.08)

	local edgePts = {
		Vector2.new(0.032, 0.24), Vector2.new(0.045, 0.44), Vector2.new(0.078, 0.64),
		Vector2.new(0.132, 0.82), Vector2.new(0.215, 0.96),
	}
	for i = 1, #edgePts - 1 do
		addArcSegment("blade", "edge", edgePts[i], edgePts[i + 1], 0.024, edgeZ,
			sk.edge, 0.22, i == 1, i == (#edgePts - 1))
	end
	addWedgeXY("blade", "edge", 0.285, 1.015, 0.022, 0.14, edgeZ, -54, false, sk.edge, 0.25)

	buildButterflyHandle("safe", 1, sk)
	buildButterflyHandle("bite", -1, sk)
end

local function buildKarambitFallback(sk)
	local thickZ = 0.064
	local bladeZ = 0.028
	local segs, ringR = 14, 0.082
	for i = 1, segs do
		local a = (i / segs) * math.pi * 2
		regPart("blade", "handle", Vector3.new(0.032, 0.042, thickZ * 0.88), sk.handle,
			CFrame.new(math.cos(a) * ringR, math.sin(a) * ringR, 0) * CFrame.Angles(0, 0, a), { reflectance = 0.04 })
	end
	local gripPts = { Vector2.new(0.01, -0.09), Vector2.new(0.03, -0.24), Vector2.new(0.01, -0.40), Vector2.new(-0.04, -0.54) }
	local gripW = { 0.13, 0.135, 0.13 }
	for i = 1, #gripPts - 1 do
		addArcSegment("blade", "handle", gripPts[i], gripPts[i + 1], gripW[i], thickZ, sk.handle, 0.03, true, i == (#gripPts - 1))
	end
	local clawPts = { Vector2.new(-0.06, -0.54), Vector2.new(-0.18, -0.66), Vector2.new(-0.34, -0.74), Vector2.new(-0.54, -0.76), Vector2.new(-0.74, -0.70) }
	local clawW = { 0.17, 0.16, 0.135, 0.095 }
	for i = 1, #clawPts - 1 do
		addArcSegment("blade", "blade", clawPts[i], clawPts[i + 1], clawW[i], bladeZ, sk.blade, 0.12, true, i == (#clawPts - 1))
	end
	addWedgeXY("blade", "blade", -0.85, -0.62, 0.078, 0.22, bladeZ, 66, false, sk.blade, 0.14)
end

local function buildKatanaFallback(sk)
	local bladeZ, gripZ = 0.024, 0.062
	regPart("blade", "handle", Vector3.new(0.088, 0.66, gripZ), sk.handle, CFrame.new(0, -0.22, 0), { reflectance = 0.02 })
	regPart("blade", "bladeDark", Vector3.new(0.030, 0.23, 0.23), Color3.fromRGB(36, 40, 48),
		CFrame.new(0, 0.12, 0) * CFrame.Angles(0, 0, math.rad(90)), { shape = Enum.PartType.Cylinder, reflectance = 0.2 })
	local bladePts = { Vector2.new(0, 0.18), Vector2.new(-0.012, 0.56), Vector2.new(-0.04, 0.96), Vector2.new(-0.085, 1.36), Vector2.new(-0.145, 1.74) }
	local bw = { 0.082, 0.078, 0.072, 0.064 }
	for i = 1, #bladePts - 1 do
		addArcSegment("blade", "blade", bladePts[i], bladePts[i + 1], bw[i], bladeZ, sk.blade, 0.16, i > 1, i == (#bladePts - 1))
	end
	addWedgeXY("blade", "blade", -0.185, 1.88, 0.060, 0.28, bladeZ, 14, true, sk.blade, 0.18)
end

-- ==========================================================
-- TweenService 駆動アニメエンジン
-- ==========================================================
local function initAnimValues(parentModel)
	local f = Instance.new("Folder")
	f.Name = "AnimValues"
	f.Parent = parentModel
	vPos = Instance.new("Vector3Value", f)
	vRot = Instance.new("Vector3Value", f)
	vBlade = Instance.new("NumberValue", f)
	vSafe = Instance.new("NumberValue", f)
	vBite = Instance.new("NumberValue", f)
end

local function getIdlePose()
	if Knife.Weapons[weaponIdx] == "Butterfly" then
		return { pos = Vector3.zero, rot = Vector3.zero, blade = -24, safe = 46, bite = -2 }
	end
	return { pos = Vector3.zero, rot = Vector3.zero, blade = 0, safe = 0, bite = 0 }
end

local function resetToIdleImmediate()
	local idle = getIdlePose()
	if vPos then
		vPos.Value = idle.pos
		vRot.Value = idle.rot
		vBlade.Value = idle.blade
		vSafe.Value = idle.safe
		vBite.Value = idle.bite
	end
end

local function nearestAngle(cur, target)
	return target + math.floor((cur - target) / 360 + 0.5) * 360
end

local function cancelTweens()
	seqId += 1
	for _, tw in ipairs(activeTweens) do
		pcall(function() tw:Cancel() end)
	end
	activeTweens = {}
	return seqId
end

local function tweenStep(myId, dur, style, dir, goal)
	if myId ~= seqId or not enabled then return false end
	local info = TweenInfo.new(dur, style, dir)
	local map = { pos = vPos, rot = vRot, blade = vBlade, safe = vSafe, bite = vBite }
	for k, targetVal in pairs(goal) do
		local obj = map[k]
		if obj then
			local tw = TweenService:Create(obj, info, { Value = targetVal })
			table.insert(activeTweens, tw)
			tw:Play()
		end
	end
	task.wait(dur)
	return myId == seqId and enabled
end

local function playEquipTween()
	local myId = cancelTweens()
	local wName = Knife.Weapons[weaponIdx]
	local idle = getIdlePose()
	if wName == "Butterfly" then
		vPos.Value = Vector3.new(0.12, -0.45, 0.25)
		vRot.Value = Vector3.new(-42, 18, -28)
		vBlade.Value = -180
		vSafe.Value = 180
		vBite.Value = 150
		task.spawn(function()
			if not tweenStep(myId, 0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
				pos = Vector3.new(-0.07, 0.06, -0.05), rot = Vector3.new(12, 14, 22),
				blade = -40, safe = 88, bite = -95,
			}) then return end
			tweenStep(myId, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out, idle)
		end)
	else
		vPos.Value = Vector3.new(0.10, -0.42, 0.22)
		vRot.Value = Vector3.new(-35, 16, -22)
		vBlade.Value = -120
		task.spawn(function()
			tweenStep(myId, 0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out, idle)
		end)
	end
end

local function playInspectTween()
	local myId = cancelTweens()
	local wName = Knife.Weapons[weaponIdx]
	local idle = getIdlePose()
	task.spawn(function()
		if wName == "Butterfly" then
			if not tweenStep(myId, 0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.In, {
				pos = Vector3.new(0.05, -0.10, 0.05), rot = Vector3.new(-16, 6, -16),
				blade = nearestAngle(vBlade.Value, -6), safe = nearestAngle(vSafe.Value, 18), bite = nearestAngle(vBite.Value, 28),
			}) then return end
			if not tweenStep(myId, 0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
				pos = Vector3.new(-0.10, 0.10, -0.08), rot = Vector3.new(18, 24, 28),
				blade = vBlade.Value + 135, safe = vSafe.Value - 125, bite = vBite.Value + 160,
			}) then return end
			if not tweenStep(myId, 0.36, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, {
				pos = Vector3.new(-0.15, 0.14, -0.04), rot = Vector3.new(24, 34, 44),
				blade = vBlade.Value + 165, safe = vSafe.Value - 135, bite = vBite.Value + 150,
			}) then return end
			if not tweenStep(myId, 0.30, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, {
				pos = Vector3.new(-0.06, 0.04, 0.02), rot = Vector3.new(4, 10, -18),
				blade = vBlade.Value + 110, safe = vSafe.Value - 100, bite = vBite.Value + 90,
			}) then return end
			if not tweenStep(myId, 0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				pos = idle.pos, rot = idle.rot,
				blade = nearestAngle(vBlade.Value, idle.blade),
				safe = nearestAngle(vSafe.Value, idle.safe),
				bite = nearestAngle(vBite.Value, idle.bite),
			}) then return end
			resetToIdleImmediate()

		elseif wName == "Karambit" then
			-- フィンガーリングを中心に 2回転スピンしてキャッチ
			if not tweenStep(myId, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
				pos = Vector3.new(-0.08, 0.06, -0.04), rot = Vector3.new(10, 14, -18),
				blade = vBlade.Value - 35,
			}) then return end
			if not tweenStep(myId, 0.62, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, {
				pos = Vector3.new(-0.14, 0.12, -0.06), rot = Vector3.new(18, 28, -28),
				blade = vBlade.Value + 755,
			}) then return end
			if not tweenStep(myId, 0.30, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				pos = idle.pos, rot = idle.rot,
				blade = nearestAngle(vBlade.Value, idle.blade),
			}) then return end
			resetToIdleImmediate()

		else
			if not tweenStep(myId, 0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In, {
				pos = Vector3.new(-0.18, 0.08, -0.10), rot = Vector3.new(18, 28, 32),
				blade = vBlade.Value - 25,
			}) then return end
			if not tweenStep(myId, 0.60, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, {
				pos = Vector3.new(-0.22, 0.14, -0.04), rot = Vector3.new(30, 44, 120),
				blade = vBlade.Value + 385,
			}) then return end
			if not tweenStep(myId, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
				pos = idle.pos, rot = idle.rot,
				blade = nearestAngle(vBlade.Value, idle.blade),
			}) then return end
			resetToIdleImmediate()
		end
	end)
end

local function playSlashTween()
	local myId = cancelTweens()
	local idle = getIdlePose()
	task.spawn(function()
		if not tweenStep(myId, 0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, {
			pos = Vector3.new(0.14, 0.08, 0.06), rot = Vector3.new(14, -18, -22),
			blade = nearestAngle(vBlade.Value, idle.blade + 6),
			safe = nearestAngle(vSafe.Value, idle.safe - 4),
			bite = nearestAngle(vBite.Value, idle.bite),
		}) then return end
		if not tweenStep(myId, 0.14, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, {
			pos = Vector3.new(-0.56, -0.06, -0.26), rot = Vector3.new(-32, 48, 38),
			blade = nearestAngle(vBlade.Value, idle.blade - 8),
			safe = nearestAngle(vSafe.Value, idle.safe - 22),
		}) then return end
		tweenStep(myId, 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out, {
			pos = idle.pos, rot = idle.rot,
			blade = nearestAngle(vBlade.Value, idle.blade),
			safe = nearestAngle(vSafe.Value, idle.safe),
			bite = nearestAngle(vBite.Value, idle.bite),
		})
	end)
end

local function applySkin()
	local sk = Knife.Skins[skinIdx]
	for _, item in ipairs(partsList) do
		if item.role == "imported" then
			continue
		elseif item.role == "blade" or item.role == "inlay" then
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

	-- 同名の .rbxm が src/assets/ にあれば最優先で読み込む！
	local rbxmLoaded = false
	if wName == "Karambit" then
		rbxmLoaded = tryBuildFromRbxm("karambit.rbxm", 1.25)
		if not rbxmLoaded then buildKarambitFallback(sk) end
	elseif wName == "Butterfly" then
		rbxmLoaded = tryBuildFromRbxm("butterfly.rbxm", 1.55)
		if not rbxmLoaded then buildButterfly(sk) end
	else
		rbxmLoaded = tryBuildFromRbxm("katana.rbxm", 2.2)
		if not rbxmLoaded then buildKatanaFallback(sk) end
	end

	-- 腕のビューモデル
	regPart("arm", "arm", Vector3.new(0.40, 0.40, 1.55), Color3.fromRGB(20, 22, 26),
		CFrame.new(0.24, -0.44, 0.72) * CFrame.Angles(math.rad(-14), math.rad(22), math.rad(-16)))

	initAnimValues(model)
	resetToIdleImmediate()
	model.Parent = workspace.CurrentCamera
end

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
	if not enabled or not model or not vPos then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	if model.Parent ~= cam then model.Parent = cam end

	local safeDt = math.clamp(dt, 0.001, 0.05)

	local targetSway = Vector2.zero
	if lastCameraCF then
		local rel = lastCameraCF:ToObjectSpace(cam.CFrame)
		local _, ry, rx = rel:ToEulerAnglesYXZ()
		targetSway = Vector2.new(math.clamp(ry * 3.2, -0.14, 0.14), math.clamp(rx * 3.2, -0.12, 0.12))
	end
	lastCameraCF = cam.CFrame

	swayVel += (targetSway - swayPos) * 180 * safeDt
	swayVel *= math.exp(-16 * safeDt)
	swayPos += swayVel * safeDt

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

	local wName = Knife.Weapons[weaponIdx]
	local baseOffset, baseAngles
	if wName == "Karambit" then
		baseOffset = Vector3.new(0.62, -0.26, offsetZ + 0.12)
		baseAngles = CFrame.Angles(math.rad(-10), math.rad(-22), math.rad(-12))
	elseif wName == "Katana" then
		baseOffset = Vector3.new(0.56, -0.52, offsetZ - 0.10)
		baseAngles = CFrame.Angles(math.rad(-22), math.rad(-20), math.rad(14))
	else
		baseOffset = Vector3.new(0.58, -0.20, offsetZ)
		baseAngles = CFrame.Angles(math.rad(-6), math.rad(-18), math.rad(-10))
	end

	local pOff = vPos.Value
	local rOff = vRot.Value
	local handCamCF = CFrame.new(
		baseOffset.X + swayPos.X + bobX + pOff.X,
		baseOffset.Y + swayPos.Y - bobY + breath + airY + pOff.Y,
		baseOffset.Z + pOff.Z
	) * baseAngles * CFrame.Angles(math.rad(rOff.X), math.rad(rOff.Y), math.rad(rOff.Z))

	local handRoot = cam.CFrame * handCamCF
	local bladeRoot = handRoot * CFrame.Angles(0, 0, math.rad(vBlade.Value))
	local safeRoot = handRoot * CFrame.Angles(0, 0, math.rad(vSafe.Value))
	local biteRoot = bladeRoot * CFrame.new(0.15 * knifeScale, 0, 0) * CFrame.Angles(0, 0, math.rad(vBite.Value))

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
	playInspectTween()
end

function Knife.TriggerSlash()
	if not enabled then return end
	playSlashTween()
end

function Knife.CycleWeapon()
	weaponIdx = (weaponIdx % #Knife.Weapons) + 1
	if enabled then
		buildModel()
		playEquipTween()
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
		playEquipTween()

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
		cancelTweens()
		if renderConn then renderConn:Disconnect(); renderConn = nil end
		if inputConn then inputConn:Disconnect(); inputConn = nil end
		if model then model:Destroy(); model = nil end
		partsList = {}
	end
end

return Knife