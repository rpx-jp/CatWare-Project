local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knife = {}

Knife.Skins = {
	{
		name = "Emerald",
		blade = Color3.fromRGB(0, 168, 92),
		fuller = Color3.fromRGB(0, 115, 62),
		edge = Color3.fromRGB(232, 248, 240),
		handle = Color3.fromRGB(22, 24, 28),
	},
	{
		name = "Crimson",
		blade = Color3.fromRGB(200, 32, 52),
		fuller = Color3.fromRGB(130, 18, 32),
		edge = Color3.fromRGB(252, 232, 235),
		handle = Color3.fromRGB(22, 22, 26),
	},
	{
		name = "Sapphire",
		blade = Color3.fromRGB(28, 132, 238),
		fuller = Color3.fromRGB(16, 82, 165),
		edge = Color3.fromRGB(230, 244, 255),
		handle = Color3.fromRGB(20, 24, 30),
	},
	{
		name = "Gold",
		blade = Color3.fromRGB(232, 182, 52),
		fuller = Color3.fromRGB(165, 122, 24),
		edge = Color3.fromRGB(255, 248, 222),
		handle = Color3.fromRGB(24, 24, 26),
	},
	{
		name = "Whiteout",
		blade = Color3.fromRGB(236, 240, 246),
		fuller = Color3.fromRGB(190, 198, 210),
		edge = Color3.fromRGB(255, 255, 255),
		handle = Color3.fromRGB(48, 52, 60),
	},
}

local enabled = false
local skinIdx = 1
local knifeScale = 1.0
local offsetZ = -1.55

local model = nil
local partsList = {}
local fingerParts = {}
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

local function regPart(group, role, size, color, material, localCF, opts)
	opts = opts or {}
	local p = makePart(
		model,
		group .. "_" .. role,
		opts.className,
		size * knifeScale,
		color,
		material,
		opts.reflectance,
		opts.shape
	)
	local entry = {
		part = p,
		baseSize = size,
		group = group,
		role = role,
		localCF = localCF,
	}
	table.insert(partsList, entry)
	return entry
end

-- 2点を滑らかに繋ぐセグメント＋丸ジョイント
local function addCurvedSegment(group, role, p1, p2, w, thickZ, color, material, reflectance, capStart, capEnd)
	local delta = p2 - p1
	local len = delta.Magnitude
	local mid = (p1 + p2) * 0.5
	local ang = math.atan2(delta.Y, delta.X) - math.rad(90)
	local rot = CFrame.Angles(0, 0, ang)

	regPart(group, role, Vector3.new(w, len, thickZ), color, material,
		CFrame.new(mid.X, mid.Y, 0) * rot, { reflectance = reflectance })

	if capStart then
		regPart(group, role, Vector3.new(thickZ, w, w), color, material,
			CFrame.new(p1.X, p1.Y, 0) * CFrame.Angles(0, math.rad(90), 0),
			{ shape = Enum.PartType.Cylinder, reflectance = reflectance })
	end
	if capEnd then
		regPart(group, role, Vector3.new(thickZ, w, w), color, material,
			CFrame.new(p2.X, p2.Y, 0) * CFrame.Angles(0, math.rad(90), 0),
			{ shape = Enum.PartType.Cylinder, reflectance = reflectance })
	end
end

-- 精密ピボットネジ（台座＋ボルト＋十字溝）
local function addPivotScrew(group, x, y, thickZ, pinDia)
	local WASHER = Color3.fromRGB(50, 54, 62)
	local STEEL = Color3.fromRGB(228, 234, 242)
	local SLOT = Color3.fromRGB(32, 34, 40)

	regPart(group, "hardware", Vector3.new(thickZ + 0.004, pinDia * 1.45, pinDia * 1.45), WASHER, Enum.Material.Metal,
		CFrame.new(x, y, 0) * CFrame.Angles(0, math.rad(90), 0), { shape = Enum.PartType.Cylinder, reflectance = 0.15 })
	regPart(group, "pin", Vector3.new(thickZ + 0.008, pinDia, pinDia), STEEL, Enum.Material.Metal,
		CFrame.new(x, y, 0) * CFrame.Angles(0, math.rad(90), 0), { shape = Enum.PartType.Cylinder, reflectance = 0.35 })
	regPart(group, "hardware", Vector3.new(pinDia * 0.55, pinDia * 0.14, thickZ + 0.011), SLOT, Enum.Material.SmoothPlastic,
		CFrame.new(x, y, 0) * CFrame.Angles(0, 0, math.rad(45)))
	regPart(group, "hardware", Vector3.new(pinDia * 0.14, pinDia * 0.55, thickZ + 0.011), SLOT, Enum.Material.SmoothPlastic,
		CFrame.new(x, y, 0) * CFrame.Angles(0, 0, math.rad(45)))
