local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Knife = {}

Knife.Skins = {
	{ name = "Emerald",  blade = Color3.fromRGB(0, 170, 95),   edge = Color3.fromRGB(232, 248, 240), handle = Color3.fromRGB(22, 24, 28) },
	{ name = "Crimson",  blade = Color3.fromRGB(205, 36, 56),  edge = Color3.fromRGB(252, 232, 235), handle = Color3.fromRGB(22, 22, 26) },
	{ name = "Sapphire", blade = Color3.fromRGB(32, 138, 240), edge = Color3.fromRGB(230, 244, 255), handle = Color3.fromRGB(20, 24, 30) },
	{ name = "Gold",     blade = Color3.fromRGB(235, 185, 55), edge = Color3.fromRGB(255, 248, 220), handle = Color3.fromRGB(24, 24, 26) },
	{ name = "Whiteout", blade = Color3.fromRGB(236, 240, 246),edge = Color3.fromRGB(255, 255, 255), handle = Color3.fromRGB(48, 52, 60) },
}

local enabled = false
local skinIdx = 1
local knifeScale = 1.0
local offsetZ = -1.55

local model = nil
local partsList = {} -- { part = BasePart, baseSize = Vector3, group = string, localCF = CFrame, role = string }
local renderConn = nil
local inputConn = nil

local animMode = "idle" -- "equip" | "inspect" | "slash" | "idle"
local animTime = 0
local swayOffset = Vector2.zero
local walkBob = 0
local lastCameraCF = nil

