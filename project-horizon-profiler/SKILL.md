---
name: project-horizon-profiler
description: >-
  Use esta skill SEMPRE ao iniciar em um repositório desconhecido ou para identificar o horizonte de desenvolvimento (Web, CLI, Desktop, Pipeline de Dados, FFI, Lib/SDK, Mobile). Calibra métricas e padrões para a stack e arquitetura do projeto.
---

# Profiler e Calibrador de Horizontes de Projeto

## 1. Mapeamento de Horizontes e Arquétipos de Projeto

Esta skill atua como **ponto de entrada preliminar** para identificar em qual horizonte o projeto se posiciona e orientar o checklist das demais skills especialistas.

---

## Passo 1 — Detecção de Horizontes e Manifests por Stack

Inspecione a árvore do repositório, dependências e manifests para mapear os horizontes ativos e seus modelos arquiteturais recomendados:

| Horizonte | Características & Manifests por Stack | Modelo Arquitetural Recomendado & Topologia |
| :--- | :--- | :--- |
| **Web Backend / API** | - **Python:** `fastapi`, `flask`, `django`, `litestar`<br>- **PHP:** `laravel/framework` (`^12.0`), `artisan`, `laravel/octane`, `symfony`<br>- **Go:** `gin-gonic/gin`, `labstack/echo`, `gofiber/fiber`, `net/http`<br>- **Ruby:** `rails`, `sinatra`, `hanami`<br>- **Rust:** `axum`, `actix-web`, `warp`<br>- **.NET:** `Microsoft.AspNetCore.*`<br>- **Node/TS:** `express`, `nest`, `fastify` | **Vertical Slice (Feature-First):** Fatias por caso de uso (`features/<feature>/` ou `app/Features/<Feature>/` / `Modules/<Feature>/` no Laravel). Evite camadas horizontais globais.<br>*Alternativa:* **Hexagonal** para domínios corporativos densos. |
| **CLI / Terminal** | - **Python:** `click`, `typer`, `argparse`<br>- **PHP:** `artisan` (`app/Console/Commands/`), `laravel-zero`, `symfony/console`, `laravel/prompts`<br>- **Go:** `spf13/cobra`, `urfave/cli`<br>- **Ruby:** `thor`, `optparse`, `gli`<br>- **Rust:** `clap`, `argh`<br>- **C:** `getopt.h`, `argp.h`, parsing manual de `argc/argv`<br>- **.NET / Node:** `Spectre.Console`, `commander`, `yargs` | **Command-Driven / Micro-Kernel:** Subcomandos isolados (`commands/<cmd>/`), separando parsing, orquestração e renderização de saída. |
| **Pipeline de Dados / Batch** | Processamento massivo de arquivos, tabelas ou streams:<br>- **Python/Rust/Go:** `polars`, `arrow/parquet`, `duckdb`, ingestão de CSV/JSON massivos, processamento em chunks/mmap.<br>- **PHP / Laravel:** `Bus::batch()`, `LazyCollection`, `chunkById()`, `laravel/horizon`.<br>- **Ruby:** `kaminari`, processadores batch background (`sidekiq-batch`). | **Stage-Based / Pipeline DAG:** Estágios sequenciais (`pipeline/stages/` ou `Pipeline::send()->through()`), priorizando imutabilidade, chunks de memória e isolamento entre transformação pura e I/O. |
| **Extensão Nativa / FFI** | Código nativo interoperando entre linguagens ou C-ABI:<br>- **C:** `CMakeLists.txt`, `Makefile`, exportação de `.so`/`.dylib`/`.dll`, headers `.h`<br>- **Rust/Python:** `maturin`, `pyo3`, `cbindgen`<br>- **Go:** `cgo`, `buildmode=c-shared`<br>- **Ruby:** extensões C via `mkmf` ou `fiddle`/`ffi` | **C-ABI Facade & Zero-Copy Boundary:** Módulos nativos isolados (`crates/*`, `native/`), com stubs tipados e liberação explícita de locks de runtime. |
| **Biblioteca / SDK** | Pacotes puros sem ponto de entrada de aplicação executável:<br>- `[project.scripts]` ausente, `lib.rs` sem `main.rs`, gem pura sem binário, exportação restrita de interfaces públicas e tipos selados. | **Layered / Facade Mínima:** Exportação estrita (`__all__`, `pub`) com API pública coesa e zero dependências pesadas de infraestrutura. |
| **Desktop / GUI** | - **Multi-stack:** `tauri` (Rust + Web), `electron`, `flutter desktop`<br>- **C/C++:** `Qt`, `GTK`, `wxWidgets`<br>- **.NET:** `WPF`, `Avalonia`, `MAUI` | **MVVM / Component-State:** Desacoplamento entre lógica de apresentação e backend nativo via IPC/canais assíncronos. |
| **Mobile (iOS / Android / Cross)** | `flutter` (`pubspec.yaml`), `react-native` / `expo`, Kotlin/Android (`build.gradle.kts`), Swift/iOS (`Package.swift`). | **Feature-First + Unidirectional State (BLoC / Riverpod / MVVM):** Resiliência offline-first, ciclo de vida de background/foreground e orçamento estrito de bateria/frames (60/120fps). |
| **Web Frontend** | `react`, `vue`, `svelte`, `next`, `astro`, bundlers (`vite`, `webpack`), manipulação de DOM/CSS. | **Feature-First Components:** Componentes e hooks agrupados pelo domínio de uso (`features/<feature>/components`). |

