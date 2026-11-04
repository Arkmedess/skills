#!/usr/bin/env bash
# audit_dockerfile.sh - Linter determinístico de Dockerfile para Produção
set -euo pipefail

DOCKERFILE="${1:-Dockerfile}"

if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ ERRO: Arquivo '$DOCKERFILE' não encontrado." >&2
  exit 2
fi

echo "🔍 Auditando '$DOCKERFILE' para conformidade com padrões de produção..."
VIOLATIONS=0

if [ -z "${NO_HADOLINT:-}" ] && command -v hadolint >/dev/null 2>&1; then
  if ! hadolint "$DOCKERFILE"; then
    echo "🚨 VIOLAÇÃO: hadolint apontou problemas no Dockerfile."
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
fi

# Extrair nomes de estágios declarados (AS <nome>) para não exigir :tag em referências internas
STAGE_NAMES=$(grep -E -i "^[[:space:]]*FROM[[:space:]]+.*[[:space:]]+AS[[:space:]]+[A-Za-z0-9._-]+" "$DOCKERFILE" | sed -E 's/.*[[:space:]][Aa][Ss][[:space:]]+([A-Za-z0-9._-]+).*/\1/' || true)

# 1. Verificar uso de tag flutuante :latest ou ausência de tag/digest (@sha256)
while IFS= read -r line; do
  [ -z "$line" ] && continue
  IMAGE_SPEC=$(echo "$line" | sed -E 's/^[[:space:]]*[Ff][Rr][Oo][Mm][[:space:]]+(--platform=[^[:space:]]+[[:space:]]+)?([^[:space:]]+).*/\2/')
  [ "$IMAGE_SPEC" = "scratch" ] && continue
  if [ -n "$STAGE_NAMES" ] && echo "$STAGE_NAMES" | grep -Fxq "$IMAGE_SPEC"; then
    continue
  fi
  if echo "$IMAGE_SPEC" | grep -Eq ":latest$"; then
    echo "⚠️ ALERTA: Imagem base utiliza tag flutuante ':latest': $IMAGE_SPEC"
    VIOLATIONS=$((VIOLATIONS + 1))
  elif ! echo "$IMAGE_SPEC" | grep -Eq "(:|@sha256:)"; then
    echo "⚠️ ALERTA: Imagem base sem tag ou digest explícito (latest implícito): $IMAGE_SPEC"
    VIOLATIONS=$((VIOLATIONS + 1))
  fi
done <<< "$(grep -E -i "^[[:space:]]*FROM[[:space:]]+" "$DOCKERFILE" || true)"

# 2. Verificar usuário não-root no estágio final (após o último FROM)
LAST_STAGE_CONTENT=$(awk 'BEGIN{IGNORECASE=1} /^[[:space:]]*FROM[[:space:]]+/ { buf="" } { buf = buf ORS $0 } END { print buf }' "$DOCKERFILE")
LAST_FROM_IMAGE=$(echo "$LAST_STAGE_CONTENT" | grep -E -i "^[[:space:]]*FROM[[:space:]]+" | tail -n 1 | sed -E 's/^[[:space:]]*[Ff][Rr][Oo][Mm][[:space:]]+(--platform=[^[:space:]]+[[:space:]]+)?([^[:space:]]+).*/\2/' || true)
LAST_USER=$(echo "$LAST_STAGE_CONTENT" | grep -E -i "^[[:space:]]*USER[[:space:]]+" | tail -n 1 | sed -E 's/^[[:space:]]*[Uu][Ss][Ee][Rr][[:space:]]+([^[:space:]]+).*/\1/' || true)

if [ -z "$LAST_USER" ]; then
  echo "🚨 VIOLAÇÃO CRÍTICA: Ausência de instrução 'USER' no estágio final. O contêiner rodará como root!"
  VIOLATIONS=$((VIOLATIONS + 1))
elif echo "$LAST_USER" | grep -E -i -q "^(root|0)(:(root|0))?$"; then
  echo "🚨 VIOLAÇÃO CRÍTICA: O estágio final define 'USER $LAST_USER' (root). Exija usuário não-root (ex.: UID 10001)!"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 3. Verificar declaração de HEALTHCHECK (dispensado para scratch/distroless, onde a sonda ocorre no orquestrador)
IS_MINIMAL_IMAGE=0
if [ "$LAST_FROM_IMAGE" = "scratch" ] || echo "$LAST_FROM_IMAGE" | grep -Eq "distroless"; then
  IS_MINIMAL_IMAGE=1
fi

if echo "$LAST_STAGE_CONTENT" | grep -E -i -q "^[[:space:]]*HEALTHCHECK[[:space:]]+NONE"; then
  echo "🚨 VIOLAÇÃO: 'HEALTHCHECK NONE' desabilita a verificação de integridade do contêiner."
  VIOLATIONS=$((VIOLATIONS + 1))
elif [ "$IS_MINIMAL_IMAGE" -eq 0 ] && ! echo "$LAST_STAGE_CONTENT" | grep -E -i -q "^[[:space:]]*HEALTHCHECK[[:space:]]+"; then
  echo "⚠️ ALERTA: Ausência de instrução 'HEALTHCHECK' nativa no Dockerfile."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 4. Verificar multi-stage build
STAGE_COUNT=$(grep -c -E -i "^[[:space:]]*FROM[[:space:]]+" "$DOCKERFILE" || true)
if [ "$STAGE_COUNT" -lt 2 ]; then
  echo "⚠️ ALERTA: Imagem não utiliza multi-stage build (apenas $STAGE_COUNT estágio FROM encontrado)."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 5. Verificar limpeza de apt-get
if grep -E -q "apt-get install" "$DOCKERFILE" && ! grep -E -q "rm -rf /var/lib/apt/lists" "$DOCKERFILE"; then
  echo "🚨 VIOLAÇÃO DE CAMADA: 'apt-get install' executado sem limpeza de '/var/lib/apt/lists/*'."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 6. Verificar existência de .dockerignore (no diretório do Dockerfile ou na raiz do repositório)
DIRNAME=$(dirname "$DOCKERFILE")
if [ ! -f "$DIRNAME/.dockerignore" ] && [ ! -f ".dockerignore" ]; then
  echo "⚠️ ALERTA DE SEGURANÇA: Arquivo '.dockerignore' não encontrado no diretório do build."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

if [ "$VIOLATIONS" -eq 0 ]; then
  echo "✅ Dockerfile 100% aprovado nos critérios de segurança e higiene de produção!"
  exit 0
else
  echo "❌ Total de violações ou alertas encontrados: $VIOLATIONS" >&2
  exit 1
fi
