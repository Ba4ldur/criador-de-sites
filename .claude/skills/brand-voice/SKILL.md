---
name: brand-voice
description: Constrói um perfil de estilo de escrita a partir de textos reais (posts, artigos, e-mails, propostas, textos do site) e reutiliza esse perfil em conteúdo, prospecção e redes sociais. Use quando o usuário quiser que os textos soem como a Attivare, como um cliente específico ou como uma pessoa, sem cara de texto genérico de IA.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Voz da Marca

Responda sempre em português do Brasil.

Construa um perfil de voz durável a partir de material real e use esse perfil em todos os textos, em vez de reinventar o estilo a cada vez ou cair no texto genérico de IA.

## Quando ativar

- O usuário quer conteúdo ou prospecção com uma voz específica
- Escrever para Instagram, LinkedIn, WhatsApp, e-mail, blog ou lançamentos
- Adaptar o tom de uma marca ou pessoa a vários canais
- O conteúdo precisa de um sistema de estilo reutilizável, não de imitação pontual

## Prioridade das fontes

Use o melhor conjunto de fontes reais disponível, nesta ordem:

1. posts originais recentes nas redes (Instagram, LinkedIn)
2. artigos, circulares a clientes, newsletters, apresentações
3. e-mails e mensagens de WhatsApp reais que funcionaram (sem dados pessoais de terceiros)
4. textos do site, propostas comerciais e materiais institucionais

Não use exemplos genéricos da internet como fonte.

## Fluxo de coleta

1. Reúna de 5 a 20 amostras representativas, quando houver.
2. Prefira material recente, a menos que o usuário diga que o antigo representa melhor a marca.
3. Separe a "voz pública" (site, redes) da "voz de relacionamento" (atendimento, WhatsApp) se as fontes mostrarem essa diferença.
4. Se o material for de um cliente, trabalhe só com o que o usuário forneceu ou autorizou.

## O que extrair

- ritmo e tamanho das frases
- concisão versus explicação
- formal versus informal (você/o senhor, uso de gírias, emojis)
- uso de parênteses
- frequência e propósito das perguntas
- quão assertivas são as afirmações
- com que frequência aparecem números, exemplos e provas
- como são feitas as transições
- o que o autor nunca faz

## Entregável

Produza um bloco `PERFIL DE VOZ` reutilizável, que outras skills possam consumir diretamente. Use o modelo em [references/modelo-perfil-de-voz.md](references/modelo-perfil-de-voz.md).

Mantenha o perfil estruturado e curto o bastante para reaproveitar na conversa. O objetivo não é crítica literária, é uso operacional.

## Padrão da Attivare (quando faltarem fontes)

Se o usuário pedir a voz da Attivare e não houver amostras suficientes, comece daqui até que material real substitua:

- direta, concreta, confiável
- especificidade, números e exemplos práticos acima de adjetivos
- tom de quem entende de tributo e negócio, sem juridiquês
- explica termos técnicos quando o público é empresário, não contador
- sem promessas de economia garantida ou "zerar impostos"
- perguntas raras e nunca usadas como isca

Isto é ponto de partida, não fato: confirme com o usuário e ajuste com amostras reais.

## Proibições

Apague e reescreva qualquer um destes:

- ganchos de curiosidade falsos ("Você não vai acreditar...")
- "não é X, é Y" como fórmula
- "sem enrolação"
- cadência de guru do LinkedIn
- perguntas-isca no final
- "É com grande satisfação que anunciamos..."
- enchimento genérico sobre "jornada"
- emojis em excesso ou fora do padrão da marca

## Regras de persistência

- Reutilize o `PERFIL DE VOZ` confirmado mais recente em tarefas relacionadas na mesma conversa.
- Se o usuário pedir um arquivo durável, salve o perfil no local indicado.
- Não crie arquivos versionados com o perfil de voz de uma pessoa sem pedido explícito.

## Uso posterior

Use esta skill antes ou dentro de:

- `content-engine`
- `marketing-campaign`
- `article-writing`
- mensagens de prospecção por WhatsApp, LinkedIn e e-mail

Se outra skill tiver uma seção parcial de voz, esta skill é a fonte de verdade.
