---
name: brand-discovery
description: Conduz uma entrevista estruturada de identidade de marca, retomável em várias sessões, em 8 módulos (propósito, posicionamento, público, personalidade, voz, narrativa, tensão fundador x empresa) usando escada de valores, 5 porquês e técnicas projetivas; salva as respostas em arquivos e gera um manual de marca mestre (90_SYNTHESIS.md). Use ao criar ou reposicionar uma marca (da Attivare ou de clientes), preparar briefing para designers ou redatores, ou tornar explícito o conhecimento implícito do fundador.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Descoberta de Marca

Responda sempre em português do Brasil.

Use esta skill para conduzir uma entrevista de identidade de marca estruturada e adaptativa. O objetivo é um `90_SYNTHESIS.md` completo: um manual de marca que a empresa usa para orientar designers, redatores e parceiros externos.

A entrevista acontece em várias sessões. Registre as respostas em arquivo ao longo do caminho, para que nada se perca quando a conversa terminar e para que a próxima sessão continue de onde a anterior parou.

## Quando ativar

- Uma marca está sendo criada, reposicionada, ou precisa de referência escrita para orientar colaboradores
- A conversa vai durar vários dias ou semanas
- Vários sócios ou envolvidos precisam ser entrevistados individualmente antes de uma conciliação
- O usuário quer um método estruturado e repetível, não um bate-papo solto
- A documentação de marca está dispersa, implícita ou dependente do fundador

## Protocolo de início de sessão

A cada ativação, faça estes passos **antes** de qualquer pergunta:

1. **Verifique o progresso anterior.** Procure os arquivos de módulo e um `state.json` na pasta de identidade de marca do projeto. Se não existirem, é um começo do zero: confirme o nome da marca, os participantes e onde salvar os arquivos, e comece pelo primeiro módulo.
2. **Leia o arquivo do módulo em andamento**, se houver, e veja as respostas já registradas na seção Bruto.
3. **Informe ao usuário** em duas ou três frases: em que módulo estamos, o status e o que falta. Depois pergunte: "Continuamos aqui ou mudamos de módulo?"

Se não houver acesso a arquivos (por exemplo, no chat), entregue ao fim de cada módulo o conteúdo completo para o usuário salvar, e peça que ele o envie de volta na próxima sessão.

## Disciplina da entrevista

Aplique estas regras em todos os módulos:

1. **Uma pergunta por vez.** Nunca apresente uma lista de perguntas.
2. **Depois de cada resposta:** paráfrase curta → uma pergunta de aprofundamento OU encerrar o tema se ele estiver saturado. Nunca avance em silêncio.
3. **Escada de valores:** para cada resposta de "o quê", pergunte "Por que isso importa para você?" até aparecer um valor central (normalmente de duas a quatro vezes).
4. **5 porquês:** para crenças ou afirmações de posicionamento, insista até chegar à razão de fundo, não à declaração de superfície.
5. **Respostas rasas:** se genéricas, cheias de jargão ou vagas, peça um exemplo concreto, uma história de cliente ou um número.
6. **Técnicas projetivas** (uma por módulo, para destravar):
   - "Se a marca fosse uma pessoa, como ela entraria numa sala?"
   - Obituário da marca: "Se a empresa fechasse daqui a cinco anos, do que os clientes sentiriam falta? O que você se arrependeria de não ter dito?"
   - Contraste: "Cite uma empresa que você admira, mas nunca gostaria de se tornar. O que exatamente a torna o modelo errado?"
7. **Sinal de saturação:** quando duas perguntas seguidas não trouxerem informação nova, resuma e encerre o módulo.
8. **Fim do módulo:** escreva o arquivo do módulo com duas seções:
   - `## Bruto`: citações literais e exemplos.
   - `## Síntese`: sua interpretação, três formulações candidatas, perguntas em aberto, contradições entre participantes.
   Depois atualize o `state.json` (veja o protocolo abaixo).

## Sequência de módulos

Os modelos de cada módulo estão em `references/`.

