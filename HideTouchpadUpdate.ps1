# Oculta a atualizacao opcional de driver "Synaptics - Mouse" no Windows Update
# para ela parar de aparecer em Configuracoes > Windows Update > Atualizacoes
# opcionais / Atualizacoes de driver.
#
# Isso evita que alguem clique em "Baixar e instalar" por engano e traga de
# volta o Problema 1 (cursor pulando/travando/preso num ponto) descrito no
# README. Seguro de rodar quantas vezes quiser (idempotente): se a atualizacao
# ja estiver oculta ou nao tiver sido oferecida ainda, o script so avisa e sai.

param([switch]$Unattended)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $(if ($Unattended) {'-Unattended'})"
    exit
}

Write-Host "=== Ocultando atualizacao de driver Synaptics no Windows Update ===" -ForegroundColor Cyan

Write-Host "`nProcurando atualizacoes pendentes (isso pode levar alguns segundos)..."
try {
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $result = $searcher.Search("IsInstalled=0 and IsHidden=0 and Type='Driver'")
} catch {
    Write-Host "Erro ao consultar o Windows Update: $_" -ForegroundColor Red
    if (-not $Unattended) { pause }
    exit 1
}

$targets = $result.Updates | Where-Object { $_.Title -match 'Synaptics' -and $_.Title -match 'Mouse' }

if (-not $targets -or $targets.Count -eq 0) {
    Write-Host "Nenhuma atualizacao pendente do driver Synaptics encontrada (ja pode estar oculta, ou o Windows ainda nao ofereceu nenhuma)." -ForegroundColor Yellow
} else {
    foreach ($update in $targets) {
        $update.IsHidden = $true
        Write-Host "  Ocultada: $($update.Title)" -ForegroundColor Green
    }
    Write-Host "`nA atualizacao nao vai mais aparecer em Windows Update ate a Microsoft oferecer uma versao com titulo diferente." -ForegroundColor Green
}

Write-Host "`n=== Concluido. ===" -ForegroundColor Green
if (-not $Unattended) { pause }
