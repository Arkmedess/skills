#!/usr/bin/env bash
# test_portability.sh - Garante que o catálogo não referencia caminhos da máquina nem ferramentas de um harness específico
# Uso: bash tests/test_portability.sh (a partir de qualquer diretório)
set -euo pipefail

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$RAIZ"

ARQUIVOS=$(git ls-files '*.md' '*.sh' '*.py' '*.yml' | grep -v '^tests/' | grep -v '/tests/' || true)
FALHAS=0

verificar() {
  local descricao="$1" padrao="$2" achados
  achados=$(echo "$ARQUIVOS" | xargs grep -n -E -- "$padrao" 2>/dev/null || true)
  if [ -n "$achados" ]; then
    FALHAS=$((FALHAS + 1))
    echo "FALHOU: $descricao"
    echo "$achados" | head -n 20
  fi
}

verificar "caminho absoluto de home de usuário" '/home/[a-z_][a-z0-9_-]*/'
verificar "nome de ferramenta específica de harness (view_file)" 'view_file'

if [ "$FALHAS" -eq 0 ]; then
  echo "Portabilidade OK."
fi
[ "$FALHAS" -eq 0 ]
