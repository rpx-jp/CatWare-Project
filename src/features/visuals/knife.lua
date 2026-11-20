local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knife = {}

Knife.Skins = {
	{
		name = "Emerald",
		blade = Color3.fromRGB(0, 178, 102),
		bladeDark = Color3.fromRGB(0, 142, 80),
		edge = Color3.fromRGB(238, 250, 244),
		handle = Color3.fromRGB(24, 26, 30),
	},
	{
		name = "Crimson",
		blade = Color3.fromRGB(210, 38, 58),
		bladeDark = Color3.fromRGB(162, 24, 40),
		edge = Color3.fromRGB(252, 236, 238),
		handle = Color3.fromRGB(24, 24, 28),
	},
	{
		name = "Sapphire",
		blade = Color3.fromRGB(32, 142, 242),
		bladeDark = Color3.fromRGB(20, 102, 192),
		edge = Color3.fromRGB(234, 246, 255),
		handle = Color3.fromRGB(22, 26, 32),
	},
	{
		name = "Gold",
		blade = Color3.fromRGB(238, 188, 56),
		bladeDark = Color3.fromRGB(186, 140, 32),
		edge = Color3.fromRGB(255, 250, 226),
		handle = Color3.fromRGB(24, 24, 28),
	},
	{
		name = "Whiteout",
		blade = Color3.fromRGB(232, 238, 246),
		bladeDark = Color3.fromRGB(192, 200, 212),
		edge = Color3.fromRGB(255, 255, 255),
		handle = Color3.fromRGB(46, 50, 58),
	},
}

local enabled = false
local skinIdx = 1
local knifeScale = 1.0
local offsetZ = -1.68

local model = nil
local partsList = {}
local renderConn = nil
local inputConn = nil

local animMode = "idle"
local animTime = 0
local swayOffset = Vector2.zero
local walkBob = 0
local lastCameraCF = nil

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

-- 2点間を丸ジョイント付きで継ぎ目ゼロ接続
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

-- X-Y平面内で正しく傾くWedge（厚さZ, 高さY, 幅X）
local function addWedgeXY(group, role, x, y, widthX, heightY, thickZ, angleDeg, flipLeft, color, reflectance)
	local yaw = flipLeft and math.rad(-90) or math.rad(90)
	regPart(group, role, Vector3.new(thickZ, heightY, widthX), color,
		CFrame.new(x, y, 0) * CFrame.Angles(0, 0, math.rad(angleDeg)) * CFrame.Angles(0, yaw, 0),
		{ className = "WedgePart", reflectance = reflectance })
end

-- 画像通りの曲線ハンドル＋丸インレイ＋ひし形ピボットピン
local function buildHandle(group, dirX, sk)
	local PIN_WHITE = Color3.fromRGB(242, 246, 250)
	local PIN_RING = Color3.fromRGB(48, 52, 60)
	local thickZ = 0.056

	-- ピボット丸ヘッド（大きめの円形ハブ）
	regPart(group, "handle", Vector3.new(thickZ, 0.155, 0.155), sk.handle,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0),
		{ shape = Enum.PartType.Cylinder, reflectance = 0.03 })

	-- 曲線パス（画像と同じ優雅な外向きカーブ）
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

	-- 末端のフレア（画像の少し反り返ったエンド）
	local tail = pts[#pts]
	local prev = pts[#pts - 1]
	local tailAng = math.atan2(tail.Y - prev.Y, tail.X - prev.X) - math.rad(90)
	regPart(group, "handle", Vector3.new(0.155, 0.065, thickZ), sk.handle,
		CFrame.new(tail.X - 0.01 * dirX, tail.Y - 0.015, 0) * CFrame.Angles(0, 0, tailAng),
		{ reflectance = 0.03 })

	-- 曲線インレイ（両端が丸いカプセル型）
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

	-- 上ピボット：丸台座 ＋ 白銀ひし形ピン
	regPart(group, "pinRing", Vector3.new(thickZ + 0.004, 0.088, 0.088), PIN_RING,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0), { shape = Enum.PartType.Cylinder })
	regPart(group, "pin", Vector3.new(0.050, 0.050, thickZ + 0.010), PIN_WHITE,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(45)), { reflectance = 0.25 })

	-- 下ピボット：白銀ひし形ピン（画像通り末端に配置）
	regPart(group, "pin", Vector3.new(0.038, 0.038, thickZ + 0.008), PIN_WHITE,
		CFrame.new(tail.X + 0.005 * dirX, tail.Y + 0.008, 0) * CFrame.Angles(0, 0, math.rad(45)),
		{ reflectance = 0.25 })
end

