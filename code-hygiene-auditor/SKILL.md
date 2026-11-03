---
name: code-hygiene-auditor
description: >-
  Use esta skill SEMPRE que o usuário pedir para revisar qualidade de código, auditar higiene,
  aplicar Clean Code, inspecionar princípios SOLID, eliminar code smells, refatorar trechos complexos,
  ou no Passo 5 antes de submeter código para commits. Executa linters nativos, inspeção de complexidade
  cognitiva, tipagem estrita e cirurgia de diff.
---

# Auditor de Higiene de Código, Qualidade Estática e SOLID

## Passo 1 — Execução de Ferramentas Nativas da Stack (Zero Warnings)
Identifique a stack pelos manifests e invoque as ferramentas oficiais configuradas no repositório.
- Consulte `references/linters-and-checkers-by-stack.md` para comandos de formatação, linter, tipagem estrita e medidores de complexidade por ecossistema.

---

## Passo 2 — Inspeção Semântica: Clean Code, Cirurgia de Diff & Code Smells
Audite rigorosamente no `git diff`:

1. **Cirurgia de Diff e Zero Resíduos:**
   - Bloqueie alterações fora de escopo (formatação ou refatoração não solicitada em código adjacente).
   - Elimine imports não utilizados, variáveis sem uso, código comentado e funções órfãs criadas pela mudança.
2. **Funções Pequenas & Nível Único de Abstração (SLA):**
   - Complexidade ciclomática/cognitiva máxima de **10** por função e aninhamento máximo de **3 níveis** (exija *guard clauses* / retornos antecipados).
   - Não misture orquestração de alto nível com detalhes de baixo nível (parsing, I/O, manipulação de strings).
3. **Assinaturas Limpas & Tipagem Estrita:**
   - Máximo de 3–4 parâmetros primitivos (agrupe *Data Clumps* em structs/DTOs).
   - Proibição de *Flag Arguments* (booleanos que alteram o fluxo interno) e tipos de fuga (`any`, `dynamic`, `object` cru ou falta de type hints).
4. **Lei de Demeter & Prevenção de Code Smells:**
   - Bloqueie cadeias de navegação profunda (`a.getB().getC().getD()`).
   - Erradique *Primitive Obsession* (use Value Objects/Newtypes para CPF, Email, Moeda, IDs), *Feature Envy* e *God Classes/Methods*.
5. **Tratamento Explícito de Erros e Comentários Limpos:**
   - Bloqueie `catch (Exception)` / `except Exception:` mudos ou genéricos.
   - Remova comentários que narram o óbvio; preserve apenas justificativas de decisões não triviais.

---

## Passo 3 — Inspeção de Princípios SOLID no Nível de Unidade

- **SRP:** Uma única razão para mudar por arquivo/classe (nunca misture persistência, regra de negócio e UI).
- **OCP:** Rejeite cadeias `if/else` ou `switch` que precisam ser editadas a cada novo tipo; exija polimorfismo/Strategy.
- **LSP:** Bloqueie subtipos que lancem `NotImplementedException` ou quebrem contratos da interface base.
- **ISP:** Rejeite interfaces gordas que forcem implementações vazias (*no-op*).
- **DIP:** Bloqueie instanciações diretas de infraestrutura (`new HttpClient()`, conexões SQL) dentro do domínio.

---

## Passo 4 — Delegação para Especialistas Canônicos
Acione via `view_file` quando detectar problemas específicos:
- **UI / Acessibilidade / Estado de Componentes:** `frontend-ui-craftsman`.
- **SQL / Migrations / Cache / Filas:** `backend-data-resilience`.
- **Test Smells:** `test-suite-architect`.
- **Prints / Logs Desestruturados:** `observability-logging-auditor`.
- **Vazamento entre Módulos:** `architecture-boundary-auditor`.

---

## Handoff

Ao concluir a auditoria, acione via `view_file` a próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: code-hygiene-auditor
Para: vertical-slice-implementer (se houver violações de SOLID/smells para corrigir) | module-documentation-scribe (se código aprovado e documentação pendente) | git-commit-sentinel (se código, testes e docs estiverem 100% limpos)
Motivo: <resultado dos linters, complexidade cognitiva e conformidade SOLID/Clean Code>
Contexto necessário: <arquivos auditados, comandos executados e pendências sanadas>
```
