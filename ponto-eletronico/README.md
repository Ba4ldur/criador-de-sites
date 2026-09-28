# Ponto Attivare

App web de ponto pelo celular. Os funcionários entram com **código + PIN**, sem precisar de conta em nenhum serviço.

- `app/`: o site (abre no navegador do celular)
- `supabase/schema.sql`: o banco de dados

## O que ele faz

**Funcionário**
- Registra entrada e saída com um toque.
- Vê as horas trabalhadas no dia e o espelho do mês.
- Pode desfazer uma marcação errada em até 2 minutos.

**Administrador** (abas extras: Equipe, Funcionários, Local)
- Vê as marcações de qualquer funcionário por mês e exporta o CSV.
- Inclui uma marcação esquecida ou anula uma marcação. As duas coisas exigem motivo e ficam registradas. **Nenhuma marcação é apagada.**
- Cadastra funcionários, troca PIN e desativa acesso.
- Configura a **cerca virtual**: o ponto só é aceito a até X metros do escritório.

**Proteções**
- O horário gravado é o do **servidor**, não o do celular.
- Cinco PINs errados bloqueiam o código por 15 minutos.
- A chave pública do app só consegue chamar as funções do sistema. As tabelas ficam fechadas.
- A localização é usada só para conferir a distância na hora da marcação. Fica gravada apenas a distância em metros, não as coordenadas.

## Instalação (uns 15 minutos)

### 1. Criar o banco no Supabase (gratuito)
1. Crie uma conta em https://supabase.com e um **projeto novo**, só para o ponto. Região sugerida: *South America (São Paulo)*.
2. No painel do projeto, abra **SQL Editor**, cole todo o conteúdo de `supabase/schema.sql` e clique em **Run**.
3. Ainda no SQL Editor, crie o primeiro administrador (troque o nome e o PIN):
   ```sql
   select criar_funcionario('ADM1', 'Seu Nome', '123456', true);
   ```

### 2. Ligar o app ao banco
1. No Supabase, abra **Project Settings > API** (ou **API Keys**) e copie:
   - a **Project URL** (ex.: `https://abcd1234.supabase.co`);
   - a chave **pública**, chamada `anon` ou `publishable`. **Nunca use a `service_role` / `secret`.**
2. Cole as duas em `app/config.js`.

### 3. Publicar o site
O site precisa estar em **https** para o celular liberar a localização. Um jeito simples e gratuito é o Netlify Drop:
1. Acesse https://app.netlify.com/drop.
2. Arraste a pasta `app` inteira.
3. O Netlify gera um endereço `https://...netlify.app`. É esse link que você manda para a equipe.

Qualquer hospedagem de site estático com https também serve (Vercel, Cloudflare Pages, GitHub Pages).

### 4. Configurar e distribuir
1. Abra o link, entre como administrador e vá em **Local**. Estando no escritório, toque em **Usar minha localização atual**, ajuste o raio (sugestão: 100 a 150 m) e salve.
2. Em **Funcionários**, cadastre cada pessoa com um código (ex.: `F01`) e um PIN.
3. Mande a cada um o link, o código e o PIN. No celular, vale usar **Adicionar à tela inicial** para abrir como um app.

## Limites

- **Isto é controle interno de jornada, não um REP-P homologado** nos termos da Portaria MTP 671/2021. Ele não gera AFD/AEJ nem comprovante com assinatura eletrônica. Para até 20 empregados por estabelecimento, a CLT (art. 74, §2º) não obriga o registro de ponto. Se a Attivare passar disso, ou se a convenção coletiva exigir, reavalie com o jurídico.
- **A localização pode ser falsificada** por quem instala um app de GPS falso. A cerca virtual dificulta, mas não impede.
- **O plano gratuito do Supabase pausa projetos parados** (hoje, depois de cerca de 1 semana sem uso). Com uso diário isso não deve acontecer. Confira a política atual no site do Supabase.
- **O PIN é a única senha.** Oriente a equipe a não compartilhar e troque o PIN de quem sair da empresa. Desativar a pessoa também encerra as sessões abertas dela.
- **Backup:** exporte os CSVs mensalmente ou consulte a política de backup do seu plano no Supabase.