end

-- 曲線ハンドル一式を構築（左右ミラー対応）
local function buildHandle(group, dirX, sk)
	local pts = {
		Vector2.new(0.000 * dirX,  0.000),
		Vector2.new(-0.014 * dirX, -0.175),
		Vector2.new(-0.044 * dirX, -0.365),
		Vector2.new(-0.092 * dirX, -0.560),
		Vector2.new(-0.158 * dirX, -0.745),
		Vector2.new(-0.228 * dirX, -0.895),
	}
	local widths = { 0.118, 0.112, 0.106, 0.106, 0.122 }
	local thickZ = 0.052

	-- 継ぎ目ゼロの曲線フレーム
	for i = 1, #pts - 1 do
		addCurvedSegment(group, "handle", pts[i], pts[i + 1], widths[i], thickZ,
			sk.handle, Enum.Material.SmoothPlastic, 0.04, true, i == (#pts - 1))
	end

	-- 先端のフレアキャップ
	local tail = pts[#pts]
	local prev = pts[#pts - 1]
	local tailAng = math.atan2(tail.Y - prev.Y, tail.X - prev.X) - math.rad(90)
	regPart(group, "handle", Vector3.new(0.148, 0.052, thickZ), sk.handle, Enum.Material.SmoothPlastic,
		CFrame.new(tail.X, tail.Y, 0) * CFrame.Angles(0, 0, tailAng))

	-- カラーインレイ（両端が丸いカプセル型）
	local inlayPts = {
		Vector2.new(-0.020 * dirX, -0.210),
		Vector2.new(-0.050 * dirX, -0.385),
		Vector2.new(-0.098 * dirX, -0.575),
		Vector2.new(-0.148 * dirX, -0.715),
	}
	for i = 1, #inlayPts - 1 do
		addCurvedSegment(group, "inlay", inlayPts[i], inlayPts[i + 1], 0.044, thickZ + 0.006,
			sk.blade, Enum.Material.Metal, 0.16, i == 1, true)
	end

	-- 上下ピボットネジ
	addPivotScrew(group, 0, 0, thickZ, 0.052)
	addPivotScrew(group, tail.X + 0.015 * dirX, tail.Y + 0.022, thickZ, 0.036)

	-- バイトハンドル側のT字ラッチ
	if group == "bite" then
		local STEEL = Color3.fromRGB(210, 218, 228)
		regPart(group, "pin", Vector3.new(0.022, 0.11, 0.022), STEEL, Enum.Material.Metal,
			CFrame.new(tail.X + 0.045, tail.Y - 0.055, 0) * CFrame.Angles(0, 0, math.rad(28)), { reflectance = 0.3 })
		regPart(group, "pin", Vector3.new(0.048, 0.020, 0.026), STEEL, Enum.Material.Metal,
			CFrame.new(tail.X + 0.068, tail.Y - 0.102, 0) * CFrame.Angles(0, 0, math.rad(28)), { reflectance = 0.3 })
	end
end

local function applySkin()
	local sk = Knife.Skins[skinIdx]
	for _, item in ipairs(partsList) do
		if item.role == "blade" or item.role == "inlay" then
			item.part.Color = sk.blade
		elseif item.role == "fuller" then
			item.part.Color = sk.fuller
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
	fingerParts = {}

	model = Instance.new("Model")
	model.Name = "CatWare_KnifeViewmodel"

	local sk = Knife.Skins[skinIdx]
	local ARM_COL = Color3.fromRGB(20, 22, 26)
	local GLOVE_COL = Color3.fromRGB(30, 33, 39)
	local KNUCKLE_COL = Color3.fromRGB(42, 46, 54)

	-- ==========================================
	-- 1. Bowie / Clip-Point ブレード（Wedge + 曲線ベベル）
	-- ==========================================
	-- タング（2つのピボットを繋ぐ基部）
	regPart("blade", "blade", Vector3.new(0.14, 0.115, 0.028), sk.blade, Enum.Material.Metal,
		CFrame.new(0.07, 0.01, 0), { reflectance = 0.16 })
	regPart("blade", "blade", Vector3.new(0.028, 0.115, 0.115), sk.blade, Enum.Material.Metal,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0), { shape = Enum.PartType.Cylinder, reflectance = 0.16 })
	regPart("blade", "blade", Vector3.new(0.028, 0.115, 0.115), sk.blade, Enum.Material.Metal,
		CFrame.new(0.14, 0, 0) * CFrame.Angles(0, math.rad(90), 0), { shape = Enum.PartType.Cylinder, reflectance = 0.16 })

	-- 根元のガードホーン（左側の小さな突起）
	regPart("blade", "blade", Vector3.new(0.024, 0.065, 0.075), sk.blade, Enum.Material.Metal,
		CFrame.new(-0.048, 0.088, 0) * CFrame.Angles(0, math.rad(-90), math.rad(25)),
		{ className = "WedgePart", reflectance = 0.16 })

	-- 刃の背（スパイン・緩やかなカーブ）
	regPart("blade", "blade", Vector3.new(0.11, 0.44, 0.024), sk.blade, Enum.Material.Metal,
		CFrame.new(0.115, 0.30, 0) * CFrame.Angles(0, 0, math.rad(-6)), { reflectance = 0.18 })
	-- 刃先方向への緩やかな曲線胴（Sphereを薄く潰して滑らかな弧を作る）
	regPart("blade", "blade", Vector3.new(0.19, 0.62, 0.025), sk.blade, Enum.Material.Metal,
		CFrame.new(0.085, 0.43, 0) * CFrame.Angles(0, 0, math.rad(-10)),
		{ shape = Enum.PartType.Ball, reflectance = 0.22 })

	-- クリップポイントの鋭い先端（WedgePart 2枚で尖った刃先を形成）
	regPart("blade", "blade", Vector3.new(0.022, 0.46, 0.135), sk.blade, Enum.Material.Metal,
		CFrame.new(0.155, 0.72, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(16), 0, 0),
		{ className = "WedgePart", reflectance = 0.20 })
	-- 刃の背のクリップ（えぐれ）
	regPart("blade", "fuller", Vector3.new(0.020, 0.28, 0.045), sk.fuller, Enum.Material.Metal,
		CFrame.new(0.158, 0.34, 0) * CFrame.Angles(0, 0, math.rad(-7)), { reflectance = 0.12 })

	-- 銀白の鋭い刃先ハイライト（カーブに沿って配置）
	regPart("blade", "edge", Vector3.new(0.018, 0.56, 0.027), sk.edge, Enum.Material.Metal,
		CFrame.new(0.016, 0.38, 0) * CFrame.Angles(0, 0, math.rad(-11)),
		{ shape = Enum.PartType.Ball, reflectance = 0.40 })
	regPart("blade", "edge", Vector3.new(0.024, 0.46, 0.022), sk.edge, Enum.Material.Metal,
		CFrame.new(0.118, 0.72, 0) * CFrame.Angles(0, math.rad(90), 0) * CFrame.Angles(math.rad(16), 0, 0),
		{ className = "WedgePart", reflectance = 0.42 })

	-- ==========================================
	-- 2. セーフ & バイト 曲線ハンドル
	-- ==========================================
	buildHandle("safe", 1, sk)
	buildHandle("bite", -1, sk)

	-- ==========================================
	-- 3. スリーブ＆タクティカルグローブ（指で握る）
	-- ==========================================
	regPart("arm", "sleeve", Vector3.new(1.50, 0.36, 0.36), ARM_COL, Enum.Material.SmoothPlastic,
		CFrame.new(0.24, -0.54, 0.74) * CFrame.Angles(math.rad(14), math.rad(74), math.rad(-10)),
		{ shape = Enum.PartType.Cylinder })
	-- 手首カフ
	regPart("arm", "cuff", Vector3.new(0.08, 0.37, 0.37), KNUCKLE_COL, Enum.Material.SmoothPlastic,
		CFrame.new(0.10, -0.44, 0.18) * CFrame.Angles(math.rad(14), math.rad(74), math.rad(-10)),
		{ shape = Enum.PartType.Cylinder })
	-- 手のひら
	regPart("arm", "palm", Vector3.new(0.22, 0.28, 0.30), GLOVE_COL, Enum.Material.SmoothPlastic,
		CFrame.new(0.06, -0.36, 0.04) * CFrame.Angles(math.rad(-8), math.rad(12), math.rad(-10)),
		{ shape = Enum.PartType.Ball })

	-- 握り込む指（4本の指＋親指）
	local fingerHeights = { -0.18, -0.27, -0.36, -0.45 }
	for i, fy in ipairs(fingerHeights) do
		local e = regPart("finger", "f" .. i, Vector3.new(0.18, 0.072, 0.072), GLOVE_COL, Enum.Material.SmoothPlastic,
			CFrame.new(-0.06, fy, -0.02) * CFrame.Angles(0, math.rad(18), math.rad(-12)),
			{ shape = Enum.PartType.Cylinder })
		table.insert(fingerParts, { entry = e, baseCF = e.localCF, idx = i })
	end
	local thumb = regPart("finger", "thumb", Vector3.new(0.19, 0.076, 0.076), KNUCKLE_COL, Enum.Material.SmoothPlastic,
		CFrame.new(0.03, -0.15, -0.05) * CFrame.Angles(math.rad(14), math.rad(-25), math.rad(38)),
		{ shape = Enum.PartType.Cylinder })
	table.insert(fingerParts, { entry = thumb, baseCF = thumb.localCF, isThumb = true })

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
		swayOffset = swayOffset:Lerp(Vector2.new(math.clamp(ry * 2.4, -0.14, 0.14), math.clamp(rx * 2.4, -0.12, 0.12)), math.clamp(dt * 12, 0, 1))
	end
	lastCameraCF = cam.CFrame

	local char = Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local speed = (hum and hum.MoveDirection.Magnitude > 0.05) and 1 or 0
	if speed > 0 then
		walkBob += dt * 9.5
	end
	local bobX = math.cos(walkBob) * 0.022 * speed
	local bobY = math.abs(math.sin(walkBob)) * 0.025 * speed
	local breath = math.sin(os.clock() * 1.8) * 0.007

	animTime += dt
	local safeAngle = math.rad(32)
	local biteAngle = math.rad(-14)
	local bladeAngle = math.rad(-10)
	local gripOpen = 0
	local extraHandCF = CFrame.identity

	if animMode == "equip" then
		local t = math.clamp(animTime / 0.55, 0, 1)
		local e = 1 - (1 - t) ^ 3
		gripOpen = math.sin(t * math.pi)
		bladeAngle = math.rad(-180 * (1 - e) - 10 * e)
		safeAngle = math.rad(190 * (1 - e) + 32 * e)
		biteAngle = math.rad(150 * math.sin(t * math.pi) - 14 * e)
		extraHandCF = CFrame.new(0, -0.24 * (1 - e), 0.24 * (1 - e))
			* CFrame.Angles(math.rad(-32 * (1 - e)), 0, math.rad(24 * math.sin(t * math.pi)))
		if t >= 1 then animMode = "idle" end

	elseif animMode == "inspect" then
		local dur = 1.35
		local t = math.clamp(animTime / dur, 0, 1)
		local spin = math.sin(t * math.pi)
		gripOpen = spin
		local easeT = t < 0.5 and (2 * t * t) or (1 - (-2 * t + 2) ^ 2 / 2)
		bladeAngle = math.rad(-10 + 360 * easeT)
		safeAngle = math.rad(32 + 360 * t)
		biteAngle = math.rad(-14 - 360 * t)
		extraHandCF = CFrame.new(-0.14 * spin, 0.12 * spin, -0.08 * spin)
			* CFrame.Angles(math.rad(16 * spin), math.rad(26 * spin), math.rad(22 * spin))
		if t >= 1 then animMode = "idle" end

	elseif animMode == "slash" then
		local dur = 0.34
		local t = math.clamp(animTime / dur, 0, 1)
		local swing = math.sin(t * math.pi)
		extraHandCF = CFrame.new(-0.46 * swing, 0.08 * swing, -0.22 * swing)
			* CFrame.Angles(math.rad(-26 * swing), math.rad(42 * swing), math.rad(34 * swing))
		safeAngle = math.rad(32 - 14 * swing)
		if t >= 1 then animMode = "idle" end
	end

	-- トリック中は指が少し開いて回転を逃がす
	for _, fp in ipairs(fingerParts) do
		if fp.isThumb then
			fp.entry.localCF = fp.baseCF * CFrame.new(0.05 * gripOpen, 0, -0.04 * gripOpen)
		else
			fp.entry.localCF = fp.baseCF * CFrame.new(0.05 * gripOpen, 0, -0.05 * gripOpen)
				* CFrame.Angles(0, math.rad(-16 * gripOpen), 0)
		end
	end

	local baseCamCF = CFrame.new(0.76 + swayOffset.X + bobX, -0.42 + swayOffset.Y - bobY + breath, offsetZ)
		* CFrame.Angles(math.rad(-8), math.rad(-20), math.rad(-14))
		* extraHandCF

	local handRoot = cam.CFrame * baseCamCF
	local bladeRoot = handRoot * CFrame.Angles(0, 0, bladeAngle)
	local safeRoot = handRoot * CFrame.Angles(0, 0, safeAngle)
	local biteRoot = bladeRoot * CFrame.new(0.14 * knifeScale, 0, 0) * CFrame.Angles(0, 0, biteAngle)

	local roots = {
		blade = bladeRoot,
		safe = safeRoot,
		bite = biteRoot,
		arm = handRoot,
		finger = handRoot,
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
		fingerParts = {}
	end
end

return Knife