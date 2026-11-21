local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- SHOCKWAVES (v2): ジャンプすると足元から地面のブロックが同心円状に隆起して外へ伝わっていく。
-- 1ブロック(3stud)単位のタイルが、中心からの距離に応じた時間差でせり上がり → 沈みながらフェードアウト。
-- API は v1 と互換 (SetEnabled / SetScale / SetColor / IsEnabled) + SetSpeed / SetTrigger を追加。
local Shockwave = {}

local BLOCK = 3 -- 1ブロック = 3 stud
local MAX_ACTIVE = 700 -- 同時に存在できるタイル数の上限 (連続ジャンプ対策)

local enabled = false
local scale = 1.0 -- 衝撃波の規模 (半径にかかる)
local speed = 1.0 -- 伝播スピード
local color = Color3.fromRGB(255, 105, 180)
local tintMix = 0.7 -- 0 = 地面の色そのまま / 1 = 指定色
local triggerJump, triggerLand = true, false

local connections = {}
local charConns = {}
local folder = nil
local active = {} -- { part, t0, delay, life, base, lift, startT }
local pool = {}
local heartbeat = nil

local function getFolder()
	if not folder or not folder.Parent then
		folder = Instance.new("Folder")
		folder.Name = "CatWareShockwaves"
		folder.Parent = workspace
	end
	return folder
end

local function acquire()
	local part = table.remove(pool)
	if part then
		return part
	end
	part = Instance.new("Part")
	part.Name = "ShockwaveTile"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function release(part)
	part.Parent = nil
	if #pool < 400 then
		table.insert(pool, part)
	else
		part:Destroy()
	end
end

-- ===== 毎フレームの更新 (タイル1枚ごとの Tween はやめて1ループで処理) =====
local function easeOutQuad(x)
	return 1 - (1 - x) * (1 - x)
end

