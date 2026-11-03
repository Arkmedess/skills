#!/usr/bin/env bash
# generate_checksums.sh - Geração determinística e validação de SHA256SUMS
set -euo pipefail

DIST_DIR="${1:-dist}"

if [ ! -d "$DIST_DIR" ]; then
  echo "❌ ERRO: Diretório de distribuição '$DIST_DIR' não encontrado."
  exit 1
fi

# Verificar se existem arquivos no diretório
FILES=$(find "$DIST_DIR" -maxdepth 1 -type f ! -name "SHA256SUMS" ! -name "*.sha256")
if [ -z "$FILES" ]; then
  echo "❌ ERRO: Nenhum artefato encontrado em '$DIST_DIR' para gerar checksums."
  exit 1
fi

echo "🔐 Gerando hashes SHA-256 criptográficos para os artefatos em '$DIST_DIR'..."

cd "$DIST_DIR"
# Gerar SHA256SUMS relativo aos nomes dos arquivos de forma segura contra espaços
find . -maxdepth 1 -type f ! -name "SHA256SUMS" ! -name "*.sha256" -printf "%f\0" | sort -z | xargs -0 sha256sum > SHA256SUMS

echo "📋 Manifesto 'SHA256SUMS' gerado:"
cat SHA256SUMS

echo ""
echo "🔍 Validando integridade criptográfica..."
sha256sum -c SHA256SUMS

echo "✅ Todos os artefatos foram validados com sucesso via SHA-256!"
exit 0
