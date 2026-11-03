# Dicionário Canônico de Labels do GitHub e Mapeamento de Commits

| Label GitHub | Tipo Conventional Commit | Cor Hex | Descrição / SLA |
| :--- | :--- | :--- | :--- |
| `type: feat` | `feat` | `#1D76DB` | Nova funcionalidade orientada a valor de negócio. |
| `type: bug` | `fix` | `#D93F0B` | Falha, regressão ou comportamento divergente. |
| `type: refactor` | `refactor` | `#F9D0C4` | Reestruturação interna sem alteração de comportamento. |
| `type: docs` | `docs` | `#0075CA` | Documentação técnica, especificações, ADRs ou guias. |
| `type: test` | `test` | `#0E8A16` | Criação ou ajuste de testes (unitários, integração, mutação). |
| `type: perf` | `perf` | `#5319E7` | Melhoria de desempenho comprovada por medição/benchmark. |
| `type: infra` | `ci` / `chore` | `#E99695` | CI/CD, contêineres, automação e manifests de build. |
| `type: security` | `fix` / `chore` | `#B60205` | Correção de vulnerabilidade, auditoria de segredos ou SCA. |
| `priority: critical` | — | `#B60205` | **P0:** Parada total de produção, corrupção de dados (SLA: < 2h). |
| `priority: high` | — | `#D93F0B` | **P1:** Bloqueio de fluxo core sem contorno (SLA: < 24h). |
| `priority: medium` | — | `#FBCA04` | **P2:** Falha parcial com contorno disponível (Fluxo normal). |
| `priority: low` | — | `#0E8A16` | **P3:** Baixo impacto, melhoria estética ou menor. |
| `scope: <modulo>` | `<escopo>` do commit | `#C2E0C6` | **Dinâmico:** reflete módulos reais (ex.: `scope: engine`, `scope: cli`). |
| `status: triage` | — | `#EDC240` | Sob investigação ou aguardando detalhamento/reprodução. |
| `status: ready-for-dev` | — | `#0E8A16` | Especificação completa, aprovada e pronta para desenvolvimento. |
| `status: in-progress` | — | `#FBCA04` | Em desenvolvimento ativo pelo time ou agente. |
| `status: blocked` | — | `#000000` | Impedimento externo ou dependência técnica pendente. |

### Procedimento de Padronização no Repositório
```shell
# Listar labels existentes
gh label list --json name,color,description

# Sincronizar label ausente
gh label create "priority: critical" --color "B60205" --description "P0: Parada total de producao, corrupcao de dados." --force
```
