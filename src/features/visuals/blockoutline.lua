local BlockOutline = {}

-- ワールドのブロック(3スタッド単位)に
--  1) 常時ピンクの縁 (SelectionBox)
--  2) 半透明ピンクのカバーでブロックを覆う (テクスチャブロックにも効く・ローカルのみ)
-- の2機能を提供する
local outlineOn = false
local tintOn = false
local color = Color3.fromRGB(255, 105, 180)
local thickness = 0.035
local tintTransparency = 0.55
local boxesByPart = {}
local coversByPart = {}
local tintFolder = nil
local connections = {}

local BLOCK_NAMES = {
	stone = true,
	granite = true,
	cobblestone = true,
	coarse_dirt = true,
	dirt = true,
	andesite = true,
	obsidian = true,
	deepslate = true,
	sand = true,
	red_sand = true,
	gravel = true,
	snow = true,
	ice = true,
	packed_ice = true,
	grass_block = true,
	moss_block = true,
	podzol = true,
	mycelium = true,
	netherrack = true,
	end_stone = true,
	terracotta = true,
	clay = true,
}

local function isTargetPart(part)
	if not part:IsA("BasePart") then return false end
	if part.Transparency >= 0.95 then return false end

	local camera = workspace:FindFirstChild("Camera")
	if camera and part:IsDescendantOf(camera) then return false end

	-- キャラ類は除外
	local char = part:FindFirstAncestorOfClass("Model")
	if char and char:FindFirstChildOfClass("Humanoid") then return false end

	-- 自分のカバーフォルダは除外
	if tintFolder and part:IsDescendantOf(tintFolder) then return false end

	-- 置かれたブロック (Workspace.Blocks 配下)
	local p = part.Parent
	while p and p ~= workspace do
		if p == workspace:FindFirstChild("Blocks") then
			return true
		end
		p = p.Parent
	end

	local name = part.Name
	return BLOCK_NAMES[name] == true or name:match("_block$") ~= nil
end

local function anyActive()
	return outlineOn or tintOn
end

local function applyOutline(part)
	if not outlineOn then return end
	if boxesByPart[part] then return end

	local sb = Instance.new("SelectionBox")
	sb.Name = "CatWareBlockOutline"
	sb.Adornee = part
	sb.LineThickness = thickness
	sb.Color3 = color
	sb.SurfaceTransparency = 1
	sb.Visible = true
	sb.Parent = part
	boxesByPart[part] = sb
end

local function getTintFolder()
	if not tintFolder or not tintFolder.Parent then
		tintFolder = Instance.new("Folder")
		tintFolder.Name = "CatWareBlockTint"
		tintFolder.Parent = workspace
	end
	return tintFolder
end

local function applyTint(part)
	if not tintOn then return end
	if coversByPart[part] then return end

	local cover = Instance.new("Part")
	cover.Name = "CatWareTintCover"
	cover.Anchored = true
	cover.CanCollide = false
	cover.CanQuery = false
	cover.CanTouch = false
	cover.CastShadow = false
	cover.Material = Enum.Material.Neon
	cover.Color = color
	cover.Transparency = tintTransparency
	cover.Size = part.Size * 1.002
	cover.CFrame = part.CFrame
	cover.Parent = getTintFolder()
	coversByPart[part] = cover
end

local function revertTint(part)
	local cover = coversByPart[part]
	if cover then
		coversByPart[part] = nil
		if cover.Parent then
			cover:Destroy()
		end
	end
end

local function detachOutline(part)
	local sb = boxesByPart[part]
	if sb then
		boxesByPart[part] = nil
		if sb.Parent then
			sb:Destroy()
		end
	end
end

local function attach(part)
	if not isTargetPart(part) then return end
	applyOutline(part)
	applyTint(part)
end

local function detach(part)
	detachOutline(part)
	revertTint(part)
end

local function refreshAll()
	if not anyActive() then return end
	for _, d in ipairs(workspace:GetDescendants()) do
		if d:IsA("BasePart") then
			attach(d)
		end
	end
end

local function disconnectAll()
	for _, conn in ipairs(connections) do
		pcall(function() conn:Disconnect() end)
	end
	connections = {}
end

local function ensureMonitors()
	if #connections > 0 then return end
	table.insert(connections, workspace.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then
			-- ゲームが名前・色を設定し終えた後に評価
			task.delay(0.1, attach, d)
		end
	end))
	table.insert(connections, workspace.DescendantRemoving:Connect(function(d)
		if boxesByPart[d] or coversByPart[d] then
			detach(d)
		end
	end))
end

function BlockOutline.SetEnabled(on)
	if outlineOn == on then return end
	outlineOn = on

	if on then
		ensureMonitors()
		refreshAll()
	else
		for part in pairs(boxesByPart) do
			detachOutline(part)
		end
		if not tintOn then
			disconnectAll()
		end
	end
end

function BlockOutline.SetTint(on)
	if tintOn == on then return end
	tintOn = on

	if on then
		ensureMonitors()
		refreshAll()
	else
		for part in pairs(coversByPart) do
			revertTint(part)
		end
		if tintFolder then
			tintFolder:Destroy()
			tintFolder = nil
		end
		if not outlineOn then
			disconnectAll()
		end
	end
end

function BlockOutline.SetColor(c)
	color = c
	for _, sb in pairs(boxesByPart) do
		sb.Color3 = c
	end
	for _, cover in pairs(coversByPart) do
		cover.Color = c
	end
end

function BlockOutline.SetThickness(val)
	thickness = val
	for _, sb in pairs(boxesByPart) do
		sb.LineThickness = val
	end
end

function BlockOutline.SetTintTransparency(val)
	tintTransparency = val
	for _, cover in pairs(coversByPart) do
		cover.Transparency = val
	end
end

function BlockOutline.IsOutlineEnabled()
	return outlineOn
end

function BlockOutline.IsTintEnabled()
	return tintOn
end

function BlockOutline.Count()
	local n = 0
	for _ in pairs(boxesByPart) do
		n += 1
	end
	return n
end

function BlockOutline.TintCount()
	local n = 0
	for _ in pairs(coversByPart) do
		n += 1
	end
	return n
end

return BlockOutline
