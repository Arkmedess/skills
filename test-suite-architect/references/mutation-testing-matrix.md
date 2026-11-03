# Governança de Testes de Mutação (Mutation Testing)

## Pipeline de Execução Segura e Budget Gate
Nunca execute mutation testing em lote cego. Toda rotina deve seguir o pipeline:

1. **Diff Scoping (`--diff-only`):** Isole a geração de mutantes estritamente no diff de arquivos e linhas modificadas no branch ou PR.
2. **Discovery (Enumeração sem Execução):** Mapeie a contagem total de mutantes antes de iniciar a execução da suíte.
3. **Estimativa de Duração Calibrada:**
   $$\text{Estimativa} \approx \frac{\text{mediana por mutante} \times \text{total de mutantes}}{\text{paralelismo efetivo}}$$
4. **Budget Gate:** Interrompa a execução automática se a estimativa ultrapassar o teto configurado ($\le 5$ minutos em CI/PR). Exija confirmação explícita para execuções globais.

---

## Triagem Heurística de Mutantes Sobreviventes
Ao analisar mutantes que não morreram, classifique a causa antes de alterar código:

- **`missing_case`:** Mutador de limite/condicional alterado sem falha (indica falta de teste para off-by-one ou branch extremo).
- **`weak_assertion`:** Mutador removeu instrução e o teste passou (indica asserção incompleta ou teste mudo).
- **`equivalent_candidate`:** Código mutado possui equivalência semântica com o original. **Regra:** Rótulo obrigatório de incerteza ("candidato a equivalente, confiança X%"). Jamais auto-descartar sem revisão humana.
- **`unreachable`:** Mutação gerada em código morto que nenhum fluxo alcança.

---

## Adaptadores e Ferramentas por Stack

| Stack | Adaptador de Mutação | Modo Diff / Scoped |
| :--- | :--- | :--- |
| **Python** | `mutmut`, `cosmic-ray`, `pytest-gremlins` | `mutmut run --paths-to-mutate=...` |
| **Rust** | `cargo-mutants` | `cargo mutants --in-diff HEAD~1` |
| **.NET** | `dotnet-stryker` | `dotnet stryker --since:main` |
| **Node / TS** | `@stryker-mutator/core` | `npx stryker run --since main` |
| **PHP / Laravel 12** | `Pest Mutation Testing` / `Infection PHP` | `./vendor/bin/pest --mutate --covered-only` ou `vendor/bin/infection --git-diff-filter=AM` |
| **Go** | `go-mutesting` | `go-mutesting ./pkg/...` |
