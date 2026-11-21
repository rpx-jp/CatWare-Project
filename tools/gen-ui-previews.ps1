# UI選択GUI用のプレビューPNGを生成するスクリプト
# 使い方: powershell -NoProfile -ExecutionPolicy Bypass -File tools\gen-ui-previews.ps1
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$repoRoot = Split-Path -Parent $PSScriptRoot
$assetsDir = Join-Path $repoRoot "src\assets"

# ---- 共通ヘルパー ----
function New-RoundPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
	$p = [System.Drawing.Drawing2D.GraphicsPath]::new()
	$d = $r * 2
	$p.AddArc($x, $y, $d, $d, 180, 90)
	$p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
	$p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
	$p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
	$p.CloseFigure()
	return $p
}

function New-Font([string]$family, [int]$size, [bool]$bold) {
	$style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
	return [System.Drawing.Font]::new($family, [float]$size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-TextL($g, [string]$t, [string]$family, [int]$size, [bool]$bold, $color, [float]$x, [float]$y) {
	$font = New-Font $family $size $bold
	$brush = [System.Drawing.SolidBrush]::new($color)
	$g.DrawString($t, $font, $brush, $x, $y)
	$brush.Dispose(); $font.Dispose()
}

function Draw-TextC($g, [string]$t, [string]$family, [int]$size, [bool]$bold, $color, [float]$x, [float]$y, [float]$w, [float]$h) {
	$font = New-Font $family $size $bold
	$brush = [System.Drawing.SolidBrush]::new($color)
	$sf = [System.Drawing.StringFormat]::new()
	$sf.Alignment = [System.Drawing.StringAlignment]::Center
	$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
	$rect = [System.Drawing.RectangleF]::new($x, $y, $w, $h)
	$g.DrawString($t, $font, $brush, $rect, $sf)
	$brush.Dispose(); $font.Dispose(); $sf.Dispose()
}

function Draw-GlassCard($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
	$path = New-RoundPath $x $y $w $h $r
	$rect = [System.Drawing.RectangleF]::new($x, $y, $w, $h)
	$c1 = [System.Drawing.Color]::FromArgb(240, 247, 250, 254)
	$c2 = [System.Drawing.Color]::FromArgb(232, 215, 222, 234)
	$brush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, $c1, $c2, [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
	$g.FillPath($brush, $path)
	$pen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(165, 255, 255, 255), [float]2.5)
	$g.DrawPath($pen, $path)
	$brush.Dispose(); $pen.Dispose()
	return $path
}

function Draw-Pill($g, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r, $fillColor) {
	$path = New-RoundPath $x $y $w $h $r
	$brush = [System.Drawing.SolidBrush]::new($fillColor)
	$g.FillPath($brush, $path)
	$brush.Dispose()
	return $path
}

# ---- 共通カラー ----
$ink = [System.Drawing.Color]::FromArgb(255, 35, 40, 55)
$subCol = [System.Drawing.Color]::FromArgb(255, 122, 130, 150)
$accent = [System.Drawing.Color]::FromArgb(255, 79, 140, 255)
$whiteHi = [System.Drawing.Color]::FromArgb(235, 255, 255, 255)
$trackCol = [System.Drawing.Color]::FromArgb(255, 198, 205, 218)
$darkDock = [System.Drawing.Color]::FromArgb(240, 18, 21, 28)

$fontLatin = "Segoe UI"
$fontJp = "Yu Gothic UI"

$emDash = [string][char]0x2014
$times = [string][char]0x00D7
$arrow = [string][char]0x2192

# ==========================================
# 1. 新しいUI (VisionOS) プレビュー: 1080 x 804
# ==========================================
$bmp = [System.Drawing.Bitmap]::new(1080, 804)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# ガラスステージ
$stage = Draw-GlassCard $g 0 0 1080 804 44
$g.SetClip($stage)

# ヘッダー
$g.FillPath([System.Drawing.SolidBrush]::new($whiteHi), (New-RoundPath 44 32 68 68 34))
$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 38, 43, 56)), 62, 50, 32, 32)
Draw-TextL $g "Home" $fontLatin 40 $true $ink 132 28
Draw-TextL $g "Overview & Status" $fontLatin 26 $false $subCol 134 78

Draw-Pill $g 736 36 300 56 28 ([System.Drawing.Color]::FromArgb(70, 255, 255, 255)) | Out-Null
Draw-TextC $g "60 fps • 32 ms" $fontLatin 26 $false ([System.Drawing.Color]::FromArgb(255, 58, 65, 82)) 736 36 300 56

# 区切り線
$g.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(90, 255, 255, 255)), 44, 128, 992, 2)

# セクションラベル
Draw-TextL $g "INTERFACE" $fontLatin 22 $true ([System.Drawing.Color]::FromArgb(255, 130, 138, 158)) 46 150

