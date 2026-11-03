---
name: code-review-pr-auditor
description: >-
  Use esta skill SEMPRE para revisar Pull Requests (PRs), inspecionar diffs completos de branches antes de merge
  ou auditar entregas de código sob a perspectiva de engenheiro sênior. Avalia Clean Code, integridade lógica,
  conformidade com SOLID, adequação pragmática de Design Patterns vs overengineering, riscos de regressão
  e robustez da suíte de testes.
---

# Auditor de Code Review, Pull Requests e Arquitetura

## Passo 1 — Inspeção do Escopo, Cirurgia de Diff e Alinhamento
1. Obtenha o diff completo (`git diff main...HEAD`, `gh pr diff` ou via MCP `github`: `get_pull_request` + `get_pull_request_files` + `get_pull_request_status`).
2. Verifique **Cirurgia de Diff (Karpathy Guidelines):** toda linha alterada deve rastrear ao requisito/issue. Bloqueie alterações colaterais não solicitadas (*scope creep*) ou refatorações cosméticas em arquivos adjacentes.

---

## Passo 2 — Checklist de Auditoria Técnica Sênior
Utilize `references/code-review-checklist.md` para auditar:
- **Clean Code & SOLID:** Funções pequenas (SLA), ausência de *flag arguments*, respeito a SRP, DIP, ISP, LSP e OCP.
- **Anti-Overengineering (YAGNI):** Rejeite abstrações prematuras, factories ou interfaces criadas para uso único.
- **Resiliência de Dados & Migrações (`backend-data-resilience`):** Bloqueie migrações com lock exclusivo em tabelas grandes, ausência de idempotência em escritas/filas, queries $N+1$ ou falta de TTL em cache.
- **Qualidade de Interface (`frontend-ui-craftsman`):** Em mudanças de UI, exija cobertura dos 5 estados (Loading, Empty, Error, Overflow, Success), semântica WCAG 2.2 AA e uso correto de Server/Client Components.
- **Robustez dos Testes (`test-suite-architect`):** Rejeite PRs sem testes para o comportamento novo ou com testes tautológicos (Over-Mocking).

---

## Passo 3 — Emissão do Parecer de Revisão
1. **Veredito:** `APROVADO`, `APROVADO COM SUGESTÕES LEVES` ou `MUDANÇAS REQUERIDAS (BLOCKER)`.
2. **Blockers:** Problemas lógicos, violações de SOLID/arquitetura, migrações inseguras, quebras de contrato ou falta de testes.
3. **Sugestões Não-Bloqueantes:** Simplificações idiomáticas pontuais.

---

## Handoff

Ao finalizar a revisão, acione via `view_file` a próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: code-review-pr-auditor
Para: vertical-slice-implementer (para corrigir blockers de código) | backend-data-resilience (se houver blocker em migration/query) | frontend-ui-craftsman (se houver blocker de UI/WCAG) | test-suite-architect (se faltarem testes) | git-commit-sentinel (se aprovado)
Motivo: <veredito da revisão: aprovado vs mudanças requeridas>
Contexto necessário: <lista de blockers com arquivo:linha e status dos testes>
```

