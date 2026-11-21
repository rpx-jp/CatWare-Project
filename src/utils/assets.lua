local Assets = {}

local FOLDER = "catware"
local ASSETS_DIR = FOLDER .. "/assets"
local baseRaw = "http://127.0.0.1:3000/src/assets/"

function Assets.SetBaseUrl(baseUrl)
	baseRaw = baseUrl .. "src/assets/"
end

local function ensureFolders()
	if not isfolder(FOLDER) then
		makefolder(FOLDER)
	end
	if not isfolder(ASSETS_DIR) then
		makefolder(ASSETS_DIR)
	end
end

local function isValidData(fileName, data)
	if type(data) ~= "string" or #data < 16 then
		return false
	end
	if fileName:match("%.rbxm") then
		return data:sub(1, 7) == "<roblox"
	elseif fileName:match("%.png$") then
		return data:sub(2, 4) == "PNG"
	end
	return true
end

function Assets.Get(fileName, forceReload)
	ensureFolders()
	local path = ASSETS_DIR .. "/" .. fileName

	if isfile(path) then
		local okRead, existing = pcall(readfile, path)
		if not okRead or not isValidData(fileName, existing) then
			pcall(delfile, path)
		end
	end

	if forceReload or not isfile(path) then
		local ok, data = pcall(function()
			return game:HttpGet(baseRaw .. fileName .. "?t=" .. tostring(os.time()))
		end)
		if ok and isValidData(fileName, data) then
			writefile(path, data)
		else
			warn("[CatWare] アセット取得失敗: " .. fileName)
			return ""
		end
	end

	return getcustomasset(path)
end

function Assets.ClearCache()
	for _, name in ipairs({
		"cw.png", "cwmini.png", "glow.png", "shadow.png",
		"stage_bg.png", "stage_glass.png", "stage_aurora.png", "stage_shadow.png",
		"dock_bg.png", "dock_glass.png", "dock_shadow.png", "dock_pill.png",
		"ui_modern.png", "ui_classic.png",
		"karambit.rbxm", "butterfly.rbxm", "katana.rbxm",
	}) do
		local path = ASSETS_DIR .. "/" .. name
		if isfile(path) then
			pcall(delfile, path)
		end
	end
end

return Assets