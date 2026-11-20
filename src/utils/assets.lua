local Assets = {}

local FOLDER = "catware"
local ASSETS_DIR = FOLDER .. "/assets"
local BASE_RAW = "https://raw.githubusercontent.com/rpx-jp/CatWare-Project/main/src/assets/"

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
			return game:HttpGet(BASE_RAW .. fileName)
		end)
		if ok and data and #data > 0 then
			writefile(path, data)
		else
			warn("[CatWare] 画像のダウンロードに失敗: " .. fileName)
			return ""
		end
	end

	return getcustomasset(path)
end

return Assets