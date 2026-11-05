# Matriz de Gerenciamento de Dependências, Lockfiles e Runtimes por Stack

## 1. Comandos de Auditoria, Atualização e Detecção de Dependências Órfãs

| Stack | Listar Desatualizados | Atualizar c/ Lockfile | Detectar Pacotes Não Usados | Build Determinístico (CI) |
| :--- | :--- | :--- | :--- | :--- |
| **Python (`uv`)** | `uv tree --outdated` | `uv lock --upgrade-package <pkg>` | `deptry .` | `uv sync --frozen` |
| **Rust (`cargo`)** | `cargo outdated` | `cargo update -p <pkg>` | `cargo machete` / `cargo +nightly udeps` | `cargo test --locked` |
| **.NET (`dotnet`)** | `dotnet list package --outdated` | `dotnet add package <pkg>` | Analisadores MSBuild / Central Package Mgmt (`Directory.Packages.props`) | `dotnet restore --locked-mode` |
| **Node / TS (`pnpm`/`npm`)** | `pnpm outdated` / `npm outdated` | `pnpm update <pkg>` | `npx knip` | `pnpm install --frozen-lockfile` / `npm ci` |
| **PHP / Laravel (`composer`)** | `composer outdated --direct` | `composer update vendor/pkg --with-all-dependencies` | `composer-unused` | `composer install --no-dev --prefer-dist --classmap-authoritative` |
| **Flutter / Dart (`pub`)** | `flutter pub outdated` | `flutter pub upgrade --tighten` | `dart fix --apply` | `flutter pub get --enforce-lockfile` |
| **Go (`go mod`)** | `go list -u -m all` | `go get pkg@version && go mod tidy` | `go mod tidy -diff` | `go build -mod=readonly` |

---

## 2. Sincronia de Versão de Runtime em Todo o Repositório

Quando atualizar a versão da linguagem/runtime, atualize **todos** os locais no mesmo PR para evitar divergência entre ambiente local, CI e produção:
1. **Arquivos de versão de ambiente:** `.python-version`, `rust-toolchain.toml`, `global.json` (.NET), `.nvmrc` / `package.json#engines`, `composer.json#require.php`.
2. **Contêineres:** `FROM` nos `Dockerfile`s (estágio de build e estágio de runtime).
3. **Pipelines CI/CD:** `actions/setup-*` ou matriz de versões em `.github/workflows/*.yml`.
4. **Configuração de Linters/Targets:** `target-version` no Ruff/Mypy, `<TargetFramework>` no `.csproj`, `edition` no `Cargo.toml`, `tsconfig.json#target`.
