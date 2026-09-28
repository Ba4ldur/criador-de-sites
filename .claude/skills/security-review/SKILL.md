---
name: security-review
description: Use esta skill ao implementar login, tratar dados digitados pelo usuário ou arquivos enviados, lidar com chaves e senhas, criar endpoints de API, ou manipular dados sensíveis de clientes (CPF, CNPJ, documentos fiscais). Fornece checklist e padrões de segurança, incluindo pontos de LGPD.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Skill: Revisão de Segurança

Garante que o código siga boas práticas de segurança e identifica vulnerabilidades.

Responda sempre em português do Brasil.

## Quando ativar

- Ao implementar autenticação ou controle de acesso
- Ao tratar dados digitados pelo usuário ou upload de arquivos (XML, SPED, EFD, PDF)
- Ao criar novos endpoints de API
- Ao lidar com chaves, tokens ou senhas
- Ao armazenar ou transmitir dados sensíveis de clientes
- Ao integrar APIs de terceiros

## Checklist de segurança

### 1. Gestão de segredos

#### ERRADO: nunca faça isto
```typescript
const apiKey = "sk-proj-xxxxx"  // Chave escrita no código
const dbPassword = "senha123"   // Senha no código-fonte
```

#### CERTO: sempre faça assim
```typescript
const apiKey = process.env.OPENAI_API_KEY
const dbUrl = process.env.DATABASE_URL

// Confirme que o segredo existe
if (!apiKey) {
  throw new Error('OPENAI_API_KEY não configurada')
}
```

**Atenção no Supabase:** a chave `anon` pode ficar no front-end (desde que o RLS esteja ativo). A chave `service_role` ignora o RLS e **nunca** pode aparecer em HTML, JavaScript de navegador ou repositório.

#### Verificação
- [ ] Nenhuma chave, token ou senha escrita no código
- [ ] Todos os segredos em variáveis de ambiente
- [ ] `.env` e `.env.local` no `.gitignore`
- [ ] Nenhum segredo no histórico do git
- [ ] Chave `service_role` fora de qualquer código de navegador

### 2. Validação de entrada

#### Sempre valide o que o usuário envia
```typescript
import { z } from 'zod'

const CadastroSchema = z.object({
  email: z.string().email(),
  nome: z.string().min(1).max(100),
  cnpj: z.string().regex(/^\d{14}$/)
})

export async function cadastrar(entrada: unknown) {
  try {
    const validado = CadastroSchema.parse(entrada)
    return await db.clientes.create(validado)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.issues }
    }
    throw error
  }
}
```

A regex acima só confere o formato. Para CPF e CNPJ, valide também os dígitos verificadores.

#### Validação de upload de arquivos
```typescript
function validarUpload(arquivo: File) {
  // Tamanho (defina o limite conforme o uso real; arquivos SPED podem ser grandes)
  const tamanhoMax = 50 * 1024 * 1024
  if (arquivo.size > tamanhoMax) {
    throw new Error('Arquivo muito grande')
  }

  // Extensão permitida (lista branca)
  const extensoes = ['.xml', '.txt', '.zip']
  const ext = arquivo.name.toLowerCase().match(/\.[^.]+$/)?.[0]
  if (!ext || !extensoes.includes(ext)) {
    throw new Error('Extensão não permitida')
  }

  return true
}
```

Não confie só na extensão: ao processar XML, valide a estrutura esperada e desative a resolução de entidades externas (proteção contra XXE) se usar um parser que a suporte.

#### Verificação
- [ ] Toda entrada do usuário validada com schema
- [ ] Uploads restritos (tamanho, tipo, extensão, estrutura)
- [ ] Nenhum dado do usuário usado diretamente em consultas
- [ ] Validação por lista branca (não lista negra)
- [ ] Mensagens de erro não revelam informação sensível

### 3. Prevenção de SQL injection

#### ERRADO: nunca concatene SQL
```typescript
// PERIGOSO: vulnerável a SQL injection
const query = `SELECT * FROM clientes WHERE email = '${email}'`
await db.query(query)
```

