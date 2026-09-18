# Fix Touchpad Synaptics x Windows 11

Scripts para notebooks Positivo/2AM (chassi Clevo/Tongfang) com Windows 11.

## Passo a passo

1. Rode `FixTouchpad.cmd` (duplo clique, aceite o UAC). Corrige o cursor
   pulando/travando/preso num ponto. **Reinicie** o notebook ao final.
2. Rode `HideTouchpadUpdate.cmd` (duplo clique, aceite o UAC). Faz a
   atualização "Synaptics - Mouse" parar de aparecer no Windows Update.
3. Só se, além disso, teclado e/ou touchpad **sumirem depois que o
   notebook dorme, hiberna ou desliga/liga rápido**: rode
   `FixInputDevices.cmd` (duplo clique, aceite o UAC). Ao final,
   **desligue completamente** o notebook (não só reiniciar) e ligue de
   novo.
4. Teste o teclado e o touchpad.

## Automatizar (opcional, recomendado)

Para não depender de rodar os scripts de novo manualmente caso o
problema volte numa atualização futura, agende como Administrador:

```powershell
schtasks /Create /TN "FixTouchpadOnBoot" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\caminho\para\touchpad\FixTouchpad.ps1 -Unattended" /SC ONSTART /RU SYSTEM /RL HIGHEST /F
schtasks /Create /TN "HideTouchpadUpdateDaily" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\caminho\para\touchpad\HideTouchpadUpdate.ps1 -Unattended" /SC DAILY /ST 09:00 /RU SYSTEM /RL HIGHEST /F
```

Ajuste `C:\caminho\para\touchpad` para onde a pasta está.

## Arquivos

| Arquivo | Descrição |
|---|---|
| `FixTouchpad.cmd` / `.ps1` | Corrige o conflito de driver Synaptics (cursor pulando/travando/preso) |
| `HideTouchpadUpdate.cmd` / `.ps1` | Oculta a atualização "Synaptics - Mouse" do Windows Update |
| `FixInputDevices.cmd` / `.ps1` | Corrige teclado/touchpad sumindo após sleep/hibernar/desligar |
| `E550_TOUCHPAD.zip` | Pacote do driver antigo, mantido só como referência (não usar) |