| Arquivo | Tema | Referências usadas |
|------|-------|-----------------|
| `10_proposito.md` | Propósito / Por quê | Círculo Dourado (Sinek), Lencioni |
| `20_posicionamento.md` | Posicionamento | Dunford "Obviously Awesome", modelo de Moore |
| `30_publico-nicho.md` | Público e nicho | Baker "Business of Expertise", perfil de cliente ideal |
| `40_personalidade-arquetipo.md` | Personalidade e arquétipo | 12 arquétipos (Mark & Pearson), 5 dimensões (J. Aaker) |
| `50_voz-tom.md` | Voz e tom | Diretrizes de voz de marca |
| `60_narrativa.md` | Narrativa / História | Trueline (Neumeier), arco da história da marca |
| `70_fundador-empresa.md` | Marca do fundador x marca da empresa | Enns "Win Without Pitching" |
| `90_SYNTHESIS.md` | Manual de marca mestre | Prisma de Kapferer, sistema de marca de Aaker |

Siga a ordem. Se o usuário pedir para pular, respeite e registre o salto no `state.json`.

## Protocolo de gravação de estado

Quando um módulo chegar à saturação ou for concluído, grave dois arquivos:

**Arquivo do módulo** em `modules/{arquivoDoModulo}`, com as seções Bruto e Síntese completas.

**`state.json`**: ponto de controle leve para retomar depois. Atualize `completedModules`, `inProgressModule`, `nextModule`, `lastUpdated`.

```json
{
  "session": "{nome_da_marca}-marca-{AAAA-MM}",
  "outputPath": "{caminho_da_pasta_de_identidade}",
  "completedModules": [],
  "inProgressModule": "10_proposito.md",
  "nextModule": "20_posicionamento.md",
  "participants": ["socio-a"],
  "lastUpdated": "{ISO-8601}"
}
```

Depois de gravar, confirme: "Módulo X salvo. Estado atualizado. Próximo: Y."

**Módulo final (90_SYNTHESIS.md):** ao escrever a síntese, defina `inProgressModule` como `"90_SYNTHESIS.md"` e `nextModule` como `null`. Depois de gravar, inclua `"90_SYNTHESIS.md"` em `completedModules` e defina `inProgressModule` como `null` (se ficar preenchido, uma sessão futura trataria o manual pronto como em andamento). Confirme: "Manual de marca concluído. Todos os módulos salvos."

## Modo com vários sócios

Com mais de um sócio, grave as respostas de cada um em `founders/{participante}.md` em vez dos arquivos principais. Valide o nome do participante antes de gravar: aceite só letras, números e hífen (ex.: `socio-a`, `ana`); rejeite nomes com separadores de caminho (`/`, `\`, `..`) ou caracteres especiais. Valide o `arquivoDoModulo` contra a sequência de módulos (10 a 90). Valide o `outputPath` para garantir que é um caminho absoluto dentro do projeto, rejeitando caminhos relativos e com `..`. Depois que todos os sócios concluírem um módulo, faça a conciliação: resuma convergências e divergências no arquivo do módulo e marque as "tensões produtivas" para uma reunião de alinhamento.

## Uso com clientes

Quando a marca for de um cliente, as respostas são informação confidencial do cliente: salve apenas no local combinado e não reutilize em outros projetos.

## Antipadrões

- **Começar sem ler o estado.** Toda sessão abre verificando os arquivos existentes e o `state.json`. Pular isso perde a continuidade.
- **Fazer várias perguntas de uma vez.** Uma pergunta por vez não é opcional: listas geram respostas de checklist, não percepção real.
- **Ir para a síntese antes da saturação.** Se as duas últimas perguntas não trouxeram nada novo, o módulo acabou. Se trouxeram, não acabou.
- **Pular a conciliação entre sócios.** Com vários envolvidos, as entrevistas individuais vêm antes da conciliação. Discutir a marca em grupo primeiro cria viés de ancoragem.
- **Tratar como sessão única.** A skill foi feita para várias sessões. Correr para o `90_SYNTHESIS.md` numa conversa só gera resultado raso.

## Skills relacionadas

- `brand-voice`: quando o módulo de voz e tom precisar de um perfil de escrita separado, baseado em textos reais
- `market-research`: depois do posicionamento, para mapear os concorrentes
