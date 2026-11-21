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
	ActiveUi = "modern",
	ActiveGui = nil,
}

-- ==========================================
-- UI 切り替え (modern = VisionOS / classic = BentoDeck Hub)
-- ==========================================
local UI_PATHS = {
	modern = "src/gui/main/init.lua",
	classic = "src/gui/main/classic.lua",
}

local PREF_FILE = "CatWare_ui.txt"

local function loadUiPref()
	if isfile and readfile and isfile(PREF_FILE) then
		local ok, content = pcall(readfile, PREF_FILE)
		if ok and (content == "modern" or content == "classic") then
			return content
		end
	end
	return nil
end

local function saveUiPref(name)
	if writefile then
		pcall(writefile, PREF_FILE, name)
	end
end

local function loadUi(name)
	local path = UI_PATHS[name] or UI_PATHS.modern
	local initFn = import(path)
	if type(initFn) ~= "function" then
		warn("[CatWare] UI の起動に失敗: " .. path)
		return
	end

	CatWare.ActiveUi = UI_PATHS[name] and name or "modern"
	CatWare.ActiveGui = initFn(CatWare)
end

function CatWare.SwitchUi(name)
	if name == CatWare.ActiveUi and CatWare.ActiveGui then
		return
	end

	saveUiPref(name)

	if CatWare.ActiveGui and CatWare.ActiveGui.Unload then
		pcall(function()
			CatWare.ActiveGui.Unload()
		end)
	end
	CatWare.ActiveGui = nil

	loadUi(name)
end

-- 1. 起動アニメーション
local playStartAnim = import("src/gui/start/init.lua")
if type(playStartAnim) == "function" then
	playStartAnim(CatWare)
end

-- 2. メインGUI起動（保存設定があればそれを使用、初回はUI選択画面を表示）
local savedUi = loadUiPref()
if savedUi then
	loadUi(savedUi)
else
	local chooseUi = import("src/gui/main/choose.lua")
	if type(chooseUi) == "function" then
		chooseUi(CatWare, function(name)
			saveUiPref(name)
			loadUi(name)
		end)
	else
		loadUi("modern")
	end
end

print("[CatWare] Loaded v" .. CatWare.Version .. " (" .. BASE_URL .. ") UI: " .. CatWare.ActiveUi)
