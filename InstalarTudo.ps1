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
        [string]$Message = "Tudo certo!"
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Desenha um icone de "sucesso" (circulo verde com check) em memoria,
    # sem depender de nenhum arquivo de imagem externo.
    $size = 96
    $icon = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($icon)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    $greenBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(46, 204, 113))
    $g.FillEllipse($greenBrush, 0, 0, $size, $size)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 8)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $points = @(
        (New-Object System.Drawing.Point([int]($size * 0.26), [int]($size * 0.52))),
        (New-Object System.Drawing.Point([int]($size * 0.42), [int]($size * 0.68))),
        (New-Object System.Drawing.Point([int]($size * 0.76), [int]($size * 0.32)))
    )
    $g.DrawLines($pen, $points)
    $g.Dispose()

    $form = New-Object System.Windows.Forms.Form
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
    $form.Text = $Title
    $form.ClientSize = New-Object System.Drawing.Size(420, 300)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.BackColor = [System.Drawing.Color]::White
    $form.TopMost = $true

    $pic = New-Object System.Windows.Forms.PictureBox
    $pic.Image = $icon
    $pic.SizeMode = "Zoom"
    $pic.Size = New-Object System.Drawing.Size($size, $size)
    $pic.Location = New-Object System.Drawing.Point((($form.ClientSize.Width - $size) / 2), 24)
    $form.Controls.Add($pic)

    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = $Title
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(33, 33, 33)
    $lblTitle.TextAlign = "MiddleCenter"
    $lblTitle.Size = New-Object System.Drawing.Size(380, 32)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 130)
    $form.Controls.Add($lblTitle)

    $lblMsg = New-Object System.Windows.Forms.Label
    $lblMsg.Text = $Message
    $lblMsg.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblMsg.ForeColor = [System.Drawing.Color]::FromArgb(90, 90, 90)
    $lblMsg.TextAlign = "MiddleCenter"
    $lblMsg.Size = New-Object System.Drawing.Size(380, 80)
    $lblMsg.Location = New-Object System.Drawing.Point(20, 166)
    $form.Controls.Add($lblMsg)

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "OK"
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.BackColor = [System.Drawing.Color]::FromArgb(46, 204, 113)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.Size = New-Object System.Drawing.Size(120, 36)
    $btn.Location = New-Object System.Drawing.Point((($form.ClientSize.Width - 120) / 2), 250)
    $btn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($btn)
    $form.AcceptButton = $btn

    $form.ShowDialog() | Out-Null
    $form.Dispose()
    $icon.Dispose()
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
    Show-SuccessDialog -Title "Instalacao concluida!" -Message "Todos os passos foram aplicados com sucesso.`n`nDesligue o notebook completamente (nao so reiniciar) e ligue de novo."
}
