#!/usr/bin/env bash
# audit_dockerfile.sh - Linter determinístico de Dockerfile para Produção
set -euo pipefail

DOCKERFILE="${1:-Dockerfile}"

if [ ! -f "$DOCKERFILE" ]; then
  echo "❌ ERRO: Arquivo '$DOCKERFILE' não encontrado."
  exit 1
fi

echo "🔍 Auditando '$DOCKERFILE' para conformidade com padrões de produção..."
VIOLATIONS=0

# 1. Verificar uso de tag flutuante :latest
if grep -E -q "FROM[ ]+.*:latest" "$DOCKERFILE"; then
  echo "⚠️ ALERTA: Imagem base utiliza tag flutuante ':latest'. Fixe a versão ou SHA256."
  grep -E -n "FROM[ ]+.*:latest" "$DOCKERFILE"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 2. Verificar usuário não-root no estágio final (após o último FROM)
LAST_STAGE_CONTENT=$(awk '/^[[:space:]]*FROM[[:space:]]+/ { buf="" } { buf = buf ORS $0 } END { print buf }' "$DOCKERFILE")
LAST_USER=$(echo "$LAST_STAGE_CONTENT" | grep -E "^[[:space:]]*USER[[:space:]]+" | tail -n 1 | sed -E 's/^[[:space:]]*USER[[:space:]]+([^[:space:]]+).*/\1/' || true)

if [ -z "$LAST_USER" ]; then
  echo "🚨 VIOLAÇÃO CRÍTICA: Ausência de instrução 'USER' no estágio final. O contêiner rodará como root!"
  VIOLATIONS=$((VIOLATIONS + 1))
elif echo "$LAST_USER" | grep -E -q "^(root|0)(:(root|0))?$"; then
  echo "🚨 VIOLAÇÃO CRÍTICA: O estágio final define 'USER $LAST_USER' (root). Exija usuário não-root (ex.: UID 10001)!"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 3. Verificar declaração de HEALTHCHECK
if ! grep -E -q "HEALTHCHECK" "$DOCKERFILE"; then
  echo "⚠️ ALERTA: Ausência de instrução 'HEALTHCHECK' nativa no Dockerfile."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 4. Verificar multi-stage build
STAGE_COUNT=$(grep -c -E "^FROM[ ]+" "$DOCKERFILE" || true)
if [ "$STAGE_COUNT" -lt 2 ]; then
  echo "⚠️ ALERTA: Imagem não utiliza multi-stage build (apenas $STAGE_COUNT estágio FROM encontrado)."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 5. Verificar limpeza de apt-get
if grep -E -q "apt-get install" "$DOCKERFILE" && ! grep -E -q "rm -rf /var/lib/apt/lists" "$DOCKERFILE"; then
  echo "🚨 VIOLAÇÃO DE CAMADA: 'apt-get install' executado sem limpeza de '/var/lib/apt/lists/*'."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# 6. Verificar existência de .dockerignore
DIRNAME=$(dirname "$DOCKERFILE")
if [ ! -f "$DIRNAME/.dockerignore" ]; then
  echo "⚠️ ALERTA DE SEGURANÇA: Arquivo '.dockerignore' não encontrado no diretório do build."
  VIOLATIONS=$((VIOLATIONS + 1))
fi

if [ "$VIOLATIONS" -eq 0 ]; then
  echo "✅ Dockerfile 100% aprovado nos critérios de segurança e higiene de produção!"
  exit 0
else
  echo "❌ Total de violações ou alertas encontrados: $VIOLATIONS"
  exit 1
fi
