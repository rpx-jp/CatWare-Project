local BASE_URL = "https://raw.githubusercontent.com/rpx-jp/CatWare-Project/main/"

local cache = {}

-- GitHub上のファイルを読み込む共通関数
local function import(path)
	if cache[path] then
		return cache[path]
	end

	local url = BASE_URL .. path
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

-- 他のファイルからも import を使えるようにしたい場合（任意）
local CatWare = {
	Version = "1.0.0",
	Import = import,
}

-- 1. 起動アニメーションを実行
local playStartAnim = import("src/gui/start/init.luau")
if type(playStartAnim) == "function" then
	playStartAnim()
end

-- 2. メインUIなどを作ったらここに追加していく
-- local initMainGui = import("src/gui/main/init.luau")
-- if type(initMainGui) == "function" then
-- 	initMainGui(CatWare)
-- end

print("[CatWare] Loaded v" .. CatWare.Version)