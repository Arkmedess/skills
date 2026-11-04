# Receitas de Migrações Zero-Downtime, Idempotência e Resiliência de Filas/ETL

## 1. Template de Migração Segura em Lote (PostgreSQL 12+ & MySQL 8.0+)

### PostgreSQL (Expand -> Backfill -> Contract com Lock Timeout)

```sql
-- 1. EXPAND: Com guard-rail de lock_timeout para nunca enfileirar atrás de queries lentas
SET lock_timeout = '2s';
SET statement_timeout = '5s';
ALTER TABLE customers ADD COLUMN IF NOT EXISTS tier VARCHAR(20);
RESET lock_timeout;
RESET statement_timeout;

-- 2. BACKFILL EM LOTES: Sem bloquear leituras/escritas concorrentes
DO $$
DECLARE
    batch_size INT := 5000;
    rows_affected INT;
    remaining_nulls BIGINT;
BEGIN
    LOOP
        WITH batch AS (
            SELECT id
            FROM customers
            WHERE tier IS NULL
            LIMIT batch_size
            FOR UPDATE SKIP LOCKED
        )
        UPDATE customers c
        SET tier = 'bronze'
        FROM batch
        WHERE c.id = batch.id;

        GET DIAGNOSTICS rows_affected = ROW_COUNT;
        COMMIT;

        IF rows_affected = 0 THEN
            -- Passada final sem SKIP LOCKED para cobrir linhas que estavam travadas
            SELECT COUNT(*) INTO remaining_nulls FROM customers WHERE tier IS NULL;
            EXIT WHEN remaining_nulls = 0;
        END IF;

        PERFORM pg_sleep(0.05); -- Alívio de I/O, replicação e autovacuum
    END LOOP;
END $$;

-- 3. CONTRACT: Validar constraint sem ACCESS EXCLUSIVE prolongado (PostgreSQL 12+)
SET lock_timeout = '2s';
ALTER TABLE customers ALTER COLUMN tier SET DEFAULT 'bronze';
ALTER TABLE customers
    ADD CONSTRAINT chk_customers_tier_not_null
    CHECK (tier IS NOT NULL) NOT VALID;

-- VALIDATE usa SHARE UPDATE EXCLUSIVE (permite leituras e escritas normais)
RESET statement_timeout;
ALTER TABLE customers VALIDATE CONSTRAINT chk_customers_tier_not_null;

-- No PG 12+, SET NOT NULL é instantâneo quando já existe CHECK (col IS NOT NULL) validada
SET lock_timeout = '2s';
ALTER TABLE customers ALTER COLUMN tier SET NOT NULL;
ALTER TABLE customers DROP CONSTRAINT chk_customers_tier_not_null;
RESET lock_timeout;
```

### MySQL 8.0+ (Online DDL)
```sql
SET SESSION lock_wait_timeout = 2;
ALTER TABLE customers
    ADD COLUMN tier VARCHAR(20) NULL,
    ALGORITHM=INSTANT;
-- Para índices sem bloquear escritas:
CREATE INDEX idx_orders_customer_created
    ON orders (customer_id, created_at DESC)
    ALGORITHM=INPLACE, LOCK=NONE;
```

### Criação Concorrente de Índices (PostgreSQL) e Escape de Transação nos ORMs
```sql
-- Executar fora de bloco BEGIN/COMMIT transacional
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_customer_created
    ON orders (customer_id, created_at DESC);
```
- **Alembic (Python):** `with op.get_context().autocommit_block(): op.create_index(..., postgresql_concurrently=True)`
- **Django (Python):** `class Migration(migrations.Migration): atomic = False` + `AddIndexConcurrently`
- **EF Core (.NET):** `migrationBuilder.Sql("CREATE INDEX CONCURRENTLY ...", suppressTransaction: true);`
- **Rails (Ruby):** `disable_ddl_transaction!` no topo da migration + `algorithm: :concurrently`
- **Laravel (PHP):** `public $withinTransaction = false;`

