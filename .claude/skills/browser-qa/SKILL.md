---
name: browser-qa
description: "Verificação automatizada de sites e ferramentas web publicados usando automação de navegador (Claude in Chrome, Playwright ou Puppeteer): erros de console, Core Web Vitals, teste de formulários e fluxos, capturas de tela em três larguras e auditoria de acessibilidade, terminando com veredito PUBLICAR / NÃO PUBLICAR. Use depois de publicar um site, landing page ou ferramenta HTML, antes de entregar ao cliente, ou para conferir layout responsivo e acessibilidade."
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# Browser QA — Teste visual e de interação automatizado

Responda sempre em português do Brasil.

## Quando usar

- Depois de publicar um site ou ferramenta em ambiente de teste ou produção
- Para conferir o comportamento da interface em várias páginas
- Antes de entregar ao cliente: confirmar que layout, formulários e botões funcionam de verdade
- Ao revisar alterações de front-end
- Em auditorias de acessibilidade e responsividade

## Como funciona

Usa a automação de navegador (Claude in Chrome, Playwright ou Puppeteer) para interagir com as páginas como um usuário real.

### Segurança primeiro: modo somente leitura por padrão

O teste usa login e fluxos reais, então o raio de impacto deve ser tratado explicitamente.
Padrão é **somente leitura**: nunca execute ação que altera dados (pagamento, exclusão, envio de formulário real, disparo de WhatsApp ou e-mail) em URL de produção sem autorização explícita do usuário **e** preferencialmente em ambiente de teste.
Use **credenciais de teste**, nunca login real de cliente. **Oculte** senhas, tokens e dados pessoais (CPF, CNPJ, telefone) antes de salvar qualquer captura de tela.

### Fase 1: teste de fumaça
```
1. Abrir a URL
2. Verificar erros no console (ignorar ruído de analytics e terceiros)
3. Confirmar que não há respostas 4xx/5xx nas requisições
4. Capturar a primeira dobra no desktop e no celular
5. Verificar Core Web Vitals: LCP < 2,5s, CLS < 0,1, INP < 200ms
   (limites de referência do web.dev)
```

### Fase 2: teste de interação
```
1. Clicar em todos os links do menu — confirmar que nenhum está quebrado
2. Enviar formulários com dados válidos — confirmar estado de sucesso
3. Enviar formulários com dados inválidos — confirmar mensagem de erro
4. Testar login: entrar → página protegida → sair (só credenciais de teste)
5. Testar as jornadas críticas (simulação, cálculo, contato por WhatsApp)
   — somente leitura por padrão; ações que alteram dados só com autorização
6. Botões de WhatsApp: conferir se o link abre com número e mensagem corretos
   (sem enviar a mensagem)
```

### Fase 3: regressão visual
```
1. Capturar as páginas principais em 3 larguras (375px, 768px, 1440px)
2. Comparar com capturas de referência salvas
   — sem referência ⇒ relatar INCONCLUSIVO, nunca aprovar em silêncio
3. Apontar deslocamentos de layout > 5px, elementos ausentes, conteúdo vazando
4. Conferir modo escuro, se existir
```

### Fase 4: acessibilidade
```
1. Rodar axe-core ou equivalente em cada página
2. Apontar violações WCAG 2.2 AA (contraste, rótulos, ordem de foco)
3. Confirmar que a navegação por teclado funciona do início ao fim
4. Conferir marcos (landmarks) para leitores de tela
```

> Observação: o axe-core cobre automaticamente só cerca de 30–40% da WCAG. Um resultado limpo é **necessário, mas não suficiente**. Navegação por teclado, ordem de foco e leitor de tela ainda exigem checagem manual. Não declare "acessível" só com o teste automático.

## Formato do relatório

```markdown
## Relatório de QA — [URL] — [data e hora]

### Teste de fumaça
- Erros no console: 0 críticos, 2 avisos (ruído de analytics)
- Rede: todas 200/304, sem falhas
- Core Web Vitals: LCP 1,2s ✓, CLS 0,02 ✓, INP 89ms ✓

### Interações
- [✓] Links do menu: 12/12 funcionando
- [✗] Formulário de contato: sem mensagem de erro para e-mail inválido
- [✓] Botão de WhatsApp: número e mensagem corretos

### Visual
- [✗] Seção principal vaza na largura de 375px
- [✓] Modo escuro consistente

### Acessibilidade
- 2 violações AA: imagem principal sem texto alternativo, baixo contraste nos links do rodapé

### Veredito: PUBLICAR COM CORREÇÕES (2 problemas, 0 bloqueios)
# veredito ∈ PUBLICAR / PUBLICAR COM CORREÇÕES / NÃO PUBLICAR; INCONCLUSIVO se não houver referência visual
```

## Integração

Funciona com qualquer ferramenta de navegador:
- Claude in Chrome (preferencial — usa o seu Chrome)
- Playwright
- Scripts diretos de Puppeteer
