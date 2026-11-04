#!/usr/bin/env bash
# test_check_version_and_readiness.sh - Testes de caracterização de check_version_and_readiness.sh
# Uso: bash tests/test_check_version_and_readiness.sh
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/check_version_and_readiness.sh"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

PASSED=0
FAILED=0

novo_repositorio() {
  rm -rf "${SANDBOX:?}/repo"
  mkdir -p "$SANDBOX/repo"
  git -C "$SANDBOX/repo" init -q
  git -C "$SANDBOX/repo" config user.email "t@t"
  git -C "$SANDBOX/repo" config user.name "t"
}

commitar() {
  echo "$RANDOM" >>"$SANDBOX/repo/f.txt"
  git -C "$SANDBOX/repo" add -A
  git -C "$SANDBOX/repo" commit -q -m "$1"
}

marcar() {
  git -C "$SANDBOX/repo" tag -a "$1" -m "$1"
}

saida_do_script() {
  (cd "$SANDBOX/repo" && bash "$SCRIPT" 2>&1)
}

verificar() {
  local descricao="$1" padrao="$2" saida
  saida="$(saida_do_script)"
  if echo "$saida" | grep -q -- "$padrao"; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    echo "FALHOU: $descricao (esperava '$padrao')"
    echo "$saida" | grep -E "tag Git|RECOMENDAÇÃO" || true
  fi
}

novo_repositorio
commitar "feat: base"
marcar v1.2.0
commitar "feat: nova capacidade"
marcar v1.3.0-rc.1
verificar "ignora pre-release como tag base" "Última tag Git encontrada: v1.2.0 "
verificar "calcula SemVer a partir da tag estável" "RECOMENDAÇÃO SEMVER: v1.3.0"

novo_repositorio
commitar "feat: base"
marcar v0.4.0
commitar "fix: corrige bug"
verificar "0.y.z com fix incrementa PATCH" "RECOMENDAÇÃO SEMVER: v0.4.1"

novo_repositorio
commitar "feat: base"
marcar v0.4.0
commitar "feat(api)!: remove rota"
verificar "0.y.z com breaking incrementa MINOR" "RECOMENDAÇÃO SEMVER: v0.5.0"

novo_repositorio
commitar "feat: base"
marcar v2.0.0
commitar "feat(api)!: remove rota"
verificar ">=1.0.0 com breaking incrementa MAJOR" "RECOMENDAÇÃO SEMVER: v3.0.0"

novo_repositorio
commitar "feat: base"
marcar v1.0.0-rc.1
commitar "fix: ajuste"
verificar "somente pre-release: usa a tag existente como fallback" "Última tag Git encontrada: v1.0.0-rc.1 "

echo "Resultado: $PASSED passaram, $FAILED falharam."
[ "$FAILED" -eq 0 ]
