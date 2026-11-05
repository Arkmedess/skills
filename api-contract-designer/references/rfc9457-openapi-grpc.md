# Referência de Contratos: OpenAPI 3.1, RFC 9457, gRPC/Protobuf e Webhooks

## 1. Componente Canônico RFC 9457 em OpenAPI 3.1

```yaml
openapi: 3.1.0
info:
  title: Billing API
  version: 1.2.0
components:
  schemas:
    ProblemDetails:
      type: object
      required: [type, title, status, detail, trace_id]
      properties:
        type:
          type: string
          format: uri
          examples: ["https://api.exemplo.com/errors/validation-failed"]
        title:
          type: string
        status:
          type: integer
          examples: [422]
        detail:
          type: string
        instance:
          type: string
          format: uri-reference
        trace_id:
          type: string
        errors:
          type: array
          items:
            type: object
            required: [field, code, message]
            properties:
              field: { type: string }
              code: { type: string }
              message: { type: string }
```

---

## 2. Regras de Evolução Segura em gRPC / Protocol Buffers (`proto3`)

1. **Nunca reutilize números de tag (`field numbers`):** Ao remover um campo, reserve imediatamente o número e o nome:
   ```protobuf
   message Invoice {
     reserved 4, 8;
     reserved "legacy_tax_code", "old_status";
     string id = 1;
     int64 amount_cents = 2;
   }
   ```
2. **Enums devem ter valor zero `UNSPECIFIED`:**
   ```protobuf
   enum InvoiceStatus {
     INVOICE_STATUS_UNSPECIFIED = 0;
     INVOICE_STATUS_PENDING = 1;
     INVOICE_STATUS_PAID = 2;
   }
   ```
3. **Verificação automatizada de quebra:** Execute `buf breaking --against '.git#branch=main'` no pipeline de CI.

---

## 3. Contratos de Webhooks (Emissão e Consumo Seguro)

1. **Assinatura Criptográfica (HMAC-SHA256 com Timestamp Anti-Replay):**
   - Inclua os headers `X-Webhook-Id` (UUID único do evento), `X-Webhook-Timestamp` (Unix epoch em segundos) e `X-Webhook-Signature` (`v1=<hmac_sha256(timestamp + "." + raw_body)>`).
   - Rejeite entregas com timestamp defasado em mais de **5 minutos** e valide a assinatura com comparação em tempo constante (`hmac.compare_digest` / `CryptographicOperations.FixedTimeEquals`).
2. **Idempotência no Consumidor:** Deduplique eventos pelo `X-Webhook-Id` antes de processar.
