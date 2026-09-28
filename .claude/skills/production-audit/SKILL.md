---
name: production-audit
description: Auditoria de prontidão para produção com base em evidências locais — para sistemas e ferramentas antes do lançamento, depois de um merge, ou para responder "o que quebra em produção?", sem enviar dados do repositório a serviços externos. Use antes de lançar ou vender um produto, entregar um sistema a cliente, ou quando perguntarem se algo está pronto.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Auditoria de Produção

Responda sempre em português do Brasil.

Use esta skill quando o usuário perguntar se um sistema está pronto para lançar, o que pode quebrar em produção ou o que precisa ser corrigido antes de um lançamento.

## Quando usar

- Perguntas como "está pronto?", "o que pode quebrar?", "o que esquecemos?", "audite este repositório"
- Uma funcionalidade foi integrada e precisa de uma checagem de risco antes de publicar
- Lançamento público, venda (ex.: Kiwify), demonstração ou entrega a cliente se aproximando
- Os testes passam, mas o usuário quer saber o risco real em produção
- Há URL publicada, branch, PR ou código disponível para coletar evidências

## Quando não usar

- Durante a implementação, quando o foco é segurança linha a linha; use `security-review` antes
- Para bibliotecas, modelos ou repositórios só de documentação
- Quando o pedido é auditoria formal de conformidade. Esta skill é triagem de engenharia, não certificação legal, contábil, fiscal ou regulatória
- Quando só existe a ideia do produto, sem código, publicação ou ambiente

## Como funciona

Monte a auditoria a partir de evidências locais e autorizadas pelo usuário. Não rode código remoto sem versão fixa, não envie conteúdo do repositório a serviços de terceiros e não use scanners externos sem aprovação explícita do usuário para aquela ferramenta e aquele fluxo de dados.

Ordem:

1. Definir o que será lançado
2. Ler as mudanças recentes e o estado atual do branch
3. Inspecionar os pontos que existem de fato no repositório: execução, login, dados, pagamentos, tarefas em segundo plano, IA e publicação
4. Verificar CI, testes, migrações, documentação de variáveis de ambiente e caminho de reversão
5. Entregar uma recomendação curta de lançar/bloquear, com correções específicas

## Checklist de evidências

Comece pelos sinais locais baratos:

```text
git status --short --branch
git log --oneline --decorate -20
git diff --stat origin/main...HEAD
```

Depois inspecione o que for específico do projeto:

- Scripts do projeto, workflows de CI, scripts de publicação
- Rotas de API, webhooks, controle de login, tarefas agendadas e migrações de banco
- Documentação das variáveis de ambiente e checagens na inicialização
- Registro de erros, logs e verificações de saúde
- Instruções de reversão, carga inicial e migração
- Testes de ponta a ponta dos caminhos mais importantes para o usuário

Se houver URL publicada no escopo, faça checagens de navegador ou HTTP só nela e evite ações com login, a não ser com conta de teste fornecida pelo usuário.

## Lentes de risco

### Segurança e acesso
- Rotas públicas, de API e administrativas estão bem separadas?
- Login e permissões são checados no servidor (ou por RLS no Supabase), e não só no navegador?
- Segredos estão fora do código de navegador, dos logs e dos arquivos versionados? (Atenção à chave `service_role` do Supabase.)
- Existem limite de requisições, proteção CSRF, CORS e validação de upload onde o sistema precisa?
- Se houver IA no produto, ela está protegida contra prompt injection e uso indevido de ferramentas?

### Integridade dos dados
- As migrações rodam limpas e têm plano de reversão ou recuperação?
- Migrações destrutivas, cargas e importações são feitas em etapas seguras?
- Políticas de acesso (RLS) e permissões batem com quem deve ver o quê?
- Operações repetidas (reenvio, reprocessamento) são idempotentes?

### Pagamentos e webhooks
- A assinatura dos webhooks (ex.: Kiwify, Stripe) é verificada antes de confiar no conteúdo?
- Cada webhook de pagamento ou liberação de acesso é idempotente?
- Reenvio, duplicidade e ordem trocada de eventos são tratados?
- Credenciais de teste e de produção estão separadas?

### Operação
- O sistema sobe a partir de um clone limpo seguindo a documentação?
- As variáveis de ambiente obrigatórias estão nomeadas, validadas e falham rápido se ausentes?
- Existe verificação de saúde que prova que as dependências respondem?
- Publicação, reversão e responsável por incidentes estão documentados?
- Os logs são úteis sem vazar segredos ou dados pessoais (CPF, CNPJ, dados fiscais)?

### Experiência do usuário
- Os caminhos críticos do lançamento foram testados no desktop e no celular?
- Formulários funcionam no celular sem zoom indesejado, sobreposição ou botão travado?
- Estados de carregamento, vazio, erro e sem permissão explicam o que aconteceu?
- Há caminho de suporte ou recuperação quando uma operação crítica falha?

### Produtos com cálculo fiscal ou financeiro
- Os resultados foram conferidos contra casos calculados manualmente ou por fonte oficial?
- Alíquotas, tabelas e datas de vigência estão em um lugar só e com a data de referência visível ao usuário?
- O produto deixa claro que é estimativa/simulação quando for o caso, e em que premissas se baseia?

## Pontuação

Use a pontuação para forçar prioridade, não para sugerir precisão matemática.

| Faixa | Nota | Significado |
| --- | --- | --- |
| Bloqueado | 0-49 | Não lançar até corrigir os riscos principais |
| Arriscado | 50-69 | Lançar só para poucos usuários ou teste interno |
| Lançável com ressalvas | 70-84 | Lançar se os responsáveis aceitarem os riscos listados |
| Sólido | 85-100 | Nenhum bloqueio evidente com as evidências disponíveis |

Limite a nota a `69` se qualquer um destes for verdade:

- Falta login ou controle de permissão em dados sensíveis
- Webhooks de pagamento ou liberação de acesso não são idempotentes
- Migrações obrigatórias não podem rodar com segurança
- Segredos expostos no código de navegador, em logs ou em arquivos versionados
- Não há caminho de reversão para uma publicação de alto impacto
- Cálculo fiscal ou financeiro não conferido contra casos de referência

Limite a nota a `84` se os testes não estiverem passando ou se o caminho crítico do lançamento não foi testado de ponta a ponta.

## Formato da resposta

Comece com uma frase:

```text
Auditoria de produção: 76/100, lançável com ressalvas; os dois riscos a corrigir antes do lançamento são a idempotência do webhook e a documentação de reversão.
```

Depois liste:

- `Bloqueios`: o que precisa ser corrigido antes de publicar
- `Correções de alto valor`: próximas correções para subir a nota
- `Evidências verificadas`: arquivos, comandos, CI, URL ou PRs inspecionados
- `Evidências ausentes`: o que mudaria a confiança se fosse fornecido
- `Próxima ação`: uma correção ou verificação concreta

Seja breve nos pontos fortes. O usuário pediu prontidão: a resposta útil é o risco restante e a próxima ação.

## Antipadrões

- Rodar `npx <pacote>@latest` ou scanner remoto como caminho padrão da auditoria
- Enviar código, segredos, dados de clientes ou estrutura privada a serviço externo sem aprovação explícita
- Dar nota sem citar as evidências verificadas
- Tratar testes passando como sinônimo de pronto para produção
- Terminar com um genérico "me diga o que você quer fazer"

## Ver também

- Skill: `security-review`
- Skill: `verification-loop`
- Skill: `browser-qa`
