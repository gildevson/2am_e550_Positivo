# Roda os tres scripts de correcao em sequencia (touchpad + Windows Update +
# teclado/touchpad apos sleep), sem precisar abrir cada um manualmente.
# So pede UAC uma vez, no inicio; os scripts chamados em seguida ja herdam
# essa elevacao e nao pedem de novo.
#
# Nao altera FixTouchpad.ps1, HideTouchpadUpdate.ps1 ou FixInputDevices.ps1 -
# so chama cada um deles na ordem certa.

param([switch]$Unattended)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $(if ($Unattended) {'-Unattended'})"
    exit
}

$dir = Split-Path -Parent $PSCommandPath

function Show-SuccessDialog {
    param(
        [string]$Title = "Instalacao concluida",
        [string]$Message = "Tudo certo!",
        [string]$BannerPath
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $bgColor = [System.Drawing.Color]::FromArgb(18, 18, 24)
    $accentColor = [System.Drawing.Color]::FromArgb(124, 58, 237)
    $titleColor = [System.Drawing.Color]::White
    $msgColor = [System.Drawing.Color]::FromArgb(170, 170, 185)

    $banner = $null
    if ($BannerPath -and (Test-Path $BannerPath)) {
        try { $banner = [System.Drawing.Image]::FromFile($BannerPath) } catch { $banner = $null }
    }

    $width = 460
    $bannerHeight = if ($banner) { [int]($width * $banner.Height / $banner.Width) } else { 0 }
    $iconSize = 44
    $contentTop = $bannerHeight + 16 + $iconSize + 12

    $form = New-Object System.Windows.Forms.Form
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
    $form.Text = $Title
    $form.ClientSize = New-Object System.Drawing.Size($width, ($contentTop + 190))
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = $bgColor
    $form.TopMost = $true

    if ($banner) {
        $pic = New-Object System.Windows.Forms.PictureBox
        $pic.Image = $banner
        $pic.SizeMode = "Zoom"
        $pic.Size = New-Object System.Drawing.Size($width, $bannerHeight)
        $pic.Location = New-Object System.Drawing.Point(0, 0)
        $form.Controls.Add($pic)
    }

    # Icone de sucesso (circulo verde com check), centralizado, abaixo do banner
    # - nunca sobrepoe a foto nem o texto.
    $icon = New-Object System.Drawing.Bitmap($iconSize, $iconSize)
    $g = [System.Drawing.Graphics]::FromImage($icon)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.FillEllipse((New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(46, 204, 113))), 0, 0, $iconSize, $iconSize)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 4)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLines($pen, @(
        (New-Object System.Drawing.Point([int]($iconSize * 0.26), [int]($iconSize * 0.52))),
        (New-Object System.Drawing.Point([int]($iconSize * 0.42), [int]($iconSize * 0.68))),
        (New-Object System.Drawing.Point([int]($iconSize * 0.76), [int]($iconSize * 0.32)))
    ))
    $g.Dispose()

    $picIcon = New-Object System.Windows.Forms.PictureBox
    $picIcon.Image = $icon
    $picIcon.SizeMode = "Zoom"
    $picIcon.Size = New-Object System.Drawing.Size($iconSize, $iconSize)
    $picIcon.Location = New-Object System.Drawing.Point((($width - $iconSize) / 2), ($bannerHeight + 16))
    $form.Controls.Add($picIcon)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = $Title
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.ForeColor = $titleColor
    $lblTitle.BackColor = [System.Drawing.Color]::Transparent
    $lblTitle.TextAlign = "MiddleCenter"
    $lblTitle.Size = New-Object System.Drawing.Size(($width - 40), 32)
    $lblTitle.Location = New-Object System.Drawing.Point(20, $contentTop)
    $form.Controls.Add($lblTitle)

    $lblMsg = New-Object System.Windows.Forms.Label
    $lblMsg.Text = $Message
    $lblMsg.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblMsg.ForeColor = $msgColor
    $lblMsg.BackColor = [System.Drawing.Color]::Transparent
    $lblMsg.TextAlign = "MiddleCenter"
    $lblMsg.Size = New-Object System.Drawing.Size(($width - 40), 80)
    $lblMsg.Location = New-Object System.Drawing.Point(20, ($contentTop + 36))
    $form.Controls.Add($lblMsg)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "OK"
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.BackColor = $accentColor
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.Size = New-Object System.Drawing.Size(130, 38)
    $btn.Location = New-Object System.Drawing.Point((($width - 130) / 2), ($contentTop + 128))
    $btn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($btn)
    $form.AcceptButton = $btn

    $form.ShowDialog() | Out-Null
    $form.Dispose()
    $icon.Dispose()
    if ($banner) { $banner.Dispose() }
}

Write-Host "=== Instalacao completa (notebook Positivo/2AM - Windows 11) ===" -ForegroundColor Cyan

Write-Host "`n--- [1/3] Corrigindo driver do touchpad ---" -ForegroundColor Cyan
& "$dir\FixTouchpad.ps1" -Unattended

Write-Host "`n--- [2/3] Ocultando atualizacao do driver Synaptics no Windows Update ---" -ForegroundColor Cyan
& "$dir\HideTouchpadUpdate.ps1" -Unattended

Write-Host "`n--- [3/3] Corrigindo teclado/touchpad apos sleep/hibernar/desligar ---" -ForegroundColor Cyan
& "$dir\FixInputDevices.ps1"

Write-Host "`n=== Tudo pronto! Desligue o notebook completamente (nao so reiniciar) e ligue de novo. ===" -ForegroundColor Green

if (-not $Unattended) {
    Show-SuccessDialog -Title "Instalacao concluida!" -Message "Todos os passos foram aplicados com sucesso.`n`nDesligue o notebook completamente (nao so reiniciar) e ligue de novo." -BannerPath (Join-Path $dir "2am-e550.png")
}
