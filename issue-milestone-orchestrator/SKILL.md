---
name: issue-milestone-orchestrator
description: >-
  Use esta skill SEMPRE que for interagir com issues ou milestones do GitHub (via MCP github ou gh CLI),
  estruturar o ROADMAP.md, criar tickets técnicos de bugs/features/refactors com critérios BDD,
  padronizar labels com taxonomia rigorosa ou gerenciar ciclos de entrega SemVer.
---

# Orquestrador de Roadmap, Milestones e Issues Técnicas (GitHub MCP & `gh CLI`)

## Modo de Execução: Rastreabilidade Técnica Ponta a Ponta
Nenhuma issue ou milestone é criada sem propósito técnico concreto, alinhamento ao roadmap e critérios de aceite verificáveis. Cada ticket reflete um contrato de código, correção reproduzível ou marco de maturidade SemVer.

---

## 1. Governança de Roadmap & Régua de Milestones SemVer

Todo repositório deve manter seu **`ROADMAP.md` na raiz** alinhado às Milestones do GitHub conforme detalhado em `references/roadmap-governance.md`:

```text
Visão Central -> Milestones SemVer (vX.Y.Z) -> Fatias Verticais / Issues -> Commits / PRs
```

### A. Régua SemVer por Fase de Maturidade
- **Fase Inicial (`0.y.z` — Pré-v1.0):**
  - `v0.1.0 - Setup & Fundação`: Estrutura de módulos, CI/CD, contratos de domínio e tooling.
  - `v0.2.0+ - Fatias Verticais`: Cada milestone fecha um épico coeso (ex.: *Resiliência de Dados*, *UI & Acessibilidade*).
- **Fase de Produção Estável (`v1.0.0+`):**
  - **MAJOR (`v2.0.0`):** Selagem de quebras de contrato de APIs públicas, schemas ou CLI.
  - **MINOR (`v1.1.0`):** Novas capacidades retrocompatíveis.
  - **PATCH (`v1.0.1`):** Correções de bugs ou melhorias de performance sem alteração de contratos.

### B. Critérios de Conclusão da Milestone (Milestone Exit Gate)
Antes de fechar uma milestone:
1. 100% das issues associadas devem estar com status fechado via PRs mesclados (`Fixes #<numero>`).
2. Status checks de CI e linters 100% verdes (`get_pull_request_status`).
3. Disparar a skill `release-distribution-engineer` para executar `check_version_and_readiness.sh`, gerar tag anotada e publicar a release com as notas estruturadas.

---

## 2. Anatomia de uma Issue Profissional e Critérios de Aceite

Toda issue deve ser concisa, inequívoca e estruturada conforme `references/issue-templates.md`:

1. **Contexto & Job-to-be-Done (JTBD) Técnico:** "Para que [consumidor/sistema], queremos [capacidade], de modo que [impacto/invariante]."
2. **Contratos Técnicos Estritos:** Definição explícita de entradas, processamento, saídas (tipos/schemas) e códigos de status/erros esperados.
3. **Critérios de Aceite BDD (Gherkin):** Cenários determinísticos `Dado... Quando... Então...` que orientam diretamente a criação de testes no TDD (`vertical-slice-implementer` e `test-suite-architect`).
4. **Escopo Negativo (Out-of-Scope — Karpathy Guidelines):** Declaração explícita do que **NÃO** faz parte da entrega, eliminando scope creep e prevenindo alterações em código adjacente.
5. **Cobertura por Especialidade:**
   - **Se Frontend:** Exigir os 5 estados de UI (Loading, Empty, Error, Overflow, Success) e acessibilidade WCAG 2.2 AA (`frontend-ui-craftsman`).
   - **Se Backend / Dados:** Exigir migração zero-downtime (*Expand-Backfill-Contract*) e idempotência (`backend-data-resilience`).

*Consulte:* [issue-templates.md](./references/issue-templates.md) para estruturas Markdown, [github-issue-forms-yaml.md](./references/github-issue-forms-yaml.md) para formulários declarativos `.github/ISSUE_TEMPLATE/*.yml` e [sample_tickets.md](./examples/sample_tickets.md) para modelos completos prontos.

---

## 3. Taxonomia Canônica de Labels e Prioridade P0–P3

Execute o script de sincronização no terminal para padronizar labels:
```bash
bash <SKILL_DIR>/scripts/sync_github_labels.sh   # <SKILL_DIR> = pasta deste SKILL.md
```

- **P0 (`priority: critical`):** SLA < 2h (parada total de produção, falha de segurança ativa ou corrupção de dados).
- **P1 (`priority: high`):** SLA < 24h (bloqueio de capacidade central sem contorno).
- **P2 (`priority: medium`):** Fluxo regular de evolução ou bug com contorno documentado.
- **P3 (`priority: low`):** Melhoria cosmética ou débito menor.
- *Consulte:* `references/github-labels-matrix.md`.

---

## 4. Operação Híbrida: Servidor MCP `github` vs. `gh CLI`

### A. Operações via Servidor MCP `github` (`call_mcp_tool`)
- **Busca de Duplicatas:** Chame `search_issues` ou `list_issues` (`state: "open"`) antes de criar tickets.
- **Criação de Issue (`create_issue`):**
  - `owner`, `repo`
  - `title`: Em formato Conventional Commits (`feat(invoicing): implementar paginação por cursor`).
  - `body`: Markdown completo com Contexto/JTBD, Contratos, BDD Gherkin, Out-of-Scope e DoD.
  - `labels`: Array com tipo, prioridade e status (ex.: `["type: feat", "priority: high", "status: ready-for-dev"]`).
  - `milestone`: ID numérico da milestone SemVer associada.
- **Atualização (`update_issue` / `add_issue_comment`):** Atualize status, comente evidências de testes ou registre o PR correspondente.

### B. Gestão de Milestones via `gh CLI`
```shell
# 1. Criar milestone SemVer e obter ID numérico
gh api repos/:owner/:repo/milestones -f title="v0.2.0 - Resiliência & Dados" -f state="open" -f description="Eliminar locks e habilitar streaming"

# 2. Consultar progresso
gh api repos/:owner/:repo/milestones --jq '.[] | {number: .number, title: .title, open: .open_issues, closed: .closed_issues}'

# 3. Fechar milestone após publicação da release
gh api repos/:owner/:repo/milestones/:id -X PATCH -f state="closed"
```

---

## Handoff

Ao finalizar a governança de issues e milestones, carregue o `SKILL.md` da próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: issue-milestone-orchestrator
Para: vertical-slice-implementer (quando a issue estiver em status: ready-for-dev) | release-distribution-engineer (quando todas as issues da milestone forem concluídas) | git-commit-sentinel (fornecendo o número #ID da issue para o footer do commit/PR)
Motivo: <resumo das issues e milestones criadas ou alinhamento do roadmap>
Contexto necessário: <números das issues (#123), milestone associada, labels aplicadas e critérios de aceite BDD>
```
