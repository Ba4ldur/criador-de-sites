---
name: postgres-patterns
description: Padrões de banco PostgreSQL para otimização de consultas, modelagem de tabelas, índices e segurança, baseados nas boas práticas do Supabase. Use ao criar tabelas, índices ou políticas de RLS, ou quando uma consulta estiver lenta.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Padrões PostgreSQL

Referência rápida de boas práticas de PostgreSQL.

Responda sempre em português do Brasil.

## Quando ativar

- Ao escrever consultas SQL ou migrações
- Ao modelar tabelas
- Ao investigar consultas lentas
- Ao implementar Row Level Security (RLS)
- Ao configurar pool de conexões

## Referência rápida

### Guia de índices

| Padrão da consulta | Tipo de índice | Exemplo |
|--------------|------------|---------|
| `WHERE col = valor` | B-tree (padrão) | `CREATE INDEX idx ON t (col)` |
| `WHERE col > valor` | B-tree | `CREATE INDEX idx ON t (col)` |
| `WHERE a = x AND b > y` | Composto | `CREATE INDEX idx ON t (a, b)` |
| `WHERE jsonb @> '{}'` | GIN | `CREATE INDEX idx ON t USING gin (col)` |
| `WHERE tsv @@ query` | GIN | `CREATE INDEX idx ON t USING gin (col)` |
| Faixas de datas em séries temporais | BRIN | `CREATE INDEX idx ON t USING brin (col)` |

### Tipos de dados

| Uso | Tipo correto | Evitar |
|----------|-------------|-------|
| IDs | `bigint` | `int` |
| Textos | `text` | `varchar(255)` |
| Data e hora | `timestamptz` | `timestamp` |
| Dinheiro | `numeric(15,2)` | `float`, `real`, `double precision` |
| Alíquotas e percentuais | `numeric(7,4)` | `float` |
| Sim/não | `boolean` | `varchar`, `int` |

Observações para vocês:
- **IDs no Supabase:** tabelas ligadas a usuários usam `uuid`, porque `auth.users.id` é `uuid`. A recomendação de `bigint` vale para tabelas próprias sem esse vínculo.
- **Valores fiscais:** o original sugeria `numeric(10,2)`, que limita a cerca de 99 milhões. Para faturamento e bases de cálculo, use precisão maior. Quantidades e valores unitários de NF-e podem ter mais de 2 casas decimais; confira as casas de cada campo no leiaute oficial vigente (MOC da NF-e) antes de definir a coluna.
- **CNPJ, CPF, chave de acesso:** guarde como `text`, nunca como número (zeros à esquerda se perdem).

### Padrões comuns

**Ordem do índice composto:**
```sql
-- Colunas de igualdade primeiro, depois as de faixa
CREATE INDEX idx ON notas (status, data_emissao);
-- Serve para: WHERE status = 'pendente' AND data_emissao > '2026-01-01'
```

**Índice de cobertura:**
```sql
CREATE INDEX idx ON clientes (email) INCLUDE (nome, created_at);
-- Evita ler a tabela em SELECT email, nome, created_at
```

**Índice parcial:**
```sql
CREATE INDEX idx ON clientes (email) WHERE deleted_at IS NULL;
-- Índice menor, só com clientes ativos
```

**Política de RLS otimizada:**
```sql
CREATE POLICY politica ON notas
  USING ((SELECT auth.uid()) = user_id);  -- Envolva em SELECT!
```

**UPSERT:**
```sql
INSERT INTO configuracoes (user_id, chave, valor)
VALUES (123, 'tema', 'escuro')
ON CONFLICT (user_id, chave)
DO UPDATE SET valor = EXCLUDED.valor;
```

**Paginação por cursor:**
```sql
SELECT * FROM produtos WHERE id > :ultimo_id ORDER BY id LIMIT 20;
-- Custo constante, ao contrário do OFFSET, que cresce com a página
```

**Fila de processamento:**
```sql
UPDATE tarefas SET status = 'processando'
WHERE id = (
  SELECT id FROM tarefas WHERE status = 'pendente'
  ORDER BY created_at LIMIT 1
  FOR UPDATE SKIP LOCKED
) RETURNING *;
```

### Detecção de antipadrões

```sql
-- Chaves estrangeiras sem índice
SELECT conrelid::regclass, a.attname
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'f'
  AND NOT EXISTS (
    SELECT 1 FROM pg_index i
    WHERE i.indrelid = c.conrelid AND a.attnum = ANY(i.indkey)
  );

-- Consultas lentas (requer a extensão pg_stat_statements)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC;

-- Tabelas com muitas linhas mortas
SELECT relname, n_dead_tup, last_vacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

### Configuração do servidor

**Atenção no Supabase hospedado:** o usuário do projeto não é superusuário, então comandos `ALTER SYSTEM` do original não funcionam lá. Ajustes de servidor são feitos pelo painel ou CLI do Supabase. Tempos limite podem ser definidos por papel, por exemplo:

```sql
ALTER ROLE authenticated SET statement_timeout = '8s';
```

Os comandos abaixo valem apenas para PostgreSQL próprio (instalado por vocês):

```sql
-- Conexões (ajuste conforme a memória)
ALTER SYSTEM SET max_connections = 100;
ALTER SYSTEM SET work_mem = '8MB';

-- Tempos limite
ALTER SYSTEM SET idle_in_transaction_session_timeout = '30s';
ALTER SYSTEM SET statement_timeout = '30s';

-- Monitoramento
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Padrão de segurança
REVOKE ALL ON SCHEMA public FROM public;

SELECT pg_reload_conf();
```

Não rode o `REVOKE ALL ON SCHEMA public` em projeto Supabase sem testar antes: ele pode afetar o acesso dos papéis padrão da plataforma.

---

*Baseado no Supabase Agent Skills (crédito: equipe Supabase) (licença MIT), via ECC.*
