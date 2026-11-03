# Ferramentas Nativas de Linters, Formatação e Tipagem por Stack

| Stack | Formatação & Linter | Tipagem Estrita | Complexidade & Dead Code |
| :--- | :--- | :--- | :--- |
| **Python** | `ruff format --check`, `ruff check` | `mypy --strict` ou `pyright` | `radon cc -s`, `flake8-cognitive-complexity` |
| **Rust** | `cargo fmt --check`, `cargo clippy --all-targets -- -D warnings` | Compilador nativo (`rustc`) | Auditoria de `unsafe`, `cargo-geiger` |
| **.NET** | `dotnet format --verify-no-changes` | `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>` | Analisadores Roslyn (ex.: NetAnalyzers) |
| **Node / TS** | `biome check` ou `prettier --check` + `eslint --max-warnings=0` | `tsc --noEmit --strict` | Regras SonarJS / ESLint complexity |
| **Flutter/Dart** | `dart format --output=none --set-exit-if-changed .` | `dart analyze --fatal-warnings` | `dart_code_metrics` |
| **Go** | `golangci-lint run`, `gofmt -l .` | Compilador nativo (`go vet`) | `gocyclo -over 10 .` |
| **PHP / Laravel 12** | `./vendor/bin/pint --test` (PSR-12 / preset `laravel`) | `./vendor/bin/phpstan analyse --memory-limit=2G` (**Larastan** nível 8+) | `./vendor/bin/rector process --dry-run`, `./vendor/bin/pest --filter=Arch` |
