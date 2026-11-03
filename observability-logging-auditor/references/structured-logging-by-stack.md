# Bibliotecas de Logging Estruturado e Tracing por Stack

| Stack | Biblioteca Recomendada | Propagação de Contexto | Destino Assíncrono |
| :--- | :--- | :--- | :--- |
| **Rust** | `tracing` + `tracing-subscriber` | Spans com campos semânticos | `tracing-appender` (non-blocking) |
| **Python** | `structlog` ou `loguru` | `contextvars` nativo | Handlers assíncronos / QueueHandler |
| **.NET** | `Serilog` ou `Microsoft.Extensions.Logging` | `Activity.Current` (W3C TraceContext) | `Serilog.Sinks.Async` |
| **Node / TS** | `pino` | AsyncLocalStorage | Pino worker thread transports |
| **PHP / Laravel 12** | `Monolog` (`JsonFormatter` em `config/logging.php`) | `Illuminate\Support\Facades\Context` (propaga automaticamente para Jobs/Horizon) | Driver `stderr` / OpenTelemetry (`open-telemetry/sdk`) / `Laravel Pulse` |
| **Go** | `slog` (nativo) ou `zap` | `context.Context` | Buffers assíncronos do Zap |
