---
name: frontend-ui-craftsman
description: >-
  Use esta skill SEMPRE que criar, alterar, revisar ou estilizar interfaces de usuário (Web Frontend em React,
  Next.js, Vue, Svelte, Astro, Laravel Blade/Livewire 3/Inertia.js, HTML/CSS ou Mobile/Desktop em Flutter). Audita a existência de Design Tokens e
  Style Guide (seguindo o atual ou criando um novo caso não exista). Aciona acessibilidade WCAG 2.2 AA,
  Core Web Vitals (LCP, INP, CLS), separação Server/Client Components, gestão de estado limpa, tipografia
  fluida, Design System e completude dos 5 estados de UI.
---

# Artesão de Interfaces Frontend, Acessibilidade (WCAG 2.2) e Web Vitals

## 1. Regra de Ouro de Construção de UI
Nenhuma tela ou componente é entregue apenas com o "caminho feliz". Toda interface assíncrona ou interativa deve implementar obrigatoriamente os **5 Estados de UI**:
1. **Loading:** Skeletons com dimensões reservadas (zero layout shift) ou indicadores de progresso acessíveis (`aria-busy="true"`).
2. **Empty:** Estado vazio informativo e acionável (orientando o usuário sobre como criar o primeiro item ou limpar filtros).
3. **Error:** Mensagem clara em linguagem humana, preservando dados já digitados pelo usuário e oferecendo ação de retentativa (*Retry*).
4. **Overflow / Partial:** Tratamento explícito de textos longos (`truncate`/`line-clamp`), listas extensas (paginação/virtualização) e telas pequenas (320px+).
5. **Success / Populated:** Estado principal com hierarquia visual clara e feedback imediato de mutações.

### Proteção Ativa Contra Concorrência e Double-Submit:
- **Anti Double-Submit:** Todo botão ou ação mutável de formulário/pagamento deve desabilitar imediatamente cliques repetidos durante a execução assíncrona (`disabled`, `aria-busy="true"`), evitando submissões duplicadas.
- **Cancelamento de Buscas (Race Conditions):** Em campos de busca/autocompletes, cancele requisições anteriores em voo via `AbortController`, impedindo que respostas obsoletas sobrescrevam o resultado mais recente.

---

## 2. Arquitetura de Componentes e Fronteiras de Estado

1. **Fronteira Server vs. Client (Next.js App Router / RSC / SSR):**
   - Componentes são *Server Components* por padrão.
   - Adicione `'use client'` **apenas nas folhas interativas da árvore** (onde há `useState`, `useRef` ou event listeners do navegador). Nunca marque layouts inteiros ou páginas raiz como client sem necessidade estrita.
2. **Taxonomia Estrita de Estado (Proibição de `useEffect` Abusivo):**
   - **Estado Derivado:** Calcule durante a renderização (`const fullName = ...` ou `useMemo`). **Proibido** usar `useEffect` + `setState` para sincronizar props ou estados derivados.
   - **Estado de Servidor (Cache Assíncrono):** Use Server Actions, loaders de rota, TanStack Query ou SWR. **Proibido** `fetch` manual dentro de `useEffect` sem tratamento de race condition (`AbortController`), cache e deduplicação.
   - **Estado de Navegação/Filtro:** Persistido na URL (`searchParams`) para permitir compartilhamento de link, refresh e navegação via botão Voltar.
   - **Estado Local Efêmero:** Restrito ao menor componente possível (ex.: abertura de dropdown, foco de input).
3. **Composição vs. Prop Drilling:**
   - Evite componentes monolíticos configurados por dezenas de props booleanas. Prefira *Compound Components* ou passagem de `children`/slots.
   - Consulte `references/component-architecture-and-design.md` para padrões detalhados.

---

## 3. Acessibilidade Obrigatória (WCAG 2.2 Nível AA — Princípios POUR)

1. **HTML Semântico Antes de ARIA:**
   - Use `<button>`, `<a href>`, `<nav>`, `<main>`, `<header>`, `<dialog>`, `<fieldset>` nativos. Nunca use `<div onClick>` para elementos interativos.
2. **Operabilidade Integral por Teclado:**
   - Todo fluxo deve funcionar exclusivamente com `Tab`, `Shift+Tab`, `Enter`, `Space`, `Escape` e setas direcionais.
   - **Proibido** remover outline de foco (`outline: none`) sem substituí-lo por `:focus-visible` de alto contraste.
   - Modais/Drawers devem capturar o foco (*focus trap*), fechar com `Escape` e devolver o foco ao elemento acionador ao fechar.
