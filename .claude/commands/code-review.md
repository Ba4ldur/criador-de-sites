---
description: Revisão de código — alterações locais ainda não commitadas ou um PR do GitHub (informe o número/URL do PR para o modo PR)
argument-hint: [número-do-pr | url-do-pr | vazio para revisão local]
---

# Revisão de Código

> Modo de revisão de PR adaptado de PRPs-agentic-eng, de Wirasm (via ECC, licença MIT).

**Entrada**: $ARGUMENTS

Responda sempre em português do Brasil.

---

## Escolha do modo

Se `$ARGUMENTS` contiver número de PR, URL de PR ou `--pr`:
→ vá para o **Modo PR** abaixo.

Caso contrário:
→ use o **Modo Local**.

---

## Modo Local

Revisão completa de segurança e qualidade das alterações ainda não commitadas.

### Fase 1: coletar

```bash
git diff --name-only HEAD
```

Se não houver arquivos alterados, pare: "Nada para revisar."

### Fase 2: revisar

Leia cada arquivo alterado por inteiro. Verifique:

**Segurança (CRÍTICO):**
- Credenciais, chaves de API ou tokens escritos no código (incluindo a chave `service_role` do Supabase)
- Vulnerabilidade de SQL injection
- Vulnerabilidade de XSS
- Falta de validação de entrada
- Dependências inseguras
- Risco de path traversal
- Arquivo fiscal real de cliente (XML, SPED, EFD) incluído no repositório

**Qualidade (ALTO):**
- Funções com mais de 50 linhas
- Arquivos com mais de 800 linhas (exceto quando o projeto é deliberadamente um HTML de arquivo único; nesse caso, avalie a organização interna)
- Aninhamento com mais de 4 níveis
- Falta de tratamento de erro
- `console.log` esquecido
- Comentários TODO/FIXME
- Valores monetários calculados com ponto flutuante sem regra de arredondamento explícita

**Boas práticas (MÉDIO):**
- Mutação de dados onde caberia imutabilidade
- Emojis no código ou em comentários
- Código novo sem testes
- Problemas de acessibilidade

### Fase 3: relatório

Gere o relatório com:
- Gravidade: CRÍTICO, ALTO, MÉDIO, BAIXO
- Arquivo e número da linha
- Descrição do problema
- Correção sugerida

Bloqueie o commit se houver problemas CRÍTICOS ou ALTOS.
Nunca aprove código com vulnerabilidade de segurança.

---

## Modo PR

Revisão completa de um PR no GitHub: busca o diff, lê os arquivos inteiros, roda a validação e prepara a revisão.

### Fase 1: buscar

Identifique o PR pela entrada:

| Entrada | Ação |
|---|---|
| Número (ex.: `42`) | Usar como número do PR |
| URL (`github.com/.../pull/42`) | Extrair o número do PR |
| Nome de branch | Encontrar o PR com `gh pr list --head <branch>` |

```bash
gh pr view <NÚMERO> --json number,title,body,author,baseRefName,headRefName,changedFiles,additions,deletions
gh pr diff <NÚMERO>
```

Se o PR não for encontrado, pare com erro.

### Fase 2: contexto

1. **Regras do projeto**: leia o `CLAUDE.md`, `.claude/docs/` e eventuais guias de contribuição
2. **Planos**: verifique `.claude/plans/` e `.claude/reviews/` em busca de contexto relacionado
3. **Intenção do PR**: extraia da descrição os objetivos e o plano de testes
4. **Arquivos alterados**: liste e classifique por tipo (código, teste, configuração, documentação)

### Fase 3: revisar

Leia cada arquivo alterado **por inteiro**, não só os trechos do diff.

```bash
gh pr diff <NÚMERO> --name-only | while IFS= read -r file; do
  gh api "repos/{owner}/{repo}/contents/$file?ref=<branch-do-pr>" --jq '.content' | base64 -d
done
```

Aplique o checklist em 7 categorias:

| Categoria | O que verificar |
|---|---|
| **Correção** | Erros de lógica, erros de limite, tratamento de nulos, casos de borda |
| **Tipos** | Tipos incompatíveis, conversões inseguras, uso de `any` |
| **Padrões** | Segue as convenções do projeto (nomes, estrutura, tratamento de erro) |
| **Segurança** | Injeção, falhas de autenticação, segredos expostos, XSS, dados de cliente |
| **Desempenho** | Consultas N+1, falta de índice, laços sem limite, arquivos grandes |
| **Completude** | Falta de testes, de tratamento de erro ou de documentação |
| **Manutenção** | Código morto, números mágicos, nomes pouco claros |

