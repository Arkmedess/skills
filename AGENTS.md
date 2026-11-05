# AGENTS.md — Regras Globais & Orquestração do Antigravity

Este arquivo governa todas as interações e sessões em qualquer projeto. Todas as diretrizes abaixo são inegociáveis.

---

## 0. Filosofia & Pilares de Engenharia

1. **Governança Calibrada por Natureza da Mudança:**
   - **Mudanças Lógicas / Comportamentais (Backend, Frontend, Core, Regras de Negócio):** Nenhum código é aceito sem teste automatizado (TDD Red $\rightarrow$ Green $\rightarrow$ Simplify), sem verificação arquitetural e sem documentação de contrato correspondente.
   - **Mudanças Documentais, Declarativas ou de Configuração (`.md`, `.json`, `.yaml`, Design Tokens CSS puros, manifests, chore, typos):** Ficam expressamente isentas de criação ou execução de testes unitários; exigem estritamente verificação estática de sintaxe, formatação, markdown-lint, integridade de links e cirurgia de diff.
2. **Nenhuma decisão de infraestrutura, banco de dados ou performance é aceita sem medição empírica (*baseline*).**
3. **Toda entrega é incremental, cirúrgica e auditável:**
   - **Cirurgia de Diff (*Karpathy Guidelines*):** Toque estritamente nas linhas exigidas pelo requisito. É proibido "melhorar", reformatar ou refatorar código adjacente não relacionado na mesma entrega.
   - **Simplicidade Primeiro (*YAGNI*):** Escreva o menor código que resolve o problema. Proibido criar abstrações, interfaces ou factories para uso único ou configurabilidade especulativa.
4. **A stack é sempre detectada a partir dos manifests do repositório** (`*.csproj`/`*.slnx`, `pyproject.toml`, `pubspec.yaml`, `Cargo.toml`, `package.json`, `go.mod`) — nenhuma skill assume uma linguagem fixa.
5. **Clean Code & SOLID como Diretriz de Modelagem:**
   - Funções pequenas no Nível Único de Abstração (SLA), máximo de 3 níveis de aninhamento (*guard clauses*), proibição de *flag arguments*, respeito à Lei de Demeter e erradicação de *Primitive Obsession*, *Feature Envy* e *God Classes*.
   - **SOLID:** SRP (uma razão para mudar), OCP (extensão sem modificar código estável), LSP (contratos base preservados sem exceções surpresa), ISP (interfaces enxutas orientadas ao consumidor) e DIP (domínio depende de portas/abstrações injetadas, nunca de I/O concreto).

---

## 0.1 Protocolo Resiliente de Ativação e Encadeamento de Skills (Hard-Gate)

> **REGRA DE BLOQUEIO DE FERRAMENTA (COMO ATIVAR UMA SKILL):**
> "Ativar uma skill" **NÃO** é um exercício mental: significa **ler obrigatoriamente, com a ferramenta de leitura de arquivos disponível, o `SKILL.md` da skill (use o caminho informado no catálogo de skills do harness; `<SKILL_DIR>` = pasta que contém esse `SKILL.md`) ANTES de propor arquitetura, escrever testes, editar código ou executar comandos daquela etapa.**
> - Se múltiplas skills forem aplicáveis ao turno atual, leia seus `SKILL.md` **em paralelo no mesmo turno** com a ferramenta de leitura de arquivos (limite pragmático de **2 a 3 skills nucleares por turno** para preservar o orçamento de contexto).
> - **Prevenção de Ciclos de Handoff:** Os blocos `HANDOFF` ao final de cada skill indicam o encadeamento lógico da esteira, mas nunca devem gerar loops infinitos (`A -> B -> A`). Uma skill já carregada na sessão atual não precisa ser relida.
> - É expressamente proibido iniciar o Passo 1 de implementação ou emitir diagnósticos sem antes ter carregado o `SKILL.md` correspondente no contexto da conversa.

### A. Matriz de Gatilhos Obrigatórios (`Intenção -> ler SKILL.md`)

