# Matriz de Validação de I/O, Carga e Pooling de Conexões

## Regra de Ouro: Latência Percentilar > Médias
Decisões de engenharia e gargalos de I/O são sempre avaliados sob **p95, p99 e taxa de erro sob concorrência**. Médias aritméticas ocultam outliers e comportamentos patológicos de cauda (*tail latency*).

---

## 1. Ferramental de Carga e Throughput
- **`k6`:** Recomendado para cenários de carga com scripts declarativos em JavaScript (suporta thresholds automáticos de p95/p99 e VUs graduais).
- **`wrk` / `autocannon`:** Benchmarks ultra-rápidos de RPS puro em HTTP/1.1 e HTTP/2.
- **`ghz`:** Benchmark de carga para serviços gRPC e streaming bidirecional.

---

## 2. Diagnóstico de Sistema e I/O de Rede/Disco
- **Monitoramento de Sockets:** `ss -s` ou `netstat -ant` para inspecionar acúmulo de sockets em `TIME_WAIT` ou `CLOSE_WAIT`.
- **Esgotamento de File Descriptors:** `lsof -p <PID>` e conferência de `ulimit -n`.
- **Chamadas de Sistema e Bloqueio:** `strace -c -p <PID>` para contabilizar tempo em chamadas de I/O (`epoll_wait`, `recvfrom`, `writev`).
- **I/O de Disco:** `iotop -aoP` para identificar processos saturando largura de banda de leitura/escrita física.

---

## 3. Padrões de Falha em I/O e Recursos Compartilhados

### A. Saturação de Pools de Conexão de Banco
- **Sintomas:** Erros de timeout (`Max pool size reached`, `Connection acquisition timeout`) ou latência de consulta que explode sob múltiplos usuários simultâneos.
- **Investigação:**
  1. Verificar se conexões estão sendo abertas e não fechadas (leaks de conexão fora de blocos `using`/`with`/`try-finally`).
  2. Ajustar tamanho do pool com base na capacidade de concorrência real do banco de dados (regrinha de ouro: `pool_size = (core_count * 2) + effective_spindle_count`).
  3. Checar tempo de vida máximo de conexão (`max_lifetime`) para evitar conexões mortas por firewall/idle timeout.

### B. Streaming vs Alocação em Buffer Total
- **Sintomas:** Consumo desproporcional de memória RAM e pressão no Garbage Collector ao trafegar arquivos ou responses grandes.
- **Regra:** Payloads binários, streams de arquivo e relatórios volumosos devem sempre usar streams assíncronos (`Stream`, `AsyncIterable`, `chunked transfer`) sem carregar o buffer inteiro em array/memória.

### C. Reuso de Conexões HTTP Externas
- **Problema:** Instanciar um cliente HTTP a cada requisição esgota as portas efêmeras do sistema operacional (*socket exhaustion*).
- **Correção:** Utilizar clientes únicos singleton ou gerenciadores de pool nativos (`IHttpClientFactory` no .NET, `httpx.Client()`/`aiohttp.ClientSession` persistentes no Python, `reqwest::Client` no Rust).
