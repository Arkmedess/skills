# Arquitetura de Componentes, Gestão de Estado e Design System

## 1. Fronteiras Server vs. Client Components (Next.js / RSC)

- **Server Components (Padrão):** Acesso direto à camada de dados/APIs internas, zero impacto no bundle JavaScript do cliente, seguro para chaves e segredos de servidor.
- **Client Components (`'use client'`):** Restritos às folhas da árvore que exigem APIs do browser (`window`, `localStorage`), hooks de estado (`useState`, `useReducer`) ou eventos (`onClick`, `onChange`).
- **Padrão de Composição (Slot Pattern):**
  Em vez de transformar um componente pesado de servidor em Client Component só porque ele está dentro de um wrapper interativo (como um Modal ou Aba), passe o Server Component como `children` para o Client Component:
  ```tsx
  // ClientWrapper.tsx ('use client') recebe children já renderizado no servidor
  export function InteractiveTabs({ children }: { children: React.ReactNode }) {
    const [open, setOpen] = useState(true);
    return open ? <section>{children}</section> : null;
  }
  ```
- **Laravel 12 (Blade / Livewire 3 / Inertia.js v2):**
  - *Blade & Livewire 3:* Prefira componentes Blade anônimos (`resources/views/components/`) puramente de servidor para UI estática, reservando componentes Livewire (`#[Locked]` em IDs sensíveis, `#[Computed]` para cache de propriedades derivadas, `wire:loading` + `wire:target` para anti double-submit) apenas para ilhas reativas.
  - *Inertia.js v2:* Utilize *Deferred Props* (`Inertia::defer(...)`) e *Merge Props* para carregar dados secundários pesados de forma assíncrona sem bloquear o *First Contentful Paint* da rota principal.

---

## 2. Anti-Patterns de `useEffect` e Gestão de Estado Limpa

1. **Derivação Síncrona (Zero Effect):**
   - *Errado:* `useEffect(() => { setFiltered(items.filter(...)); }, [items]);`
   - *Certo:* `const filtered = useMemo(() => items.filter(...), [items]);` (ou cálculo direto se a lista for pequena).
2. **Reset de Estado por Mudança de Identidade:**
   - *Errado:* `useEffect(() => { setComment(''); }, [userId]);`
   - *Certo:* Passar `key={userId}` para o componente `<ProfileForm key={userId} />`, permitindo que o framework recrie o estado de forma limpa.
3. **Eventos de Usuário vs. Efeitos:**
   - Ações disparadas por clique/submissão (ex.: enviar POST de compra, registrar analytics do clique) pertencem ao **Event Handler** (`onSubmit`/`onClick`), nunca a um `useEffect` monitorando flags booleanas.

---

## 3. Design Tokens e Style Guide: Fonte da Verdade e Consistência

1. **Auditoria de Existência:**
   - Inspecione sempre se o repositório possui arquivos de tokens (`tokens.css`, `theme.ts`, `variables.css`, `tailwind.config.*`) e Style Guide (`STYLEGUIDE.md`, documentação de design).
   - **Se existir:** Reutilize estritamente os tokens existentes. Proibido criar valores ou estilos paralelos.
   - **Se não existir:** Crie a base de design tokens e formalize o Style Guide antes de construir os componentes isolados.

2. **Tipografia Fluida e Escala Espacial:**
- **Escala Tipográfica e Legibilidade:**
  - Corpo de texto: `font-size: clamp(1rem, 0.95rem + 0.25vw, 1.125rem)`, `line-height: 1.5`, largura máxima `65ch`.
  - Títulos: `line-height: 1.15` a `1.25`, `letter-spacing: -0.02em`, `text-wrap: balance`.
  - Números em tabelas e métricas financeiras: `font-variant-numeric: tabular-nums` para alinhamento vertical perfeito.
- **Hierarquia e Espaçamento:**
  - Utilize escala consistente em múltiplos de `4px` (`0.25rem`, `0.5rem`, `0.75rem`, `1rem`, `1.5rem`, `2rem`, `3rem`).
  - Agrupamento por proximidade (Lei de Gestalt): o espaçamento *interno* de um card/grupo deve ser sempre menor que o espaçamento *externo* entre grupos adjacentes.

