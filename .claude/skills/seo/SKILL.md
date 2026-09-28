---
name: seo
description: Audita, planeja e implementa melhorias de SEO — SEO técnico, otimização da página, dados estruturados, Core Web Vitals, SEO local e estratégia de conteúdo. Use quando o usuário quiser mais visibilidade no Google para um site ou landing page, corrigir problemas de SEO, criar schema, sitemap/robots ou mapear palavras-chave.
metadata:
  origin: ECC (traduzido e adaptado para a Attivare)
---

# SEO

Responda sempre em português do Brasil.

Melhore a visibilidade nas buscas com correção técnica, desempenho e relevância de conteúdo, não com truques.

## Quando usar

- Auditar rastreamento, indexação, canonicals ou redirecionamentos
- Melhorar títulos, meta descriptions e hierarquia de títulos
- Adicionar ou validar dados estruturados
- Melhorar Core Web Vitals
- Pesquisar palavras-chave e associá-las a páginas
- Planejar links internos, sitemap ou robots.txt
- SEO local para negócios com endereço físico

## Como funciona

### Princípios

1. Corrija bloqueios técnicos antes de otimizar conteúdo.
2. Cada página deve ter uma intenção de busca principal clara.
3. Prefira sinais de qualidade de longo prazo a padrões manipulativos.
4. Pense no celular primeiro: o Google indexa pela versão mobile.
5. Recomendações devem ser específicas por página e implementáveis.

### Checklist de SEO técnico

#### Rastreamento
- `robots.txt` libera as páginas importantes e bloqueia as de pouco valor
- nenhuma página importante marcada como `noindex` sem querer
- páginas importantes a poucos cliques da inicial
- sem cadeias de redirecionamento com mais de dois saltos
- tags canonical consistentes e sem ciclos

#### Indexação
- formato de URL preferido consistente
- páginas em vários idiomas com `hreflang` correto, se houver
- sitemap refletindo as páginas públicas pretendidas
- nenhuma URL duplicada competindo sem canonical

#### Desempenho
- LCP < 2,5s
- INP < 200ms
- CLS < 0,1
- correções comuns: pré-carregar imagens principais, reduzir bloqueio de renderização, reservar espaço no layout, cortar JavaScript pesado, comprimir imagens e vídeos

#### Dados estruturados
- página inicial: `Organization` ou `LocalBusiness` (ou subtipo, ex.: `AccountingService`, `AutoRepair`), quando aplicável
- artigos: `Article` / `BlogPosting`
- produtos: `Product` e `Offer`
- páginas internas: `BreadcrumbList`
- perguntas e respostas: `FAQPage` só quando o conteúdo realmente corresponde

### SEO local (negócios com endereço)

- nome, endereço e telefone (NAP) **idênticos** no site, no Perfil de Empresa no Google e nas redes sociais
- cidade e bairro no título e no conteúdo quando fizer sentido (ex.: "em Teresina")
- schema `LocalBusiness` com endereço, telefone, horário e coordenadas
- mapa incorporado e link para rotas
- página ou seção por serviço principal, não tudo em um parágrafo só
- incentivar avaliações reais no Google (nunca comprar ou inventar)

### Regras da página

#### Títulos (title)
- cerca de 50-60 caracteres
- tema ou palavra-chave principal no início
- legível para pessoas, não recheado para robôs

#### Meta descriptions
- cerca de 120-160 caracteres
- descrever a página com honestidade
- incluir o tema principal de forma natural

#### Hierarquia de títulos
- um único `H1` claro
- `H2` e `H3` refletindo a hierarquia real do conteúdo
- não pular níveis só por causa do visual

### Mapeamento de palavras-chave

1. definir a intenção de busca
2. levantar variações realistas (incluindo como o cliente fala, não o jargão técnico)
3. priorizar por aderência à intenção, valor provável e concorrência
4. associar uma palavra-chave/tema principal a uma URL
5. detectar e evitar canibalização (duas páginas brigando pela mesma busca)

### Links internos

- linkar das páginas fortes para as que você quer posicionar
- usar texto âncora descritivo
- evitar âncoras genéricas ("clique aqui") quando der para ser específico
- ao criar páginas novas, linkar para as existentes relacionadas

## Exemplos

### Fórmula de título
```text
Tema principal - Complemento específico | Marca
```
Exemplo: `Contabilidade para Restaurantes em Teresina | Attivare`

### Fórmula de meta description
```text
Ação + tema + proposta de valor + um detalhe de apoio
```

### Exemplo de JSON-LD (negócio local)
```json
{
  "@context": "https://schema.org",
  "@type": "AccountingService",
  "name": "Nome da Empresa",
  "telephone": "+55-86-0000-0000",
  "address": {
    "@type": "PostalAddress",
    "streetAddress": "Rua Exemplo, 123",
    "addressLocality": "Teresina",
    "addressRegion": "PI",
    "addressCountry": "BR"
  }
}
```
(Dados fictícios: substitua pelos reais e confira no validador de dados estruturados do Google.)

### Formato do resultado da auditoria
```text
[ALTO] Títulos duplicados nas páginas de serviço
Local: servicos.html
Problema: todas as páginas usam o mesmo título padrão, o que enfraquece a relevância e gera sinais duplicados.
Correção: título único por serviço, com o nome do serviço e a cidade.
```

## Antipadrões

| Antipadrão | Correção |
| --- | --- |
| encher de palavras-chave | escrever primeiro para pessoas |
| páginas rasas e quase duplicadas | consolidar ou diferenciar |
| schema para conteúdo que não existe na página | schema deve refletir a realidade |
| recomendar conteúdo sem ler a página | ler a página real primeiro |
| saída genérica "melhore o SEO" | amarrar cada recomendação a uma página ou elemento |

## Skills relacionadas

- `browser-qa` (medir Core Web Vitals no site publicado)
- `brand-voice`
- `market-research`
