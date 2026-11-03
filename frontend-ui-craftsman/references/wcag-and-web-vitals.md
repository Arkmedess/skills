# Checklist WCAG 2.2 AA e Core Web Vitals (LCP, INP, CLS)

## 1. Matriz de Auditoria de Acessibilidade (WCAG 2.2 Nível AA)

| Princípio (POUR) | Critério Crítico | Regra de Implementação e Verificação |
| :--- | :--- | :--- |
| **Perceptível** | Contraste & Cor (1.4.3 / 1.4.11) | Texto normal $\ge 4.5:1$; texto grande ($\ge 18\text{pt}$ ou $14\text{pt}$ bold) e componentes de UI $\ge 3:1$. Estados de erro exigem ícone/texto além da cor vermelha. |
| **Perceptível** | Alternativas em Texto (1.1.1) | `<img alt="Descrição da ação/conteúdo">` para imagens informativas; `<img alt="" aria-hidden="true">` para decorativas. Ícones em botões sem texto exigem `aria-label`. |
| **Perceptível** | Reflow & Zoom (1.4.4 / 1.4.10) | Layout funcional em largura de `320px` e zoom de `200%` sem scroll horizontal em textos de leitura. Usar `rem`/`em` para fontes. |
| **Operável** | Teclado & Foco Visível (2.1.1 / 2.4.7) | Ordem de tabulação lógica (`tabIndex={0}` ou nativo; proibido `tabIndex > 0`). Estilo `:focus-visible` nítido em todos os controles interativos. |
| **Operável** | Tamanho de Alvo de Toque (2.5.8) | Alvos clicáveis/tocáveis com área mínima de `24x24px` CSS (recomendado `44x44px` em mobile) ou espaçamento equivalente. |
| **Compreensível** | Labels e Erros de Input (3.3.1 / 3.3.2) | Todo `<input>`, `<select>`, `<textarea>` associado a um `<label htmlFor="...">`. Mensagens de erro vinculadas via `aria-describedby` e `aria-invalid="true"`. |
| **Robusto** | Regiões Dinâmicas (4.1.2 / 4.1.3) | Toasts, alertas e resultados de busca assíncrona anunciados via `role="status"` (`aria-live="polite"`) ou `role="alert"` (`aria-live="assertive"`). |

---

## 2. Receitas de Otimização de Core Web Vitals

### A. LCP (Largest Contentful Paint — Meta: `< 2.5s`)
- **Ativo Principal Above-the-Fold:**
  ```html
  <picture>
    <source srcset="/hero.avif" type="image/avif" />
    <source srcset="/hero.webp" type="image/webp" />
    <img
      src="/hero.jpg"
      alt="Painel de controle principal"
      width="1200"
      height="675"
      loading="eager"
      fetchpriority="high"
    />
  </picture>
  ```
- **Proibições:** Nunca aplicar `loading="lazy"` na imagem principal do topo da página; nunca bloquear o HTML inicial com scripts síncronos no `<head>`.

### B. INP (Interaction to Next Paint — Meta: `≤ 200ms`)
- **Isolamento de Hidratação e Bundle:**
  - Substituir bibliotecas pesadas (ex.: `moment` $\rightarrow$ `date-fns` ou `Intl.DateTimeFormat` nativo; import seletivo de utilitários).
  - Aplicar *debounce* ou `useDeferredValue`/`startTransition` em filtros de busca e listas pesadas para manter a resposta imediata do input de digitação.
  - Carregar modais complexos, gráficos e editores sob demanda (`lazy(() => import('./HeavyChart'))`).

### C. CLS (Cumulative Layout Shift — Meta: `< 0.1`)
- **Reserva de Espaço Estático:**
  - Sempre definir `width` e `height` ou `aspect-ratio` em mídias e iframes.
  - Componentes de *Skeleton* devem espelhar exatamente a altura mínima (`min-height`) do componente carregado.
  - Nunca inserir banners ou alertas dinâmicos empurrando o conteúdo existente abaixo do cursor do usuário.