| Gatilho / Contexto da Tarefa | Skill Obrigatória (`SKILL.md`) | Responsabilidade Crítica |
| :--- | :--- | :--- |
| **Repositório desconhecido / Início de projeto** | `project-horizon-profiler` | Identificar arquétipo (Web, CLI, Batch, FFI, Lib, Mobile) e calibrar métricas. |
| **Nova Feature / Novo Módulo / Refactor / Dúvida de Acoplamento** | `architecture-boundary-auditor` | Mapear fronteiras, validar DIP/ISP/OCP e propor topologia (somente leitura). |
| **Implementação ou Alteração de Código (Geral / Legado)** | `vertical-slice-implementer` | Ciclo TDD (`Red -> Green -> Simplify`), Characterization Tests, Clean Code, SOLID e cirurgia de diff. |
| **Contratos de API HTTP/REST, OpenAPI, gRPC, RFC 9457 ou Webhooks** | `api-contract-designer` | Semântica HTTP, Problem Details (RFC 9457), evolução sem quebra (Expand-Contract) e idempotência. |
| **Direção de Arte, Identidade Visual, UI Design ou Anti-Clichê** | `frontend-design` | Identidade autoral, validação/criação de tokens e style guide, resolução visual e UX. |
| **Interfaces Web/Mobile, Componentes, CSS, UX ou Acessibilidade** | `frontend-ui-craftsman` | WCAG 2.2 AA, Core Web Vitals (LCP/INP/CLS), governança de tokens/style guide e 5 estados de UI. |
| **Migrations, SQL, Índices, Paginação, Cache, Filas ou ETL** | `backend-data-resilience` | Zero-Downtime Migrations (`Expand-Backfill-Contract`), idempotência, DLQ e TTLs. |
| **Planejamento, Criação ou Auditoria de Testes** | `test-suite-architect` | TQA (4 dimensões), Testcontainers, mutação por diff, Testing Library/Playwright. |
| **Verificação Pós-Implementação, Linter e Refinamento** | `code-hygiene-auditor` | Linters nativos (zero warnings), complexidade $\le 10$, SLA, SOLID e code smells. |
| **Revisão de Pull Request ou Diff de Branch** | `code-review-pr-auditor` | Gatekeeper sênior: cirurgia de diff, regressões, segurança de migrations e testes. |
| **Bugs, Falhas de Teste, Stacktraces ou Comportamento Anômalo** | `systematic-debugging` | Reprodução mínima determinística em teste (*Red*) e isolamento da causa-raiz. |
| **Lentidão, Latência, CPU/RAM, Queries Lentas ou Web Vitals** | `runtime-performance-diagnostician` | Baseline empírico obrigatório antes de otimizar CPU, I/O, banco ou bundle. |
| **Autenticação, Autorização (IDOR/BOLA), Segredos, CORS ou SCA** | `security-vulnerability-warden` | Auditoria OWASP Top 10, controle de acesso granular, JWT e dependências. |
| **Atualização de Dependências, Pacotes, Lockfiles ou Runtimes** | `dependency-upgrade-steward` | Upgrades SemVer isolados, determinismo de lockfiles, codemods e sincronia de runtime. |
| **Logs, Traces, Métricas ou Remoção de `print`/`console.log`** | `observability-logging-auditor` | OpenTelemetry, correlação `trace_id`/`span_id`, sanitização de PII e níveis. |
| **Ferramentas de Linha de Comando (CLI) ou Scripts com Flags** | `cli-development` | Separação `stdout`/`stderr`, exit codes ($0, 1, 2$), `--json`, TTY e `NO_COLOR`. |
| **Dockerfiles, Compose, GitHub Actions ou Pipelines CI/CD** | `infra-pipeline-hardener` | Multi-stage rootless, limites de recursos, cache BuildKit e pipeline fail-fast. |
| **README, ADRs (MADR), Diagramas C4-Mermaid ou Changelog** | `module-documentation-scribe` | Documentação Docs-as-Code (Diátaxis) em nível macro (raiz) e micro (fatia). |
| **Preparação e Execução de Commits Git** | `git-commit-sentinel` | Validação determinística do staged diff e Conventional Commits em português. |
| **Criação/Triagem de Issues, Labels ou Milestones no GitHub** | `issue-milestone-orchestrator` | Governança via `gh CLI`, prioridades P0–P3 e marcos SemVer. |
| **Bump de Versão, Tags SemVer, Checksums ou Releases** | `release-distribution-engineer` | Detecção de breaking changes, `SHA256SUMS`, SBOM e publicação SLSA/Sigstore. |

### B. Pipelines de Encadeamento Adaptativo por Cenário
Não aguarde o usuário pedir cada skill individualmente. Encadeie a leitura das skills conforme a natureza e a envergadura da demanda:
1. **Fluxo de Nova Feature / Evolução Arquitetural Completa:**
   `architecture-boundary-auditor` $\rightarrow$ `vertical-slice-implementer` (+ `frontend-design` se direção de arte/identidade \| + `frontend-ui-craftsman` se UI \| + `backend-data-resilience` se DB/Filas/Cache) $\rightarrow$ `test-suite-architect` $\rightarrow$ `code-hygiene-auditor` $\rightarrow$ `module-documentation-scribe` $\rightarrow$ `git-commit-sentinel`.
2. **Fluxo de Ajuste Pontual / Cirúrgico (Sem Quebra de Arquitetura):**
   `vertical-slice-implementer` (ou skill especialista da área) $\rightarrow$ `code-hygiene-auditor` $\rightarrow$ `git-commit-sentinel` (dispensa auditoria de fronteiras e escrita de ADR se não houver decisão de design global).
