---
name: context-budget
description: Audita quanto do contexto do Claude Code é consumido por agents, skills, servidores MCP, regras e CLAUDE.md; identifica excesso e componentes redundantes e gera recomendações priorizadas de economia. Use quando o contexto estiver enchendo rápido, a qualidade das respostas cair, ou antes de instalar mais skills, agents ou MCPs.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Orçamento de Contexto

Responda sempre em português do Brasil.

Analisa o custo em tokens de cada componente carregado numa sessão do Claude Code e aponta otimizações para recuperar espaço.

## Quando usar

- A sessão parece lenta ou a qualidade das respostas está caindo
- Muitas skills, agents ou servidores MCP foram adicionados recentemente
- Para saber quanto espaço de contexto realmente sobra
- Antes de instalar mais componentes

## Como funciona

### Fase 1: inventário

Varra as pastas de componentes (do projeto `.claude/` e do usuário `~/.claude/`) e estime o consumo:

**Agents** (`agents/*.md`)
- Linhas e tokens por arquivo (palavras × 1,3)
- Tamanho do campo `description`
- Alerta: arquivos com mais de 200 linhas; descrição com mais de 30 palavras

**Skills** (`skills/*/SKILL.md`)
- Tokens por SKILL.md
- Alerta: arquivos com mais de 400 linhas
- Procure cópias duplicadas da mesma skill em lugares diferentes

**Regras** (`rules/**/*.md`, se houver)
- Tokens por arquivo
- Alerta: mais de 100 linhas; conteúdo sobreposto entre regras

**Servidores MCP** (`.mcp.json` ou configuração ativa)
- Número de servidores e total de ferramentas
- Estimativa de ~500 tokens por ferramenta
- Alerta: servidores com mais de 20 ferramentas; servidores que só embrulham comandos disponíveis de graça (`gh`, `git`, `npm`, `supabase`)

**CLAUDE.md** (projeto + usuário)
- Tokens por arquivo
- Alerta: total combinado acima de 300 linhas

### Fase 2: classificar

| Grupo | Critério | Ação |
|--------|----------|--------|
| **Sempre necessário** | Citado no CLAUDE.md, usado por um comando ativo ou compatível com o tipo do projeto | Manter |
| **Às vezes necessário** | Específico de um domínio, não citado no CLAUDE.md | Considerar ativar só quando preciso |
| **Raramente necessário** | Sem uso, conteúdo sobreposto ou sem relação com o projeto | Remover ou carregar sob demanda |

### Fase 3: detectar problemas

- **Descrições de agents inchadas**: a descrição é carregada sempre, mesmo que o agent nunca seja usado
- **Agents pesados**: arquivos longos inflam o contexto a cada chamada
- **Componentes redundantes**: skills que fazem a mesma coisa (ex.: várias skills de design ou de SEO), regras que repetem o CLAUDE.md
- **Excesso de MCP**: mais de 10 servidores, ou servidores que substituem comandos gratuitos
- **CLAUDE.md inchado**: explicações longas, seções desatualizadas

### Fase 4: relatório

```
Relatório de Orçamento de Contexto
═══════════════════════════════════════

Custo total estimado: ~XX.XXX tokens
Contexto disponível efetivo: ~XXX.XXX tokens (XX%)

Por componente:
┌─────────────────┬────────┬───────────┐
│ Componente      │ Qtde   │ Tokens    │
├─────────────────┼────────┼───────────┤
│ Agents          │ N      │ ~X.XXX    │
│ Skills          │ N      │ ~X.XXX    │
│ Regras          │ N      │ ~X.XXX    │
│ Ferramentas MCP │ N      │ ~XX.XXX   │
│ CLAUDE.md       │ N      │ ~X.XXX    │
└─────────────────┴────────┴───────────┘

Problemas encontrados (N), ordenados por economia:

3 principais otimizações:
1. [ação] → economiza ~X.XXX tokens
2. [ação] → economiza ~X.XXX tokens
3. [ação] → economiza ~X.XXX tokens

Economia potencial: ~XX.XXX tokens (XX% do custo atual)
```

Os números são estimativas. Não afirme de cabeça o tamanho da janela de contexto do modelo: se precisar dele, confirme na documentação atual.

## Boas práticas

- **Estimativa**: palavras × 1,3 para texto; caracteres ÷ 4 para arquivos com muito código
- **MCP é a maior alavanca**: cada ferramenta custa ~500 tokens; um servidor de 30 ferramentas pode custar mais que todas as skills juntas
- **Skills sobrepostas competem entre si**: além do custo, pioram a escolha de qual skill usar
- **Audite depois de mudanças**: rode sempre que adicionar skill, agent ou MCP
- **Nunca remova nada sem confirmação do usuário**: esta skill recomenda, não apaga
