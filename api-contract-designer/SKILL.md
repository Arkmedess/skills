---
name: api-contract-designer
description: >-
  Use esta skill SEMPRE que criar, alterar, versionar ou revisar contratos de APIs HTTP/REST (OpenAPI 3.1),
  gRPC/Protobuf, GraphQL, Webhooks ou eventos assíncronos (AsyncAPI). Garante padronização de erros via
  RFC 9457 (Problem Details), semântica estrita de status codes e métodos HTTP, evolução retrocompatível
  (Expand-Contract de payloads), envelopes de paginação por cursor e governança Contract-First.
---

# Arquiteto de Contratos de API (OpenAPI 3.1, RFC 9457, gRPC & Webhooks)

## 1. Princípio Fundamental: Contrato Explícito e Retrocompatibilidade
Nenhuma rota HTTP, método gRPC ou evento de mensageria é exposto sem schema tipado, validação estrita de entrada e tratamento padronizado de erros. O contrato público é uma fronteira SemVer: quebras silenciosas de payload são bloqueadas.

---

## 2. Semântica HTTP, Idempotência e Status Codes

1. **Métodos e Garantias de Idempotência:**
   - `GET` / `HEAD`: Estritamente seguros (zero mutação de estado).
   - `PUT` / `DELETE`: Idempotentes por definição (repetir a chamada produz o mesmo estado final).
   - `POST` / `PATCH`: Quando mutarem recursos críticos (pagamentos, pedidos, provisionamento), exija o header `Idempotency-Key` (UUID v4/v7) com armazenamento atômico da resposta pelo período de retenção.
2. **Taxonomia Estrita de Status Codes:**
   - `200 OK` (leitura/atualização síncrona), `201 Created` (com header `Location` obrigatório), `202 Accepted` (processamento assíncrono enfileirado, retornando link de status/polling), `204 No Content` (exclusão ou comando sem corpo).
   - `400 Bad Request` (JSON malformado/sintaxe), `401 Unauthorized` (não autenticado), `403 Forbidden` (autenticado sem permissão — ou `404` se a existência do recurso for confidencial contra BOLA/IDOR), `404 Not Found`, `409 Conflict` (violação de unicidade ou concorrência otimista `ETag`), `422 Unprocessable Content` (violação de regra/validação semântica de domínio), `429 Too Many Requests` (com header `Retry-After` obrigatório).
   - **Proibido** retornar `200 OK` com `{ "success": false, "error": "..." }` no corpo.

---

## 3. Padronização Universal de Erros: RFC 9457 (Problem Details for HTTP APIs)

Toda resposta de erro (`4xx` e `5xx`) deve usar `Content-Type: application/problem+json` seguindo a **RFC 9457** (sucessora da RFC 7807):

```json
{
  "type": "https://api.exemplo.com/errors/validation-failed",
  "title": "Falha de validação nos parâmetros da requisição",
  "status": 422,
  "detail": "O campo 'amount_cents' deve ser um inteiro positivo maior que zero.",
  "instance": "/v1/invoices",
  "trace_id": "4bf92f3577b34da6a3ce929d0e0e4736",
  "errors": [
    { "field": "amount_cents", "code": "must_be_positive", "message": "Deve ser maior que 0" }
  ]
}
```
- **Segurança (`500 Internal Server Error`):** Jamais exponha stacktraces, nomes de tabelas SQL ou detalhes internos em `detail`. Retorne mensagem genérica humana acompanhada do `trace_id` para correlação nos logs internos.

---

## 4. Evolução Sem Quebra (Expand-Contract em Payloads) e Versionamento

1. **Regras de Mudança Retrocompatível (Aditiva):**
   - **Permitido em MINOR/PATCH:** Adicionar novos endpoints, adicionar campos opcionais na requisição (com default seguro) ou adicionar novos campos na resposta.
   - **Bloqueado (Exige Nova Versão MAJOR `/v2` ou ciclo de Deprecação):** Remover ou renomear campo existente, mudar tipo de dado (ex.: `int` $\rightarrow$ `string`), tornar campo opcional da request em obrigatório, ou adicionar novo valor em `enum` fechado sem que os clientes tenham fallback (`unknown`).
2. **Política de Deprecação HTTP:**
   - Antes de remover um campo ou rota, emita os headers `Deprecation: true`, `Sunset: <HTTP-date>` e `Link: <url-nova>; rel="successor-version"` durante a janela de migração acordada.
3. **Convenções de Tipos em JSON/OpenAPI:**
   - **Datas/Timestamps:** Sempre ISO 8601 / RFC 3339 em UTC (`2026-11-04T21:00:00Z`).
   - **Valores Monetários:** Inteiros na menor unidade (`amount_cents: 1990` + `currency: "BRL"`) ou string decimal exata (`"19.90"`). **Proibido** usar `float`/`double` binário para dinheiro.
   - **Paginação por Cursor:** Padronize o envelope `{ "data": [...], "page_info": { "next_cursor": "...", "has_next_page": true } }` alinhado com `backend-data-resilience`.
   - Consulte [rfc9457-openapi-grpc.md](./references/rfc9457-openapi-grpc.md) para templates OpenAPI 3.1, Protobuf/gRPC e assinatura HMAC de Webhooks.

---

## Handoff

Ao concluir o desenho ou auditoria do contrato de API, carregue o `SKILL.md` da próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: api-contract-designer
Para: vertical-slice-implementer (para implementar o handler/endpoint com TDD) | backend-data-resilience (para alinhar paginação por cursor e idempotência no banco) | security-vulnerability-warden (para auditar BOLA/IDOR e rate-limiting) | module-documentation-scribe (para publicar a especificação OpenAPI/CHANGELOG)
Motivo: <resumo das rotas/métodos desenhados, schema RFC 9457 e garantias de retrocompatibilidade>
Contexto necessário: <contratos de request/response, status codes mapeados e regras de idempotência>
```
