# Compose l'image de partage Open Graph (1200x630) pour www.hackmybody.fr/h-score
# Rendu pixel-parfait via System.Drawing. Sortie : og-image.png
Add-Type -AssemblyName System.Drawing

$W = 1200; $H = 630
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Palette
$cream    = [System.Drawing.ColorTranslator]::FromHtml('#faf8f4')
$ink      = [System.Drawing.ColorTranslator]::FromHtml('#10151f')
$inkSoft  = [System.Drawing.ColorTranslator]::FromHtml('#3d4657')
$accent   = [System.Drawing.ColorTranslator]::FromHtml('#b98a2f')
$accentDk = [System.Drawing.ColorTranslator]::FromHtml('#96701f')
$paperAlt = [System.Drawing.ColorTranslator]::FromHtml('#f1ede5')
$panelTop = [System.Drawing.ColorTranslator]::FromHtml('#223049')

function Brush($c) { New-Object System.Drawing.SolidBrush $c }

# --- Fond crème ---
$g.Clear($cream)

# --- Panneau sombre à droite (700..1200) dégradé ---
$panelRect = New-Object System.Drawing.Rectangle 700, 0, 500, $H
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush $panelRect, $panelTop, $ink, 115.0
$g.FillRectangle($grad, $panelRect)

# ================= COLONNE GAUCHE =================
$xL = 56

# Logo HACKMYBODY
$fLogo = New-Object System.Drawing.Font('Georgia', 21, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$g.DrawString('HACKMY', $fLogo, (Brush $ink), $xL, 46)
$szHack = $g.MeasureString('HACKMY', $fLogo)
$g.DrawString('BODY', $fLogo, (Brush $accent), ($xL + $szHack.Width - 8), 46)

# Eyebrow (majuscules espacées manuellement)
$fEye = New-Object System.Drawing.Font('Segoe UI', 11.5, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$eye = 'DIAGNOSTIC GRATUIT — 60 SECONDES'
$eyeSpaced = ($eye.ToCharArray() -join [char]0x200A)  # hair space entre chaque lettre
$g.DrawString($eyeSpaced, $fEye, (Brush $accentDk), $xL, 168)

# Titre (Georgia, gros)
$fH1 = New-Object System.Drawing.Font('Georgia', 40, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$fH1i = New-Object System.Drawing.Font('Georgia', 40, ([System.Drawing.FontStyle]::Bold -bor [System.Drawing.FontStyle]::Italic), [System.Drawing.GraphicsUnit]::Point)
$g.DrawString('Votre entreprise', $fH1, (Brush $ink), ($xL - 4), 205)
$g.DrawString('tourne.', $fH1, (Brush $ink), ($xL - 4), 273)
$g.DrawString('Et votre santé ?', $fH1i, (Brush $accentDk), ($xL - 4), 341)

# Sous-titre (Segoe UI)
$fSub = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$g.DrawString('Le H-Score' + [char]0x2122 + ' : le diagnostic santé & énergie', $fSub, (Brush $inkSoft), ($xL - 2), 430)
$g.DrawString('conçu pour les cadres et dirigeants.', $fSub, (Brush $inkSoft), ($xL - 2), 462)

# Pills en bas
$fPill = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
function DrawPill($text, $x, $y) {
  $sz = $g.MeasureString($text, $fPill)
  $padX = 18; $padY = 9
  $w = [int]($sz.Width + 2*$padX); $h = [int]($sz.Height + 2*$padY)
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $r = $h / 2
  $path.AddArc($x, $y, $r*2, $r*2, 90, 180)
  $path.AddArc($x + $w - $r*2, $y, $r*2, $r*2, 270, 180)
  $path.CloseFigure()
  $g.FillPath((Brush $paperAlt), $path)
  $g.DrawString($text, $fPill, (Brush $ink), ($x + $padX), ($y + $padY))
  return $w
}
$py = 540
$px = $xL
foreach ($t in @('10 questions', 'Résultat immédiat', '100% confidentiel')) {
  $used = DrawPill $t $px $py
  $px += $used + 12
}

# ================= PANNEAU DROIT : anneau =================
$cx = 950.0; $cy = 300.0; $rad = 118.0; $stroke = 20.0
# anneau de fond (blanc translucide)
$penBg = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(30, 255, 255, 255)), $stroke
$penBg.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penBg.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawEllipse($penBg, ($cx - $rad), ($cy - $rad), ($rad*2), ($rad*2))
# arc doré (~250°)
$penVal = New-Object System.Drawing.Pen $accent, $stroke
$penVal.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penVal.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawArc($penVal, ($cx - $rad), ($cy - $rad), ($rad*2), ($rad*2), -90, 250)

# "H" au centre
$fScore = New-Object System.Drawing.Font('Georgia', 62, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$g.DrawString('H', $fScore, (Brush ([System.Drawing.Color]::White)), $cx, ($cy - 68), $sf)
$fScoreSub = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
$g.DrawString('VOTRE SCORE', $fScoreSub, (Brush ([System.Drawing.Color]::FromArgb(150, 255, 255, 255))), $cx, ($cy + 40), $sf)

# URL en bas du panneau
$fUrl = New-Object System.Drawing.Font('Segoe UI', 13, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
$g.DrawString('hackmybody.fr', $fUrl, (Brush ([System.Drawing.Color]::FromArgb(190, 255, 255, 255))), $cx, 560, $sf)

# --- Sauvegarde ---
$out = Join-Path $PSScriptRoot 'og-image.png'
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
Write-Output "og-image.png genere : $([math]::Round((Get-Item $out).Length/1KB)) Ko"
