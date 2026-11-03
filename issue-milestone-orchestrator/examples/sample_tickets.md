# Exemplos Reais de Tickets Técnicos de Alta Maturidade (GitHub Issues)

Exemplos práticos de issues prontas para produção, com vínculo explícito a milestones do roadmap, critérios BDD e escopo negativo.

---

## 1. Fatia Vertical Backend: Paginação por Cursor (`type: feat`, `priority: high`)

```markdown
## 1. Contexto, Alinhamento de Roadmap & JTBD
- **Milestone Alvo:** `v0.2.0 - Resiliência de Dados & Performance`
- **Fatia Vertical / Módulo:** `features/invoicing/delivery/http`
- **Job-to-be-Done Técnico:**
  > **Para que** os sistemas integradores e o frontend consultem históricos com mais de 500.000 faturas sem degradação linear de banco por `OFFSET`,
  > **Queremos** implementar paginação baseada em cursor indexado composto (`created_at`, `id`),
  > **De modo que** o tempo de resposta p95 permaneça estritamente abaixo de 50ms e a API ofereça navegação sequencial determinística.

## 2. Contrato Técnico & Assinaturas
- **Entrada (Query Parameters):**
  - `cursor_created_at` (string, ISO 8601 UTC, opcional).
  - `cursor_id` (string, UUIDv7, opcional).
  - `limit` (int, default 50, min 1, max 100).
- **Processamento:**
  - Repositório monta predicado:
    ```sql
    WHERE tenant_id = :tenant_id
      AND (:cursor_created_at IS NULL OR (created_at, id) < (:cursor_created_at, :cursor_id))
    ORDER BY created_at DESC, id DESC
    LIMIT :limit + 1
    ```
  - Se retornar `:limit + 1` itens, extrair `has_more = true` e o token composto do último item como `next_cursor`.
- **Saída (Response DTO):**
  ```json
  {
    "items": [
      { "id": "018d9f4e-...", "amount_cents": 15000, "created_at": "2026-10-18T20:00:00Z" }
    ],
    "next_cursor": "eyJjcmVhdGVkX2F0IjoiMjAyNi0xMC0xOFQyMDowMDowMFoiLCJpZCI6IjAxOGQ5ZjRlLi4ifQ==",
    "has_more": true
  }
  ```

## 3. Critérios de Aceite BDD (Gherkin)
```gherkin
Cenário: Primeira requisição sem cursor
  Dado que existem 150 faturas cadastradas para o inquilino autenticado
  Quando a rota GET "/api/v1/invoices?limit=50" for chamada
  Então deve retornar status HTTP 200
  E a lista "items" deve conter exatamente 50 faturas
  E "has_more" deve ser "true"
  E "next_cursor" não deve ser nulo

Cenário: Próxima página usando cursor anterior
  Dado o "next_cursor" gerado na requisição anterior
  Quando a rota GET "/api/v1/invoices" for chamada passando este cursor
  Então deve retornar as próximas 50 faturas sem duplicação ou omissão de registros

Cenário: Cursor malformado
  Quando a rota GET "/api/v1/invoices?cursor=token_invalido" for chamada
  Então deve retornar status HTTP 400 com código de erro "CURSOR_INVALID"
```

## 4. Escopo Negativo (Out-of-Scope)
- ❌ Não inclui filtros por data inicial/final (escopo da issue #54).
- ❌ Não altera o endpoint de faturas avulsas GET `/api/v1/invoices/:id`.
- ❌ Proibido alterar schema ou migração nesta issue (índice já existe da milestone v0.1.0).

## 5. Definition of Done (DoD)
- [ ] Implementado via TDD em fatia isolada (`vertical-slice-implementer`).
- [ ] Testes de integração com Testcontainers PostgreSQL validando plano de execução do índice (`test-suite-architect`).
- [ ] Contrato documentado em `features/invoicing/README.md` (`module-documentation-scribe`).
- [ ] Commit no padrão `feat(invoicing): implementar paginação keyset por cursor` referenciando esta issue.
```

---

## 2. Componente Frontend: Painel de Métricas (`type: feat`, `scope: ui`)