local function makePart(parent, name, size, color, material, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Shape = shape or Enum.PartType.Block
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

local function regPart(group, role, size, color, material, localCF, shape)
	local p = makePart(model, group .. "_" .. role, size * knifeScale, color, material, shape)
	table.insert(partsList, {
		part = p,
		baseSize = size,
		group = group,
		role = role,
		localCF = localCF,
	})
	return p
end

local function applySkin()
	local sk = Knife.Skins[skinIdx]
	for _, item in ipairs(partsList) do
		if item.role == "blade" or item.role == "inlay" then
			item.part.Color = sk.blade
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
	local SILVER = Color3.fromRGB(235, 240, 245)
	local ARM_COL = Color3.fromRGB(18, 20, 24)
	local HAND_COL = Color3.fromRGB(26, 28, 34)

	-- ==========================================
	-- 1. ブレード（Bowie / Clip-Point 形状）
	-- ==========================================
	regPart("blade", "blade", Vector3.new(0.18, 0.16, 0.032), sk.blade, Enum.Material.Metal,
		CFrame.new(0.07, 0.06, 0))
	regPart("blade", "blade", Vector3.new(0.08, 0.06, 0.028), sk.blade, Enum.Material.Metal,
		CFrame.new(-0.04, 0.10, 0) * CFrame.Angles(0, 0, math.rad(20)))
	regPart("blade", "blade", Vector3.new(0.17, 0.56, 0.024), sk.blade, Enum.Material.Metal,
		CFrame.new(0.09, 0.39, 0) * CFrame.Angles(0, 0, math.rad(-5)))
	regPart("blade", "blade", Vector3.new(0.13, 0.42, 0.022), sk.blade, Enum.Material.Metal,
		CFrame.new(0.15, 0.80, 0) * CFrame.Angles(0, 0, math.rad(-18)))

	-- 刃先の白銀ハイライト
	regPart("blade", "edge", Vector3.new(0.030, 0.56, 0.026), sk.edge, Enum.Material.SmoothPlastic,
		CFrame.new(0.008, 0.40, 0) * CFrame.Angles(0, 0, math.rad(-5)))
	regPart("blade", "edge", Vector3.new(0.026, 0.41, 0.024), sk.edge, Enum.Material.SmoothPlastic,
		CFrame.new(0.085, 0.81, 0) * CFrame.Angles(0, 0, math.rad(-18)))

	-- ==========================================
	-- 2. セーフハンドル（左：手で握る側）
	-- ==========================================
	regPart("safe", "pin", Vector3.new(0.056, 0.056, 0.064), SILVER, Enum.Material.SmoothPlastic,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(45)))
	regPart("safe", "handle", Vector3.new(0.125, 0.46, 0.050), sk.handle, Enum.Material.SmoothPlastic,
		CFrame.new(-0.02, -0.22, 0) * CFrame.Angles(0, 0, math.rad(-4)))
	regPart("safe", "handle", Vector3.new(0.118, 0.48, 0.050), sk.handle, Enum.Material.SmoothPlastic,
		CFrame.new(-0.10, -0.65, 0) * CFrame.Angles(0, 0, math.rad(-14)))
	regPart("safe", "handle", Vector3.new(0.145, 0.12, 0.050), sk.handle, Enum.Material.SmoothPlastic,
		CFrame.new(-0.18, -0.89, 0) * CFrame.Angles(0, 0, math.rad(-22)))
	regPart("safe", "pin", Vector3.new(0.042, 0.042, 0.056), SILVER, Enum.Material.SmoothPlastic,
		CFrame.new(-0.17, -0.87, 0) * CFrame.Angles(0, 0, math.rad(45)))

	-- セーフハンドル・カラーインレイ
	regPart("safe", "inlay", Vector3.new(0.048, 0.34, 0.054), sk.blade, Enum.Material.SmoothPlastic,
		CFrame.new(-0.02, -0.23, 0) * CFrame.Angles(0, 0, math.rad(-4)))
	regPart("safe", "inlay", Vector3.new(0.046, 0.36, 0.054), sk.blade, Enum.Material.SmoothPlastic,
		CFrame.new(-0.10, -0.64, 0) * CFrame.Angles(0, 0, math.rad(-14)))

	-- ==========================================
	-- 3. バイトハンドル（右：回転する側）
	-- ==========================================
	regPart("bite", "pin", Vector3.new(0.056, 0.056, 0.064), SILVER, Enum.Material.SmoothPlastic,
		CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(45)))
	regPart("bite", "handle", Vector3.new(0.125, 0.46, 0.050), sk.handle, Enum.Material.SmoothPlastic,
		CFrame.new(0.02, -0.22, 0) * CFrame.Angles(0, 0, math.rad(4)))
	regPart("bite", "handle", Vector3.new(0.118, 0.48, 0.050), sk.handle, Enum.Material.SmoothPlastic,
		CFrame.new(0.10, -0.65, 0) * CFrame.Angles(0, 0, math.rad(14)))
	regPart("bite", "handle", Vector3.new(0.145, 0.12, 0.050), sk.handle, Enum.Material.SmoothPlastic,
		CFrame.new(0.18, -0.89, 0) * CFrame.Angles(0, 0, math.rad(22)))
	regPart("bite", "pin", Vector3.new(0.042, 0.042, 0.056), SILVER, Enum.Material.SmoothPlastic,
		CFrame.new(0.17, -0.87, 0) * CFrame.Angles(0, 0, math.rad(45)))

	-- バイトハンドル・カラーインレイ
	regPart("bite", "inlay", Vector3.new(0.048, 0.34, 0.054), sk.blade, Enum.Material.SmoothPlastic,
		CFrame.new(0.02, -0.23, 0) * CFrame.Angles(0, 0, math.rad(4)))
	regPart("bite", "inlay", Vector3.new(0.046, 0.36, 0.054), sk.blade, Enum.Material.SmoothPlastic,
		CFrame.new(0.10, -0.64, 0) * CFrame.Angles(0, 0, math.rad(14)))

	-- ==========================================
	-- 4. 腕＆手（右下からの一人称アーム）
	-- ==========================================
	regPart("arm", "arm", Vector3.new(0.42, 0.42, 1.55), ARM_COL, Enum.Material.SmoothPlastic,
		CFrame.new(0.20, -0.52, 0.68) * CFrame.Angles(math.rad(-14), math.rad(16), math.rad(-12)))
	regPart("arm", "hand", Vector3.new(0.28, 0.24, 0.34), HAND_COL, Enum.Material.SmoothPlastic,
		CFrame.new(0.06, -0.42, 0.06) * CFrame.Angles(math.rad(-6), math.rad(10), math.rad(-8)))

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

	-- カメラ回転から自然なスウェイを計算
	if lastCameraCF then
		local rel = lastCameraCF:ToObjectSpace(cam.CFrame)
		local _, ry, rx = rel:ToEulerAnglesYXZ()
		swayOffset = swayOffset:Lerp(Vector2.new(math.clamp(ry * 2.4, -0.14, 0.14), math.clamp(rx * 2.4, -0.12, 0.12)), math.clamp(dt * 12, 0, 1))
	end
	lastCameraCF = cam.CFrame

	-- 移動時の歩行ボブ
	local char = Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local speed = (hum and hum.MoveDirection.Magnitude > 0.05) and 1 or 0
	if speed > 0 then
		walkBob += dt * 9.5
	end
	local bobX = math.cos(walkBob) * 0.025 * speed
	local bobY = math.abs(math.sin(walkBob)) * 0.028 * speed
	local breath = math.sin(os.clock() * 1.8) * 0.008

	-- 各関節の角度＆手首のポーズ
	animTime += dt
	local safeAngle = math.rad(34)   -- 画像のように左ハンドルが少し開いた構え
	local biteAngle = math.rad(-14)  -- 右ハンドルは腕に沿う構え
	local bladeAngle = math.rad(-12)
	local extraHandCF = CFrame.identity

	if animMode == "equip" then
		local t = math.clamp(animTime / 0.55, 0, 1)
		local e = 1 - (1 - t) ^ 3
		bladeAngle = math.rad(-180 * (1 - e) - 12 * e)
		safeAngle = math.rad(190 * (1 - e) + 34 * e)
		biteAngle = math.rad(150 * math.sin(t * math.pi) - 14 * e)
		extraHandCF = CFrame.new(0, -0.25 * (1 - e), 0.25 * (1 - e))
			* CFrame.Angles(math.rad(-35 * (1 - e)), 0, math.rad(25 * math.sin(t * math.pi)))
		if t >= 1 then animMode = "idle" end

	elseif animMode == "inspect" then
		local dur = 1.35
		local t = math.clamp(animTime / dur, 0, 1)
		local spin = math.sin(t * math.pi)
		-- バタフライナイフを回してキャッチするトリック
		bladeAngle = math.rad(-12 + 360 * (t < 0.5 and (2 * t * t) or (1 - (-2 * t + 2) ^ 2 / 2)))
		safeAngle = math.rad(34 + 360 * t)
		biteAngle = math.rad(-14 - 360 * t)
		extraHandCF = CFrame.new(-0.14 * spin, 0.12 * spin, -0.08 * spin)
			* CFrame.Angles(math.rad(18 * spin), math.rad(28 * spin), math.rad(24 * spin))
		if t >= 1 then animMode = "idle" end

	elseif animMode == "slash" then
		local dur = 0.34
		local t = math.clamp(animTime / dur, 0, 1)
		local swing = math.sin(t * math.pi)
		extraHandCF = CFrame.new(-0.45 * swing, 0.08 * swing, -0.22 * swing)
			* CFrame.Angles(math.rad(-28 * swing), math.rad(42 * swing), math.rad(36 * swing))
		safeAngle = math.rad(34 - 16 * swing)
		if t >= 1 then animMode = "idle" end
	end

	-- カメラ基準のベース配置（画像の右下構図に合わせる）
	local baseCamCF = CFrame.new(0.76 + swayOffset.X + bobX, -0.44 + swayOffset.Y - bobY + breath, offsetZ)
		* CFrame.Angles(math.rad(-8), math.rad(-20), math.rad(-14))
		* extraHandCF

	local handRoot = cam.CFrame * baseCamCF

	-- 関節CFrame計算
	local bladeRoot = handRoot * CFrame.Angles(0, 0, bladeAngle)
	local safeRoot = handRoot * CFrame.Angles(0, 0, safeAngle)
	local biteRoot = bladeRoot * CFrame.new(0.14 * knifeScale, 0, 0) * CFrame.Angles(0, 0, biteAngle)
	local armRoot = handRoot

	local roots = {
		blade = bladeRoot,
		safe = safeRoot,
		bite = biteRoot,
		arm = armRoot,
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