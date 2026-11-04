---
name: runtime-performance-diagnostician
description: >-
  Use esta skill sempre que houver menção a lentidão, gargalos de I/O ou banco, testes de carga,
  saturação de conexões, profiling de CPU/memória, Core Web Vitals (LCP, INP, CLS), tamanho de bundle
  ou necessidade de benchmarks. Proíbe otimização especulativa — exige medição empírica e baseline antes de alterar código.
---

# Diagnosticador de Performance, Web Vitals e Benchmarks

## 1. Regra de Bloqueio: Medição Empírica Prévia (Baseline Obrigatório)
Nenhum código é alterado por performance sem medição empírica prévia (*baseline* antes vs. depois). Argumentos subjetivos ("parece lento", "teoricamente mais rápido") são estritamente bloqueados.

Para medir duração (com aquecimento e múltiplas repetições estatísticas) e pico de memória física RSS de um processo no terminal:
```bash
python3 <SKILL_DIR>/scripts/measure_rss_memory.py [--warmup 2] [--runs 5] -- [comando...]   # <SKILL_DIR> = pasta deste SKILL.md
```

---

## 2. Triagem do Domínio do Gargalo

1. **Gargalo de CPU / Algoritmo e Memória:**
   - Complexidade patológica ($O(n^2)$ ou pior em caminhos quentes), alocações excessivas na heap ou retenção de locks de runtime (GIL).
   - *Ação:* Consulte `references/profiling-tools-by-stack.md` (flamegraphs, CPU/heap profilers).
2. **Gargalo de I/O, Banco de Dados ou Concorrência Backend:**
   - Queries sem índice (`Seq Scan` em tabelas grandes), $N+1$ queries, paginação `OFFSET` profunda, chamadas bloqueantes em event loop ou falta de connection pooling.
   - *Ação:* Execute `EXPLAIN (ANALYZE, BUFFERS)`, consulte `references/load-io-benchmark-matrix.md` (k6, wrk) e acione `backend-data-resilience` para refatorar queries/índices/cache.
3. **Gargalo de Frontend, Bundle & Core Web Vitals:**
   - **LCP (> 2.5s):** Ativo principal sem `fetchpriority="high"`, imagens não otimizadas (sem AVIF/WebP) ou cascata de requisições bloqueantes.
   - **INP (> 200ms):** Bundle JS inflado bloqueando a main thread, re-renderizações desnecessárias em árvore profunda ou falta de *code-splitting* (`lazy`/`dynamic`).
   - **CLS (> 0.1):** Mídias/skeletons sem dimensões reservadas (`width`/`height`/`aspect-ratio`).
   - *Ação:* Audite tamanho de pacotes/chunks e acione `frontend-ui-craftsman` para aplicar as correções de UI/Vitals.

---

## 3. Relatório de Diagnóstico e Portão de Aprovação
Toda intervenção exige apresentação do relatório (*Baseline $\rightarrow$ Gargalo Isolado $\rightarrow$ Proposta e Trade-offs $\rightarrow$ Meta Pós-Otimização*) e aprovação do desenvolvedor antes de alterar o código de produção.
- *Consulte:* `examples/benchmark_report.md`.

---

## Handoff

Ao concluir o diagnóstico, carregue o `SKILL.md` da próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: runtime-performance-diagnostician
Para: vertical-slice-implementer (otimização de código geral) | backend-data-resilience (índices, queries, paginação e cache) | frontend-ui-craftsman (otimização de LCP, INP, CLS e bundle)
Motivo: <resumo do diagnóstico com baseline comprovado e proposta de correção>
Contexto necessário: <métrica de baseline (p95/p99/RSS/Web Vitals), gargalo isolado e trade-offs>
```