```markdown
## 1. Contexto & Alinhamento de Roadmap
- **Milestone Alvo:** `v0.3.0 - Interface & Acessibilidade`
- **Componente / Módulo:** `features/dashboard/components/RevenueCard.tsx`
- **Fronteira:** Client Component folha (`'use client'`) consumindo hook reativo.

## 2. Cobertura Obrigatória dos 5 Estados de UI
1. **Loading:** Skeleton com dimensões reservadas (`w-full h-36 rounded-lg`) e animação suave (CLS zero).
2. **Empty:** Mensagem "Nenhuma receita computada no período" com botão secundário "Configurar Integração".
3. **Error:** Card em tom de alerta suave, preservando layout e exibindo botão "Tentar novamente" que revalida o fetch.
4. **Overflow / Truncation:** Valores numéricos renderizados com `tabular-nums` e tooltips se excederem o container em telas de 320px.
5. **Success:** Valor monetário em destaque com indicador de tendência verde/vermelho acessível.

## 3. Conformidade Acessibilidade (WCAG 2.2 AA)
- Foco visível (`:focus-visible`) com contraste 3:1 no botão de recarga.
- Indicador de tendência não depende apenas de cor: possui ícone com seta e `aria-label="Aumento de 8% em relação ao mês anterior"`.
- Textos em conformidade com contraste de 4.5:1.

## 4. Critérios de Aceite BDD (Testing Library / Vitest)
```gherkin
Cenário: Renderização do estado de sucesso
  Dado que a API respondeu com receita de R$ 120.500,00 e aumento de 5%
  Quando o componente for renderizado
  Então deve exibir o texto "R$ 120.500,00"
  E o leitor de tela deve anunciar "Aumento de 5% em relação ao período anterior"

Cenário: Falha de rede e retentativa
  Dado que a requisição de receita falhou com erro de rede
  Quando o componente for renderizado
  Então deve exibir o botão "Tentar novamente"
  E ao clicar no botão deve disparar nova tentativa de revalidação
```

## 5. Escopo Negativo
- ❌ Não inclui renderização do gráfico histórico completo em SVG (pertence à issue #62).
```

---

## 3. Migração Zero-Downtime: Campo Obrigatório com Backfill (`type: data`)

```markdown
## 1. Contexto & Tabela Afetada
- **Milestone Alvo:** `v0.2.0 - Resiliência de Dados`
- **Tabela / Escala:** `tenants` (~800.000 registros).
- **Objetivo:** Adicionar coluna obrigatória `status` com valor padrão `active` sem travar escritas concorrentes.

## 2. Estratégia Zero-Downtime (Expand-Backfill-Contract)
1. **Expand (DDL 1):**
   ```sql
   ALTER TABLE tenants ADD COLUMN IF NOT EXISTS status VARCHAR(20) NULL;
   ```
2. **Backfill em Lotes (DML):**
   ```sql
   DO $$
   DECLARE batch_size INT := 5000; rows_affected INT;
   BEGIN
       LOOP
           WITH batch AS (
               SELECT id FROM tenants WHERE status IS NULL LIMIT batch_size FOR UPDATE SKIP LOCKED
           )
           UPDATE tenants t SET status = 'active' FROM batch WHERE t.id = batch.id;
           GET DIAGNOSTICS rows_affected = ROW_COUNT;
           EXIT WHEN rows_affected = 0;
           COMMIT;
           PERFORM pg_sleep(0.05);
       END LOOP;
   END $$;
   ```
3. **Contract (DDL 2):**
   ```sql
   ALTER TABLE tenants ALTER COLUMN status SET DEFAULT 'active';
   ALTER TABLE tenants ADD CONSTRAINT chk_tenants_status_not_null CHECK (status IS NOT NULL) NOT VALID;
   ALTER TABLE tenants VALIDATE CONSTRAINT chk_tenants_status_not_null;
   ```

## 3. Critérios de Aceite e Rollback
- [ ] Script de rollback (`down`) executa remoção limpa da constraint e da coluna.
- [ ] Tempo máximo de lock em qualquer etapa < 50ms verificado em staging.
- [ ] Validação de integridade pós-execução (`SELECT COUNT(*) FROM tenants WHERE status IS NULL` retorna 0).
```
