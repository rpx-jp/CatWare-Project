local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- SHOCKWAVES: ジャンプした時にピンクの半透明ブロックが衝撃波のように段階的に広がる
local Shockwave = {}

local enabled = false
local maxScale = 1.0
local color = Color3.fromRGB(255, 105, 180)
local connections = {}
local folder = nil

local BLOCK = 3 -- このゲームのブロック単位 (3スタッド)

local function getFolder()
	if not folder or not folder.Parent then
		folder = Instance.new("Folder")
		folder.Name = "CatWareShockwaves"
		folder.Parent = workspace
	end
	return folder
end

local function makePart(name, transparency)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Transparency = transparency
	return part
end

local function groundPosition(rootPart)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { rootPart.Parent, getFolder() }

	local hit = workspace:Raycast(rootPart.Position, Vector3.new(0, -10, 0), params)
	if hit then
		return hit.Position
	end
	return rootPart.Position - Vector3.new(0, 3, 0)
end

-- ブロック単位で段階的に広がる半透明の波
local function spawnWave(basePos, maxRadius, startTransparency, stepDelay, lift)
	local f = getFolder()
	local cf = CFrame.new(basePos + Vector3.new(0, 0.06, 0))

	local wave = makePart("ShockwaveWave", startTransparency)
	wave.Size = Vector3.new(BLOCK, 0.4, BLOCK)
	wave.CFrame = cf
	wave.Parent = f

	task.spawn(function()
		local steps = 6
		for i = 1, steps do
			if not enabled or not wave.Parent then
				return
			end
			local size = BLOCK + (maxRadius - BLOCK) * (i / steps)
			size = math.floor(size / BLOCK + 0.5) * BLOCK -- ブロック単位にスナップ
			wave.Size = Vector3.new(size, 0.4, size)
			wave.Transparency = startTransparency + 0.4 * (i / steps)
			wave.CFrame = cf + Vector3.new(0, lift * (i / steps), 0)
			task.wait(stepDelay)
		end
		if wave.Parent then
			TweenService:Create(wave, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Transparency = 1,
			}):Play()
			Debris:AddItem(wave, 0.35)
		end
	end)
end

local function spawnCubeBurst(basePos)
	local f = getFolder()
	local startPos = basePos + Vector3.new(0, 1.4, 0)

	local cube = makePart("ShockwaveCube", 0.35)
	cube.Size = Vector3.new(BLOCK, BLOCK, BLOCK)
	cube.CFrame = CFrame.new(startPos)
	cube.Parent = f

	TweenService:Create(cube, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = Vector3.new(BLOCK * 2.2, BLOCK * 2.2, BLOCK * 2.2) * maxScale,
		Transparency = 1,
		CFrame = CFrame.new(startPos + Vector3.new(0, 1.8, 0)),
	}):Play()

	Debris:AddItem(cube, 0.55)
end

local function spawnShockwave(rootPart)
	if not enabled then return end
	local basePos = groundPosition(rootPart)

	-- 1波目: 地面を覆う半透明ブロック層
	spawnWave(basePos, 24 * maxScale, 0.45, 0.06, 0.25)
	-- 発光キューブのバースト
	spawnCubeBurst(basePos)
	-- 2波目: すこし遅れて追従
	task.delay(0.12, function()
		if not enabled then return end
		spawnWave(basePos, 15 * maxScale, 0.6, 0.07, 0.45)
	end)
end

local function hookCharacter(character)
	local humanoid = character:WaitForChild("Humanoid", 8)
	if not humanoid then return end
	table.insert(connections, humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Jumping then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				spawnShockwave(root)
			end
		end
	end))
end

local function disconnectAll()
	for _, conn in ipairs(connections) do
		pcall(function() conn:Disconnect() end)
	end
	connections = {}
end

function Shockwave.SetEnabled(on)
	if enabled == on then return end
	enabled = on
	disconnectAll()
	if folder then
		folder:Destroy()
		folder = nil
	end
	if on then
		local player = Players.LocalPlayer
		if player.Character then
			hookCharacter(player.Character)
		end
		table.insert(connections, player.CharacterAdded:Connect(hookCharacter))
	end
end

function Shockwave.SetScale(val)
	maxScale = val
end

function Shockwave.SetColor(c)
	color = c
end

function Shockwave.IsEnabled()
	return enabled
end

return Shockwave