---

## 2. Padrões de Idempotência, Checkpointing e DLQ

### A. Upsert Idempotente em Lotes
- Sempre deduplicar o lote em memória pela chave de conflito antes do `INSERT ... ON CONFLICT DO UPDATE`.
- Atualizar apenas quando o timestamp/versão do evento recebido for mais recente que o armazenado (`WHERE target.updated_at < EXCLUDED.updated_at`).

### B. Paginação Keyset (Cursor)
```sql
-- Página 1: sem cursor inicial
-- Páginas seguintes: usando o último (created_at, id) da página anterior
SELECT id, status, total_cents, created_at
FROM invoices
WHERE tenant_id = :tenant_id
  AND (created_at, id) < (:cursor_created_at, :cursor_id)
ORDER BY created_at DESC, id DESC
LIMIT 50;
```

### C. Checklist de Segurança Pré-Deploy de Migração
1. A migração é compatível com a versão $N-1$ do código que ainda está rodando durante o *rolling deploy*?
2. Índices novos estão usando `CONCURRENTLY`?
3. Há script de rollback (`down`) testado que desfaz a alteração sem perda de dados legados?
4. Queries novas possuem índice cobrindo os predicados de `WHERE` e `ORDER BY` (validado via `EXPLAIN (ANALYZE, BUFFERS)`)?

---

## 3. Padrões Específicos para PHP / Laravel 12 (Eloquent, Migrations, Queues & Cache)

### A. Prevenção Estrita de $N+1$ e Atributos Fantasmas (`AppServiceProvider`)
Habilite o modo estrito do Eloquent no `boot()` do `AppServiceProvider`:
```php
Model::shouldBeStrict(! $this->app->isProduction());
// Em produção, registre violações de lazy loading nos logs sem derrubar a request:
if ($this->app->isProduction()) {
    Model::handleLazyLoadingViolationUsing(function (Model $model, string $relation): void {
        Log::warning("Lazy loading detectado: {$model::class}::{$relation}");
    });
}
```

### B. Migrações Concorrentes no Laravel 12 (PostgreSQL)
Para criar índices `CONCURRENTLY` no PostgreSQL via Laravel Migration, desabilite a transação automática da migration:
```php
return new class extends Migration {
    public $withinTransaction = false;

    public function up(): void
    {
        DB::statement('CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_tenant_created ON orders (tenant_id, created_at DESC)');
    }

    public function down(): void
    {
        DB::statement('DROP INDEX CONCURRENTLY IF EXISTS idx_orders_tenant_created');
    }
};
```

### C. Isolamento Transacional (`AfterCommit`), Jobs Idempotentes e Chunks
- **Efeitos Colaterais Pós-Commit:** Implemente a interface `ShouldDispatchAfterCommit` em Jobs/Events/Notifications ou encadeie `->afterCommit()` / `DB::afterCommit(fn () => ...)` para garantir que nenhuma mensagem seja despachada no Redis/Horizon antes do `COMMIT` real da transação no banco.
- **Idempotência de Jobs e Locks Atômicos:** Implemente `ShouldBeUnique` (definindo `uniqueId()` e `$uniqueFor`) em Jobs críticos e utilize `Cache::lock("payment:{$orderId}", 10)->block(5, fn () => ...)` para impedir concorrência duplicada.
- **Processamento em Lote e Paginação Keyset:**
  - Substitua `paginate()` (baseado em `OFFSET`) por `cursorPaginate()` em listagens volumosas.
  - Em comandos batch/ETL, proíba `Model::all()`; utilize sempre `chunkById(1000, ...)` ou `lazyById(1000)` para manter o consumo de memória RAM $O(1)$.
- **Prevenção de Cache Stampede (SWR Nativo):** Utilize `Cache::flexible($key, [300, 900], fn () => ...)` do Laravel 12 (*stale-while-revalidate* nativo) em chaves quentes.