#### CERTO: sempre use consultas parametrizadas
```typescript
// Seguro: consulta via cliente do Supabase
const { data } = await supabase
  .from('clientes')
  .select('*')
  .eq('email', email)

// Ou SQL puro: o valor vai no array de parâmetros, nunca na string.
// Use a sintaxe de marcador do seu driver (o Postgres numera os
// marcadores; o MySQL usa "?").
await db.query(
  'SELECT * FROM clientes WHERE email = ?',
  [email]
)
```

<!-- Não escreva um marcador literal de cifrão seguido de número neste arquivo.
     Ao invocar a skill com argumentos, ele é substituído e o exemplo acima
     passa a parecer SQL concatenado, justamente o antipadrão alertado aqui. -->

#### Verificação
- [ ] Todas as consultas parametrizadas
- [ ] Nenhuma concatenação de strings em SQL
- [ ] ORM ou query builder usado corretamente

### 4. Autenticação e autorização

#### Armazenamento de token
```typescript
// ERRADO: localStorage (vulnerável a XSS)
localStorage.setItem('token', token)

// CERTO: cookie httpOnly
res.setHeader('Set-Cookie',
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`)
```

Observação: o cliente JavaScript do Supabase guarda a sessão no navegador por padrão. Em sistemas com dados sensíveis, avalie o fluxo com cookies no servidor.

#### Checagem de permissão
```typescript
export async function excluirCliente(clienteId: string, solicitanteId: string) {
  // SEMPRE verifique a permissão antes
  const solicitante = await db.usuarios.findUnique({
    where: { id: solicitanteId }
  })

  if (solicitante.papel !== 'admin') {
    return { error: 'Não autorizado', status: 403 }
  }

  await db.clientes.delete({ where: { id: clienteId } })
}
```

#### Row Level Security (Supabase)
```sql
-- Ative o RLS em todas as tabelas
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;

-- Cada usuário vê apenas os próprios registros
CREATE POLICY "Usuário vê os próprios dados"
  ON clientes FOR SELECT
  USING ((SELECT auth.uid()) = user_id);

-- Cada usuário altera apenas os próprios registros
CREATE POLICY "Usuário altera os próprios dados"
  ON clientes FOR UPDATE
  USING ((SELECT auth.uid()) = user_id);
```

#### Verificação
- [ ] Permissão checada antes de operações sensíveis
- [ ] RLS ativo em todas as tabelas do Supabase
- [ ] Controle de acesso por papel implementado
- [ ] Sessão gerenciada com segurança

### 5. Prevenção de XSS

#### Sanitize HTML vindo do usuário
```typescript
import DOMPurify from 'isomorphic-dompurify'

