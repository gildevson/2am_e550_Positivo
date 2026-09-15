# Corretor de Touchpad Synaptics x Windows 11
# Remove drivers Synaptics legados (causam cursor pulando/travando/travado num ponto)
# e bloqueia o Windows Update de reinstala-los sozinho.
# Rode este script sempre apos formatar o notebook, ou se o problema do touchpad voltar.

param([switch]$Unattended)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Write-Host "=== Corretor de Touchpad Synaptics (Windows 11) ===" -ForegroundColor Cyan

Write-Host "`n[1/4] Parando servicos/processos Synaptics..."
Get-Service | Where-Object { $_.Name -match 'SynTP|Synaptics' } | Stop-Service -Force -ErrorAction SilentlyContinue
Get-Process | Where-Object { $_.Name -match '^Syn' } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "`n[2/4] Removendo dispositivos Synaptics ativos..."
$devices = Get-PnpDevice | Where-Object { $_.FriendlyName -match 'Synaptics' -and $_.Class -in @('Mouse', 'HIDClass') }
if ($devices) {
    foreach ($dev in $devices) {
        Write-Host "  Removendo: $($dev.FriendlyName) [$($dev.InstanceId)]"
        pnputil /remove-device "$($dev.InstanceId)" | Out-Null
    }
} else {
    Write-Host "  Nenhum dispositivo Synaptics ativo encontrado."
}

Write-Host "`n[3/4] Apagando pacotes de driver Synaptics do driver store..."
$synDrivers = Get-WindowsDriver -Online -All | Where-Object { $_.ProviderName -match 'Synaptics' }
if ($synDrivers) {
    foreach ($d in $synDrivers) {
        Write-Host "  Apagando pacote: $($d.Driver) ($($d.OriginalFileName))"
        pnputil /delete-driver $d.Driver /uninstall /force | Out-Null
    }
} else {
    Write-Host "  Nenhum pacote de driver Synaptics encontrado no driver store."
}

Write-Host "`n[4/5] Bloqueando Windows Update de reinstalar drivers automaticamente..."
$wuPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
if (-not (Test-Path $wuPath)) { New-Item -Path $wuPath -Force | Out-Null }
New-ItemProperty -Path $wuPath -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -PropertyType DWord -Force | Out-Null

Write-Host "`n[5/5] Removendo filtro 'SynTP' orfao da classe Teclado (causa o Codigo 19 no teclado interno)..."
$kbdClassKey = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e96b-e325-11ce-bfc1-08002be10318}"
$upper = (Get-ItemProperty -Path $kbdClassKey -Name UpperFilters -ErrorAction SilentlyContinue).UpperFilters
if ($upper -and ($upper -contains 'SynTP')) {
    $cleaned = $upper | Where-Object { $_ -ne 'SynTP' }
    Set-ItemProperty -Path $kbdClassKey -Name UpperFilters -Value $cleaned -Type MultiString
    Write-Host "  Filtro 'SynTP' removido da classe Teclado (ficava: $($upper -join ', '))."
    $kbdDevice = Get-PnpDevice -Class Keyboard -PresentOnly | Where-Object { $_.InstanceId -match '^ACPI\\MSFT0001' }
    foreach ($kd in $kbdDevice) {
        pnputil /restart-device "$($kd.InstanceId)" | Out-Null
        Write-Host "  Dispositivo reiniciado: $($kd.FriendlyName) [$($kd.InstanceId)]"
    }
} else {
    Write-Host "  Nenhum filtro 'SynTP' orfao encontrado na classe Teclado."
}

Write-Host "`n=== Concluido. Reinicie o notebook para o Windows aplicar o driver generico do touchpad. ===" -ForegroundColor Green
if (-not $Unattended) { pause }
