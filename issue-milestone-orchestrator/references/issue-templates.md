# Templates Técnicos de Issues (Padrão de Engenharia de Produção)

Tickets no repositório devem ser estritamente técnicos, objetivos, orientados a contratos de código, critérios BDD (`Dado... Quando... Então...`) e escopo delimitado (*Out-of-Scope*).

---

## 1. Capacidade Técnica / Fatia Vertical Backend (`type: feat`)

```markdown
## 1. Contexto, Alinhamento de Roadmap & JTBD
- **Milestone Alvo:** `vX.Y.Z` (ex.: `v0.2.0 - Resiliência & Dados`)
- **Fatia Vertical / Módulo:** `features/<feature>` (ex.: `features/invoicing`)
- **Job-to-be-Done Técnico:**
  > **Para que** os clientes da API possam consultar extratos com histórico superior a 100.000 lançamentos sem timeout de banco,
  > **Queremos** implementar paginação por cursor indexado (`created_at`, `id`),
  > **De modo que** o tempo de resposta p95 permaneça estável abaixo de 80ms independente do volume.

## 2. Contrato Técnico & Assinaturas
- **Entrada (Input):** Parâmetros de query `cursor_created_at` (ISO 8601 UTC), `cursor_id` (UUIDv7) e `limit` (int, default 50, máx 100).
- **Processamento:** Query SQL com predicado Keyset `WHERE (created_at, id) < (:last_created_at, :last_id) ORDER BY created_at DESC, id DESC LIMIT :limit`.
- **Saída (Output):** DTO JSON `{ items: Invoice[], next_cursor: string | null, has_more: boolean }`.
- **Erros Mapeados:** Cursor malformado retorna HTTP 400 (`CURSOR_INVALID`); limite fora da faixa retorna HTTP 422.

## 3. Critérios de Aceite BDD (Gherkin)
```gherkin
Cenário: Primeira página de lançamentos sem cursor inicial
  Dado que existem 120 faturas cadastradas para o inquilino X
  Quando a API for chamada com "limit=50" sem cursor
  Então deve retornar as 50 faturas mais recentes
  E o campo "has_more" deve ser "true"
  E o "next_cursor" deve conter o token composto da 50ª fatia

Cenário: Próxima página usando cursor da resposta anterior
  Dado o cursor retornado na requisição anterior
  Quando a API for chamada passando este cursor e "limit=50"
  Então deve retornar exatamente os 50 lançamentos imediatamente anteriores
  E nenhum registro deve ser duplicado ou omitido
```

## 4. Escopo Negativo (Out-of-Scope — Cirurgia de Diff)
- ❌ **Não inclui:** Filtros por status de pagamento (será tratado na issue #46).
- ❌ **Não inclui:** Exportação em CSV/PDF.
- ❌ **Proibido:** Modificar endpoints de consulta legado nesta mesma fatia.

## 5. Definition of Done (DoD)
- [ ] Implementado via TDD em fatia vertical isolada (`vertical-slice-implementer`).
- [ ] Testes de integração com Testcontainers PostgreSQL validando índice composto (`test-suite-architect`).
- [ ] README local da fatia atualizado com o contrato público (`module-documentation-scribe`).
- [ ] Commit atômico com Conventional Commits referenciando esta issue (`git-commit-sentinel`).
```

---

## 2. Interface / Componente Frontend (`type: feat`, `scope: ui`)

```markdown
## 1. Contexto de UI & Mapeamento no Roadmap
- **Milestone Alvo:** `vX.Y.Z` (ex.: `v0.3.0 - Interface & Acessibilidade`)
- **Componente / Tela:** `features/dashboard/components/MetricCard`
- **Fronteira:** Client Component pontual (`'use client'`) recebendo dados de Server Component.

## 2. Requisitos dos 5 Estados de UI
1. **Loading:** Skeleton com mesma altura e largura do card (`min-height: 140px`), sem layout shift (CLS < 0.05).
2. **Empty:** Exibir mensagem "Nenhuma movimentação registrada" com botão acionável "Novo Lançamento".
3. **Error:** Exibir toast ou card de erro com mensagem amigável, preservando contexto e botão "Tentar novamente".
4. **Overflow / Truncation:** Textos de títulos longos cortados com `truncate` e tooltip nativo; números grandes com `tabular-nums`.
5. **Success:** Renderização da métrica com variação percentual e badge semântico.

## 3. Acessibilidade (WCAG 2.2 AA) & Performance
- **Teclado:** Navegável 100% via Tab com `:focus-visible` em contraste $\ge 3:1$.
- **Leitor de Tela:** Variações numéricas anunciadas com `aria-label="Aumento de 12% em relação ao mês anterior"`.
- **Contraste:** Texto sobre superfície com contraste mínimo de 4.5:1.

## 4. Critérios de Aceite BDD (Testing Library / Vitest)
```gherkin
Cenário: Exibição do estado carregado
  Dado que o carregamento da métrica foi concluído com sucesso
  Quando o componente for renderizado
  Então deve exibir o título e o valor formatado com role "region"
  E o skeleton de carregamento não deve mais estar no DOM
