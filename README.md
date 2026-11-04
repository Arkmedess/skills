# Catálogo de Skills de Engenharia de Software & Governança

Coleção de **19 skills modulares** e das regras globais ([`AGENTS.md`](./AGENTS.md)) para agentes de codificação (Antigravity, Claude Code, Codex, Cursor e similares), cobrindo arquitetura, TDD cirúrgico, resiliência de dados, UI/UX autoral, segurança, observabilidade, CI/CD e releases SemVer.

---

## Catálogo de Skills

| Skill | Responsabilidade Principal |
| :--- | :--- |
| [`project-horizon-profiler`](./project-horizon-profiler/SKILL.md) | Detecção de horizonte (Web, CLI, Batch/ETL, FFI, SDK, Mobile, Desktop) e calibração das demais skills. |
| [`architecture-boundary-auditor`](./architecture-boundary-auditor/SKILL.md) | Auditoria de fronteiras (Vertical Slice, Hexagonal, Pipeline DAG, Clean Arch) e princípios SOLID. |
| [`vertical-slice-implementer`](./vertical-slice-implementer/SKILL.md) | Implementação TDD (`Red -> Green -> Simplify`), Clean Code, SOLID e Cirurgia de Diff. |
| [`frontend-design`](./frontend-design/SKILL.md) | Direção de arte autoral, prevenção de clichês ("AI Slop"), Design Tokens e leis de UX. |
| [`frontend-ui-craftsman`](./frontend-ui-craftsman/SKILL.md) | WCAG 2.2 AA, Core Web Vitals (LCP, INP, CLS), 5 estados de UI e separação RSC/Client. |
| [`backend-data-resilience`](./backend-data-resilience/SKILL.md) | Migrações Zero-Downtime (`Expand-Backfill-Contract`), idempotência, Outbox, paginação por cursor e cache. |
| [`cli-development`](./cli-development/SKILL.md) | Convenções POSIX (`stdout`/`stderr`, exit codes `0/1/2/130`, `--json`, `NO_COLOR`). |
| [`test-suite-architect`](./test-suite-architect/SKILL.md) | Governança TQA (4 dimensões), Testcontainers, Property-Based Testing e mutação por diff. |
| [`code-hygiene-auditor`](./code-hygiene-auditor/SKILL.md) | Linters nativos (zero warnings), complexidade cognitiva $\le 10$, SLA e erradicação de code smells. |
| [`code-review-pr-auditor`](./code-review-pr-auditor/SKILL.md) | Revisão sênior de PRs: cirurgia de diff, regressões, segurança de migrações e robustez de testes. |
| [`systematic-debugging`](./systematic-debugging/SKILL.md) | Reprodução mínima determinística em teste (*Red*), `git bisect` e isolamento da causa raiz. |
| [`runtime-performance-diagnostician`](./runtime-performance-diagnostician/SKILL.md) | Medição empírica obrigatória (*baseline* RSS/latência/throughput) antes de qualquer otimização. |
| [`security-vulnerability-warden`](./security-vulnerability-warden/SKILL.md) | OWASP Top 10, BOLA/IDOR, SCA de dependências, varredura de segredos e headers de transporte. |
| [`observability-logging-auditor`](./observability-logging-auditor/SKILL.md) | Logging estruturado JSON, OpenTelemetry (`trace_id`/`span_id`), RED/USE e sanitização de PII. |
| [`infra-pipeline-hardener`](./infra-pipeline-hardener/SKILL.md) | Dockerfiles multi-stage rootless, limites de recursos no Compose e GitHub Actions fail-fast com SHA pinning. |
| [`module-documentation-scribe`](./module-documentation-scribe/SKILL.md) | Documentação Diátaxis em 2 níveis (macro/micro), diagramas C4-Mermaid, ADRs (MADR) e Changelog. |
| [`git-commit-sentinel`](./git-commit-sentinel/SKILL.md) | Validação determinística do staged diff (`gitleaks` + higiene) e Conventional Commits v1.0.0. |
| [`issue-milestone-orchestrator`](./issue-milestone-orchestrator/SKILL.md) | Governança de `ROADMAP.md`, issues BDD Gherkin, labels P0–P3 e milestones SemVer. |
| [`release-distribution-engineer`](./release-distribution-engineer/SKILL.md) | Pre-Release Briefing, cálculo SemVer, sincronia de manifests, `SHA256SUMS`, SBOM e SLSA/Sigstore. |

---

## Instalação

Clone no diretório de skills do seu agente e vincule o `AGENTS.md`:

```bash
git clone https://github.com/Arkmedess/skills.git ~/.gemini/config/skills
cp ~/.gemini/config/skills/AGENTS.md ~/.gemini/config/AGENTS.md
```

---

## Execução da Suíte de Testes

```bash
bash tests/test_portability.sh
bash git-commit-sentinel/tests/test_verify_staged_diff.sh
bash release-distribution-engineer/tests/test_check_version_and_readiness.sh
```

---

## Licença

Distribuído sob a licença [MIT](./LICENSE).
