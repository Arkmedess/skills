---
name: vertical-slice-implementer
description: >-
  Use esta skill SEMPRE que o pedido for implementar, alterar, estender ou refatorar uma funcionalidade/módulo
  de código — em qualquer linguagem ou framework. Aciona Clean Code rigoroso, princípios SOLID,
  Design Patterns pragmáticos (GoF), TDD com fase Simplify, mudanças cirúrgicas e produção de código final
  (sem placeholders). Subordinada ao Portão de Entrega Incremental do AGENTS.md.
---

# Implementador de Fatia Vertical (Clean Code, SOLID & TDD Cirúrgico)

## 1. Restrições Inegociáveis & Cirurgia de Código (Karpathy Guidelines)

1. **Código Final de Produção:** Proibido omitir trechos com `// resto do código aqui` ou placeholders.
2. **Simplicidade Primeiro (YAGNI Estrito):** Escreva o código mínimo que resolve o problema. Proibido criar abstrações para código de uso único, configurabilidade especulativa ou tratamento para cenários impossíveis.
3. **Mudanças Cirúrgicas:**
   - Toque **apenas** nas linhas exigidas pelo requisito atual.
   - **Proibido** "melhorar", reformatar ou refatorar código adjacente não relacionado.
   - Remova imports/variáveis que a **sua** mudança tornou órfãos, mas não remova código legado alheio sem autorização.
   - Toda linha alterada no `git diff` deve rastrear diretamente ao pedido do usuário.
4. **Comentários Limpos:** Proibido comentários narrativos (`// incrementa contador`). Comente apenas o *porquê* de decisões não óbvias ou contornos de limitações externas.

---

## 2. Ciclo TDD Obrigatório: Red $\rightarrow$ Green $\rightarrow$ Simplify

1. **Red (Especificação):** Comece pelo teste no diretório da fatia, focando em comportamento observável e invariantes de domínio (nunca em detalhes internos).
2. **Green (Implementação Mínima):** Escreva apenas o código necessário para passar no contrato aprovado.
3. **Simplify (Refatoração Pós-Green):** Com os testes verdes, revise o diff recém-criado para eliminar duplicação, reduzir aninhamento (usando *guard clauses*) e garantir Nível Único de Abstração (SLA) mantendo a suíte verde.
4. **Protocolo para Código Legado / Brownfield Sem Testes (*Characterization Tests* & *Seams*):**
   - Quando precisar alterar um módulo legado acoplado que ainda não possui testes:
     1. **Characterization Test (Golden Master):** Escreva primeiro um teste que capture e fixe o comportamento atual observável do código legado sem modificá-lo.
     2. **Extração de Costura (*Seam* / Feathers):** Introduza a menor fronteira de injeção possível (parâmetro opcional ou interface de porta) para isolar I/O externo sem reescrever a classe inteira.
     3. **Strangler Fig / Mudança Cirúrgica:** Adicione o novo comportamento protegido pelo teste de caracterização + o novo teste TDD (*Red $\rightarrow$ Green*).

---

## 3. Topologia e Delegação de Especialidades

- **Topologia Coesa por Horizonte:** Agrupe pelo eixo funcional do modelo arquitetural ativo calibrado por `project-horizon-profiler` e `architecture-boundary-auditor` (`features/<feature>/` em Web/APIs/Apps, `commands/<cmd>/` em CLIs, `pipeline/stages/` em Pipelines de Dados ou `domain/`+`ports/`+`adapters/` em Hexagonal). Proibido criar pastas horizontais genéricas soltas (`controllers/`, `services/`, `utils/` globais) quando o projeto seguir Vertical Slice.
- **Fronteiras de Especialidade (Carregue o `SKILL.md` em conjunto):**
  - Se a fatia envolver **Contratos de API HTTP/REST, OpenAPI, gRPC, RFC 9457 ou Webhooks**: leia e aplique `api-contract-designer`.
  - Se a fatia envolver **UI / Frontend / Componentes / CSS / Flutter**: leia e aplique `frontend-ui-craftsman`.
  - Se a fatia envolver **Migrations, SQL, Paginação, Filas, ETL ou Cache**: leia e aplique `backend-data-resilience`.
  - Se a arquitetura do repositório ainda não foi validada: leia e aplique `architecture-boundary-auditor` primeiro.

---

## 4. Clean Code, SOLID e Design Patterns Pragmáticos

1. **SOLID Aplicado:**
   - **SRP:** Separe ponto de entrada/transporte (Handler), regras puras (Domain) e contratos de I/O (Ports).
   - **DIP & ISP:** O domínio define interfaces enxutas focadas apenas no que a fatia consome; implementações de I/O são injetadas.
   - **OCP & LSP:** Substitua cadeias de `if/else` crescentes por polimorfismo/Strategy; garanta que implementações honrem o contrato base sem lançar exceções surpresa.
2. **Funções e Assinaturas (SLA):**
   - Funções pequenas, máximo de 3 níveis de indentação e sem *Flag Arguments* (parâmetros booleanos que bifurcam a função).
3. **Design Patterns GoF (Uso Intencional vs. Anti-Patternitis):**
   - Use **Factory Method / Builder** para invariantes de criação complexas; **Adapter / Decorator / Facade** para isolar SDKs externos e comportamentos transversais (retry, cache); **Strategy / Command / Observer** para políticas variáveis e efeitos desacoplados.
   - **Bloqueio de Overengineering:** Nunca introduza Factories ou Interfaces se uma função pura ou struct simples resolver.

---

## 5. Tipagem, Erros Explícitos e Eficiência

- Consulte `references/stack-idioms.md` para convenções nativas da stack. Erros de negócio são tipos/valores explícitos no retorno (`Result<T, E>`, união discriminada ou exceção de domínio tipada), nunca falhas silenciosas.
- Previna operações bloqueantes em loops, consultas $N+1$ e alocações desnecessárias. Se o caminho exigir tuning de performance, delegue para `runtime-performance-diagnostician` (proibida otimização especulativa sem baseline).

---

## Handoff

Ao concluir a fatia, carregue o `SKILL.md` da próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: vertical-slice-implementer
Para: code-hygiene-auditor (obrigatório para lint e Clean Code) | test-suite-architect (para testes de integração/mutação) | module-documentation-scribe (quando houver novo recurso ou alteração de contrato público)
Motivo: <resumo da funcionalidade implementada, ciclo Red-Green-Simplify e testes executados>
Contexto necessário: <contrato público da fatia, arquivos alterados e decisões de design>
```
