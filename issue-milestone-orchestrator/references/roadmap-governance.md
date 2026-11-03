# Governança de Roadmap de Engenharia e Gestão de Milestones

## 1. Princípios de Roadmap Profissional
Um roadmap de software de alta maturidade não é uma lista de desejos informal nem um backlog infinito desordenado. É um **instrumento de compromisso técnico e arquitetural**, estruturado hierarquicamente:

```text
Visão / Capacidade Central (Core Vision)
└── Épicos de Arquitetura / Entrega
    └── Milestones SemVer (v0.1.0, v0.2.0, v1.0.0...)
        └── Fatias Verticais / Issues Coesas (#42, #43, #44...)
            └── Commits Atômicos & Pull Requests (Fixes #42)
```

### Regras Inegociáveis de Roadmap:
1. **Régua SemVer Vinculada ao Escopo:**
   - **Fase Inicial (`0.y.z`):** Cada milestone fecha um conjunto coeso de fatias verticais ou fundação (`v0.1.0 - Setup & Core`, `v0.2.0 - Persistência & Streaming`, `v0.3.0 - UI & Acessibilidade`).
   - **Fase de Produção Estável (`v1.0.0+`):** Milestones `MINOR` (`v1.1.0`, `v1.2.0`) representam capacidades novas retrocompatíveis; milestones `PATCH` (`v1.0.1`) agrupam correções de defeitos críticos. Quebras de contrato exigem marco `MAJOR` (`v2.0.0`).
2. **Critérios Explícitos de Saída de Milestone (Exit Criteria):**
   Nenhuma milestone é considerada concluída sem que:
   - 100% das issues associadas estejam fechadas com PRs mesclados e testados.
   - A suíte de testes de integração e linters esteja verde no CI.
   - A documentação de módulo (`module-documentation-scribe`) e o `CHANGELOG.md` estejam sincronizados.
   - A skill `release-distribution-engineer` execute a verificação `check_version_and_readiness.sh`.

---

## 2. Estrutura Canônica do Arquivo `ROADMAP.md` na Raiz do Repositório

```markdown
# Roadmap de Engenharia do Sistema

Documento orientador de capacidades técnicas, maturidade de arquitetura e entregas SemVer.

---

## 🎯 Visão Executiva & Próximas Entregas

| Milestone | Foco Principal | Status | Previsão / Alvo |
| :--- | :--- | :--- | :--- |
| **[v0.1.0 - Fundação & Setup](#v010---fundação--setup)** | Arquitetura base, CI/CD, contratos de domínio e tooling. | ✅ Concluído | 2026-Q1 |
| **[v0.2.0 - Resiliência & Dados](#v020---resiliência--dados)** | Migrações zero-downtime, paginação por cursor e cache. | 🚧 Em Andamento | 2026-Q2 |
| **[v0.3.0 - Interface & Acessibilidade](#v030---interface--acessibilidade)** | Componentes, 5 estados de UI e conformidade WCAG 2.2 AA. | 📋 Planejado | 2026-Q2 |
| **[v1.0.0 - Estabilidade de Produção](#v100---estabilidade-de-produção)** | Selagem de APIs públicas, auditoria de segurança e SLA. | 🔒 Bloqueado | 2026-Q3 |

---

## Detalhamento das Milestones

### v0.2.0 - Resiliência de Dados e Processamento Assíncrono
**Objetivo:** Eliminar locks de banco em tabelas de alto volume e garantir idempotência em filas.

- [x] **#42** - `feat(db): template de migração com batch backfill e skip locked`
- [ ] **#45** - `feat(orders): paginação keyset baseada em cursor composto`
- [ ] **#48** - `feat(cache): governança de TTL e proteção contra cache stampede no Redis`
- [ ] **#51** - `test(db): suíte de idempotência transacional com Testcontainers`

**Critérios de Conclusão da Milestone (DoD):**
1. Testes de estresse com 500k registros com zero table lock exclusivo.
2. 100% dos status checks verdes no GitHub.
3. Changelog v0.2.0 consolidado via `git-cliff`.
```

---

## 3. Gestão de Ciclo de Vida da Milestone via Terminal (`gh CLI`)

```shell
# 1. Criar milestone oficial
gh api repos/:owner/:repo/milestones \
  -f title="v0.2.0 - Resiliência & Dados" \
  -f state="open" \
  -f description="Eliminar locks em tabelas de alto volume e implementar paginação por cursor."

# 2. Consultar milestones ativas e progresso
gh api repos/:owner/:repo/milestones \
  --jq '.[] | {id: .number, title: .title, open_issues: .open_issues, closed_issues: .closed_issues}'

# 3. Fechar milestone após publicação da release
gh api repos/:owner/:repo/milestones/:milestone_number -X PATCH -f state="closed"
```