# Row1: トグルON
Draw-Pill $g 44 192 992 76 22 ([System.Drawing.Color]::FromArgb(195, 255, 255, 255)) | Out-Null
Draw-Pill $g 72 213 56 34 17 $accent | Out-Null
$g.FillEllipse([System.Drawing.SolidBrush]::new($whiteHi), 94, 215, 30, 30)
Draw-TextL $g "背景ぼかし (Blur)" $fontJp 27 $false $ink 150 200
Draw-TextL $g "16 px" $fontLatin 21 $false $subCol 150 234

# Row2: スライダー
Draw-Pill $g 44 286 992 76 22 ([System.Drawing.Color]::FromArgb(195, 255, 255, 255)) | Out-Null
Draw-TextL $g "カメラ FOV" $fontJp 27 $false $ink 72 296
Draw-Pill $g 72 340 700 8 4 $trackCol | Out-Null
Draw-Pill $g 72 340 300 8 4 $accent | Out-Null
$g.FillEllipse([System.Drawing.SolidBrush]::new($whiteHi), 358, 328, 32, 32)
Draw-TextL $g "70" $fontLatin 24 $false $subCol 800 300

# Row3: トグルOFF
Draw-Pill $g 44 380 992 76 22 ([System.Drawing.Color]::FromArgb(195, 255, 255, 255)) | Out-Null
Draw-Pill $g 72 401 56 34 17 $trackCol | Out-Null
$g.FillEllipse([System.Drawing.SolidBrush]::new($whiteHi), 74, 403, 30, 30)
Draw-TextL $g "Glass Panels" $fontLatin 27 $false $ink 150 388
Draw-TextL $g "26 %" $fontLatin 21 $false $subCol 150 422

# ドック
Draw-Pill $g 90 684 900 96 48 $darkDock | Out-Null
$g.DrawPath([System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(60, 255, 255, 255), [float]2), (New-RoundPath 90 684 900 96 48))
$dockSlots = @(180, 360, 540, 720, 900)
for ($i = 0; $i -lt 5; $i++) {
	if ($i -eq 0) {
		$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(235, 255, 255, 255)), $dockSlots[$i] - 28, 704, 56, 56)
		$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 38, 43, 56)), $dockSlots[$i] - 11, 721, 22, 22)
	}
 else {
		$g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(80, 255, 255, 255)), $dockSlots[$i] - 22, 710, 44, 44)
	}
}

$g.ResetClip()
$bmp.Save((Join-Path $assetsDir "ui_modern.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Host "ui_modern.png generated"

# ==========================================
# 2. 従来のUI (BentoDeck) プレビュー: 952 x 748
# ==========================================
$bmp2 = [System.Drawing.Bitmap]::new(952, 748)
$g2 = [System.Drawing.Graphics]::FromImage($bmp2)
$g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g2.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# 上部バー
$topBar = Draw-GlassCard $g2 0 0 952 84 26
$g2.SetClip($topBar)
Draw-TextL $g2 "CatWare" $fontLatin 30 $true $ink 30 0
Draw-Pill $g2 168 22 78 40 20 ([System.Drawing.Color]::FromArgb(215, 214, 230, 255)) | Out-Null
Draw-TextC $g2 "v2.0" $fontLatin 22 $true ([System.Drawing.Color]::FromArgb(255, 61, 110, 224)) 168 22 78 40
$g2.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 90, 235, 160)), 452, 36, 12, 12)
Draw-TextL $g2 "60 FPS  •  32 ms" $fontLatin 24 $false $subCol 476 0
Draw-Pill $g2 824 16 52 52 16 ([System.Drawing.Color]::FromArgb(190, 255, 255, 255)) | Out-Null
Draw-TextC $g2 $emDash $fontLatin 22 $false $subCol 824 16 52 52
Draw-Pill $g2 884 16 52 52 16 ([System.Drawing.Color]::FromArgb(190, 255, 255, 255)) | Out-Null
Draw-TextC $g2 $times $fontLatin 24 $true $subCol 884 16 52 52
$g2.ResetClip()

# プロフィールカード
$prof = Draw-GlassCard $g2 0 108 400 344 32
$g2.SetClip($prof)
$g2.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 28, 32, 42)), 144, 148, 112, 112)
$g2.DrawEllipse([System.Drawing.Pen]::new($accent, [float]5), 144, 148, 112, 112)
$g2.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 58, 65, 82)), 172, 172, 56, 56)
Draw-TextC $g2 "DisplayName" $fontLatin 28 $true $ink 0 276 400 30
Draw-TextC $g2 "@username" $fontLatin 22 $false $subCol 0 314 400 24
Draw-Pill $g2 94 392 212 44 22 ([System.Drawing.Color]::FromArgb(190, 255, 255, 255)) | Out-Null
$g2.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 90, 235, 160)), 112, 408, 12, 12)
Draw-TextC $g2 "Active Session" $fontLatin 20 $false ([System.Drawing.Color]::FromArgb(255, 58, 65, 82)) 112 392 194 44
$g2.ResetClip()

