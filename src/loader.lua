local BASE_URL = "https://raw.githubusercontent.com/rpx-jp/CatWare-Project/main/"

local cache = {}

local function import(path)
	if cache[path] then
		return cache[path]
	end

    local url = BASE_URL .. path .. "?t=" .. tostring(os.time())
	local ok, source = pcall(function()
		return game:HttpGet(url)
	end)

	if not ok then
		warn("[CatWare] ダウンロード失敗: " .. path .. " / " .. tostring(source))
		return nil
	end

	local fn, syntaxErr = loadstring(source)
	if not fn then
		warn("[CatWare] 構文エラー: " .. path .. " / " .. tostring(syntaxErr))
		return nil
	end

	local runOk, result = pcall(fn)
	if not runOk then
		warn("[CatWare] 実行エラー: " .. path .. " / " .. tostring(result))
		return nil
	end

	cache[path] = result
	return result
end

local CatWare = {
	Version = "1.0",
	Import = import,
	Assets = import("src/utils/assets.lua"),
	Theme = import("src/utils/theme.lua"),
	Notify = import("src/utils/notify.lua"),
}

-- 1. 起動アニメーション
local playStartAnim = import("src/gui/start/init.lua")
if type(playStartAnim) == "function" then
	playStartAnim(CatWare)
end

-- 2. メインGUI起動
local initMainGui = import("src/gui/main/init.lua")
if type(initMainGui) == "function" then
	initMainGui(CatWare)
end

print("[CatWare] Loaded v" .. CatWare.Version)