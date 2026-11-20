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

function Assets.Get(fileName)
	ensureFolders()
	local path = ASSETS_DIR .. "/" .. fileName

	if not isfile(path) then
		local ok, data = pcall(function()
			return game:HttpGet(baseRaw .. fileName)
		end)
		if ok and data and #data > 0 then
			writefile(path, data)
		else
			warn("[CatWare] 画像取得失敗: " .. fileName)
			return ""
		end
	end

	return getcustomasset(path)
end

function Assets.ClearCache()
	for _, name in ipairs({
		"cw.png", "cwmini.png", "glow.png", "shadow.png",
		"tile_tl.png", "tile_tr.png", "tile_bl.png", "tile_br.png",
		"tile_stroke_tl.png", "tile_stroke_tr.png", "tile_stroke_bl.png", "tile_stroke_br.png",
		"tile_shadow_tl.png", "tile_shadow_tr.png", "tile_shadow_bl.png", "tile_shadow_br.png",
	}) do
		local path = ASSETS_DIR .. "/" .. name
		if isfile(path) then
			pcall(delfile, path)
		end
	end
end

return Assets