local function step()
	local now = os.clock()
	local i = 1
	while i <= #active do
		local a = active[i]
		local age = now - a.t0 - a.delay
		local part = a.part
		if age < 0 then
			i += 1
		elseif age >= a.life then
			release(part)
			active[i] = active[#active]
			active[#active] = nil
		else
			if part.Parent == nil then
				part.Parent = getFolder()
			end
			local u = age / a.life
			-- 前半 28% でぐっとせり上がり、残りでゆっくり沈みつつ透明に
			local rise = 0.28
			local h
			if u < rise then
				h = easeOutQuad(u / rise)
			else
				local d = (u - rise) / (1 - rise)
				h = 1 - d * d
			end
			local y = a.lift * h
			part.CFrame = CFrame.new(a.base + Vector3.new(0, y + a.thick / 2, 0))
			local fade = u < rise and 0 or ((u - rise) / (1 - rise))
			part.Transparency = a.startT + (1 - a.startT) * fade * fade
			i += 1
		end
	end
	if #active == 0 and heartbeat then
		heartbeat:Disconnect()
		heartbeat = nil
	end
end

local function ensureLoop()
	if not heartbeat then
		heartbeat = RunService.Heartbeat:Connect(step)
	end
end

-- ===== 衝撃波の生成 =====
local function spawnShockwave(rootPart, groundHint)
	if not enabled then
		return
	end

	local character = rootPart.Parent
	local f = getFolder()

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, f }

	-- 足元の地面
	local origin = rootPart.Position
	local center = workspace:Raycast(origin, Vector3.new(0, -12, 0), params)
	local centerPos = center and center.Position or groundHint
	if not centerPos then
		return
	end

	local radius = math.clamp(math.floor(5 * scale + 0.5), 2, 12) -- ブロック数
	local stepDelay = 0.05 / speed -- 1リングごとの遅延
	local life = 0.34 / math.sqrt(speed)
	local t0 = os.clock()

	-- プレイヤー足元を原点に、3stud グリッドのセルを走査
	local gx = math.floor(centerPos.X / BLOCK + 0.5) * BLOCK
	local gz = math.floor(centerPos.Z / BLOCK + 0.5) * BLOCK
	local castFromY = centerPos.Y + 4

	local count = 0
	for dx = -radius, radius do
		for dz = -radius, radius do
			local dist = math.sqrt(dx * dx + dz * dz)
			if dist <= radius + 0.25 then
				if #active + count >= MAX_ACTIVE then
					break
				end
				local x = gx + dx * BLOCK
				local z = gz + dz * BLOCK
				local hit = workspace:Raycast(Vector3.new(x, castFromY, z), Vector3.new(0, -12, 0), params)
				if hit and hit.Normal.Y > 0.7 then
					local ring = math.floor(dist + 0.5)
					local falloff = 1 - (dist / (radius + 1)) -- 外側ほど低く
					local thick = 0.9
					local part = acquire()
					local base = hit.Position + Vector3.new(0, 0.03, 0)
					local groundColor = hit.Instance:IsA("BasePart") and hit.Instance.Color or color
					part.Size = Vector3.new(BLOCK - 0.2, thick, BLOCK - 0.2)
					part.Color = groundColor:Lerp(color, tintMix)
					part.Transparency = 1
					part.CFrame = CFrame.new(base + Vector3.new(0, thick / 2, 0))
					-- 親は step() で表示開始時に設定 (delay 中は非表示)
					table.insert(active, {
						part = part,
						t0 = t0,
						delay = ring * stepDelay,
						life = life,
						base = base,
						thick = thick,
						lift = (1.0 + 2.6 * falloff) * (0.7 + 0.3 * scale),
						startT = 0.15 + 0.35 * (1 - falloff),
					})
					count += 1
				end
			end
		end
	end

	if count > 0 then
		ensureLoop()
	end
end

-- ===== トリガー =====
local function clearCharConns()
	for _, c in ipairs(charConns) do
		pcall(function()
			c:Disconnect()
		end)
	end
	charConns = {}
end

local function hookCharacter(character)
	clearCharConns()
	local humanoid = character:WaitForChild("Humanoid", 8)
	local root = character:WaitForChild("HumanoidRootPart", 8)
	if not humanoid or not root then
		return
	end

	table.insert(
		charConns,
		humanoid.StateChanged:Connect(function(old, new)
			if triggerJump and new == Enum.HumanoidStateType.Jumping then
				spawnShockwave(root)
			elseif triggerLand and new == Enum.HumanoidStateType.Landed then
				spawnShockwave(root, root.Position - Vector3.new(0, humanoid.HipHeight + root.Size.Y / 2, 0))
			end
		end)
	)
end

local function stopAll()
	if heartbeat then
		heartbeat:Disconnect()
		heartbeat = nil
	end
	for _, a in ipairs(active) do
		pcall(function()
			a.part:Destroy()
		end)
	end
	active = {}
	for _, p in ipairs(pool) do
		pcall(function()
			p:Destroy()
		end)
	end
	pool = {}
	if folder then
		folder:Destroy()
		folder = nil
	end
end

function Shockwave.SetEnabled(on)
	if enabled == on then
		return
	end
	enabled = on

	for _, c in ipairs(connections) do
		pcall(function()
			c:Disconnect()
		end)
	end
	connections = {}
	clearCharConns()
	stopAll()

	if on then
		local player = Players.LocalPlayer
		if player.Character then
			task.spawn(hookCharacter, player.Character)
		end
		table.insert(connections, player.CharacterAdded:Connect(hookCharacter))
	end
end

function Shockwave.SetScale(val)
	scale = val
end

function Shockwave.SetSpeed(val)
	speed = math.max(0.3, val)
end

function Shockwave.SetColor(c)
	color = c
end

function Shockwave.SetTintMix(v)
	tintMix = math.clamp(v, 0, 1)
end

-- which = "jump" | "land"
function Shockwave.SetTrigger(which, on)
	if which == "jump" then
		triggerJump = on
	elseif which == "land" then
		triggerLand = on
	end
end

-- テスト・手動発火用
function Shockwave.Fire()
	local char = Players.LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		spawnShockwave(root)
	end
end

function Shockwave.IsEnabled()
	return enabled
end

return Shockwave