---
name: architecture-boundary-auditor
description: >-
  Use esta skill SEMPRE antes de iniciar uma feature nova em bases de código existentes, antes de qualquer refactor amplo, ao entrar em um repositório desconhecido, ou quando o usuário pedir "revisar arquitetura", "auditar estrutura", "mapear módulos", "verificar SOLID arquitetural", "por que isso está acoplado" ou similar. Também aciona automaticamente quando outra skill relatar suspeita de vazamento entre módulos/fatias. Funciona com qualquer stack (monorepo .NET, Python, Flutter, Node, Rust) — a linguagem é detectada, não assumida.
---

# Auditor de Fronteiras Arquiteturais, SOLID & Design Patterns

## Modo de Operação: Somente Leitura
Esta skill **nunca** cria ou altera código diretamente. Ela produz diagnóstico de arquitetura. Caso correções sejam necessárias, produza o diagnóstico e pergunte antes de delegar para `vertical-slice-implementer`.

---

## Passo 1 — Detecção da Stack, Topologia e Adequação do Modelo Arquitetural
Inspecione os manifests do repositório, árvores de diretórios e padrões de chamada para mapear o modelo arquitetural ativo:
- **Modelos Canônicos Suportados:**
  - *Vertical Slice (Feature-First):* Fatias coesas orientadas a casos de uso (`features/<feature>/`).
  - *Hexagonal / Ports & Adapters:* Domínio puro isolado com interfaces (`ports/`) e implementações (`adapters/`).
  - *Pipeline / Stream-Processing (Stage-Based):* Estágios lineares ou DAGs de processamento de dados (`pipeline/stages/` ou `stages/`).
  - *CLI / Command-Driven:* Subcomandos modulares (`commands/<cmd>/`).
  - *Clean Architecture Clássica:* Camadas concêntricas rígidas (`domain/`, `usecases/`, `infrastructure/`).
- Consulte [boundary-rules-by-stack.md](./references/boundary-rules-by-stack.md) para as regras de fatiamento por ecossistema (.NET, Python, PHP/Laravel 12, Rust, Go, Node, Flutter) e isolamento em projetos híbridos FFI.

### Protocolo para Repositórios Sem Arquitetura Definida ou Ambígua:
Se o repositório for novo, apresentar pastas horizontais genéricas (`controllers/`, `services/`, `models/`) ou ausência de fronteiras:
1. **Inspeção de Contexto com `project-horizon-profiler`:** Identifique a natureza do sistema (API, Pipeline de Dados, CLI, SDK).
2. **Proibição de Imposição Cega:** Nunca imponha silenciosamente Clean Architecture clássica onde uma Vertical Slice ou Pipeline de Dados for mais aderente.
3. **Estruturação de Alternativas:** No relatório (Passo 3), liste 2 a 3 modelos arquiteturais cabíveis, explicitando trade-offs e sugerindo a recomendação mais limpa e manutenível para o desenvolvedor deliberar.

---

## Passo 2 — Mapeamento e Classificação de Violações (SOLID & Padrões)
Percorra a árvore e sinalize:

1. **Incompatibilidade ou Degradação do Modelo Arquitetural:**
   - Adição de camadas horizontais artificiais em projetos de Vertical Slice.
   - Indireções desnecessárias de controllers/handlers em pipelines de dados que deveriam ser estágios lineares imutáveis.
   - Mistura de parsing de CLI diretamente dentro de regras de domínio.
2. **Vazamento entre fatias verticais:** Uma feature importando domínio interno ou banco de outra fatia diretamente em vez de usar contratos públicos ou eventos.
3. **Violação de Inversão de Dependência (DIP Arquitetural):**
   - Camadas de domínio ou casos de uso dependendo diretamente de detalhes de infraestrutura (banco de dados, clientes HTTP, SDKs em nuvem, sistema de arquivos).
   - Exija o padrão **Ports & Adapters (Hexagonal / Clean Architecture)**: o core define interfaces (portas) e a infraestrutura implementa essas interfaces (adaptadores).
4. **Violação de Segregação de Interfaces (ISP Arquitetural):**
   - Contratos públicos e DTOs massivos compartilhados entre múltiplas fatias ou módulos. Exija contratos enxutos, orientados estritamente ao consumidor (*Consumer-Driven Contracts*).
5. **Violação de Aberto/Fechado (OCP Arquitetural):**
   - O núcleo compartilhado ou orquestrador central precisa ser modificado a cada nova funcionalidade adicionada. Exija mecanismos de extensão polimórficos, registro de handlers ou barramentos de comandos/eventos.
6. **Padrões de Isolamento Arquitetural Ausentes:**
   - **Anti-Corruption Layer (ACL):** Ausência de camada de tradução ao integrar com serviços externos ou sistemas legados, permitindo que conceitos e contratos externos contaminem o domínio.
   - **Repository / Gateway:** Acesso direto a ORMs ou drivers de conexão espalhados em camadas de negócio sem uma fronteira de abstração testável.
   - **Event-Driven / Pub-Sub:** Acoplamento síncrono excessivo entre fatias verticais independentes; recomende comunicação assíncrona orientada a eventos de domínio quando não houver necessidade de consistência imediata.
7. **Contaminação do núcleo compartilhado:** Módulos `core/` ou `shared/` abrigando regras de negócio específicas de uma única feature.
8. **Ciclos de Dependência:** Acoplamento circular entre pacotes ou projetos (`A -> B -> A`).
9. **Superfície pública mal definida:** Ausência de pontos de entrada claros (`__all__`, `pub(crate)`, `internal/`), expondo arquivos internos como se fossem públicos.
10. **Vazamento na fronteira FFI / Nativa:** Código hospedeiro manipulando primitivos nativos sem encapsulamento seguro ou retendo locks de runtime (GIL) desnecessariamente.
11. **Evolução desgovernada de contratos:** Quebra incompatível de esquemas de dados colunares (Parquet, Arrow) ou DTOs sem versionamento SemVer.

---

## Passo 3 — Emissão do Relatório (RFC Concisa)
Para cada violação identificada ou caso de repositório indefinido, reporte:
- **Ponto de Atrito / Estado Atual:** Local exato, acoplamentos encontrados e avaliação do modelo de arquitetura atual.
- **Opções Arquiteturais (em caso de repositórios indefinidos):** 2 ou 3 abordagens com prós e contras.
- **Impacto em Escala:** Efeito em tempo de compilação, manutenibilidade, acoplamento de deploys e testabilidade.
- **Proposta de Isolamento / Recomendação:** Contrato público sugerido (interface/porta, padrão arquitetural, evento de domínio ou DTO segregado).

---

## Passo 4 — Portão de Bloqueio
Finalize com uma pergunta de calibração objetiva confirmando a abordagem arquitetural com o desenvolvedor antes de prosseguir com qualquer implementação de código.

---

## Handoff

Ao concluir a execução desta skill, emita obrigatoriamente o bloco de handoff:

```text
HANDOFF
De: architecture-boundary-auditor
Para: vertical-slice-implementer (se arquitetura aprovada) | issue-milestone-orchestrator (para estruturar milestones de setup/fundação ou cadastrar issues de type: refactor) | test-suite-architect (se exigir testes de regressão prévios) | module-documentation-scribe (se a lacuna for documental)
Assunto: <resumo das fronteiras mapeadas, conformidade com SOLID e diagnóstico arquitetural>
Contexto necessário: <relatório RFC de fronteiras, contratos acordados e acoplamentos críticos>
```

