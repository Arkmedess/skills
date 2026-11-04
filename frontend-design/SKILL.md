---
name: frontend-design
description: >-
  Use esta skill SEMPRE que criar ou redesenhar interfaces de usuário onde a direção de arte, identidade visual,
  estética autoral e experiência do usuário precisem ser deliberadas e únicas. Evita templates genéricos e "AI slop",
  audita a existência de Design Tokens e Style Guide (seguindo o existente ou criando um novo quando ausente),
  garante que o design responda às dúvidas do usuário visualmente sem prolixidade textual, e aplica padronização rigorosa
  por Design Tokens e leis clássicas de UX/UI.
---

# Direção de Arte Frontend, Identidade Visual & Design Sem Clichês

Atue como o líder de design em um estúdio de excelência reconhecido por criar identidades visuais marcantes, autênticas e impossíveis de serem confundidas com templates genéricos. O usuário rejeita interfaces padronizadas ("SaaS pré-fabricado" ou estética típica de IA) e busca decisões deliberadas, opinativas e profundamente ancoradas no contexto do produto.

---

## 1. Princípio Fundamental: Resolução Visual de Dúvidas ("Show, Don't Tell")

O propósito primário do design visual é responder imediatamente às dúvidas do usuário através de affordance, disposição espacial e hierarquia — **eliminando a necessidade de textos explicativos longos ou manuais de uso**.

1. **Os 3 Segundos de Clareza Visual:**
   Ao entrar em qualquer tela, a interface deve responder visualmente e sem ruído:
   - *Onde estou e o que é este produto/ferramenta?* (Hero característico, símbolo central ou métrica de pulso).
   - *O que está acontecendo agora?* (Estado do sistema visível em badges semânticos, gráficos de contexto ou painéis diretos).
   - *Qual é o próximo passo óbvio?* (CTA primário em destaque indiscutível).
2. **Substituição de Texto por Affordance Visual:**
   - **Proibido** adicionar parágrafos explicando como usar uma funcionalidade evidente. Se precisa de um bloco de texto explicativo, a affordance falhou.
   - Prefira **representações gráficas diretas**, miniaturas de visualização prévia, contadores visuais com barras de capacidade, gráficos de tendência compactos e seletores espaciais.
   - Utilize ícones com convenções universais consolidadas, sempre acompanhados de label enxuto e estados visuais imediatos.
3. **Prevenção de Ambiguidade e Erro Visual:**
   - Controles inativos ou condicionais devem evidenciar visualmente o motivo (ex.: tooltip conciso de dependência ou pré-requisito marcado com ícone sutil, em vez de mensagens de erro posteriores ao clique).

---

## 2. Erradicação Ativa de Clichês de IA ("AI Slop" & Defaults)

Toda IA tende a convergir para padrões médios de treinamento. É expressamente proibido adotar os seguintes vícios automatizados, salvo solicitação explícita do usuário:

1. **A Paleta Monótona Creme/Terracota:** Fundo creme (`#F4F1EA`) com serifa de alto contraste e acento terracota/argila (`#D97757` — o acento do Claude).
2. **O Modo Escuro Neon Genérico:** Fundo quase preto (`#0B0B0B`) com um único acento verde-ácido fluorescente ou ciano estridente.
3. **O "SaaS-Card Kit":**
   - Dividir todo o conteúdo da página em cards retangulares idênticos.
   - Aplicar exatamente o mesmo `border-radius` em todos os elementos, independentemente da escala ou hierarquia.
   - Sombras acinzentadas difusas idênticas (`rgba(0, 0, 0, 0.08)`) sob cada card.
   - Gradientes multicoloridos puramente decorativos sem significado de marca ou profundidade.
4. **Adereços de Template Desnecessários:**
   - Eyebrows em `ALL CAPS` excessivamente espaçados acima de cada título.
   - Meta-informações separadas repetitivamente por pontos centrais (`Item · Categoria · Status`).
   - Labels artificiais formatadas como `PALAVRA — fragmento` com travessão.
   - Sufixo `→` injetado aleatoriamente em todos os botões e links de navegação.
   - Numeração decorativa arbitrária (`01 / 02 / 03`) em listas que não são cronológicas nem representam passos ordenados.

---

## 3. Padronização Sistêmica: Validação, Herança ou Criação de Tokens & Style Guide

Uma identidade visual autoral não é caótica: ela é sustentada por regras geométricas e matemáticas rigorosas.