function exibirConteudo(html: string) {
  const limpo = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
    ALLOWED_ATTR: []
  })
  return limpo
}
```

Em HTML puro, prefira `textContent` a `innerHTML` para exibir dados vindos de arquivos importados (nomes de emitentes, descrições de produtos etc.).

#### Content Security Policy

Comece restritivo e só afrouxe com um plano documentado de remoção. Não use `'unsafe-inline'` ou `'unsafe-eval'` como padrão: eles anulam boa parte da proteção da CSP e devem ser tratados como dívida temporária.

#### Verificação
- [ ] HTML do usuário sanitizado
- [ ] Dados importados exibidos com `textContent`, não `innerHTML`
- [ ] Cabeçalhos de CSP configurados
- [ ] Nenhuma renderização dinâmica sem validação

### 6. Proteção contra CSRF

```typescript
res.setHeader('Set-Cookie',
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict`)
```

#### Verificação
- [ ] Token CSRF em operações que alteram dados
- [ ] SameSite=Strict nos cookies

### 7. Limite de requisições (rate limiting)

```typescript
import rateLimit from 'express-rate-limit'

const limitador = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100,                 // 100 requisições por janela
  message: 'Muitas requisições'
})

app.use('/api/', limitador)
```

#### Verificação
- [ ] Limite em todos os endpoints de API
- [ ] Limites mais rígidos em operações pesadas
- [ ] Limite por IP e por usuário autenticado

### 8. Exposição de dados sensíveis

#### Logs
```typescript
// ERRADO: registrar dados sensíveis
console.log('Login:', { email, senha })
console.log('Cliente:', { cpf, nome, faturamento })

// CERTO: registrar só o necessário
console.log('Login:', { userId })
console.log('Cliente:', { clienteId })
```

#### Mensagens de erro
```typescript
// ERRADO: expor detalhes internos
catch (error) {
  return { error: error.message, stack: error.stack, status: 500 }
}

// CERTO: mensagem genérica para o usuário
catch (error) {
  console.error('Erro interno:', error)
  return { error: 'Ocorreu um erro. Tente novamente.', status: 500 }
}
```

#### Verificação
- [ ] Nenhuma senha, token ou segredo em logs
- [ ] Nenhum CPF, CNPJ ou dado fiscal de cliente em logs
- [ ] Mensagens de erro genéricas para o usuário
- [ ] Stack trace nunca exposto ao usuário

### 9. Dados de clientes e LGPD (Lei nº 13.709/2018)

Sistemas contábeis e fiscais lidam com dados pessoais (CPF, nome, endereço, salário) e dados empresariais sigilosos. A LGPD exige tratar só o necessário (art. 6º, III) e adotar medidas de segurança adequadas (art. 46).

#### Verificação
- [ ] Nenhum arquivo fiscal real (XML, SPED, EFD) versionado no repositório
- [ ] Fixtures de teste sintéticas ou anonimizadas (CPF/CNPJ fictícios, valores alterados)
- [ ] Dados processados no navegador não enviados a serviços de terceiros sem necessidade
- [ ] Dados armazenados (Supabase ou outro) com RLS e acesso restrito
- [ ] Política definida de retenção e exclusão dos arquivos importados

Esta seção é um checklist técnico, não parecer jurídico. Dúvidas sobre base legal ou retenção devem ser confirmadas com o encarregado de dados ou com assessoria jurídica.

### 10. Segurança das dependências

```bash
npm audit          # procura vulnerabilidades
npm audit fix      # corrige o que for automático
npm outdated       # pacotes desatualizados
```

```bash
# SEMPRE commite o arquivo de lock
git add package-lock.json
# Em CI/CD, use builds reproduzíveis
npm ci
```

Em HTML de arquivo único que carrega bibliotecas por CDN, fixe a versão exata de cada biblioteca.

#### Verificação
- [ ] Dependências atualizadas
- [ ] `npm audit` sem vulnerabilidades conhecidas
- [ ] Arquivo de lock commitado
- [ ] Bibliotecas de CDN com versão fixa

## Testes de segurança automatizados

```typescript
test('exige autenticação', async () => {
  const response = await fetch('/api/protegido')
  expect(response.status).toBe(401)
})

test('exige papel de admin', async () => {
  const response = await fetch('/api/admin', {
    headers: { Authorization: `Bearer ${tokenUsuarioComum}` }
  })
  expect(response.status).toBe(403)
})

test('rejeita entrada inválida', async () => {
  const response = await fetch('/api/clientes', {
    method: 'POST',
    body: JSON.stringify({ email: 'nao-e-email' })
  })
  expect(response.status).toBe(400)
})
```

## Checklist antes de publicar em produção

- [ ] **Segredos**: nada no código, tudo em variáveis de ambiente
- [ ] **Entradas**: todas validadas
- [ ] **SQL injection**: todas as consultas parametrizadas
- [ ] **XSS**: conteúdo do usuário sanitizado
- [ ] **CSRF**: proteção ativa
- [ ] **Autenticação**: tokens tratados corretamente
- [ ] **Autorização**: checagem de papéis
- [ ] **Rate limiting**: ativo nos endpoints
- [ ] **HTTPS**: obrigatório em produção
- [ ] **Cabeçalhos de segurança**: CSP e X-Frame-Options configurados
- [ ] **Erros**: nenhum dado sensível nas mensagens
- [ ] **Logs**: nenhum dado sensível registrado
- [ ] **Dependências**: atualizadas e sem vulnerabilidades
- [ ] **RLS**: ativo no Supabase
- [ ] **CORS**: configurado corretamente
- [ ] **Uploads**: validados (tamanho, tipo, estrutura)
- [ ] **LGPD**: nenhum dado real de cliente no repositório ou em logs

## Referências

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Segurança no Supabase](https://supabase.com/docs/guides/auth)
- [Web Security Academy](https://portswigger.net/web-security)

---

**Lembre-se**: segurança não é opcional. Uma única vulnerabilidade pode comprometer a plataforma inteira e os dados dos clientes. Na dúvida, escolha o caminho mais cauteloso.
