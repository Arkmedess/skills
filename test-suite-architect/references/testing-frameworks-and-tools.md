# Frameworks, Ferramental e Cobertura por Stack

## Matriz de Ferramentas por Camada

| Stack | Framework Base | Property-Based | Integração / Efêmeros / Contrato | Cobertura Mínima (80%) |
| :--- | :--- | :--- | :--- | :--- |
| **Python** | `pytest`, `pytest-asyncio` | `hypothesis` | `testcontainers-python`, `respx`, `pact-python` | `pytest-cov --cov-fail-under=80` |
| **Rust** | `rstest`, `tests/` | `proptest`, `quickcheck` | `testcontainers-rs`, `wiremock`, `pact_consumer` | `cargo-llvm-cov --fail-under-lines 80` (ou `cargo-tarpaulin`) |
| **Go** | `testing` (`go test -race`), `testify` | `rapid`, `gopter` | `testcontainers-go`, `httptest` | `go test -coverprofile=coverage.out` ($\ge 80\%$) |
| **.NET** | `xUnit`, `FluentAssertions` | `FsCheck`, `CsCheck` | `WebApplicationFactory`, `Testcontainers`, `PactNet` | `dotnet-coverage` / `Coverlet` (80%) |
| **Node/TS** | `vitest` | `fast-check` | `testcontainers`, `MSW`, `@pact-foundation/pact` | `@vitest/coverage-v8 --thresholds.lines 80` |
| **PHP / Laravel 12** | `Pest v3` (`PHPUnit 11`), `LazilyRefreshDatabase` | `eris` / Pest Datasets | `Testcontainers`, `Http::fake()`, `Bus::fake()`, `Storage::fake()` | `./vendor/bin/pest --coverage --min=80` |
| **Flutter** | `flutter_test`, `bloc_test` | `glados` | `mocktail` para interfaces | `flutter test --coverage` (verificar LCOV) |

---

## Padrões de Testcontainers e Isolamento
- **Persistência Efêmera:** Priorize instâncias reais efêmeras via Testcontainers (PostgreSQL, Redis, RabbitMQ, LocalStack) em vez de bancos em memória com dialetos divergentes (ex.: evitar SQLite simulando PostgreSQL).
- **Gerenciamento de Ciclo de Vida:** Inicialize containers por suíte/assembly ou via reuso de fixtures (`session-scoped`), evitando subir e destruir contêineres a cada método de teste individual.
