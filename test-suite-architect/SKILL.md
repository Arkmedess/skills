---
name: test-suite-architect
description: >-
  Use esta skill SEMPRE que for planejar, implementar, auditar ou refatorar suítes de testes (unitários,
  integração com Testcontainers, mutação, Property-Based, componentes de UI ou E2E com Playwright).
  Avalia as 4 dimensões de TQA, elimina Test Smells e garante pirâmide de testes equilibrada.
---

# Arquiteto de Suíte de Testes (Governança TQA & Engenharia de Qualidade)

## 1. Governança TQA: 4 Dimensões Canônicas
1. **Efetividade:** Capacidade comprovada de matar mutantes e detectar regressões comportamentais reais.
2. **Adequação:** Invariantes validados por Property-Based Testing cruzados com cobertura de branches ($\ge 80\%$).
3. **Confiabilidade:** Zero flakiness e zero contaminação de estado entre execuções.
4. **Manutenibilidade:** Testes expressivos, acoplados ao comportamento público e livres de *Test Smells*.

---

## 2. Pirâmide de Testes e Regras por Camada

- **Unitários (Base):** Ultra-rápidos, sem I/O, testando invariantes de domínio e regras puras com instâncias reais (proibido mockar entidades de domínio).
- **Integração Backend (Meio):** Validação de persistência, migrações, idempotência (`UPSERT`), queries e filas contra containers reais efêmeros (**Testcontainers**: PostgreSQL, Redis, RabbitMQ) — nunca bancos em memória com dialeto divergente.
- **Componentes & E2E Frontend:**
  - *Componentes (Testing Library / Vitest):* Consulte elementos exclusivamente como o usuário os percebe (`getByRole`, `getByLabelText`, `getByText`) e dispare eventos com `userEvent`. **Proibido** testar estados internos de hooks ou seletores de classe CSS.
  - *Fluxos Críticos E2E (Playwright):* Cubra autenticação, checkout e fluxos multi-etapas usando *Locators* resilientes e auto-waiting nativo.
- **Workflows Assíncronos / Temporais:** Utilize relógios determinísticos (*time-skipping* / *fake timers*) para testar retries, timeouts e agendamentos sem usar `sleep` real.
- Consulte `references/testing-frameworks-and-tools.md` para a matriz de ferramentas por stack.

---

## 3. Governança de Mutação (Mutation Testing)
Toda rotina de mutação obedece ao **Diff Scoping** (apenas linhas alteradas) e ao **Budget Gate**.
- Consulte `references/mutation-testing-matrix.md` para triagem (`missing_case`, `weak_assertion`, `equivalent_candidate`).

---

## 4. Prevenção de Test Smells e Densidade de Asserções

1. **Test Smells Bloqueados:**
   - *Assertion Roulette:* Múltiplos asserts sem contexto claro da falha.
   - *Mystery Guest:* Dependência de arquivos/dados externos ocultos fora da fixture.
   - *Sleepy Test:* Uso de `sleep()`/`setTimeout()` fixo em vez de polling/await reativo.
   - *Over-Mocking & Tautologia:* Testes que apenas verificam se o mock retornou o que foi configurado no próprio teste.
2. **Densidade de Asserções e Casos de Borda:**
   - Proibido asserções superficiais (`assert result is not None`). Exija verificação do estado final de negócio e efeitos colaterais esperados.
   - Cubra sistematicamente limites numéricos, fuso horário/UTC, coleções vazias, concorrência e entradas malformadas.

---

## Handoff

Ao concluir a suíte, acione via `view_file` a próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: test-suite-architect
Para: vertical-slice-implementer (para matar mutantes sobreviventes) | code-hygiene-auditor (para lint e higiene dos testes) | git-commit-sentinel (se suíte e cobertura estiverem aprovadas)
Motivo: <resumo da suíte sob as 4 dimensões TQA, cobertura e mutantes analisados>
Contexto necessário: <arquivos de teste criados/auditados e cenários de borda cobertos>
```
