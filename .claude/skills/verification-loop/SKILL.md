---
name: verification-loop
description: Executa uma verificação em seis etapas do trabalho feito na sessão — build, checagem de tipos/sintaxe, lint, testes, varredura de segurança e revisão do diff — e gera um relatório APROVADO/REPROVADO. Use ao terminar uma funcionalidade ou refatoração, antes de abrir um PR, ou sempre que for preciso comprovar que o código está validado.
license: MIT
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Skill: Ciclo de Verificação

Sistema de verificação completa para sessões do Claude Code.

## Regra de ouro

Toda etapa deve ser **executada de verdade**, com a saída real do comando mostrada no relatório. Se uma etapa não puder ser executada (ferramenta ausente, projeto sem script correspondente), marque como **NÃO EXECUTADA** e explique o motivo. Nunca marque como aprovada uma etapa que não rodou.

Responda sempre em português do Brasil.

## Quando usar

- Depois de concluir uma funcionalidade ou alteração relevante
- Antes de abrir um PR
- Depois de uma refatoração
- Sempre que for preciso comprovar a qualidade do código

## Etapa 0: identificar o tipo de projeto

Verifique os arquivos de configuração (`package.json`, `pyproject.toml` etc.). Se o projeto for um **HTML de arquivo único** sem `package.json`, adapte as etapas: extraia o JavaScript dos blocos `<script>` e valide a sintaxe (por exemplo, com `node --check` sobre o trecho extraído). Rode apenas as etapas que se aplicam ao tipo de projeto detectado.

## Etapas de verificação

### Etapa 1: build
```bash
npm run build 2>&1 | tail -20
```
Se o build falhar, PARE e corrija antes de continuar.

### Etapa 2: checagem de tipos / sintaxe
```bash
set -o pipefail
# Projetos TypeScript
npx --no-install tsc --noEmit 2>&1 | head -30
# Projetos Python
pyright . 2>&1 | head -30
```
Relate todos os erros. Corrija os críticos antes de continuar.

### Etapa 3: lint
```bash
# JavaScript/TypeScript
npm run lint 2>&1 | head -30
# Python
ruff check . 2>&1 | head -30
```

### Etapa 4: testes
```bash
npm run test -- --coverage 2>&1 | tail -50
```
Relate: total de testes, aprovados, reprovados e cobertura (%).

**Classificação obrigatória da origem dos dados de teste:**
- **Fixture sintética**: dados fictícios ou anonimizados
- **Arquivo fiscal real**: XML, SPED ou EFD de cliente

Nada pode ser declarado "pronto para produção" sem validação com arquivo real.

### Etapa 5: varredura de segurança
```bash
# Segredos no código
grep -rn "sk-" --include="*.ts" --include="*.js" --include="*.html" . 2>/dev/null | head -10
grep -rn "api_key\|service_role" --include="*.ts" --include="*.js" --include="*.html" . 2>/dev/null | head -10
# console.log esquecido
grep -rn "console.log" --include="*.ts" --include="*.js" --include="*.html" . 2>/dev/null | head -10
# Arquivos fiscais reais versionados por engano
git ls-files | grep -iE "\.(xml|txt)$" | head -20
```
Para cada XML ou TXT versionado, confirme se é fixture sintética. Se não for, é falha de segurança (dados de cliente no repositório — risco LGPD).

### Etapa 6: revisão do diff
```bash
git diff --stat
git diff HEAD~1 --name-only
```
Revise cada arquivo alterado em busca de:
- alterações não intencionais
- falta de tratamento de erro
- casos de borda (campo vazio, nulo, arquivo malformado)

## Formato do relatório

```
RELATÓRIO DE VERIFICAÇÃO
========================

Build:      [APROVADO/REPROVADO/NÃO EXECUTADO]
Tipos:      [APROVADO/REPROVADO/NÃO EXECUTADO] (X erros)
Lint:       [APROVADO/REPROVADO/NÃO EXECUTADO] (X avisos)
Testes:     [APROVADO/REPROVADO/NÃO EXECUTADO] (X/Y aprovados, Z% cobertura)
Dados:      [fixture sintética / arquivo fiscal real]
Segurança:  [APROVADO/REPROVADO] (X problemas)
Diff:       [X arquivos alterados]

Resultado:  [PRONTO / NÃO PRONTO] para PR
Maturidade: [validado com fixture / validado com arquivo real]

Problemas a corrigir:
1. ...
2. ...
```

## Modo contínuo

Em sessões longas, rode esta verificação:
- ao terminar cada função
- ao terminar cada componente ou regra
- antes de passar para a próxima tarefa
