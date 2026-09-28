---
name: product-lens
description: Valida o "porquê" antes de construir, com quatro diagnósticos de produto — diagnóstico no estilo aceleradora que gera um PRODUCT-BRIEF.md com recomendação seguir/não seguir, revisão com olhar de fundador, auditoria da jornada do usuário (tempo até o primeiro resultado) e priorização de funcionalidades por ICE. Use antes de criar um produto ou ferramenta nova, ao escolher entre funcionalidades, antes de um lançamento, ou para transformar uma ideia vaga em um resumo de produto.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Lente de Produto — pense antes de construir

Responda sempre em português do Brasil.

Esta skill cuida do diagnóstico do produto, não da especificação técnica. Depois de decidir "sim, vamos construir", o próximo passo é o comando `/plan`.

## Quando usar

- Antes de começar qualquer produto ou funcionalidade: validar o "porquê"
- Revisão periódica: estamos construindo a coisa certa?
- Quando houver dúvida entre funcionalidades
- Antes de um lançamento: conferir a jornada do usuário
- Para transformar uma ideia vaga em um resumo de produto antes de planejar a parte técnica

## Como funciona

### Modo 1: diagnóstico do produto

Faz as perguntas difíceis:

```
1. Para quem é? (pessoa específica, não "empresas" ou "contadores")
2. Qual é a dor? (quantifique: com que frequência, quão ruim, o que fazem hoje?)
3. Por que agora? (o que mudou que torna isso possível ou necessário?
   ex.: reforma tributária, nova obrigação acessória)
4. Qual a versão "10 estrelas"? (com dinheiro e tempo ilimitados)
5. Qual o MVP? (a menor coisa que prova a tese)
6. Qual o antiobjetivo? (o que você explicitamente NÃO vai construir?)
7. Como saber se está funcionando? (métrica, não impressão)
8. Quem paga e quanto? (preço, canal de venda, margem)
```

Saída: um `PRODUCT-BRIEF.md` com as respostas, os riscos e uma recomendação seguir/não seguir.

Para produtos que envolvem regra fiscal, contábil ou trabalhista, inclua nos riscos: dependência de legislação que pode mudar, necessidade de atualização periódica e responsabilidade por cálculo errado.

### Modo 2: revisão com olhar de fundador

Analisa o projeto atual como um fundador analisaria:

```
1. Ler README, CLAUDE.md, arquivos de configuração, commits recentes
2. Deduzir: o que isto está tentando ser?
3. Pontuar sinais de encaixe produto-mercado (0-10):
   - Trajetória de uso
   - Indícios de retenção (clientes que voltam)
   - Sinais de receita (página de preço, integração de pagamento, vendas)
   - Vantagem competitiva (o que é difícil de copiar?)
4. Identificar: a única coisa que multiplicaria o resultado
5. Apontar: o que está sendo construído e não importa
```

### Modo 3: auditoria da jornada do usuário

Mapeia a experiência real do usuário:

```
1. Usar o produto como um usuário novo
2. Documentar cada atrito (passos confusos, erros, falta de instrução)
3. Cronometrar cada passo
4. Comparar com o onboarding de concorrentes
5. Pontuar o tempo até o primeiro resultado útil
6. Recomendar as 3 principais correções no onboarding
```

### Modo 4: priorização de funcionalidades

Quando há 10 ideias e é preciso escolher 2:

```
1. Listar todas as funcionalidades candidatas
2. Pontuar cada uma: impacto (1-5) × confiança (1-5) ÷ esforço (1-5)
3. Ordenar pela pontuação ICE
4. Aplicar restrições: caixa, tamanho da equipe, dependências
5. Saída: roteiro priorizado com justificativa
```

## Saída

Todos os modos geram documentos acionáveis, não redações. Cada recomendação tem um próximo passo específico.

Diferencie sempre o que é fato (dado fornecido pelo usuário ou verificado), inferência e hipótese a validar.

## Integração

- `/plan` para transformar o resumo aprovado em plano de implementação
- `browser-qa` para confirmar os achados da auditoria de jornada
- `market-research` para validar tamanho de mercado e concorrentes
