#!/usr/bin/env bash
# test_measure_rss_memory.sh - Testes para measure_rss_memory.py
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/measure_rss_memory.py"
PASSED=0
FAILED=0

assert_eq() {
  local desc="$1" esperado="$2" atual="$3"
  if [ "$esperado" = "$atual" ]; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    echo "FALHOU: $desc (esperava '$esperado', obteve '$atual')"
  fi
}

assert_contains() {
  local desc="$1" padrao="$2" texto="$3"
  if echo "$texto" | grep -q -- "$padrao"; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    echo "FALHOU: $desc (não encontrou '$padrao')"
  fi
}

# 1. Sem argumentos -> exit code 2 (erro de sintaxe/parâmetros CLI)
status=0
python3 "$SCRIPT" >/dev/null 2>&1 || status=$?
assert_eq "sem argumentos retorna exit 2" "2" "$status"

# 2. Execução com --warmup 1 --runs 2 reporta estatísticas e preserva stderr do comando
OUT=$(python3 "$SCRIPT" --warmup 1 --runs 2 -- python3 -c 'import sys; sys.stderr.write("aviso-importante-stderr\n"); print("ok-stdout")' 2>&1)
assert_contains "exibe stdout do comando" "ok-stdout" "$OUT"
assert_contains "preserva stderr do comando" "aviso-importante-stderr" "$OUT"
assert_contains "reporta mediana/desvio em múltiplas runs" "Mediana:" "$OUT"
assert_contains "reporta Pico de RSS" "Pico de RSS:" "$OUT"

echo "Resultado: $PASSED passaram, $FAILED falharam."
[ "$FAILED" -eq 0 ]