3. **Formulários, Imagens e Contraste:**
   - Todo campo de formulário exige `<label>` explícito e erros vinculados via `aria-describedby` e `aria-invalid="true"`.
   - Imagens funcionais exigem `alt` descritivo; imagens puramente decorativas exigem `alt=""` e `aria-hidden="true"`.
   - Contraste mínimo de **4.5:1** para texto normal e **3:1** para texto grande/ícones funcionais. Nunca transmita estado (erro/sucesso) usando apenas cor.
   - Consulte `references/wcag-and-web-vitals.md` para o checklist completo de auditoria WCAG 2.2.

---

## 4. Core Web Vitals & Performance de Renderização

1. **LCP (Largest Contentful Paint < 2.5s):**
   - Imagens hero/above-the-fold devem usar `loading="eager"`, `fetchpriority="high"` e formatos modernos (`AVIF`/`WebP`).
   - Imagens fora da dobra inicial devem usar `loading="lazy"` e `decoding="async"`.
2. **INP (Interaction to Next Paint ≤ 200ms):**
   - Aplique *code-splitting* (`React.lazy` / `next/dynamic`) em modais pesados, gráficos e editores ricos.
   - Evite re-renderizações em cascata mantendo referências estáveis e isolando inputs de alta frequência.
3. **CLS (Cumulative Layout Shift < 0.1):**
   - Toda tag `<img>`, `<video>` ou container de anúncio/embed deve declarar `width` e `height` ou `aspect-ratio` explícito no CSS.
   - Fontes web devem usar `font-display: swap` ou `optional` com métricas de fallback alinhadas.

---

## 5. Design System, Tokens e Style Guide: Governança Estrita

1. **Auditoria Prévia Obrigatória (Tokens & Style Guide):**
   - Antes de implementar ou alterar qualquer componente, tela ou folha de estilo, inspecione a base de código para verificar se o projeto já possui Design Tokens e Style Guide configurados (`tokens.css`, `theme.ts`/`theme.js`, `variables.css`, `tailwind.config.*`, `STYLEGUIDE.md`, etc.).
   - **Caso EXISTAM Tokens e/ou Style Guide:** **Siga estritamente o ecossistema atual.** É expressamente proibido usar valores mágicos hexadecimais, medidas arbitrárias fora da escala ou ignorar o style guide em vigor. Todos os componentes devem consumir exclusivamente os tokens existentes (ex.: `var(--surface-base)`, `var(--spacing-md)`).
   - **Caso NÃO EXISTAM Tokens e Style Guide:** Em novas features, telas ou componentes, **crie formalmente o arquivo base de Design Tokens** (ex.: `tokens.css` ou módulo de theme) e o **Style Guide** (em alinhamento com `frontend-design`). Em hotfixes ou ajustes cirúrgicos pontuais, preserve a Cirurgia de Diff seguindo o padrão local sem adicionar arquivos extras não solicitados.
2. **Escala Espacial e Ritmo Visual:**
   - Utilize rigorosamente a escala de espaçamento em múltiplos de `4px`/`8px` definida nos tokens. Proibido espalhar valores arbitrários (`13px`, `27px`).
3. **Tipografia Legível e Fluida:**
   - Largura de linha de leitura entre `60ch` e `75ch`; `line-height: 1.5` para corpo de texto e `1.15–1.25` para títulos; tamanhos fluidos via `clamp()` ou `rem` (nunca `px` fixo para fonte, respeitando o zoom de 200% do usuário).

---

## 6. Testes de UI Centrados no Usuário
- Teste o comportamento visível ao usuário usando queries semânticas (`getByRole`, `getByLabelText`, `getByText`).
- **Proibido** testar estado interno de hooks ou usar seletores de classe CSS/estrutura DOM frágil.

---

## Handoff

Ao concluir a implementação ou auditoria de interface, carregue o `SKILL.md` da próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: frontend-ui-craftsman
Para: test-suite-architect (para suíte de componentes/E2E Playwright) | code-hygiene-auditor (para validação de lint, tipos e Clean Code) | runtime-performance-diagnostician (se houver degradação de Web Vitals/bundle) | module-documentation-scribe (para documentar componentes e contratos de UI)
Motivo: <resumo dos componentes criados/auditados, estados cobertos, conformidade WCAG 2.2 AA e Web Vitals>
Contexto necessário: <arquivos de UI alterados, fronteiras Server/Client definidas e cobertura dos 5 estados>
```

