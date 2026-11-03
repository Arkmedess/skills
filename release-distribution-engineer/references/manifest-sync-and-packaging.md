# Sincronização de Manifests, Flags `--version` e Empacotamento de Artefatos

## 1. Matriz de Sincronização Atômica de Versão
Em qualquer bump de versão (`chore(release): lançar versão vX.Y.Z`), todos os arquivos abaixo presentes no repositório devem ser atualizados no mesmo commit:

| Ecossistema | Manifests de Versão | Lockfiles / Metadados | Constantes de Código e Flag `--version` |
| :--- | :--- | :--- | :--- |
| **Python** | `pyproject.toml` (`version = "X.Y.Z"`) | `uv.lock` / `poetry.lock` | `<pkg>/__init__.py` (`__version__ = "X.Y.Z"`), `typer`/`click`/`argparse` `--version` |
| **Rust** | `Cargo.toml` (`version = "X.Y.Z"`) | `Cargo.lock` (`cargo check`) | `#[command(version)]` no `clap` (lê `CARGO_PKG_VERSION`) |
| **Node / TS** | `package.json` (`"version": "X.Y.Z"`) | `package-lock.json` | `.version("X.Y.Z")` no `commander`/`yargs` ou OpenAPI spec |
| **.NET / C#** | `Directory.Build.props` ou `*.csproj` (`<Version>X.Y.Z</Version>`) | `packages.lock.json` (se ativo) | `AssemblyInformationalVersion` |
| **Go** | `VERSION` (se usado) | `go.mod` (major `v2+` no module path) | Variável `var version = "vX.Y.Z"` injetada via `-ldflags "-X main.version=vX.Y.Z"` |
| **PHP / Laravel 12** | `composer.json` (se `version` declarado) ou `VERSION` | `composer.lock` (`composer update --lock`) | `config/app.php` (`'version' => 'X.Y.Z'`) ou `Laravel Zero` (`config/app.php` `--version`) |
| **Flutter / Dart** | `pubspec.yaml` (`version: X.Y.Z+build`) | — | Sobre/Configurações do App |

---

## 2. Empacotamento e Compilação de Artefatos
1. **Extensões Nativas e Wheels (Python/Rust/C):**
   - Utilizar `maturin build --release --strip` ou matriz de `cibuildwheel` para gerar wheels multiplataforma (`manylinux_2_28`, `musllinux`, macOS universal2, Windows x64) + `sdist`.
2. **Binários Standalone (CLI em Go/Rust/C):**
   - Compilação estática com remoção de símbolos de debug (`strip = true` no `Cargo.toml` ou `go build -trimpath -ldflags="-s -w -X main.version=vX.Y.Z"`).
3. **Integridade Criptográfica (`SHA256SUMS`):**
   - Todo release com binários ou pacotes deve incluir `SHA256SUMS` gerado e verificado por `scripts/generate_checksums.sh`.

---

## 3. Tabela de Flags do `gh release create` por Cenário

| Cenário de Lançamento | Formato da Tag | Flags Obrigatórias no `gh release create` |
| :--- | :--- | :--- |
| **Release Estável (Linha Atual)** | `vX.Y.Z` | `--verify-tag --target <branch/sha> --title "vX.Y.Z - ..." --notes-file release-notes.md --latest` |
| **Release Candidate / Beta / Alpha** | `vX.Y.Z-rc.1` | `--verify-tag --target <branch/sha> --title "vX.Y.Z-rc.1" --notes-file release-notes.md --prerelease` |
| **Hotfix em Versão Legada (ex.: v1.x quando v2.x já é Latest)** | `v1.4.2` | `--verify-tag --target release/v1.4 --title "v1.4.2" --notes-file release-notes.md --latest=false` |
| **Release Preparada para Aprovação Humana** | `vX.Y.Z` | `--verify-tag --target <branch/sha> --title "vX.Y.Z - ..." --notes-file release-notes.md --draft` |
