# Corretor de Teclado + Touchpad que somem apos sleep/desligar (Windows 11)
# Causa comum: Inicializacao Rapida (Fast Startup) e gerenciamento de energia
# desligando os dispositivos internos (teclado/touchpad) e eles nao "acordando".
# Rode este script se o teclado e/ou touchpad pararem de responder depois
# que o notebook dormiu, hibernou ou foi reiniciado.

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "=== Corretor de Teclado/Touchpad (sleep/resume, Windows 11) ===" -ForegroundColor Cyan

Write-Host "`n[1/3] Desativando Inicializacao Rapida (Fast Startup)..."
$powerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
New-ItemProperty -Path $powerPath -Name "HiberbootEnabled" -Value 0 -PropertyType DWord -Force | Out-Null
# Nao desliga a hibernacao (powercfg /hibernate off): FixTouchpadSleep.ps1 usa
# hibernar no lugar da suspensao. HiberbootEnabled = 0 ja desliga o Fast Startup.

Write-Host "`n[2/3] Desativando 'permitir que o computador desligue este dispositivo' para teclado/touchpad/HID..."
$targets = Get-PnpDevice -PresentOnly | Where-Object {
    $_.Class -in @('Keyboard', 'Mouse', 'HIDClass') -and $_.Status -eq 'OK'
}
foreach ($dev in $targets) {
    $devKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$($dev.InstanceId)\Device Parameters"
    if (Test-Path $devKey) {
        New-ItemProperty -Path $devKey -Name "EnhancedPowerManagementEnabled" -Value 0 -PropertyType DWord -Force -ErrorAction SilentlyContinue | Out-Null
    }
    Write-Host "  Ajustado: $($dev.FriendlyName)"
}

Write-Host "`n[3/3] Desativando USB Selective Suspend no plano de energia ativo..."
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setactive SCHEME_CURRENT

Write-Host "`n=== Concluido. Desligue o notebook completamente (nao so reiniciar) e ligue de novo. ===" -ForegroundColor Green
Write-Host "Se teclado/touchpad ainda sumirem apos dormir, o problema pode ser do Embedded Controller (hardware) - nesse caso, reset de EC (bateria+power 15s) ou assistencia tecnica." -ForegroundColor Yellow
pause
