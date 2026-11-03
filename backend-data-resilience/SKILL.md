---
name: backend-data-resilience
description: >-
  Use esta skill SEMPRE que criar ou revisar migrações de banco de dados (schemas, índices, backfills),
  queries SQL/ORM de alto volume, paginação de APIs, cache distribuído (Redis), filas/workers assíncronos
  ou pipelines ETL/batch. Garante Zero-Downtime Migrations, idempotência estrita, paginação por cursor,
  DLQs, retry com jitter e governança de cache.
---

# Arquiteto de Resiliência de Dados, Migrações Zero-Downtime e Filas

## 1. Migrações de Banco de Dados sem Indisponibilidade (Expand-Backfill-Contract)

É expressamente proibido aplicar alterações destrutivas ou que adquiram locks exclusivos prolongados (`ACCESS EXCLUSIVE`) diretamente em tabelas produtivas de alto volume:

1. **Adição de Coluna Obrigatória (3 Etapas):**
   - *Expand:* Adicione a nova coluna como `NULLABLE` (sem `DEFAULT` volátil que reescreva a tabela).
   - *Backfill:* Atualize os registros existentes em lotes (*batches* de 1.000 a 10.000 linhas) usando `FOR UPDATE SKIP LOCKED` com pausas curtas entre transações.
   - *Contract:* Aplique a constraint `NOT NULL` (ou `CHECK ... NOT VALID` seguido de `VALIDATE CONSTRAINT`).
2. **Renomeação ou Mudança de Tipo de Coluna:**
   - Proibido `RENAME COLUMN` ou `ALTER COLUMN TYPE` direto se houver instâncias da aplicação rodando em paralelo. Adicione a coluna nova, faça dual-write na aplicação, execute o backfill e remova a coluna antiga em deploy posterior.
3. **Criação de Índices:**
   - Em PostgreSQL/bancos relacionais, crie e remova índices em tabelas existentes **sempre de forma concorrente** (`CREATE INDEX CONCURRENTLY`), fora de blocos de transação que bloqueiem escritas.
4. **Reversibilidade e Validação:**
   - Toda migração exige script de `down` (rollback) determinístico e checagem de invariantes de contagem antes e depois da execução.
   - Consulte `references/zero-downtime-migrations-and-etl.md` para templates SQL e Python/ORM.

---

## 2. Idempotência e Resiliência em Workers, Filas e ETL

Toda operação de escrita exposta a retries de rede, webhooks ou consumidores de fila deve ser **idempotente por construção**:

1. **Idempotência de Escrita:**
   - **APIs Mutáveis (POST/PATCH):** Exija e valide chave de idempotência (`Idempotency-Key` com lock atômico e TTL) para operações financeiras, pedidos ou disparos externos.
   - **Persistência em Lote:** Utilize `UPSERT` (`INSERT ... ON CONFLICT DO UPDATE`) baseado em chave natural/única de negócio ou *Delete-then-Insert* dentro da mesma transação para partições de data.
2. **Isolamento de Transações de Banco vs. Efeitos Colaterais:**
   - **Regra de Ouro:** **Proibido disparar chamadas HTTP, envio de e-mails ou publicações diretas em mensageria/filas dentro de transações de banco abertas.** Transações devem ser estritamente de banco de dados e ultracurtas (< 50ms).
   - Para garantir consistência eventual sem bloquear transações ou gerar efeitos colaterais fantasmas em caso de rollback, utilize o padrão **Transactional Outbox** (gravar a mensagem na tabela outbox na mesma transação e despachar via worker assíncrono) ou publique o evento estritamente *após* o commit com sucesso.
3. **Cancelamento Cooperativo e Propagação de Contexto:**
   - Propague sinais de cancelamento (`CancellationToken` em C#, `context.Context` em Go, `AbortController` em Node/TS) até as queries do banco e adaptadores de I/O.
   - Interrompa a execução de queries no servidor se o cliente desconectar, evitando conexões presas e desperdício de CPU (*Orphan Work*).
4. **Checkpointing e Processamento em Chunks:**
   - Nunca carregue datasets inteiros na memória RAM. Processe em streams/chunks de tamanho fixo e salve o cursor do último lote confirmado (*Checkpoint*) para permitir retomada do ponto exato de falha.
5. **Tratamento de Falhas, Retries e Dead Letter Queue (DLQ):**
   - Retries de rede/I/O devem usar **Exponential Backoff com Jitter** e `timeout` explícito em todas as chamadas externas (proibido chamar HTTP/DB sem timeout).
   - Registros corrompidos (*Poison Pills*) em lotes ou filas não devem abortar todo o lote sem rastreio: isole a falha e encaminhe o payload bruto + erro para uma **DLQ** auditável.

---

## 3. Eficiência de Consultas, Paginação e Governança de Cache

1. **Prevenção de $N+1$ e Projeções Enxutas:**
   - Proibido executar queries dentro de loops. Use *eager loading* controlado (`JOIN` / `WHERE id IN (...)`) e selecione apenas as colunas necessárias (evite `SELECT *` em tabelas largas).
2. **Paginação por Cursor (Keyset / Seek Pagination):**
   - Para listagens de grande volume, substitua `OFFSET / LIMIT` (que degrada linearmente $O(N)$ no banco) por paginação baseada em cursor indexado (`WHERE (created_at, id) < (:last_created_at, :last_id) ORDER BY created_at DESC, id DESC LIMIT :limit`).
3. **Governança de Cache (Redis / Memcached):**
   - **TTL Obrigatório:** Nenhuma chave de cache de aplicação pode ser gravada sem expiração (`EX`/`PX`), exceto configurações estáticas explícitas.
   - **Namespaces e Versionamento:** Estruture chaves no padrão `<servico>:<dominio>:<versao>:<id>` (ex.: `billing:invoice:v1:9821`).
   - **Invalidação e Stampede:** Defina explicitamente como o cache é invalidado após escritas (Write-Through ou invalidação de chave/tag) e proteja chaves quentes contra *Cache Stampede* (lock curto de recomputação ou *stale-while-revalidate*).

---

## Handoff

Ao concluir a modelagem de migração, persistência, fila ou cache, acione via `view_file` a próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: backend-data-resilience
Para: test-suite-architect (para validar migração/queries com Testcontainers reais e idempotência) | runtime-performance-diagnostician (para EXPLAIN ANALYZE e benchmark de throughput/memória) | code-hygiene-auditor (para validação estática e Clean Code) | module-documentation-scribe (para documentar mudanças de schema e contratos)
Motivo: <resumo da migração segura, estratégia de idempotência, paginação ou política de cache implementada>
Contexto necessário: <arquivos de migração/repositório alterados, índices criados, plano de rollback e TTLs definidos>
```

