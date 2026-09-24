# Fix Touchpad Synaptics x Windows 11 - 2AM E550

![Notebook 2AM E550](2am-e550.png)

Scripts para notebooks Positivo/2AM (chassi Clevo/Tongfang) com Windows 11.

## Como baixar

1. Acesse: https://github.com/gildevson/2am_e550_Positivo
2. Clique no botão verde **"Code"** → **"Download ZIP"**
3. Depois de baixar, clique com o botão direito no arquivo `.zip` →
   **"Extrair tudo..."** → escolha uma pasta (ex: `C:\touchpad-fix`)
4. Abra a pasta extraída

## Como instalar (recomendado: tudo de uma vez)

1. Dentro da pasta, dê **duplo clique em `InstalarTudo.cmd`**
2. Vai aparecer um aviso do Windows (UAC) pedindo permissão — clique em **"Sim"**
3. Uma janela preta abre e mostra o progresso automaticamente (4 passos)
4. No final aparece uma tela escura com a foto do notebook e um check
   verde dizendo **"Instalação concluída!"** — clique em **OK**
5. **Desligue o notebook completamente** (não só reiniciar) e ligue de novo
6. Teste o touchpad e o teclado

Isso já corrige o driver do touchpad, oculta a atualização problemática
no Windows Update, corrige teclado/touchpad sumindo após dormir e evita
o touchpad travar ao acordar da suspensão — tudo de uma vez só.

> **Atenção:** depois de instalar, o notebook **não suspende mais, ele
> hiberna**. Parado, só a tela apaga (na bateria, hiberna após 30 min).
> Fechar a tampa ou apertar o botão de energia faz hibernar. Para voltar,
> aperte o botão de energia — demora uns 10 a 20 segundos, mas o touchpad
> volta funcionando.

## Passo a passo (rodando um script por vez)

Se preferir rodar cada correção separada em vez do instalador completo:

1. Rode `FixTouchpad.cmd` (duplo clique, aceite o UAC). Corrige o cursor
   pulando/travando/preso num ponto. **Reinicie** o notebook ao final.
2. Rode `HideTouchpadUpdate.cmd` (duplo clique, aceite o UAC). Faz a
   atualização "Synaptics - Mouse" parar de aparecer no Windows Update.
3. Só se, além disso, teclado e/ou touchpad **sumirem depois que o
   notebook dorme, hiberna ou desliga/liga rápido**: rode
   `FixInputDevices.cmd` (duplo clique, aceite o UAC). Ao final,
   **desligue completamente** o notebook (não só reiniciar) e ligue de
   novo.
4. Só se o touchpad **travar quando o notebook volta do descanso/
   suspensão** (e só voltar reiniciando): rode `FixTouchpadSleep.cmd`
   (duplo clique, aceite o UAC). Troca a suspensão por hibernação.
5. Teste o teclado e o touchpad.

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
| `InstalarTudo.cmd` / `.ps1` | Roda as quatro correções abaixo em sequência, com tela final de aviso |
| `FixTouchpad.cmd` / `.ps1` | Corrige o conflito de driver Synaptics (cursor pulando/travando/preso) |
| `HideTouchpadUpdate.cmd` / `.ps1` | Oculta a atualização "Synaptics - Mouse" do Windows Update |
| `FixInputDevices.cmd` / `.ps1` | Corrige teclado/touchpad sumindo após sleep/hibernar/desligar |
| `FixTouchpadSleep.cmd` / `.ps1` | Troca suspensão por hibernação (touchpad PS/2 travava ao acordar da suspensão) |
| `2am-e550.png` | Foto do notebook usada no README e na tela final do `InstalarTudo` |
| `E550_TOUCHPAD.zip` | Pacote do driver antigo, mantido só como referência (não usar) |
