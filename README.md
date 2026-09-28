# Pleno Car — Estética Automotiva: site

Landing page em **um único HTML** (`index.html`), com CSS e JS embutidos. Bibliotecas e fontes via `cdn.jsdelivr.net`:
GSAP 3.15 + ScrollTrigger, Lenis 1.3.26, Saira (eixo de largura) e Inter (fontes variáveis via Fontsource).

## Arquivos
- `index.html`: página completa
- `img/`: fotos otimizadas (WebP), logo, favicon e imagem de compartilhamento (`og.jpg`)
- `originais/`: arquivos enviados. **Os `ia-*.png` são versões tratadas por IA e NÃO são usados no site** (regra: só fotos reais).

## Comportamento
- Lenis (rolagem suave) na página inteira; animações apenas em fotos (máscara + parallax leve) e títulos grandes.
- Sequência 01/03–03/03 fixa só no desktop (≥ 1024 px); no mobile fica empilhada.
- Com `prefers-reduced-motion` ou se o CDN falhar: sem Lenis, sem animação, página completa e estática.

## Pendências
- [ ] **CONFIRMAR** o texto da etapa 01 ("acompanhar o serviço"): versão alternativa está em comentário no `index.html`
- [ ] Fotos originais de câmera/celular sem "upscale": as `foto_*_4K.jpg` foram ampliadas e ficam suaves em tela cheia
- [ ] Confirmar se há outros serviços para a faixa e a lista (hoje: PPF, Ceramic Protection, Black Piano, Pintura e Funilaria)
- [ ] Horário de funcionamento (não publicado)
- [ ] Domínio definitivo: trocar `https://ba4ldur.github.io/criador-de-sites/` (canonical, og:url, og:image e JSON-LD)
- [ ] Logo em vetor (SVG/AI/PDF), se existir
