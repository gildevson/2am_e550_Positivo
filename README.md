# Fix Touchpad Synaptics x Windows 11

Scripts para corrigir dois problemas comuns de touchpad/teclado em notebooks
Positivo/2AM (chassi Clevo/Tongfang) com Windows 11.

## Ordem de execução (importante)

Existem **dois scripts para dois problemas diferentes**. Não são a mesma
coisa e não precisam ser rodados os dois sempre — siga esta ordem:

| Ordem | Script | Quando rodar |
|---|---|---|
| **1º sempre** | `FixTouchpad.cmd` | Corrige o driver Synaptics conflitando com o Windows 11 (cursor pulando/travando/preso num ponto fixo). Rode logo após formatar, ou se o touchpad voltar a se comportar assim. |
| **2º só se precisar** | `FixInputDevices.cmd` | Só se, **além disso**, teclado e/ou touchpad sumirem/pararem de responder depois que o notebook dorme, hiberna ou desliga/liga rápido. |

Passo a passo:

1. Rode `FixTouchpad.cmd` primeiro (duplo clique, aceite o UAC).
2. **Reinicie** o notebook.
3. Teste o touchpad. Se o cursor já está normal (não pula/trava/não fica
   preso num ponto), o Problema 1 está resolvido — pode parar aqui.
4. Se, mesmo assim, teclado e/ou touchpad **sumirem depois de
   dormir/hibernar/desligar rápido**, rode `FixInputDevices.cmd` (duplo
   clique, aceite o UAC).
5. Ao final desse, **desligue o notebook completamente** (não apenas
   reiniciar) e ligue de novo.
6. Teste teclado e touchpad novamente.

## Passo a passo (instalação)

