# Kit Attivare — seleção traduzida do ECC

Origem: repositório github.com/affaan-m/ECC (versão 2.2.2), licença MIT (ver ECC-LICENSE-MIT.txt).
Traduzido e adaptado para a Attivare. Os hooks do ECC NÃO fazem parte deste kit.

## Desenvolvimento (Claude Code)
| Item | Tipo | Uso |
|---|---|---|
| /plan | comando | Plano antes de codar; espera sua aprovação |
| /code-review | comando | Revisão das alterações ou de um PR |
| verification-loop | skill | Validação real com relatório APROVADO/REPROVADO |
| tdd-workflow | skill | Teste antes do código, com relatório de evidências |
| security-review | skill | Checklist de segurança + LGPD |
| silent-failure-hunter | agent | Caça erros engolidos e falhas silenciosas |
| click-path-audit | skill | Botões que "não fazem nada" em ferramentas HTML |
| browser-qa | skill | Teste do site publicado no navegador |
| production-audit | skill | "Está pronto para lançar?" com nota e bloqueios |
| postgres-patterns | skill | Boas práticas de banco (Supabase) |
| database-migrations | skill | Migrações de banco seguras |
| context-budget | skill | Auditoria de excesso de skills/MCP no contexto |

## Negócio e marketing (Claude Code e claude.ai)
| Item | Uso |
|---|---|
| product-lens | Validar um produto antes de construir (seguir/não seguir) |
| market-research | Pesquisa de mercado e concorrentes com fontes |
| marketing-campaign | Campanha completa de lançamento |
| brand-voice | Perfil de voz a partir de textos reais |
| brand-discovery | Entrevista de marca em 8 módulos (rebranding) |
| content-engine | Posts e roteiros nativos de cada rede |
| article-writing | Artigos, blog, circulares a clientes |
| seo | SEO técnico, local e de conteúdo |

## Instalação
- Claude Code: extraia a pasta .claude na raiz do repositório e faça commit.
- claude.ai: extraia o kit-attivare-claude-ai.zip e envie cada zip de dentro dele como uma skill.
