# Convenções de Fronteiras Modulares e Manifests por Stack

## 1. Mapeamento de Manifests & Padrão de Fatiamento
- **.NET (`*.csproj`, `*.slnx`, `*.sln`):** Fatiamento por projetos de assembly isolados (`*.Domain`, `*.Features.*`, `*.Infrastructure`).
- **Python (`pyproject.toml`):** Fatiamento por pacotes de domínio (`src/<modulo>/features/`). Superfície pública restrita no `__all__` de `__init__.py`.
- **PHP / Laravel 12 (`composer.json`):** Fatiamento orientado a domínio/fatias (`app/Features/<Feature>/` ou `app/Modules/<Modulo>/` via PSR-4 / `internachi/modular`) contendo `Actions/`, `Data/` (DTOs `readonly`), `Models/`, `Http/Controllers/` (Single-Action `__invoke`) e `Http/Requests/` (`FormRequest`). Proibido concentrar regras de negócio em *Fat Models* Eloquent ou *God Controllers*.
- **Rust (`Cargo.toml` workspace):** Fatiamento por crates independentes em `crates/*`. Exposição estrita de tipos via `pub(crate)` e `pub` seletivo em `lib.rs`.
- **Node / TypeScript (`package.json`, pnpm / Turborepo):** Fatiamento por workspaces (`packages/*`, `apps/*`). Imports internos restritos via `exports` no `package.json` ou barrel files explícitos.
- **Go (`go.mod`):** Fatiamento por `internal/` (regras inacessíveis de fora do módulo) e `pkg/` (contratos públicos).
- **Flutter (`pubspec.yaml`, `melos.yaml`):** Separação entre apps e packages reutilizáveis.

### Linters Automatizados de Fronteira Arquitetural (Fitness Functions)
- **.NET:** `ArchUnitNET` ou `NetArchTest.Rules` em suíte de arquitetura.
- **Python:** `import-linter` (`.importlinter`) ou `tach` para bloquear imports cruzados entre fatias.
- **PHP / Laravel 12:** **Pest Architecture Testing** (`arch()->expect('App\Features\Billing\Domain')->toHaveNoDependenciesOutside(...)`, `arch()->preset()->laravel()`) ou `Deptrac` (`deptrac.yaml`).
- **TypeScript / Node:** `dependency-cruiser` ou `eslint-plugin-boundaries`.
- **Rust:** `cargo-deny` e visibilidade estrita `pub(crate)` por crate do workspace.
- **Go:** `depguard` via `golangci-lint` somado ao bloqueio nativo de `internal/`.

---

## 2. Fronteiras em Projetos Híbridos e FFI (Nativo + Scripting)
Quando coexistirem manifests de linguagens nativas e de alto nível (ex.: Rust + Python via `maturin`/`PyO3`, C + Go via `cgo`):
- **Encapsulamento Seguro:** Tipos nativos e ponteiros crus não devem vazar para o código hospedeiro.
- **Contratos Tipados:** Exigir arquivos de stub (`.pyi`, `.d.ts`) com tipos estritos espelhando a API nativa exportada.
- **Tratamento de Exceções:** Mapear erros de Result nativo para exceções idiomáticas da linguagem de alto nível.
- **Gerenciamento de Locks de Runtime:** Liberar explicitamente locks de runtime (ex.: Python GIL via `py.allow_threads`) durante operações CPU-bound intensivas na camada nativa.
