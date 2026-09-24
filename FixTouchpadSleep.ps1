# Corretor de Touchpad que trava ao voltar da suspensao (sleep S3)
# Neste notebook o touchpad funciona como mouse PS/2 (ACPI\SYN1222). Ao voltar
# da suspensao S3 ele volta "fora de sincronia" (log do Windows: i8042prt,
# evento 50 - "erro de estado interno no driver para o dispositivo apontador
# PS/2") e so volta a funcionar reiniciando o notebook.
#
# A solucao e nao usar a suspensao S3:
#  - Parado: so a tela apaga, o notebook nao suspende. Na bateria, apos 30 min
#    parado, ele hiberna.
#  - Tampa fechada / botao de energia / tecla de dormir: hiberna. Ao voltar da
#    hibernacao o touchpad e inicializado do zero, como ao ligar o notebook.
# Aplica em todos os planos de energia. Seguro de rodar quantas vezes quiser.

param([switch]$Unattended)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $(if ($Unattended) {'-Unattended'})"
    exit
}

Write-Host "=== Corretor de Touchpad travando apos suspensao (Windows 11) ===" -ForegroundColor Cyan

Write-Host "`n[1/4] Ativando hibernacao (mantendo Inicializacao Rapida desligada)..."
powercfg /hibernate on
$powerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
New-ItemProperty -Path $powerPath -Name "HiberbootEnabled" -Value 0 -PropertyType DWord -Force | Out-Null

$schemes = powercfg /list | Select-String -Pattern '([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})' | ForEach-Object { $_.Matches[0].Value }

Write-Host "`n[2/4] Desativando suspensao automatica quando o notebook fica parado..."
# SUB_SLEEP: STANDBYIDLE = suspender apos (0 = nunca), HIBERNATEIDLE = hibernar apos (segundos)
foreach ($s in $schemes) {
    powercfg /setacvalueindex $s SUB_SLEEP STANDBYIDLE 0
    powercfg /setdcvalueindex $s SUB_SLEEP STANDBYIDLE 0
    powercfg /setacvalueindex $s SUB_SLEEP HIBERNATEIDLE 0
    powercfg /setdcvalueindex $s SUB_SLEEP HIBERNATEIDLE 1800
}

Write-Host "`n[3/4] Tampa / botao de energia / tecla de dormir -> Hibernar..."
# Acoes: 0 = nada, 1 = suspender, 2 = hibernar, 3 = desligar
# GUIDs em vez de aliases (LIDACTION etc.): neste notebook o powercfg nao
# reconhece esses aliases.
$buttonsGroup = '4f971e89-eebd-4455-a8de-9e59040e7347'
$buttonActions = @(
    '5ca83367-6e45-459f-a27b-476b1d01c936', # fechar a tampa
    '7648efa3-dd9c-4e3e-b566-50f929386280', # botao de energia
    '96996bc0-ad50-47ec-923b-6f41874dd9eb'  # tecla/botao de dormir
)
foreach ($s in $schemes) {
    foreach ($action in $buttonActions) {
        powercfg /setacvalueindex $s $buttonsGroup $action 2
        powercfg /setdcvalueindex $s $buttonsGroup $action 2
    }
}
powercfg /setactive SCHEME_CURRENT

Write-Host "`n[4/4] Trocando 'Suspender' por 'Hibernar' no menu de energia do Iniciar..."
$explorerPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $explorerPolicy)) { New-Item -Path $explorerPolicy -Force | Out-Null }
New-ItemProperty -Path $explorerPolicy -Name "ShowSleepOption" -Value 0 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $explorerPolicy -Name "ShowHibernateOption" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "`n=== Concluido. O notebook nao vai mais suspender - vai hibernar. ===" -ForegroundColor Green
if (-not $Unattended) { pause }
