# Changelog

Todas as mudanças notáveis neste repositório são documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
e este projeto adere ao [Versionamento Semântico (SemVer 2.0.0)](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- `AGENTS.md` versionado na raiz do repositório para eliminar dependência externa.
- Suítes de testes automatizados: `tests/test_portability.sh`, `git-commit-sentinel/tests/test_verify_staged_diff.sh` e `release-distribution-engineer/tests/test_check_version_and_readiness.sh`.
- Integração com `gitleaks git --staged` no `verify_staged_diff.sh`.
- `README.md`, `LICENSE` (MIT), `CHANGELOG.md` e workflow `.github/workflows/ci.yml`.

### Fixed
- `git-commit-sentinel`: correção das expressões regulares de arquivos confidenciais (`*.pem`, `*.key`, `*.pfx`, `*.p12`), chaves privadas com múltiplos qualificadores (`BEGIN RSA/OPENSSH/EC PRIVATE KEY`), tokens `sk-proj-`/`sk-ant-`/`AIza` e falsos positivos em títulos Markdown `=======`.
- `release-distribution-engineer`: filtragem de tags de pre-release (`-rc`, `-beta`, `-alpha`) ao localizar a tag estável base e correção dos caminhos de anexos em `gh release create`.
- `backend-data-resilience`: adição de `SET lock_timeout`/`statement_timeout`, verificação final de nulos após `FOR UPDATE SKIP LOCKED`, sequência completa `CHECK NOT VALID -> VALIDATE -> SET NOT NULL -> DROP CONSTRAINT` no PostgreSQL 12+ e Online DDL no MySQL 8.0+.

### Changed
- Substituição de todos os caminhos absolutos de máquina por `<SKILL_DIR>` e remoção do acoplamento a nomes de ferramentas específicas de um único harness.
- Harmonização de `--log-format json`, métricas tipográficas (`60ch–75ch`, `line-height: 1.5`), alvos de toque WCAG 2.2 (24x24px AA vs 44x44px AAA) e ordem de custo computacional no CI.
