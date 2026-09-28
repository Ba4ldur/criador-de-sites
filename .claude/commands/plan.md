---
description: Reescreve os requisitos, avalia riscos e cria um plano de implementação passo a passo. ESPERA a confirmação do usuário antes de tocar em qualquer código.
argument-hint: "[descrição da funcionalidade | caminho/para/arquivo.md]"
---

# Comando /plan

Este comando cria um plano de implementação completo **antes** de escrever qualquer código. Aceita requisitos em texto livre ou um arquivo markdown de especificação.

Responda sempre em português do Brasil. Execute tudo na própria sessão, sem acionar subagentes.

## O que este comando faz

1. **Reescreve os requisitos**: deixa claro o que precisa ser construído
2. **Identifica riscos**: aponta problemas e bloqueios possíveis
3. **Cria o plano em etapas**: divide a implementação em fases
4. **Espera confirmação**: DEVE receber aprovação do usuário antes de prosseguir

## Quando usar

- Ao iniciar uma nova funcionalidade ou regra
- Em mudanças de arquitetura relevantes
- Em refatorações complexas
- Quando vários arquivos ou componentes serão afetados
- Quando os requisitos estão pouco claros ou ambíguos

## Como funciona

O assistente vai:

1. **Analisar o pedido** e reescrever os requisitos em termos claros
2. **Basear o plano nos padrões do código existente**, quando o repositório estiver disponível
3. **Dividir em fases** com passos específicos e executáveis
4. **Identificar dependências** entre componentes
5. **Avaliar riscos** e bloqueios possíveis, incluindo riscos fiscais e de LGPD quando houver dados de cliente
6. **Estimar a complexidade** (Alta/Média/Baixa)
7. **Apresentar o plano** e ESPERAR sua confirmação explícita

## Modos de entrada

| Entrada | Modo | Comportamento |
|---|---|---|
| Caminho de arquivo markdown | Referência | Lê o arquivo como contexto e gera o plano na conversa |
| Texto livre | Conversacional | Gera o plano na conversa |
| Vazio | Esclarecimento | Pergunta o que deve ser planejado |

## Ancoragem nos padrões do projeto

Antes de escrever o plano, procure no código as convenções que a implementação deve seguir. Registre o melhor exemplo de cada categoria, com referência de arquivo:

| Categoria | O que registrar |
|---|---|
| Nomenclatura | Como arquivos, funções, tipos e regras são nomeados na área afetada |
| Tratamento de erros | Como falhas são lançadas, retornadas, registradas ou tratadas |
| Logs | Níveis, formato e o que é registrado |
| Acesso a dados | Padrões de consulta, leitura de arquivos e parsers |
| Testes | Local dos testes, framework, fixtures e estilo das asserções |

Se não existir código parecido, diga isso explicitamente. Não invente um padrão.

## Estrutura do plano

````markdown
# Plano: {Nome da funcionalidade}

**Complexidade**: {Baixa | Média | Alta}

## Resumo
{2 a 3 frases}

## Padrões a seguir
| Categoria | Origem | Padrão |
|---|---|---|
| Nomenclatura | `arquivo:linha` | {descrição curta} |
| Erros | `arquivo:linha` | {descrição curta} |
| Testes | `arquivo:linha` | {descrição curta} |

## Arquivos a alterar
| Arquivo | Ação | Motivo |
|---|---|---|
| `caminho` | CRIAR / ALTERAR / EXCLUIR | {motivo} |

## Tarefas
### Tarefa 1: {nome}
- **Ação**: {o que fazer}
- **Seguir**: {padrão a espelhar}
- **Validar**: {comando que comprova que está correto}

## Validação
```bash
{comandos de validação do projeto}
```

## Riscos
| Risco | Probabilidade | Mitigação |
|---|---|---|

## Aceite
- [ ] Todas as tarefas concluídas
- [ ] Validação executada e aprovada (com a saída mostrada)
- [ ] Padrões seguidos, não reinventados
````

## Exemplo de uso

```
Usuário: /plan cruzar a chave de acesso dos XMLs de NF-e com o registro C100 da EFD ICMS/IPI

Assistente:
# Plano: Cruzamento XML NF-e × EFD ICMS/IPI (C100)

## Requisitos reescritos
- Ler os XMLs de NF-e importados e extrair a chave de acesso (44 dígitos)
- Ler o arquivo da EFD ICMS/IPI e extrair o campo CHV_NFE dos registros C100
- Apontar notas presentes no XML e ausentes na EFD, e vice-versa
- Classificar cada divergência por nível de risco

## Fases
### Fase 1: parser
- Extrair a chave do XML e validar o formato (44 dígitos numéricos)
- Ler as linhas |C100| da EFD pelo delimitador "|"

### Fase 2: motor de cruzamento
- Comparar os dois conjuntos de chaves
- Gerar a lista de divergências com a origem de cada uma

### Fase 3: testes
- Fixtures sintéticas: caso conforme, nota só no XML, nota só na EFD, chave malformada

## Riscos
- ALTO: interpretação errada de layout. Conferir no Guia Prático da EFD ICMS/IPI vigente antes de implementar
- MÉDIO: arquivos grandes (milhares de notas), impacto de desempenho no navegador
- MÉDIO: fixtures sintéticas não cobrem variações reais dos emissores

## Complexidade estimada: MÉDIA

**AGUARDANDO CONFIRMAÇÃO**: posso seguir com este plano? (sim / não / ajustar)
```

(O exemplo acima é só ilustrativo do formato. Os campos e regras reais devem ser confirmados no layout oficial vigente.)

## Observações importantes

**CRÍTICO**: este comando **NÃO** escreve nenhum código até você confirmar o plano explicitamente com "sim", "pode seguir" ou resposta afirmativa equivalente.

Se quiser mudanças, responda com:
- "ajustar: [suas mudanças]"
- "outra abordagem: [alternativa]"
- "pular a fase 2 e fazer a fase 3 primeiro"

## Depois do plano

- Use a skill `verification-loop` para validar o que foi implementado
- Use `/code-review` para revisar a implementação concluída