1. Baixe/clone este repositório para uma pasta local, ex: `C:\touchpad-fix`.
2. Abra a pasta e identifique qual problema você tem (veja as seções
   [Problema 1](#problema-1-driver-synaptics-conflitando-com-windows-11) e
   [Problema 2](#problema-2-teclado-eou-touchpad-somem-após-sleephibernardesligar)
   abaixo).
3. Rode o `.cmd` correspondente com duplo clique e aceite o UAC.
4. Reinicie o notebook e teste o touchpad/teclado.
5. (Opcional, recomendado) Configure a [execução automática na
   inicialização](#automatizar-na-inicialização) para o Windows Update não
   conseguir trazer o problema de volta sem você perceber.

## Problema 1: Driver Synaptics conflitando com Windows 11

Notebook Positivo com touchpad Synaptics (driver antigo, feito para
Windows 10 / touchpads PS2). Ao instalar esse driver manualmente
(`Setup.cmd` + `SynPD.inf`), ele conflita com a pilha de touchpad do
Windows 11:

- Cursor pula e trava aleatoriamente
- Depois passa a responder só em um ponto fixo da superfície (ex: canto
  inferior esquerdo), independente de onde o dedo realmente toca
- No Gerenciador de Dispositivos o driver aparece como "OK", sem erro
  (por isso parece defeito físico, mas é só incompatibilidade de driver)

Causa raiz: driver Synaptics legado (`synpd.inf`, `synhidmini.inf`,
`synsmbdrv.inf`, `synservice.inf`) não traduz corretamente as
coordenadas de toque para a API de touchpad do Windows 11. O driver
genérico (built-in) do Windows não tem esse problema.

### Solução

1. Remover o dispositivo de touchpad Synaptics ativo
2. Apagar os pacotes de driver Synaptics do driver store do Windows
   (não basta desinstalar o dispositivo, o pacote precisa ser apagado
   senão o Windows pode reaplicar sozinho)
3. Deixar o Windows redetectar o touchpad com o driver genérico
   (HID-compliant touch pad)
4. Bloquear o Windows Update de reinstalar drivers automaticamente
   (`ExcludeWUDriversInQualityUpdate = 1`), para o driver ruim não
   voltar sozinho numa atualização futura

### Como usar

1. Rode `FixTouchpad.cmd` (duplo clique)
2. Aceite o prompt do UAC (permissão de administrador)
3. Reinicie o notebook quando o script terminar
4. Teste o touchpad

### Quando usar

- Depois de formatar o notebook (rode uma vez após configurar o
  Windows, antes de instalar qualquer driver de touchpad manualmente)
- Se o touchpad voltar a pular/travar/ficar preso em um ponto

## Problema 2: Teclado e/ou touchpad somem após sleep/hibernar/desligar

Esse é um problema muito comum em notebooks com Windows 11 — muita
gente relata teclado e/ou touchpad parando de responder depois que o
notebook dorme, hiberna ou é desligado/ligado rapidamente. Não é
exclusivo desse modelo de notebook.

Causa raiz mais comum: a Inicialização Rápida (Fast Startup) e o
gerenciamento de energia do Windows desligam os dispositivos internos
(teclado/touchpad/HID) para economizar energia e eles não "acordam"
sozinhos ao religar.

### O que fazer se acontecer

1. Rode `FixInputDevices.cmd` (duplo clique)
2. Aceite o prompt do UAC (permissão de administrador)
3. O script vai:
   - Desativar a Inicialização Rápida (Fast Startup)
   - Impedir que o Windows desligue teclado/touchpad/dispositivos HID
     para economizar energia
   - Desativar o USB Selective Suspend no plano de energia ativo
4. Ao final, **desligue o notebook completamente** (não apenas
   reiniciar) e ligue de novo
5. Teste o teclado e o touchpad

Se o teclado/touchpad ainda sumirem depois disso, o problema pode ser
do Embedded Controller (hardware) — nesse caso, tente um reset de EC
(remover a bateria, se possível, e segurar o botão de power por 15s
com o notebook desligado da tomada) ou procure assistência técnica.

## Automatizar na inicialização

O `FixTouchpad.ps1` já bloqueia o Windows Update de reinstalar drivers
(passo 4 da solução), mas, como garantia extra, dá para agendar o script
para rodar sozinho toda vez que o Windows iniciar — sem UAC, sem janela
visível, sem precisar lembrar de rodar de novo.

O script aceita um parâmetro `-Unattended` que pula o `pause` final
(necessário para rodar em segundo plano, sem travar esperando um
"pressione uma tecla" que nunca vai chegar).

1. Ajuste o caminho abaixo para onde você colocou a pasta.
2. Abra um **PowerShell como Administrador** (Iniciar → digite
   `PowerShell` → botão direito → "Executar como administrador").
3. Cole o comando (tudo em uma linha só):

   ```powershell
   schtasks /Create /TN "FixTouchpadOnBoot" /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\caminho\para\touchpad\FixTouchpad.ps1 -Unattended" /SC ONSTART /RU SYSTEM /RL HIGHEST /F
   ```

4. Confirme que a tarefa foi criada:

   ```powershell
   schtasks /Query /TN "FixTouchpadOnBoot" /V /FO LIST
   ```

   Deve aparecer `Executar como Usuário: SISTEMA` e
   `Tipo de Agendamento: Na inicialização do sistema`.

5. (Opcional) Teste sem reiniciar:

   ```powershell
   schtasks /Run /TN "FixTouchpadOnBoot"
   ```

   Depois rode o `Query` de novo e confira `Último resultado: 0`.

Para remover a automação depois, rode (também como Administrador):

```powershell
schtasks /Delete /TN "FixTouchpadOnBoot" /F
```

## Arquivos

| Arquivo | Descrição |
|---|---|
| `FixTouchpad.cmd` | Corrige o conflito de driver Synaptics (Problema 1) |
| `FixTouchpad.ps1` | Lógica em PowerShell chamada pelo `FixTouchpad.cmd`. Aceita `-Unattended` para rodar sem pausa (uso em tarefa agendada) |
| `FixInputDevices.cmd` | Corrige teclado/touchpad sumindo após sleep (Problema 2) |
| `FixInputDevices.ps1` | Lógica em PowerShell chamada pelo `FixInputDevices.cmd` |
| `E550_TOUCHPAD.zip` | **NÃO EXTRAIR/EXECUTAR** — pacote completo do driver antigo (Setup.cmd + Syn\*/Smb_driver\*), mantido zipado só como referência do que causa o Problema 1 |

## Não fazer

- Não extrair/rodar `Setup.cmd` de dentro do `E550_TOUCHPAD.zip` —
  ele reinstala o driver problemático
- Não confiar em calibração de touchpad para o Problema 1 — é de
  driver, não de calibração/hardware