3. **Fluxo de Mudança Puramente Documental ou de Configuração (`.md`, `.json`, docs):**
   `module-documentation-scribe` $\rightarrow$ `git-commit-sentinel` (dispensa TDD e suíte de testes de código de produção).
4. **Fluxo de Correção de Bug:**
   `systematic-debugging` (reprodução em teste *Red*) $\rightarrow$ `vertical-slice-implementer` (correção cirúrgica *Green* + *Simplify*) $\rightarrow$ `code-hygiene-auditor` $\rightarrow$ `git-commit-sentinel`.
5. **Fluxo de Otimização de Performance:**
   `runtime-performance-diagnostician` (medição de baseline) $\rightarrow$ `backend-data-resilience` ou `frontend-ui-craftsman` ou `vertical-slice-implementer` $\rightarrow$ `test-suite-architect`.
6. **Fluxo de Commit, Versionamento e Release (Git Local + MCP `github`):**
   `release-distribution-engineer` (auditoria `check_version_and_readiness.sh` + Pre-Release Briefing + sincronia de manifests/`--version`) $\rightarrow$ `module-documentation-scribe` (`CHANGELOG.md`) $\rightarrow$ `git-commit-sentinel` (`chore(release): lançar versão vX.Y.Z` + tag anotada `-a`) $\rightarrow$ `release-distribution-engineer` (`gh release create` com flags `--verify-tag`, `--target`, `--latest`/`--prerelease` + `SHA256SUMS`) $\rightarrow$ `issue-milestone-orchestrator` (fechamento da milestone).

---

## 1. Critérios de Modelos Arquiteturais & Calibração de Topologia

O agente **não impõe uma arquitetura única** para todos os problemas. A arquitetura deve emergir da natureza do sistema:

### A. Taxonomia de Modelos Arquiteturais
1. **Vertical Slice Architecture (Feature-First):**
   - *Quando adotar:* APIs REST/GraphQL, microsserviços, aplicações Web full-stack e sistemas orientados a casos de uso independentes.
   - *Topologia:* Agrupamento por fatias coesas (`features/<nome_da_feature>/`), contendo pontos de entrada, domínio, adaptadores e testes próprios. Elimina pastas horizontais globais (`controllers/`, `services/`, `repositories/`).
2. **Hexagonal Architecture (Ports & Adapters):**
   - *Quando adotar:* Domínios com regras densas e múltiplos canais de entrada (HTTP, CLI, Filas) e saída (bancos, integrações externas).
   - *Topologia:* Núcleo puro (`domain/`) cercado por contratos (`ports/`) e implementações (`adapters/`).
3. **Pipeline / Stream-Processing Architecture (Stage-Based):**
   - *Quando adotar:* Engenharia de dados, batch, ETL, ingestão massiva e extensões colunares (Polars, Arrow, Parquet).
   - *Topologia:* Estágios sequenciais ou DAGs (`pipeline/stages/`), priorizando imutabilidade, processamento em chunks, zero-copy e isolamento entre transformação pura e I/O.
4. **Command-Driven / Micro-Kernel (CLI):**
   - *Quando adotar:* Ferramentas de terminal e automações (`commands/<subcomando>/`).
5. **Clean Architecture Tradicional (Camadas Concêntricas):**
   - *Quando adotar:* Monolitos corporativos onde a separação `Entities / UseCases / Adapters / Frameworks` já é o padrão consolidado.

### B. Protocolo para Repositórios Sem Arquitetura Definida ou Ambígua
1. **Inspeção de Contexto (Zero Suposição):** Carregue (leia o `SKILL.md` de) as skills `project-horizon-profiler` e `architecture-boundary-auditor`.
2. **Proposta Arquitetural Estruturada:** É proibido criar pastas silenciosamente. Apresente ao desenvolvedor o diagnóstico atual, 2 ou 3 abordagens viáveis com prós/contras e a recomendação justificada.
3. **Decisão do Desenvolvedor:** Aguarde aprovação explícita antes de criar diretórios ou mover arquivos.

---

## 2. Portão de Entrega Incremental e Contextualização (Ciclo de 6 Etapas)

O escopo de cada entrega é limitado à **menor unidade lógica coesa e auditável** (ex.: um contrato e seu teste, ou um método/componente pontual). É proibido alterar múltiplos módulos dispersos em lote sem autorização.

### Fluxo Obrigatório em 6 Etapas:
- **Passo 1 — Pre-Flight de Skills, Localização & Intenção Arquitetural:**
  - Carregue (leia) os `SKILL.md` exigidos pela tarefa.
  - Declare obrigatoriamente no topo da resposta: **`[Skills Ativas: <nomes-das-skills-lidas>]`**.
  - Declare em 1 frase o objetivo da mudança, os arquivos exatos afetados (`file:///...`), a fatia/camada impactada e o princípio SOLID/padrão aplicado.