# Visualsカード
$vis = Draw-GlassCard $g2 424 108 528 344 32
$g2.SetClip($vis)
$glow = [System.Drawing.Drawing2D.GraphicsPath]::new()
$glow.AddEllipse(406, 80, 290, 290)
$glowBrush = [System.Drawing.Drawing2D.PathGradientBrush]::new($glow)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(110, 79, 140, 255)
$glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 79, 140, 255))
$g2.FillPath($glowBrush, $glow)

$iconPath = New-RoundPath 508 196 76 76 20
$iconRect = [System.Drawing.RectangleF]::new(508, 196, 76, 76)
$iconBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new($iconRect, [System.Drawing.Color]::FromArgb(255, 79, 140, 255), [System.Drawing.Color]::FromArgb(255, 127, 178, 255), [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g2.FillPath($iconBrush, $iconPath)
$g2.FillEllipse([System.Drawing.SolidBrush]::new($whiteHi), 530, 218, 32, 32)

Draw-TextL $g2 "Visuals" $fontLatin 38 $true $ink 464 336
Draw-TextL $g2 "Atmosphere, Blur & Camera" $fontLatin 22 $false $subCol 464 388
Draw-TextL $g2 $arrow $fontLatin 34 $true $accent 884 384
Draw-Pill $g2 796 134 124 40 20 ([System.Drawing.Color]::FromArgb(190, 255, 255, 255)) | Out-Null
Draw-TextC $g2 "VISUAL" $fontLatin 20 $true $accent 796 134 124 40
$g2.ResetClip()

# 3D Modelsカード
$mod = Draw-GlassCard $g2 0 476 400 272 32
$g2.SetClip($mod)
$iconPath2 = New-RoundPath 36 528 64 64 16
$iconRect2 = [System.Drawing.RectangleF]::new(36, 528, 64, 64)
$iconBrush2 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($iconRect2, [System.Drawing.Color]::FromArgb(255, 143, 115, 255), [System.Drawing.Color]::FromArgb(255, 178, 158, 255), [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g2.FillPath($iconBrush2, $iconPath2)
$g2.FillEllipse([System.Drawing.SolidBrush]::new($whiteHi), 54, 546, 28, 28)
Draw-TextL $g2 "3D Models" $fontLatin 30 $true $ink 36 646
Draw-TextL $g2 "HUD & Overlays" $fontLatin 21 $false $subCol 36 688
Draw-TextL $g2 $arrow $fontLatin 28 $true $accent 336 684
$g2.ResetClip()

# Settingsカード
$set = Draw-GlassCard $g2 424 476 252 272 32
$g2.SetClip($set)
$iconPath3 = New-RoundPath 518 536 64 64 32
$iconRect3 = [System.Drawing.RectangleF]::new(518, 536, 64, 64)
$iconBrush3 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($iconRect3, [System.Drawing.Color]::FromArgb(255, 79, 140, 255), [System.Drawing.Color]::FromArgb(255, 127, 178, 255), [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g2.FillPath($iconBrush3, $iconPath3)
$g2.FillEllipse([System.Drawing.SolidBrush]::new($whiteHi), 536, 554, 28, 28)
Draw-TextC $g2 "Settings" $fontLatin 27 $true $ink 424 648 252 32
$g2.ResetClip()

# Themesカード
$thm = Draw-GlassCard $g2 700 476 252 272 32
$g2.SetClip($thm)
$iconPath4 = New-RoundPath 794 536 64 64 32
$iconRect4 = [System.Drawing.RectangleF]::new(794, 536, 64, 64)
$iconBrush4 = [System.Drawing.Drawing2D.LinearGradientBrush]::new($iconRect4, [System.Drawing.Color]::FromArgb(255, 255, 145, 195), [System.Drawing.Color]::FromArgb(255, 255, 183, 214), [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
$g2.FillPath($iconBrush4, $iconPath4)
$g2.FillEllipse([System.Drawing.SolidBrush]::new($whiteHi), 812, 554, 28, 28)
Draw-TextC $g2 "Themes" $fontLatin 27 $true $ink 700 648 252 32
$dotCols = @(
	[System.Drawing.Color]::FromArgb(255, 130, 205, 255),
	[System.Drawing.Color]::FromArgb(255, 255, 145, 195),
	[System.Drawing.Color]::FromArgb(255, 175, 145, 255)
)
for ($i = 0; $i -lt 3; $i++) {
	$g2.FillEllipse([System.Drawing.SolidBrush]::new($dotCols[$i]), 700 + 252 - 58 - $i * 20, 492, 14, 14)
}
$g2.ResetClip()

$bmp2.Save((Join-Path $assetsDir "ui_classic.png"), [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose(); $bmp2.Dispose()
Write-Host "ui_classic.png generated"
