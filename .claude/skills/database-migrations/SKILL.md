---
name: database-migrations
description: "Padrões seguros e reversíveis de migração de banco PostgreSQL/Supabase: mudanças só para frente em produção, renomeação sem parada (expandir-contrair), índices concorrentes, cargas de dados em lotes e plano de reversão. Use ao criar ou alterar tabelas, adicionar coluna ou índice em tabela com dados, migrar dados, planejar reversão ou publicar mudança de banco sem derrubar o sistema."
metadata:
  origin: ECC (traduzido e adaptado para a Attivare; seções de Prisma, Drizzle, Kysely, Django e Go removidas)
---

# Padrões de Migração de Banco

Responda sempre em português do Brasil.

Mudanças de estrutura de banco seguras e reversíveis para sistemas em produção.

## Quando ativar

- Criar ou alterar tabelas
- Adicionar ou remover colunas e índices
- Migrar dados (preencher, transformar)
- Planejar mudanças de estrutura sem parar o sistema
- Configurar o controle de migrações de um projeto novo

## Princípios

1. **Toda mudança é uma migração**: nunca altere o banco de produção à mão (nem pelo editor SQL do painel)
2. **Em produção, migrações só andam para frente**: reverter é uma nova migração para frente
3. **Estrutura e dados em migrações separadas**: nunca misture DDL e DML na mesma migração
4. **Teste com volume de dados real**: uma migração que funciona com 100 linhas pode travar com 10 milhões
5. **Migração publicada é imutável**: nunca edite uma migração que já rodou em produção

## No Supabase

- Crie migrações como arquivos versionados (pasta `supabase/migrations/`), aplicadas pela CLI do Supabase ou pela ferramenta de migração do MCP do Supabase, e não por SQL solto no painel.
- Toda tabela nova precisa de RLS ativo e políticas antes de ir para produção (veja a skill `security-review`).
- Antes de migração arriscada, confirme que existe backup recente e como restaurá-lo no seu plano do Supabase.
- Mostre ao usuário o SQL da migração e peça confirmação antes de aplicar em produção.

## Checklist de segurança da migração

Antes de aplicar qualquer migração:

- [ ] Tem caminho de ida e de volta (ou está marcada explicitamente como irreversível)
- [ ] Não trava a tabela inteira em tabelas grandes (use operações concorrentes)
- [ ] Colunas novas têm valor padrão ou aceitam nulo (nunca NOT NULL sem padrão em tabela existente)
- [ ] Índices criados de forma concorrente em tabelas existentes
- [ ] Carga de dados em migração separada da mudança de estrutura
- [ ] Testada contra uma cópia com dados de volume real
- [ ] Plano de reversão documentado

## Padrões PostgreSQL

### Adicionar coluna com segurança

```sql
-- BOM: coluna que aceita nulo, sem travamento
ALTER TABLE clientes ADD COLUMN site_url TEXT;

-- BOM: coluna com padrão (no Postgres 11+ é instantâneo, sem reescrever a tabela)
ALTER TABLE clientes ADD COLUMN ativo BOOLEAN NOT NULL DEFAULT true;

-- RUIM: NOT NULL sem padrão em tabela existente
ALTER TABLE clientes ADD COLUMN regime TEXT NOT NULL;
-- Falha se já houver linhas, ou exige reescrever/travar a tabela
```

### Adicionar índice sem parar o sistema

```sql
-- RUIM: bloqueia gravações em tabelas grandes
CREATE INDEX idx_notas_chave ON notas (chave_acesso);

-- BOM: não bloqueia gravações
CREATE INDEX CONCURRENTLY idx_notas_chave ON notas (chave_acesso);

-- Atenção: CONCURRENTLY não pode rodar dentro de um bloco de transação.
-- Muitas ferramentas de migração (incluindo a do Supabase) rodam cada arquivo
-- em transação; nesse caso, o índice concorrente precisa de tratamento à parte.
```