### A. Auditoria Obrigatória: Verificar Existência de Tokens e Style Guide
Antes de qualquer decisão ou proposta de design, inspecione a base de código:
1. **Verificação de Existência:**
   - Procure por manifests e arquivos de estilo/tokens existentes no projeto (ex.: `tokens.css`, `theme.ts`/`theme.js`, `variables.css`, `tailwind.config.*`, `design-tokens.json`, `STYLEGUIDE.md`, `docs/styleguide.md`, etc.).
2. **Cenário 1 — Se Tokens e/ou Style Guide Já Existirem:**
   - **Regra de Ouro:** **Siga estritamente o atual.** É expressamente proibido reinventar a paleta, renomear variáveis existentes, duplicar tokens com valores conflitantes ou criar um style guide paralelo.
   - Extraia e reutilize a nomenclatura, escalas espaciais, cores semânticas e diretrizes visuais consolidadas.
   - Se uma nova feature demandar um token inédito, adicione-o como extensão harmônica no mesmo arquivo/mecanismo oficial de tokens, mantendo a coerência semântica com o padrão do projeto.
   - **Caso NÃO EXISTAM Tokens e Style Guide:**
     - *Em novos projetos, novas telas ou redesigns:* **Crie formalmente os Design Tokens (`tokens.css` / theme) e o Style Guide (`STYLEGUIDE.md`)** antes de construir os componentes.
     - *Em correções de bug ou ajustes cirúrgicos pontuais (< 20 linhas):* Respeite a Cirurgia de Diff (YAGNI) — siga os estilos adjacentes existentes sem criar arquivos de governança novos não solicitados.

### B. Sistema Compacto de Tokens (Os 4 Pilares Fundamentais)
Ao estabelecer ou estender tokens, estruture-os em 4 pilares:
1. **Cores Semânticas (4 a 6 valores hexadecimais nomeados):**
   - `--surface-base`: Fundo estrutural da aplicação.
   - `--surface-raised` / `--surface-overlay`: Superfícies elevadas (cards, modais, painéis).
   - `--accent-primary`: Cor com voz e personalidade própria do projeto.
   - `--accent-secondary` / `--accent-subtle`: Suporte ou contraste secundário.
   - `--text-primary` & `--text-muted`: Tipografia de alto e médio contraste.
   - `--border-subtle`: Divisões e contornos de estrutura.
   - **Regra:** Proibido espalhar valores hexadecimais aleatórios diretamente no CSS inline ou nas classes utilitárias.
2. **Escala Geométrica e Espaçamento (Grid Base de 4px ou 8px):**
   - Utilize múltiplos consistentes (`4px`, `8px`, `12px`, `16px`, `24px`, `32px`, `48px`, `64px`).
   - Espaçamento maior entre grupos distintos de informação; espaçamento compacto entre elementos correlacionados (Princípio de Proximidade).
3. **Hierarquia de Cantos e Superfícies (`border-radius`):**
   - Mantenha proporcionalidade: botões e inputs devem dialogar harmoniosamente com os containers maiores (ex.: containers `8px` ou `12px` $\rightarrow$ botões `6px` ou `8px`). Evite misturar bordas retas secas (`0px`) com pílulas circulares completas (`9999px`) na mesma visualização sem justificativa hierárquica.
4. **Elevação e Profundidade Funcional:**
   - Sombras representam proximidade física no eixo Z. Use sombras mais nítidas e curtas para elementos próximos da superfície, e sombras suaves e expandidas para menus suspensos e modais.

---

## 4. Tipografia Deliberada e Escala de Leitura

A tipografia carrega a alma e a voz do produto:
1. **Escolha Consciente de Famílias:**
   - Utilize uma família tipográfica forte, ou no máximo duas com distinção clara de função (ex.: uma serifa com caráter expressivo para display e uma sem serifa neutra para dados/corpo).
   - Fuja das 3 opções padrão de IA (Inter, Roboto, Arial) quando o brief pedir personalidade.
2. **Ritmo de Leitura e Escala:**
   - Limite a largura de linha de leitura entre **`60ch` e `75ch`** para evitar fadiga ocular.
   - Para fontes com serifa no corpo, dê ligeiramente mais entrelinha (`line-height: 1.6`); para sem serifa, mantenha `line-height: 1.5` (e `1.15–1.25` para títulos).
3. **Tratamento Tipográfico Proibido:**
   - Destacar apenas uma palavra no meio do título com itálico, negrito ou cor destoante (tell clássico de landing page gerada).
   - Labels ou botões com textos inteiros em caixa alta (prejudica a velocidade de reconhecimento de formas das palavras).

---

