---
name: observability-logging-auditor
description: >-
  Use esta skill SEMPRE que for implementar, revisar ou auditar logging estruturado, telemetria OpenTelemetry,
  correlação de Trace/Span IDs, taxonomia de severidade ou para eliminar prints/resíduos de debug em código de produção.
---

# Auditor de Logging Estruturado e Observabilidade

## Regra de Contexto por Tipo de Artefato
- **Serviço / API / Worker:** Configura handler/subscriber no ponto de entrada. Saída em JSON estruturado com campos obrigatórios (`timestamp` ISO 8601 UTC, `level`, `service.name`, `service.version`, `environment`, `trace_id`, `span_id`).
- **CLI:** Configura no ponto de entrada; formatação amigável por padrão em **stderr** quando conectado a TTY; JSON estruturado apenas sob flag `--log-format json`.
- **Biblioteca / SDK / Extensão Nativa:** **Nunca configura handlers**. Apenas emite eventos via interfaces padrão (`logging.getLogger(__name__)`, `tracing`, `ILogger<T>`). Quem consome decide o destino.
- **Desktop / Batch:** Arquivos com rotação no diretório de dados do usuário (XDG/AppData).

---

## 5 Dimensões Canônicas de Auditoria

1. **Estruturação Semântica & OpenTelemetry:**
   - Atributos canônicos top-level (`trace_id`, `span_id` em hex minúsculo).
   - Cobertura das metodologias **RED** (Rate, Errors, Duration) para APIs e **USE** (Utilization, Saturation, Errors) para recursos.
   - *Consulte:* `references/opentelemetry-semantic-conventions.md`.

2. **Taxonomia Rígida de Níveis:**
   - `FATAL`/`CRITICAL`: Falha catastrófica que encerra o processo.
   - `ERROR`: Falha de operação/requisição não recuperada (requer alerta).
   - `WARN`: Degradação contornada por fallback, retentativa ou aproximação de rate-limits.
   - `INFO`: Marcos de ciclo de vida e transições de negócio (proibido emitir em loops massivos).
   - `DEBUG`/`TRACE`: Detalhes diagnósticos de engenharia.

3. **Sanitização Ativa de PII e Segredos (LGPD/GDPR & OWASP):**
   - Bloqueie logs contendo senhas, chaves de API, tokens Bearer, CPFs ou dados pessoais. Exija máscaras ativas.
   - Proíba serialização crua de objetos de domínio contendo campos sensíveis.

4. **Rastreabilidade de Contexto Distribuído:**
   - Propagação de `trace_id` e `correlation_id` (W3C TraceContext) entre funções, corrotinas e chamadas remotas.

5. **Performance e I/O Não-Bloqueante:**
   - Em caminhos quentes, exija appenders assíncronos e avaliação preguiçosa (*lazy evaluation*).
   - *Consulte:* `references/structured-logging-by-stack.md` para bibliotecas idiomáticas por stack (Serilog, structlog, tracing, pino).

---

## Handoff

Ao concluir a auditoria de logging, emita obrigatoriamente o bloco de handoff:

```text
HANDOFF
De: observability-logging-auditor
Para: vertical-slice-implementer (para corrigir pontos cegos de log ou sanitizar dados) | security-vulnerability-warden (se houver credenciais/segredos expostos em logs) | runtime-performance-diagnostician (para validar latência e overhead de logging) | git-commit-sentinel (se a conformidade de logs estiver 100% aprovada)
Motivo: <resumo da auditoria de logging, taxonomias e níveis verificados>
Contexto necessário: <arquivos inspecionados, vazamentos identificados e correções estruturadas>
```
