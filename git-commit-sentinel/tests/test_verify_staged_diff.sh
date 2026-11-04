#!/usr/bin/env bash
# test_verify_staged_diff.sh - Testes de caracterização de verify_staged_diff.sh (sem dependências externas)
# Uso: bash tests/test_verify_staged_diff.sh
# Segredos de teste são montados por concatenação para não acionar scanners ao versionar este arquivo.
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/verify_staged_diff.sh"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

PASSED=0
FAILED=0

novo_repositorio() {
  rm -rf "${SANDBOX:?}/repo"
  mkdir -p "$SANDBOX/repo"
  git -C "$SANDBOX/repo" init -q
}

executar_script() {
  (cd "$SANDBOX/repo" && git add -A && NO_GITLEAKS=1 bash "$SCRIPT" >/dev/null 2>&1)
}

esperar() {
  local esperado="$1" descricao="$2" status=0
  executar_script || status=$?
  if [ "$esperado" = "bloquear" ] && [ "$status" -ne 0 ]; then
    PASSED=$((PASSED + 1))
  elif [ "$esperado" = "permitir" ] && [ "$status" -eq 0 ]; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    echo "FALHOU: esperava $esperado -> $descricao (exit $status)"
  fi
}

caso() {
  local esperado="$1" arquivo="$2" conteudo="$3"
  novo_repositorio
  mkdir -p "$(dirname "$SANDBOX/repo/$arquivo")"
  printf '%s\n' "$conteudo" >"$SANDBOX/repo/$arquivo"
  esperar "$esperado" "$arquivo :: ${conteudo:0:40}"
}

PEM_BEGIN="-----BEGIN "
SK_PREFIX="s""k-"
GH_PREFIX="gh""p_"
AWS_PREFIX="AK""IA"
GCP_PREFIX="AI""za"
TOKEN_36="abcdefghijklmnopqrstuvwxyzABCDEF0123"

# Arquivos confidenciais (nome)
caso bloquear "server.pem" "x"
caso bloquear "secret.key" "x"
caso bloquear "certs/client.pfx" "x"
caso bloquear "certs/client.p12" "x"
caso bloquear ".env" "A=1"
caso bloquear "config/.env.production" "A=1"
caso bloquear "home/.ssh/id_rsa" "x"
caso bloquear "home/.ssh/id_ed25519" "x"
caso bloquear "secrets/credentials.json" "{}"
caso permitir ".env.example" "A=changeme"
caso permitir "keyboard.md" "texto"

# Credenciais inline
caso bloquear "a.txt" "${PEM_BEGIN}RSA PRIVATE KEY-----"
caso bloquear "a.txt" "${PEM_BEGIN}OPENSSH PRIVATE KEY-----"
caso bloquear "a.txt" "${PEM_BEGIN}PRIVATE KEY-----"
caso bloquear "a.txt" "${PEM_BEGIN}EC PRIVATE KEY-----"
caso bloquear "a.txt" "k=${SK_PREFIX}proj-AbCdEfGhIjKlMnOpQrStUvWxYz012345"
caso bloquear "a.txt" "k=${SK_PREFIX}ant-api03-AbCdEfGhIjKlMnOpQrStUv"
caso bloquear "a.txt" "k=${SK_PREFIX}AbCdEfGhIjKlMnOpQrStUvWxYz012345"
caso bloquear "a.txt" "t=${GH_PREFIX}${TOKEN_36}"
caso bloquear "a.txt" "id=${AWS_PREFIX}ABCDEFGHIJKLMNOP"
caso bloquear "a.txt" "k=${GCP_PREFIX}SyA-bcdefghijklmnopqrstuvwxyz012345"
caso bloquear "a.txt" "${SK_PREFIX}AbCdEfGhIjKlMnOpQrStUvWxYz012345"
caso permitir "a.txt" "classe=task-aaaaaaaaaaaaaaaaaaaaaaaaaaaa"

# Marcadores de conflito de merge
caso bloquear "a.py" "<<<<<<< HEAD"
caso bloquear "a.py" ">>>>>>> feature"
caso permitir "README.md" "Titulo"$'\n'"======="
caso permitir "a.py" "x = 1"

echo "Resultado: $PASSED passaram, $FAILED falharam."

# Integração com gitleaks (segredo que o regex local não cobre: chave live do Stripe)
if command -v gitleaks >/dev/null 2>&1; then
  novo_repositorio
  printf 'k=%s\n' "sk_li""ve_4eC39HqLyjWDarjtT1zdp7dc" >"$SANDBOX/repo/pay.txt"
  status=0
  (cd "$SANDBOX/repo" && git add -A && bash "$SCRIPT" >/dev/null 2>&1) || status=$?
  if [ "$status" -ne 0 ]; then
    echo "gitleaks: bloqueou segredo fora do regex local (ok)"
  else
    FAILED=$((FAILED + 1)); echo "FALHOU: gitleaks instalado não bloqueou sk_live"
  fi
else
  echo "gitleaks ausente: teste de integração ignorado"
fi
[ "$FAILED" -eq 0 ]
