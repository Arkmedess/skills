# OpenTelemetry Semantic Conventions e Metodologias RED / USE

## 1. Estrutura Canônica de Log Estruturado (JSON)

Para garantir correlação instantânea e bidirecional com traces e métricas no Datadog, Grafana ou Jaeger:

```json
{
  "timestamp": "2026-10-08T22:30:00.123Z",
  "level": "ERROR",
  "message": "Falha na aquisição de conexão do pool de banco",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "span_id": "00f067aa0ba902b7",
  "service.name": "order-processor",
  "service.version": "1.2.0",
  "environment": "production",
  "http.request.method": "POST",
  "http.response.status_code": 500,
  "db.system": "postgresql",
  "exception.type": "TimeoutException",
  "exception.message": "Connection acquisition timed out after 5000ms",
  "exception.stacktrace": "..."
}
```

### Regras Obrigatórias de Atributos:
- **`trace_id` e `span_id`:** Devem ser strings em **hexadecimal minúsculo**, posicionadas como campos de nível superior (*top-level fields*).
- **Formatadores de Exceção:** Nunca logue stack traces concatenados na mensagem de texto principal. Capture `exception.type`, `exception.message` e `exception.stacktrace` em atributos estruturados.

---

## 2. Metodologia RED para Serviços e APIs
Ao desenhar telemetria e instrumentação para endpoints HTTP/gRPC, cubra sistematicamente as 3 variáveis:
- **Rate (Vazão):** Quantidade de requisições processadas por segundo (`http.server.request.count`).
- **Errors (Erros):** Quantidade e proporção de requisições que falharam (`http.server.response.status_code >= 500`).
- **Duration (Duração):** Distribuição de latência medida em histogramas com percentis **p50, p95 e p99** (`http.server.request.duration`).

---

## 3. Metodologia USE para Recursos e Infraestrutura
Ao monitorar pools de conexão, threads, filas e memória:
- **Utilization (Utilização):** Percentual médio de capacidade sendo ativamente consumida (ex.: 80% do pool de DB ocupado).
- **Saturation (Saturação):** Medida de trabalho enfileirado aguardando recurso (ex.: fila de requisições aguardando conexão vaga).
- **Errors (Erros):** Ocorrências de recusa ou estouro de recursos (ex.: `Max pool size reached`, timeouts).
