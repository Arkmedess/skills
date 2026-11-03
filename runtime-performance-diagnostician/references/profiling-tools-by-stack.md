# Ferramentas de Profiling e Microbenchmarks por Stack

## .NET
- **Produção / Diagnóstico em Execução:** `dotnet-trace`, `dotnet-dump`, `dotnet-counters` (para monitoramento de GC e contadores de threadpool).
- **Microbenchmarks:** `BenchmarkDotNet` para testes reproduzíveis com isolamento estático e métricas de alocação de memória.

## Python
- **Produção / Amostragem sem Overhead:** `py-spy` (gera flamegraphs sem necessidade de instrumentar código).
- **Diagnóstico Local Detalhado:** `scalene` (detalha CPU, memória por linha e se o tempo está em Python ou código C/nativo) e `cProfile`.
- **Microbenchmarks:** `pytest-benchmark`.

## Rust
- **Visualização de Gargalos:** `cargo flamegraph` ou `perf` no Linux.
- **Microbenchmarks:** `criterion` (para medições estatisticamente robustas com gráficos de regressão).

## Go
- **Profiling Integrado:** `pprof` (`go tool pprof` para CPU, heap, goroutine e bloqueio de mutex).
- **Microbenchmarks:** Subcomando nativo `testing.B` (`go test -bench=. -benchmem`).

## Flutter / Dart
- **Diagnóstico Visual:** Flutter DevTools (timeline, uso de memória, taxa de rebuilds de widget e jank de frames).
- **Prevenção de Render Overhead:** Inspecionar `RepaintBoundary` e rebuilds desnecessários antes de otimizar lógica de negócio.

## Node.js / TypeScript
- **Servidor:** `node --prof` analisado com `node --prof-process`, ou `clinic.js` (Doctor, Flame, Bubbleprof).
- **Frontend / SSR:** React DevTools Profiler, Lighthouse e medição de Core Web Vitals (LCP, FID/INP, CLS).

## PHP / Laravel 12
- **Profiling de CPU e Memória:** `Blackfire.io`, `php-spx` (SPX Profiler com flamegraphs embutidos) ou `Excimer` / `XHProf`.
- **Inspeção de Queries, Filas e Slow Requests:** `DB::listen()` / `explain()` do Eloquent, `Laravel Telescope` (exclusivo em desenvolvimento local) e `Laravel Pulse` / `Nightwatch` (em produção).
- **Runtime & Microbenchmarks:** `PHPBench` (`./vendor/bin/phpbench run`) para microbenchmarks; validar ativação do `OPcache` + `JIT` e monitorar vazamento de memória em workers de longa duração do **Laravel Octane** (`octane:status`, `--max-requests=500`).

## Banco de Dados (Qualquer Stack)
- **Inspeção de Planos de Execução:** `EXPLAIN ANALYZE` (PostgreSQL / MySQL) para validar leituras sequenciais (Seq Scan vs Index Scan) antes de especular criação de índices.
