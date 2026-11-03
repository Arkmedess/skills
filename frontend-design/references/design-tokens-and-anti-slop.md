# Referência de Design Tokens, Anti-Slop e Leis Clássicas de UX/UI

## 1. Catálogo de Clichês Visuais de IA Bloqueados ("AI Slop")
Salvo pedido explícito do usuário, evite convergir para os seguintes padrões saturados:
1. **Paleta Monótona Creme/Terracota:** Fundo creme (`#F4F1EA`) com serifa de alto contraste e acento terracota/argila (`#D97757`).
2. **Modo Escuro Neon Genérico:** Fundo quase preto (`#0B0B0B`) com acento verde-ácido fluorescente ou ciano estridente sem relação com o domínio.
3. **"SaaS-Card Kit" Indiscriminado:**
   - Envolver cada bloco de informação em cards retangulares idênticos com o mesmo `border-radius` e sombras difusas idênticas (`rgba(0, 0, 0, 0.08)`).
   - Gradientes multicoloridos puramente decorativos sem significado semântico ou de marca.
4. **Adereços de Template Artificial:**
   - Eyebrows em `ALL CAPS` com `letter-spacing` exagerado acima de cada título.
   - Meta-informações separadas repetitivamente por pontos centrais (`Item · Categoria · Status`).
   - Labels formatadas como `PALAVRA — fragmento` com travessão.
   - Sufixo `→` injetado em todos os botões e links.
   - Numeração decorativa (`01 / 02 / 03`) em listas não sequenciais.
   - Destacar uma única palavra no meio do título com itálico, gradiente ou cor destoante.

---

## 2. Template Base de Sistema Compacto de Tokens (`tokens.css`)
Quando o projeto ainda não possuir tokens formais, crie a estrutura base seguindo os 4 pilares:

```css
:root {
  /* 1. Cores Semânticas (Superfícies, Texto, Acentos e Bordas) */
  --surface-base: #FAFAFA;
  --surface-raised: #FFFFFF;
  --surface-overlay: rgba(255, 255, 255, 0.92);
  --text-primary: #111315;
  --text-muted: #5A6065;
  --accent-primary: #0F4C81;
  --accent-subtle: #E8F1F8;
  --border-subtle: #E2E5E9;

  /* 2. Escala Geométrica de Espaçamento (Grid Base 4px/8px) */
  --space-1: 0.25rem; /* 4px */
  --space-2: 0.5rem;  /* 8px */
  --space-3: 0.75rem; /* 12px */
  --space-4: 1rem;    /* 16px */
  --space-6: 1.5rem;  /* 24px */
  --space-8: 2rem;    /* 32px */
  --space-12: 3rem;   /* 48px */

  /* 3. Hierarquia Proporcional de Raios de Borda */
  --radius-sm: 6px;   /* Botões, badges e inputs */
  --radius-md: 10px;  /* Containers e painéis */
  --radius-lg: 14px;  /* Modais e drawers */

  /* 4. Elevação Funcional (Eixo Z) */
  --shadow-sm: 0 1px 2px rgba(17, 19, 21, 0.06);
  --shadow-md: 0 4px 12px rgba(17, 19, 21, 0.08);
  --shadow-lg: 0 12px 32px rgba(17, 19, 21, 0.14);
}
```