### Renomear coluna sem parar o sistema

Nunca renomeie direto em produção. Use o padrão expandir-contrair:

```sql
-- Passo 1: adicionar a coluna nova (migração 001)
ALTER TABLE clientes ADD COLUMN nome_fantasia TEXT;

-- Passo 2: preencher os dados (migração 002, migração de dados)
UPDATE clientes SET nome_fantasia = apelido WHERE nome_fantasia IS NULL;

-- Passo 3: atualizar o código para ler/gravar nas duas colunas
-- Publicar o código

-- Passo 4: parar de gravar na antiga e removê-la (migração 003)
ALTER TABLE clientes DROP COLUMN apelido;
```

### Remover coluna com segurança

```sql
-- Passo 1: remover todas as referências à coluna no código
-- Passo 2: publicar o código sem a referência
-- Passo 3: remover a coluna na migração seguinte
ALTER TABLE notas DROP COLUMN status_antigo;
```

### Migração de grandes volumes de dados

```sql
-- RUIM: atualiza todas as linhas numa transação só (trava a tabela)
UPDATE clientes SET email_normalizado = LOWER(email);

-- BOM: atualização em lotes
DO $$
DECLARE
  tamanho_lote INT := 10000;
  linhas INT;
BEGIN
  LOOP
    UPDATE clientes
    SET email_normalizado = LOWER(email)
    WHERE id IN (
      SELECT id FROM clientes
      WHERE email_normalizado IS NULL
      LIMIT tamanho_lote
      FOR UPDATE SKIP LOCKED
    );
    GET DIAGNOSTICS linhas = ROW_COUNT;
    RAISE NOTICE 'Atualizadas % linhas', linhas;
    EXIT WHEN linhas = 0;
    COMMIT;
  END LOOP;
END $$;
```

Atenção: `COMMIT` dentro de `DO` só funciona quando o bloco **não** está dentro de uma transação externa. Se a ferramenta rodar a migração em transação, faça os lotes por fora (script ou várias execuções).

## Estratégia sem parada (expandir-contrair)

Para mudanças críticas em produção:

```
Fase 1: EXPANDIR
  - Adicionar a coluna/tabela nova (aceitando nulo ou com padrão)
  - Publicar: o sistema grava na ANTIGA e na NOVA
  - Preencher os dados existentes

Fase 2: MIGRAR
  - Publicar: o sistema lê da NOVA e grava nas DUAS
  - Conferir a consistência dos dados

Fase 3: CONTRAIR
  - Publicar: o sistema usa só a NOVA
  - Remover a coluna/tabela antiga em migração separada
```

### Exemplo de cronograma

```
Dia 1: migração adiciona a coluna novo_status (aceita nulo)
Dia 1: publica versão 2 — grava em status e novo_status
Dia 2: roda a migração de preenchimento das linhas existentes
Dia 3: publica versão 3 — lê só de novo_status
Dia 7: migração remove a coluna status antiga
```

## Antipadrões

| Antipadrão | Por que falha | Alternativa |
|-------------|-------------|-----------------|
| SQL manual em produção | Sem histórico, impossível repetir | Sempre usar arquivos de migração |
| Editar migração já publicada | Ambientes ficam diferentes entre si | Criar nova migração |
| NOT NULL sem padrão | Trava a tabela ou falha com dados existentes | Adicionar aceitando nulo, preencher, depois restringir |
| Índice comum em tabela grande | Bloqueia gravações durante a criação | CREATE INDEX CONCURRENTLY |
| Estrutura + dados na mesma migração | Difícil reverter, transações longas | Migrações separadas |
| Remover coluna antes de tirar do código | Erros por coluna inexistente | Tirar do código primeiro, remover na publicação seguinte |
| Tabela nova sem RLS no Supabase | Dados expostos pela API pública | Ativar RLS e políticas na mesma migração que cria a tabela |
