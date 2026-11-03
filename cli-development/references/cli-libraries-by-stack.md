# Bibliotecas e Ferramental de CLI por Stack

| Stack | Parsing de Argumentos & Subcomandos | Renderização & TTY (Cores/Tabelas) | Test Runner de CLI | Distribuição Recomendada |
| :--- | :--- | :--- | :--- | :--- |
| **Python** | `typer` (baseado em type hints) ou `click` | `rich` (respeita TTY e `NO_COLOR`) | `CliRunner` (`click.testing` / `typer.testing`) | `pipx` (se Python já presente) ou `PyInstaller` (standalone) |
| **Rust** | `clap` (com feature `derive`) | `colored`, `indicatif` (barras de progresso) | `assert_cmd` + `predicates` | Binário compilado `cargo build --release` |
| **Go** | `cobra` + `pflag` | `lipgloss` / `bubbletea` | Testes em `cmd_test.go` | Binário estático `CGO_ENABLED=0 go build` |
| **.NET** | `System.CommandLine` | `Spectre.Console` | Testes com `Console.SetOut` | Single-file publish (`dotnet publish -p:PublishSingleFile=true`) |
| **PHP / Laravel 12** | `Artisan Console` (`symfony/console`) | `Laravel Prompts`, `Termwind` | `$this->artisan('cmd')->assertExitCode(0)` | `Laravel Zero` + `Box` (`.phar` standalone) ou binário estático `FrankenPHP` |
| **Node / TS** | `commander`, `yargs` ou `citty` | `chalk`, `ora` | `execa` em testes de integração | `npx` / pacote npm global ou executável `pkg`/`bun build --compile` |
