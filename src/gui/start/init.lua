local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local FOLDER_NAME = "Luna"
local ASSETS_FOLDER = FOLDER_NAME .. "/assets"
local LOGO_PATH = ASSETS_FOLDER .. "/cw.png"

-- GitHubに上げた cw.png の Raw URL に書き換えてください
local LOGO_URL = "https://raw.githubusercontent.com/ユーザー名/リポジトリ名/main/src/assets/cw.png"

-- 1. フォルダとPNGファイルの保存（初回のみダウンロード）
local function loadLogoAsset(): string
	if not isfolder(FOLDER_NAME) then
		makefolder(FOLDER_NAME)
	end
	if not isfolder(ASSETS_FOLDER) then
		makefolder(ASSETS_FOLDER)
	end

	if not isfile(LOGO_PATH) then
		local pngData = game:HttpGet(LOGO_URL)
		writefile(LOGO_PATH, pngData)
	end

	return getcustomasset(LOGO_PATH)
end

-- 2. 起動アニメーションを再生する関数
local function playStartAnim()
	local logoAsset = loadLogoAsset()

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "LunaStartAnim"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 999
	screenGui.Parent = playerGui

	-- 背景の暗転（不要なら削除OK）
	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	backdrop.BackgroundTransparency = 1
	backdrop.Parent = screenGui

	-- ロゴ画像
	local logo = Instance.new("ImageLabel")
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.Position = UDim2.fromScale(0.5, 0.5)
	logo.Size = UDim2.fromOffset(180, 180) -- 初期サイズ（少し小さめ）
	logo.BackgroundTransparency = 1
	logo.Image = logoAsset
	logo.ImageTransparency = 1
	logo.ScaleType = Enum.ScaleType.Fit
	logo.Parent = screenGui

	-- フェードイン + ポップアップ
	local fadeInInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	TweenService:Create(backdrop, fadeInInfo, { BackgroundTransparency = 0.35 }):Play()
	local logoIn = TweenService:Create(logo, fadeInInfo, {
		ImageTransparency = 0,
		Size = UDim2.fromOffset(230, 230),
	})
	logoIn:Play()
	logoIn.Completed:Wait()

	-- 表示キープ時間
	task.wait(1.0)

	-- フェードアウト
	local fadeOutInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	TweenService:Create(backdrop, fadeOutInfo, { BackgroundTransparency = 1 }):Play()
	local logoOut = TweenService:Create(logo, fadeOutInfo, {
		ImageTransparency = 1,
		Size = UDim2.fromOffset(260, 260),
	})
	logoOut:Play()
	logoOut.Completed:Wait()

	-- 終了後にGUIを削除
	screenGui:Destroy()
end

return playStartAnim