Projetos podem ser **híbridos** (ex.: motor nativo em Rust/C + orquestrador em Python/Go + CLI). Quando for híbrido, declare explicitamente cada camada e sua fronteira. Consulte [data-pipeline-native-extension.md](./references/data-pipeline-native-extension.md) para diretrizes aprofundadas de projetos Batch/ETL combinados com extensões nativas FFI (Zero-Copy, Arrow C Data Interface, GIL release e proteção contra Zip-Slip/Zip-Bomb).

---

## Passo 2 — Calibração das Demais Skills por Horizonte

Ao emitir o relatório de perfil, forneça a calibração que as outras skills devem obedecer:

### 1. Para `architecture-boundary-auditor` & `vertical-slice-implementer`:
- **Topologia Arquitetural Recomendada:** O profiler define o modelo de arquitetura mais compatível com o horizonte.
- **Protocolo para Repositórios Sem Arquitetura Definida:** Se a topologia for inexistente ou ambígua, proíba qualquer imposição cega de Clean Architecture clássica. Exija a elaboração de 2 a 3 abordagens com prós/contras na RFC para deliberação do desenvolvedor antes de implementar.

### 2. Para `runtime-performance-diagnostician`:
- **Web API:** Foco em latência percentilar ($p50, p95, p99$), RPS, concorrência (VUs) e saturação de conexões HTTP/DB.
- **Pipeline de Dados / Batch:** **Ignore RPS HTTP**. Meça **taxa de processamento (registros/s)**, **throughput de I/O (MB/s)**, tempo de paginação/conversão e **pico de memória RSS**.
- **CLI:** Meça tempo de inicialização (*cold start* $< 100\text{ms}$), consumo de memória em execuções curtas e lazy loading de imports.
- **Extensão Nativa / C / FFI:** Meça alocações na heap, custo de cópia de fronteira (zero-copy), overhead de bindings e liberação de locks de runtime (ex.: GIL em Python).

### 3. Para `observability-logging-auditor`:
- **Web API / Serviços:** Logs estruturados em JSON para stdout, níveis semânticos e correlation IDs.
- **CLI:** Logs formatados para leitura humana em **stderr** (quando TTY); JSON apenas com `--format json`; stdout reservado estritamente para dados de saída (pipes); logs detalhados apenas com `-v`/`--debug`.
- **Biblioteca / SDK / Extensão Nativa:** **Proibido configurar handlers ou subscribers globais**. Apenas emita eventos estruturados para o ecossistema do consumidor hospedeiro.

### 4. Para `security-vulnerability-warden`:
- **Web API:** OWASP Top 10, sanitização de entrada HTTP, JWT, CORS, cookies e CSP.
- **CLI:** Permissões de arquivos criados (`umask`), injeção de comandos via shell/subprocess, path traversal ao ler argumentos locais e segurança de credenciais no keyring do SO.
- **Pipeline de Dados:** Integridade criptográfica de downloads (validação de SHA256), proteção contra **Zip-Slip** e descompressão maliciosa (Zip Bomb).
- **C / Extensão Nativa:** Prevenção de buffer overflow, memory leaks, use-after-free e verificação de sanitizers (`AddressSanitizer` / `UndefinedBehaviorSanitizer`).

### 5. Para `test-suite-architect`:
- **Pipeline de Dados:** Testes com *Golden Datasets* reais, verificação de esquemas colunares (Parquet Schema) e idempotência de reprocessamento.
- **CLI:** Testes de interface de linha de comando (parsing de flags válidas/inválidas, verificação de exit codes $0, 1, 2$ e estabilidade do payload `--json`).
- **C / Extensão Nativa:** Testes de fronteira FFI, validação de conversão de tipos C/Rust/Python e assertividade de tratamento de erros sem segfault.

### 6. Para Especialistas de Domínio (`frontend-ui-craftsman`, `backend-data-resilience`, `cli-development`):
- **Web Frontend / Mobile / Desktop:** Acione obrigatoriamente `frontend-ui-craftsman` (WCAG 2.2 AA, Core Web Vitals, fronteiras Server/Client e 5 estados de UI).
- **Web Backend / Pipeline de Dados:** Acione obrigatoriamente `backend-data-resilience` sempre que houver migrations, queries SQL, cache, filas ou ETL.
- **CLI / Terminal:** Acione obrigatoriamente `cli-development` (separação stdout/stderr, exit codes e `--json`).

---

## Handoff

Ao traçar o perfil de horizonte do projeto, acione via `view_file` a próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: project-horizon-profiler
Para: architecture-boundary-auditor (auditoria estrutural) | vertical-slice-implementer (implementação geral) | frontend-ui-craftsman (se Web/Mobile/GUI) | backend-data-resilience (se DB/Filas/ETL) | cli-development (se CLI)
Motivo: <horizontes identificados e diretrizes de calibração técnica>
Contexto necessário: <perfil de horizontes, stacks envolvidas e restrições de I/O, UI, logs e testes aplicadas>
```