- **Passo 2 — Contrato, Assinatura & Teste TDD (Red) ou Minuta Declarativa:**
  - *Mudança Lógica:* Apresente a interface/assinatura e o teste automatizado especificando o comportamento e erros explícitos, **sem implementar o código de produção ainda**.
  - *Mudança Documental/Declarativa:* Apresente a estrutura do arquivo ou minuta do diff planejado e validação de formato/schema.
- **Passo 3 — Checkpoint de Calibração com o Desenvolvedor:**
  - Sempre que houver trade-offs arquiteturais (ex.: síncrono vs. fila, RSC vs. Client, estratégia de migração), liste prós e contras concisos e confirme com o desenvolvedor antes de codificar a produção.
  - **Fast-Path para Mudanças Cirúrgicas Triviais ($\le 20$ linhas, sem quebra de contrato público, sem nova dependência e sem migração de banco):** Dispensa a pausa do Passo 3; avance diretamente do teste (Red) para a implementação (Green) e verificação estática (Passo 5) no mesmo turno.
- **Passo 4 — Implementação Mínima Coesa (Green) & Simplify:**
  - Entregue o código final (sem placeholders) estritamente necessário para passar no teste, seguido do refinamento *Simplify* (remoção de duplicação e garantia de SLA) e cobertura dos 5 estados (se UI) ou idempotência (se Backend).
- **Passo 5 — Verificação Estática, Testes & Zero Warnings:**
  - Execute os testes automatizados (em mudanças lógicas) e os linters nativos da stack (`code-hygiene-auditor`), garantindo zero warnings e ausência de resíduos de debug. Em mudanças documentais, execute linters de markdown e validação de links.
- **Passo 6 — Documentação & Commit Atômico:**
  - Atualize a documentação impactada (`module-documentation-scribe`, quando houver alteração de contrato público ou novos recursos) e valide o staged diff via `git-commit-sentinel` com Conventional Commits em português.

---

## 3. Padrões de Código e Idiomas por Stack

### A. Nomenclatura e Casing
- Nomes expressivos e reveladores de intenção; proibidas abreviações crípticas (`usr`, `ctx_fn`, `tmp_calc`).
- **Constantes globais/imutáveis:** `SCREAMING_SNAKE_CASE`.
- **Por linguagem:**
  - **Python:** `snake_case` (funções, variáveis, módulos), `PascalCase` (classes, tipos), `_prefixo` (privados).
  - **C# / .NET:** `PascalCase` (classes, métodos, propriedades, interfaces `I...`), `camelCase` (locais/parâmetros), `_camelCase` (campos privados).
  - **TypeScript / JavaScript:** `camelCase` (funções, variáveis, hooks `use...`), `PascalCase` (componentes, classes, tipos, interfaces).
  - **Rust:** `snake_case` (funções, variáveis, módulos), `PascalCase` (structs, enums, traits).
  - **Dart / Flutter:** `camelCase` (membros), `PascalCase` (classes, widgets, enums), `lower_snake_case` (arquivos).

### B. Docstrings e Documentação Interna (Sempre em Português)
- Todas as docstrings, cabeçalhos de módulo e anotações de contratos públicos devem ser escritos em **Português** no padrão nativo da stack (PEP 257 Google/Sphinx, XML Docs `///`, TSDoc `/** */`, Rust/Dart `///`).
- Comentários internos narrativos (`// incrementa x`) são proibidos; documente apenas o *porquê* de decisões não triviais.

---

## 4. Git, Conventional Commits v1.0.0, MCP `github` e Releases SemVer

Toda operação de commit (via Git local ou servidor MCP `github` em `push_files`/`create_or_update_file`/`merge_pull_request`) e de lançamento de versão deve ser validada por `git-commit-sentinel` e `release-distribution-engineer`:

```text
<tipo>(<escopo>)[!]: <descrição concisa no imperativo, minúscula e sem ponto final>

- <mudança técnica explicando o 'porquê', invariantes e validações executadas>

[BREAKING CHANGE: <descrição exata da quebra e guia de migração>]
[Fixes: #123 | Closes: #123 | Refs: #123]
```

- **Tipos aceitos:** `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `chore`, `style`, `revert`.
- **Breaking Changes:** Exigem obrigatoriamente `!` antes de `:` no cabeçalho **e** o footer `BREAKING CHANGE:` no rodapé.
- **Versionamento e Releases:** Nenhum bump ou release ocorre sem antes executar `check_version_and_readiness.sh` e apresentar o **Pre-Release Briefing** (versão atual nas tags/manifests/`--version`, contagem de commits do ciclo, versão SemVer calculada e flags explícitas `--verify-tag`, `--target`, `--latest`/`--prerelease`/`--draft`).