```

## 5. Escopo Negativo
- ❌ Não inclui renderização de gráficos avançados (depende da issue #52).
```

---

## 3. Migração de Banco de Dados e Resiliência (`type: infra` / `type: data`)

```markdown
## 1. Contexto & Tabela Afetada
- **Milestone Alvo:** `vX.Y.Z`
- **Tabela / Volume Estimado:** `orders` (~15 milhões de linhas).
- **Objetivo:** Adicionar coluna obrigatória `processed_at` e índice de busca por data de processamento.

## 2. Estratégia Zero-Downtime (Expand-Backfill-Contract)
1. **Expand:** Adicionar `processed_at TIMESTAMPTZ NULL` (sem bloqueio de escrita).
2. **Backfill em Lotes:**
   - Loop em batches de 5.000 registros usando `FOR UPDATE SKIP LOCKED`.
   - Pausa de `0.05s` entre transações para não sobrecarregar I/O e CPU do banco.
3. **Contract:**
   - Adicionar constraint `CHECK (processed_at IS NOT NULL) NOT VALID`.
   - Executar `VALIDATE CONSTRAINT` em transação separada.
4. **Índice Concorrente:**
   - `CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_processed_at ON orders(processed_at);`

## 3. Validação e Rollback
- [ ] Script de rollback (`down`) testado sem perda de dados existentes.
- [ ] Validação de contagem antes e após a migração (`COUNT(*)` idêntico).
- [ ] Nenhuma transação com lock superior a 100ms.
```

---

## 4. Defeito Técnico / Regressão (`type: bug`)

```markdown
## 1. Comportamento Observado vs. Esperado
- **Observado:** [Crash, vazamento de memória, cálculo divergente ou resposta 500]
- **Esperado:** [Comportamento correto especificado pelo contrato de negócio]
- **Prioridade / SLA:** `priority: critical` (P0) | `priority: high` (P1) | `priority: medium` (P2) | `priority: low` (P3)

## 2. Reprodução Mínima Determinística
```bash
# Sequência exata de comandos ou chamada curl que reproduz a falha
curl -X POST http://localhost:8080/api/v1/checkout \
  -H "Content-Type: application/json" \
  -d '{"items": [], "coupon": "DISCOUNT"}'
```

## 3. Evidência Técnica (Logs / Stacktrace / Frame)
```text
ZeroDivisionError: division by zero
  File "features/checkout/pricing.py", line 42, in calculate_totals
    discount_per_item = total_discount / len(items)
```

## 4. Critério de Aceite da Correção
- [ ] Teste automatizado de reprodução em `tests/features/test_pricing.py` falhando no estado atual (*Red*).
- [ ] Correção cirúrgica fazendo o teste passar com 100% de passagem na suíte (*Green* + *Simplify*).
- [ ] Validação de que coleções vazias retornam erro amigável HTTP 422 em vez de HTTP 500.
```

---

## 5. Performance e Benchmarks (`type: perf`)

```markdown
## 1. Gargalo Isolado & Baseline Empírico
- **Métrica Atual (Baseline):** Latência p99 = 450ms em carga de 500 RPS; ou RSS de 900MB.
- **Ferramenta de Medição:** `k6` / `wrk` / `scalene` / `measure_rss_memory.py`.
- **Gargalo Identificado:** Consulta N+1 no repositório de clientes e serialização JSON síncrona.

## 2. Invariantes Preservados
- Contratos de API pública e schemas permanecem 100% inalterados.
- Nenhuma alteração funcional observável pelo consumidor externo.

## 3. Meta Mensurável e Validação
- **Meta Pós-Otimização:** Latência p99 < 100ms em 500 RPS e RSS < 256MB.
- **Comando de Verificação:**
```bash
k6 run tests/load/invoices_p99.js
```
```