Gravidade de cada achado:

| Gravidade | Significado | Ação |
|---|---|---|
| **CRÍTICO** | Vulnerabilidade de segurança ou risco de perda de dados | Corrigir antes do merge |
| **ALTO** | Bug ou erro de lógica com chance de causar problema | Deve corrigir antes do merge |
| **MÉDIO** | Qualidade de código ou boa prática ausente | Correção recomendada |
| **BAIXO** | Estilo ou sugestão menor | Opcional |

### Fase 4: validar

Detecte o tipo de projeto pelos arquivos de configuração e rode os comandos aplicáveis:

**Node.js / TypeScript** (tem `package.json`):
```bash
npm run typecheck 2>/dev/null || npx tsc --noEmit 2>/dev/null
npm run lint
npm test
npm run build
```

**Python** (tem `pyproject.toml` / `setup.py`):
```bash
pytest
```

**HTML de arquivo único** (sem `package.json`): valide a sintaxe do JavaScript extraído dos blocos `<script>`.

Registre aprovado/reprovado para cada comando. Mostre a saída real; comando não executado deve constar como "não executado".

### Fase 5: decidir

| Condição | Decisão |
|---|---|
| Nenhum problema CRÍTICO/ALTO e validação aprovada | **APROVAR** |
| Só problemas MÉDIOS/BAIXOS e validação aprovada | **APROVAR** com comentários |
| Algum problema ALTO ou falha de validação | **SOLICITAR ALTERAÇÕES** |
| Algum problema CRÍTICO | **BLOQUEAR**: corrigir antes do merge |

Casos especiais:
- PR em rascunho → sempre **COMENTAR** (sem aprovar nem bloquear)
- Só documentação/configuração → revisão mais leve, foco em correção

### Fase 6: relatório

Crie o arquivo `.claude/reviews/pr-<NÚMERO>-review.md`:

```markdown
# Revisão do PR #<NÚMERO> — <TÍTULO>

**Revisado em**: <data>
**Autor**: <autor>
**Branch**: <origem> → <destino>
**Decisão**: APROVAR | SOLICITAR ALTERAÇÕES | BLOQUEAR

## Resumo
<avaliação geral em 1 a 2 frases>

## Achados
### CRÍTICO
<achados ou "Nenhum">
### ALTO
<achados ou "Nenhum">
### MÉDIO
<achados ou "Nenhum">
### BAIXO
<achados ou "Nenhum">

## Resultado da validação
| Verificação | Resultado |
|---|---|
| Tipos | Aprovado / Reprovado / Não executado |
| Lint | Aprovado / Reprovado / Não executado |
| Testes | Aprovado / Reprovado / Não executado |
| Build | Aprovado / Reprovado / Não executado |

## Arquivos revisados
<lista com tipo de alteração: Adicionado/Modificado/Excluído>
```

### Fase 7: publicar (somente com autorização)

**Antes de publicar qualquer coisa no GitHub, mostre o resumo da revisão ao usuário e peça autorização explícita.** Só depois rode:

```bash
# Se APROVAR
gh pr review <NÚMERO> --approve --body "<resumo da revisão>"
# Se SOLICITAR ALTERAÇÕES
gh pr review <NÚMERO> --request-changes --body "<resumo com correções exigidas>"
# Se só COMENTAR
gh pr review <NÚMERO> --comment --body "<resumo>"
```

### Fase 8: saída

```
PR #<NÚMERO>: <TÍTULO>
Decisão: <APROVAR | SOLICITAR ALTERAÇÕES | BLOQUEAR>

Problemas: <x> críticos, <x> altos, <x> médios, <x> baixos
Validação: <x>/<total> verificações aprovadas

Arquivos:
  Revisão: .claude/reviews/pr-<NÚMERO>-review.md
  GitHub: <URL do PR>

Próximos passos:
  - <sugestões conforme a decisão>
```

---

## Casos especiais

- **Sem o `gh` instalado**: faça só a revisão local (lendo o diff) e não publique no GitHub. Avise o usuário.
- **Branches divergentes**: sugira `git fetch origin && git rebase origin/<destino>` antes da revisão.
- **PR grande (mais de 50 arquivos)**: avise sobre o tamanho. Revise primeiro o código, depois os testes, depois configuração e documentação.
