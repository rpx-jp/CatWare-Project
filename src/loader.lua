local DEV_MODE = true
local BASE_URL = DEV_MODE
	and "http://127.0.0.1:3000/"
	or "https://raw.githubusercontent.com/rpx-jp/CatWare-Project/main/"

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

local Assets = import("src/utils/assets.lua")
if Assets and Assets.SetBaseUrl then
	Assets.SetBaseUrl(BASE_URL)
end

local CatWare = {
	Version = "2.0",
	BaseUrl = BASE_URL,
	Import = import,
	Assets = Assets,
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

print("[CatWare] Loaded v" .. CatWare.Version .. " (" .. BASE_URL .. ")")