# Fix Touchpad Synaptics x Windows 11

## Problema

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

## Solução

1. Remover o dispositivo de touchpad Synaptics ativo
2. Apagar os pacotes de driver Synaptics do driver store do Windows
   (não basta desinstalar o dispositivo, o pacote precisa ser apagado
   senão o Windows pode reaplicar sozinho)
3. Deixar o Windows redetectar o touchpad com o driver genérico
   (HID-compliant touch pad)
4. Bloquear o Windows Update de reinstalar drivers automaticamente
   (`ExcludeWUDriversInQualityUpdate = 1`), para o driver ruim não
   voltar sozinho numa atualização futura

## Como usar

1. Rode `FixTouchpad.cmd` (duplo clique)
2. Aceite o prompt do UAC (permissão de administrador)
3. Reinicie o notebook quando o script terminar
4. Teste o touchpad

## Quando usar

- Depois de formatar o notebook (rode uma vez após configurar o
  Windows, antes de instalar qualquer driver de touchpad manualmente)
- Se o touchpad voltar a pular/travar/ficar preso em um ponto

## Arquivos

| Arquivo | Descrição |
|---|---|
| `FixTouchpad.cmd` | Executa o script de correção (é este que você roda) |
| `FixTouchpad.ps1` | Lógica em PowerShell chamada pelo `.cmd` |
| `Setup.cmd` | **NÃO EXECUTAR** — instalador do driver antigo que causa o problema |
| `E550_TOUCHPAD.zip`, `Syn*.dll/inf/sys/exe` | Arquivos do driver antigo (mantidos só como referência) |

## Não fazer

- Não rodar `Setup.cmd` de novo — ele reinstala o driver problemático
- Não confiar em calibração de touchpad para esse sintoma — o problema
  é de driver, não de calibração/hardware