-- 画像通りの曲線クリップポイントブレード
local function buildBlade(sk)
	local thickZ = 0.026
	local edgeZ = 0.028

	-- 根元の八角形ベース（2つのピボットの間）
	regPart("blade", "bladeDark", Vector3.new(0.20, 0.16, thickZ + 0.006), sk.bladeDark,
		CFrame.new(0.075, -0.02, 0) * CFrame.Angles(0, 0, math.rad(-10)), { reflectance = 0.05 })
	regPart("blade", "bladeDark", Vector3.new(0.16, 0.16, thickZ + 0.006), sk.bladeDark,
		CFrame.new(0.075, -0.02, 0) * CFrame.Angles(0, 0, math.rad(35)), { reflectance = 0.05 })

	-- 根元左側の曲がったツメ（ガードホーン）
	addWedgeXY("blade", "blade", -0.055, 0.095, 0.085, 0.055, thickZ, 78, true, sk.blade, 0.06)
	addWedgeXY("blade", "blade", -0.095, 0.082, 0.055, 0.036, thickZ, 118, true, sk.blade, 0.06)

	-- ブレード本体：緩やかに右へ反りながら広がる5セグメント曲線
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

	-- 背中の暗い面取り（立体感を出すツートン）
	local darkPts = {
		Vector2.new(0.125, 0.16),
		Vector2.new(0.155, 0.38),
		Vector2.new(0.192, 0.58),
	}
	for i = 1, #darkPts - 1 do
		addArcSegment("blade", "bladeDark", darkPts[i], darkPts[i + 1], 0.055, thickZ + 0.002,
			sk.bladeDark, 0.06, i == 1, true)
	end

	-- 背中のクリップポイント・フック（画像の右上の返り）
	addWedgeXY("blade", "blade", 0.232, 0.69, 0.075, 0.14, thickZ, -22, false, sk.blade, 0.08)

	-- 先端の鋭い曲線Bowieティップ
	addWedgeXY("blade", "blade", 0.228, 0.89, 0.155, 0.26, thickZ, -32, false, sk.blade, 0.08)
	addWedgeXY("blade", "blade", 0.308, 1.00, 0.085, 0.17, thickZ, -52, false, sk.blade, 0.08)

	-- 左側の鋭い白銀エッジライン（カーブに沿って綺麗に光る刃先）
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

	buildBlade(sk)
	buildHandle("safe", 1, sk)
	buildHandle("bite", -1, sk)

	-- 画像のようなシンプル＆クリーンなダークアーム（右下から斜めに伸びる腕）
	regPart("arm", "arm", Vector3.new(0.42, 0.42, 1.65), Color3.fromRGB(20, 22, 26),
		CFrame.new(0.24, -0.44, 0.72) * CFrame.Angles(math.rad(-14), math.rad(22), math.rad(-16)))

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
	if not enabled or not model then return end
	local cam = workspace.CurrentCamera
	if not cam then return end
	if model.Parent ~= cam then
		model.Parent = cam
	end

	if lastCameraCF then
		local rel = lastCameraCF:ToObjectSpace(cam.CFrame)
		local _, ry, rx = rel:ToEulerAnglesYXZ()
		swayOffset = swayOffset:Lerp(Vector2.new(math.clamp(ry * 2.2, -0.12, 0.12), math.clamp(rx * 2.2, -0.10, 0.10)), math.clamp(dt * 12, 0, 1))
	end
	lastCameraCF = cam.CFrame

	local char = Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local speed = (hum and hum.MoveDirection.Magnitude > 0.05) and 1 or 0
	if speed > 0 then
		walkBob += dt * 9.5
	end
	local bobX = math.cos(walkBob) * 0.020 * speed
	local bobY = math.abs(math.sin(walkBob)) * 0.022 * speed
	local breath = math.sin(os.clock() * 1.8) * 0.006

	animTime += dt
	-- 画像そのままのV字オープンポーズ
	local safeAngle = math.rad(46)
	local biteAngle = math.rad(-2)
	local bladeAngle = math.rad(-24)
	local extraHandCF = CFrame.identity

	if animMode == "equip" then
		local t = math.clamp(animTime / 0.55, 0, 1)
		local e = 1 - (1 - t) ^ 3
		bladeAngle = math.rad(-180 * (1 - e) - 24 * e)
		safeAngle = math.rad(195 * (1 - e) + 46 * e)
		biteAngle = math.rad(140 * math.sin(t * math.pi) - 2 * e)
		extraHandCF = CFrame.new(0, -0.22 * (1 - e), 0.22 * (1 - e))
			* CFrame.Angles(math.rad(-28 * (1 - e)), 0, math.rad(22 * math.sin(t * math.pi)))
		if t >= 1 then animMode = "idle" end

	elseif animMode == "inspect" then
		local dur = 1.35
		local t = math.clamp(animTime / dur, 0, 1)
		local spin = math.sin(t * math.pi)
		local easeT = t < 0.5 and (2 * t * t) or (1 - (-2 * t + 2) ^ 2 / 2)
		bladeAngle = math.rad(-24 + 360 * easeT)
		safeAngle = math.rad(46 + 360 * t)
		biteAngle = math.rad(-2 - 360 * t)
		extraHandCF = CFrame.new(-0.12 * spin, 0.10 * spin, -0.06 * spin)
			* CFrame.Angles(math.rad(14 * spin), math.rad(24 * spin), math.rad(20 * spin))
		if t >= 1 then animMode = "idle" end

	elseif animMode == "slash" then
		local dur = 0.34
		local t = math.clamp(animTime / dur, 0, 1)
		local swing = math.sin(t * math.pi)
		extraHandCF = CFrame.new(-0.46 * swing, 0.08 * swing, -0.22 * swing)
			* CFrame.Angles(math.rad(-26 * swing), math.rad(42 * swing), math.rad(34 * swing))
		safeAngle = math.rad(46 - 18 * swing)
		if t >= 1 then animMode = "idle" end
	end

	-- 画面内に収まりつつ右下構図になるカメラオフセット
	local baseCamCF = CFrame.new(0.58 + swayOffset.X + bobX, -0.20 + swayOffset.Y - bobY + breath, offsetZ)
		* CFrame.Angles(math.rad(-6), math.rad(-18), math.rad(-10))
		* extraHandCF

	local handRoot = cam.CFrame * baseCamCF
	local bladeRoot = handRoot * CFrame.Angles(0, 0, bladeAngle)
	local safeRoot = handRoot * CFrame.Angles(0, 0, safeAngle)
	local biteRoot = bladeRoot * CFrame.new(0.15 * knifeScale, 0, 0) * CFrame.Angles(0, 0, biteAngle)

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