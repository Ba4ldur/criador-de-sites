# PRODUCT-BRIEF — Ponto eletrônico via celular (Attivare)

> Diagnóstico gerado com a skill `product-lens` (Modo 1) em 28/09/2026.
> Legenda: **[FATO]** = informado por você · **[INFERÊNCIA]** = deduzido dos fatos · **[HIPÓTESE]** = precisa ser validado · **[VERIFICAR]** = confirmar em fonte oficial ou com profissional habilitado.

## Recomendação: **NÃO CONSTRUIR agora.** Primeiro veja se o ponto é mesmo obrigatório para vocês e, se precisar de ponto eletrônico, contrate um app pronto.

Construir faz sentido só se a meta mudar para **vender o sistema aos clientes da Attivare**. Aí seria outro produto, com outro diagnóstico (ver seção 9).

---

## 1. Para quem é?
- **[FATO]** Uso interno da Attivare.
- **[FATO]** Até 20 empregados na fase inicial.

## 2. Qual é a dor?
- **[FATO]** O custo do relógio de ponto físico (REP).
- **[LACUNA]** Faltam números: quanto custa hoje (compra, manutenção, bobina, suporte) e quanto se gasta por mês no fechamento. Sem esses números não dá para comparar com a alternativa.
- **[INFERÊNCIA]** Se o problema é o custo do relógio, trocar por um app é justo. A questão é se vale **construir** esse app ou **contratar** um.

## 3. Por que agora?
- **[LACUNA]** Não ficou claro. Pode ser que o relógio atual quebrou, o contrato está vencendo ou vão contratar gente para trabalho externo. Isso muda a urgência.

## 4. O ponto é obrigatório para vocês? (achado mais importante)
- **[FATO normativo]** CLT, art. 74, §2º (redação da Lei 13.874/2019): o registro de ponto é **obrigatório para estabelecimentos com mais de 20 trabalhadores**.
- **[INFERÊNCIA]** Com até 20 empregados **por estabelecimento**, a Attivare pode não ter obrigação legal de controlar ponto. Nesse caso, o relógio físico talvez nem seja necessário.
- **[VERIFICAR]** O limite conta **por estabelecimento**. Confirme quantos trabalhadores há em cada unidade ou filial e se a convenção coletiva da categoria exige controle de jornada mesmo abaixo de 20.
- **[TRADE-OFF]** Deixar de controlar o ponto tem custo. Numa ação trabalhista por horas extras, a empresa sem registro fica com pouca prova. Para empresas com mais de 20, a Súmula 338 do TST põe o ônus da prova no empregador. Abaixo de 20, a falta de registro é prova fraca para o próprio empregador. **[VERIFICAR com advogado trabalhista]**
- **[OPÇÃO]** A CLT, art. 74, §4º, permite o **registro de ponto por exceção** (só horas extras, faltas e atrasos) mediante acordo individual escrito, convenção ou acordo coletivo. Isso pode resolver a dor quase de graça.

## 5. Versão "10 estrelas"
Um app que registra o ponto sem esforço, com cerca virtual. Ele gera o comprovante ao trabalhador, calcula banco de horas e horas extras e integra com a folha. Também produz os arquivos exigidos (AFD e AEJ), guarda trilha de auditoria de toda correção e tem modo offline. Obs.: tudo isso já existe pronto no mercado.

## 6. MVP (se fosse construir)
Marcação pelo celular com cerca virtual, horário vindo do servidor (não do aparelho), comprovante ao trabalhador, espelho de ponto mensal e registro de correções que não pode ser apagado.

**[INFERÊNCIA]** Mesmo esse MVP já esbarra em exigências legais (seção 8). Não existe versão "simples" de ponto eletrônico que dispense conformidade.

## 7. Antiobjetivos (o que NÃO construir)
- Biometria facial ou selfie (dado sensível pela LGPD, art. 5º, II; custo alto de conformidade).
- Rastreamento contínuo de localização (só no momento da marcação).
- Cálculo de folha de pagamento (fica no sistema de folha).
- Edição de marcação sem registro do que foi alterado.

## 8. Riscos (se construir internamente)
| Risco | Detalhe | Grau |
|---|---|---|
| Não conformidade com a Portaria MTP 671/2021 | Um app de ponto provavelmente se enquadra como **REP-P** (registro de ponto por programa). **[VERIFICAR]** os requisitos no texto vigente da portaria. Entre os que lembro, sem certeza: registro do programa no INPI, atestado técnico e termo de responsabilidade, comprovante com assinatura eletrônica, geração de AFD e AEJ. | Alto |
| Mudança da norma | A regra de ponto eletrônico mudou várias vezes (Portaria 1.510/2009, depois Portaria 671/2021). Quem constrói precisa acompanhar e atualizar. | Médio |
| Prova fraca em ação trabalhista | Sem trilha de auditoria e horário confiável, o registro pode ser questionado na Justiça. | Alto |
| LGPD na cerca virtual | Localização é dado pessoal. Exige finalidade clara, coleta só no momento da marcação, aviso ao empregado e prazo de guarda definido. | Médio |
| Custo de manutenção | Com até 20 usuários, o custo de construir e manter tende a superar a assinatura de um app pronto. **[HIPÓTESE]** | Alto |
| Celular de uso pessoal | Usar o aparelho pessoal do empregado pode gerar discussão sobre custo e sobre registro fora do horário. **[VERIFICAR]** | Baixo/Médio |

## 9. Quem paga e quanto?
- **Uso interno:** a Attivare paga e não tem receita. A conta é: custo do REP físico atual × assinatura de um app pronto × custo de construir e manter.
- **[HIPÓTESE]** Apps de ponto por celular prontos cobram por empregado por mês. Com até 20 pessoas, o total tende a ficar bem abaixo do custo de desenvolver. **[VERIFICAR]** os preços atuais de 3 fornecedores (a skill `market-research` pode fazer isso).
- **Virada que mudaria a recomendação:** se a Attivare atende clientes (por exemplo, como escritório contábil) e quer oferecer ponto integrado à folha que já processa, aí o produto pode ter receita e diferencial. Nesse caso, refazer este diagnóstico com os clientes como público.

## 10. Como saber se funciona?
- Custo mensal do controle de ponto (antes e depois).
- Tempo do fechamento mensal do ponto (antes e depois).
- Número de correções manuais por mês.
- Zero marcações sem comprovante.

---

## Próximos passos
1. **Confirmar a obrigação:** quantos trabalhadores há por estabelecimento e o que diz a convenção coletiva (CLT art. 74, §2º). → Responsável: você ou o jurídico.
2. **Levantar o custo atual** do REP físico (R$/mês) e o tempo gasto no fechamento.
3. **Avaliar o registro por exceção** (CLT art. 74, §4º) como alternativa de custo quase zero.
4. **Se precisar de ponto eletrônico:** comparar 3 apps de REP-P prontos (preço, cerca virtual, comprovante, integração com a folha). Posso fazer isso com a skill `market-research`.
5. **Construir só se** a decisão for vender o sistema aos clientes. Nesse caso, novo diagnóstico e depois `/plan`.