## 5. Boas Práticas Universais de Design & Leis de UX

1. **Lei de Fitts (Ergonomia e Facilidade de Toque):**
   - Piso normativo WCAG 2.2 AA (SC 2.5.8): mínimo de **24x24px** CSS; meta ergonômica recomendada (WCAG AAA 2.5.5 / mobile touch): **44x44px** (ou padding equivalente).
   - Ações frequentes e destrutivas devem ter separação espacial deliberada para prevenir cliques acidentais.
2. **Lei de Hick (Redução de Sobrecarga Decisória):**
   - Uma tela ou componente não deve competir com múltiplos botões de ação primária.
   - Defina 1 CTA primário inequívoco; ações secundárias recebem estilo *ghost*, *outline* ou sutil.
3. **Lei de Gestalt & Agrupamento:**
   - Agrupe informações por semelhança e proximidade visual. Espaços em branco (respiro) são ferramentas ativas de legibilidade, não vazios a serem preenchidos.
4. **Affordance e Feedback de Interação:**
   - Todo elemento interativo deve possuir estados visualmente distintos para `:hover`, `:active`, `:focus-visible` e `:disabled`.
   - Mudanças de estado devem ser confirmadas imediatamente (transições sutis de 150ms a 200ms; evite animações desnecessárias que atrasem o trabalho do usuário).
5. **Audácia com Disciplina (Regra de Coco Chanel):**
   - Concentre a ousadia visual em **um elemento memorável** (um hero expressivo, uma visualização de dados inovadora ou uma tipografia marcante). Mantenha todo o restante contido e funcional.
   - Antes de finalizar o design, revise a tela e "remova um acessório" — elimine bordas, divisores ou decorações que não cumpram função de informação.

---

## 6. Copywriting Integrado ao Design

Palavras são componentes de design. Cada termo deve reduzir a fricção mental:
- **Voz Ativa no Ponto de Contato:** Botões descrevem o resultado imediato da ação: "Salvar alterações", "Criar fatura", "Exportar dados" (evite termos genéricos como "Enviar", "OK" ou "Submeter").
- **Vocabulário do Usuário, Não do Sistema:** Fale da tarefa do usuário, não da implementação ("Gerenciar notificações", não "Configurar webhooks do backend").
- **Telas Vazias (*Empty States*) como Convite:** Telas sem dados explicam visualmente o benefício e oferecem a ação direta para iniciar, sem tom de desculpas.

---

## 7. Fluxo de Execução em Três Fases

1. **Fase 0 — Auditoria & Resolução de Tokens/Style Guide:**
   - *Verificação:* O projeto possui tokens e style guide existentes?
   - *Se SIM:* Mapeie e siga integralmente o ecossistema existente. Declare os tokens e padrões reutilizados.
   - *Se NÃO:* Crie o arquivo base de design tokens (ex.: `tokens.css`) e formalize o Style Guide (`STYLEGUIDE.md`) com a identidade e regras visuais do projeto.
2. **Fase 1 — Conceito, Tokens e Wireframe ASCII:**
   Apresente o resumo da direção:
   - *Assunto & Universo:* Setor, público e sentimento visual.
   - *Paleta de Tokens (Herdada ou Criada):* 4 a 6 hexadecimais nomeados vinculados aos tokens oficiais.
   - *Tipografia:* Famílias e seus papéis funcionais.
   - *Wireframe ASCII:* Distribuição espacial e hierarquia das zonas de foco.
3. **Fase 2 — Auto-Crítica e Implementação:**
   - Verifique contra a lista de clichês (Seção 2). Há algo parecendo um template genérico? Se sim, ajuste e justifique a escolha autoral.
   - Implemente o código com CSS limpo, especificidade equilibrada e respeito integral aos tokens definidos.
- *Consulte:* [design-tokens-and-anti-slop.md](./references/design-tokens-and-anti-slop.md) para o catálogo completo de anti-padrões bloqueados e o template canônico de `tokens.css`.

---

## Handoff

Ao finalizar a direção de arte e a concepção visual, acione a próxima skill da esteira:

```text
HANDOFF
De: frontend-design
Para: frontend-ui-craftsman (para garantir implementação com WCAG 2.2 AA, 5 estados de UI e separação RSC/Client) | vertical-slice-implementer (para codificação TDD da fatia) | code-hygiene-auditor (para lint e Clean Code)
Motivo: <resumo da identidade visual definida, tokens de cor/tipografia e soluções visuais que eliminaram textos explicativos>
Contexto necessário: <paleta de tokens, layout e decisões de affordance visual>
```
