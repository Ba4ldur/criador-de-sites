---
name: click-path-audit
description: "Rastreia cada botão e ponto de interação da interface por toda a sequência de mudanças de estado, para achar bugs em que as funções funcionam isoladamente mas se anulam, produzem estado final errado ou deixam a tela inconsistente. Use quando um botão 'não faz nada', quando a depuração normal não achou o erro, ou depois de refatorar estado compartilhado em simuladores, calculadoras e ferramentas HTML."
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Auditoria de caminho de clique

Responda sempre em português do Brasil.

Encontra bugs que a leitura do código não pega: efeitos colaterais entre funções, condições de corrida entre chamadas em sequência e ações que desfazem umas às outras em silêncio.

## O problema que resolve

A depuração tradicional verifica:
- A função existe? (ligação faltando)
- Ela quebra? (erro em execução)
- Retorna o tipo certo? (fluxo de dados)

Mas NÃO verifica:
- **O estado final da tela corresponde ao que o rótulo do botão promete?**
- **A função B desfaz em silêncio o que a função A acabou de fazer?**
- **O estado compartilhado (objeto global, store, contexto) tem efeitos colaterais que anulam a ação pretendida?**

Exemplo típico: o botão "Nova simulação" chama `ativarModoEdicao(true)` e depois `selecionarCliente(null)`. As duas funcionam sozinhas. Mas `selecionarCliente` também zera `modoEdicao` como efeito colateral. Resultado: o botão parece não fazer nada.

## Como funciona

Para CADA ponto de interação na área analisada:

```
1. IDENTIFICAR o manipulador (onclick, addEventListener, onsubmit, onchange etc.)
2. RASTREAR cada função chamada no manipulador, NA ORDEM
3. Para CADA chamada:
   a. Que estado ela LÊ?
   b. Que estado ela ESCREVE?
   c. Tem EFEITOS COLATERAIS em estado compartilhado?
   d. Zera ou limpa algum estado como efeito colateral?
4. VERIFICAR: alguma chamada posterior DESFAZ uma mudança anterior?
5. VERIFICAR: o estado FINAL é o que o usuário espera pelo rótulo do botão?
6. VERIFICAR: há condição de corrida (chamadas assíncronas que terminam na ordem errada)?
```

## Passos de execução

### Passo 1: mapear o estado

Antes de auditar qualquer botão, monte o mapa de efeitos colaterais de cada ação sobre o estado:

```
Para cada objeto de estado / store / contexto no escopo:
  Para cada função que o altera:
    - Que campos ela define?
    - Ela ZERA outros campos como efeito colateral?
    - Documente: nomeDaFuncao → {define: [...], zera: [...]}
```

Este mapa é a referência crítica. O bug do exemplo acima é invisível sem saber que `selecionarCliente` zera `modoEdicao`.

**Formato:**
```
ESTADO: estadoSimulador
  ativarModoEdicao(bool) → define: {modoEdicao}
  selecionarCliente(cliente|null) → define: {clienteAtual, resultados} ZERA: {modoEdicao: false, parcelas: []}
  recalcular() → define: {resultados, totais}

ZERAMENTOS PERIGOSOS (funções que limpam estado que não é delas):
  selecionarCliente → zera modoEdicao (que pertence a ativarModoEdicao)
  reiniciar → zera tudo
```

### Passo 2: auditar cada ponto de interação

```
PONTO: [rótulo do botão] em [arquivo:linha]
  MANIPULADOR: onclick → {
    chamada 1: funcaoA() → define {X: true}
    chamada 2: funcaoB() → define {Y: null} ZERA {X: false}  ← CONFLITO
  }
  ESPERADO: o usuário vê [o que o rótulo promete]
  REAL: X é false porque funcaoB o zerou
  VEREDITO: BUG — [descrição]
```

**Verifique cada um destes padrões de bug:**

#### Padrão 1: desfazer em sequência
```
manipulador() {
  definirA(true)     // X = true
  definirB(null)     // efeito colateral: X = false
}
// Resultado: X é false. A primeira chamada foi inútil.
```

#### Padrão 2: corrida assíncrona
```
manipulador() {
  buscarA().then(() => estado.carregando = false)
  buscarB().then(() => estado.carregando = true)
}
// Resultado: o estado final depende de qual termina primeiro
```

#### Padrão 3: valor capturado desatualizado
```
let total = estado.total
botao.onclick = () => {
  estado.total = total + 1  // usa valor antigo capturado
}
```

#### Padrão 4: transição de estado ausente
```
// Botão diz "Salvar", mas o manipulador só valida e nunca salva
// Botão diz "Excluir", mas só marca uma flag sem chamar a API
// Botão diz "Exportar", mas a função de exportação foi removida
```

#### Padrão 5: caminho morto por condição
```
manipulador() {
  if (algumEstado) {       // algumEstado é SEMPRE false neste ponto
    fazerAAcaoDeVerdade()  // nunca executa
  }
}
```

#### Padrão 6: interferência de observador
```
// O botão define estadoX = true
// Um observador (useEffect, listener, setInterval) vigia estadoX e o volta para false
// O usuário não vê nada acontecer
```

#### Padrão 7: tela não atualizada
```
// O manipulador altera o estado corretamente,
// mas a função que redesenha a tela (render/atualizarTela) não é chamada
// O usuário vê o valor antigo
```

### Passo 3: relatório

Para cada bug encontrado:

```
CLIQUE-NNN: [gravidade: CRÍTICO/ALTO/MÉDIO/BAIXO]
  Ponto: [rótulo do botão] em [arquivo:linha]
  Padrão: [Desfazer em sequência / Corrida assíncrona / Valor desatualizado / Transição ausente / Caminho morto / Interferência de observador / Tela não atualizada]
  Manipulador: [nome da função ou inline]
  Rastreio:
    1. [chamada] → define {campo: valor}
    2. [chamada] → ZERA {campo: valor}  ← CONFLITO
  Esperado: [o que o usuário espera]
  Real: [o que acontece]
  Correção: [correção específica]
```

Em ferramentas de cálculo (simuladores, precificação, auditoria), trate como **CRÍTICO** qualquer bug que faça a tela exibir um resultado que não corresponde aos dados de entrada atuais.

## Controle de escopo

Esta auditoria é trabalhosa. Ajuste o escopo:

- **Sistema inteiro:** no lançamento ou depois de uma grande refatoração. Mapeie o estado primeiro (Passo 1) e depois audite tela por tela.
- **Uma tela:** depois de construir uma tela nova ou quando alguém relatar um botão quebrado.
- **Foco no estado:** depois de alterar uma função de estado compartilhado, audite todos os pontos que a chamam.

## Quando usar

- Quando a depuração normal "não achou nada", mas o usuário diz que o botão não funciona
- Depois de alterar funções de estado compartilhado
- Depois de qualquer refatoração que mexa em estado compartilhado
- Antes de lançar, nos fluxos críticos
- Quando um botão "não faz nada": esta é A ferramenta para isso

## Quando NÃO usar

- Bugs de API (resposta no formato errado, endpoint ausente)
- Problemas de estilo e layout: inspeção visual (ou skill `browser-qa`)
- Problemas de desempenho: ferramentas de profiling

## Integração com outras skills

- Cada bug encontrado aqui deve ganhar um teste
- Depois das correções, rode a skill `verification-loop`
