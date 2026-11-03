# Ferramentas Nativas de Detecção de Quebra de Contrato e API

| Stack | Ferramenta Recomendada | Comando / Uso |
| :--- | :--- | :--- |
| **Rust** | `cargo-semver-checks` | `cargo semver-checks check-release` (compara contra o último release do crates.io ou tag git) |
| **Python** | `griffe` / `mypy stubtest` | `griffe check <package>` ou validação de assinaturas públicas exportadas |
| **Go** | `gorelease` ou `apidiff` | `gorelease` (analisa retrocompatibilidade e sugere versão) |
| **C / C++** | `abi-compliance-checker` / `libabigail` | `abidiff libv1.so libv2.so` (analisa quebra de ABI binária) |
| **PHP / Laravel 12** | `roave/backward-compatibility-check` | `vendor/bin/roave-backward-compatibility-check` (compara classes, métodos e contratos públicos entre tags Git) |
| **Node / TS** | `@arethetypeswrong/cli` | `attw --pack .` (avalia exportação correta de tipos CJS/ESM) |
