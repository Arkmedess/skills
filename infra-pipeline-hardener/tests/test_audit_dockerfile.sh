#!/usr/bin/env bash
# test_audit_dockerfile.sh - Testes determinísticos para audit_dockerfile.sh
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/audit_dockerfile.sh"
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT

PASSED=0
FAILED=0

caso() {
  local esperado="$1" descricao="$2" conteudo="$3" criar_ignore="${4:-sim}"
  rm -rf "${SANDBOX:?}/ctx"
  mkdir -p "$SANDBOX/ctx"
  [ "$criar_ignore" = "sim" ] && printf ".git\nnode_modules\n" >"$SANDBOX/ctx/.dockerignore"
  printf '%b\n' "$conteudo" >"$SANDBOX/ctx/Dockerfile"
  local status=0
  NO_HADOLINT=1 bash "$SCRIPT" "$SANDBOX/ctx/Dockerfile" >/dev/null 2>&1 || status=$?
  if [ "$esperado" = "aprovar" ] && [ "$status" -eq 0 ]; then
    PASSED=$((PASSED + 1))
  elif [ "$esperado" = "rejeitar" ] && [ "$status" -ne 0 ]; then
    PASSED=$((PASSED + 1))
  else
    FAILED=$((FAILED + 1))
    echo "FALHOU: esperava $esperado -> $descricao (exit $status)"
  fi
}

caso aprovar "multi-stage válido com USER 10001 e HEALTHCHECK" \
  "FROM python:3.13-slim AS builder\nRUN echo build\nFROM python:3.13-slim\nUSER 10001\nHEALTHCHECK CMD true"

caso aprovar "multi-stage com estágio final scratch e USER numérico (sem exigir HEALTHCHECK shell)" \
  "FROM golang:1.23-alpine AS builder\nRUN echo build\nFROM scratch\nUSER 10001:10001\nENTRYPOINT [\"/app\"]"

caso aprovar "multi-stage com distroless nonroot" \
  "FROM rust:1.82 AS builder\nRUN echo build\nFROM gcr.io/distroless/cc-debian12:nonroot\nUSER nonroot:nonroot\nENTRYPOINT [\"/app\"]"

caso rejeitar "FROM sem tag (latest implícito)" \
  "FROM python AS builder\nFROM python:3.13-slim\nUSER 10001\nHEALTHCHECK CMD true"

caso rejeitar "FROM com :latest explícito" \
  "FROM python:latest AS builder\nFROM python:3.13-slim\nUSER 10001\nHEALTHCHECK CMD true"

caso rejeitar "HEALTHCHECK NONE desabilitando healthcheck" \
  "FROM python:3.13-slim AS builder\nFROM python:3.13-slim\nUSER 10001\nHEALTHCHECK NONE"

caso rejeitar "ausência de USER no estágio final" \
  "FROM python:3.13-slim AS builder\nFROM python:3.13-slim\nHEALTHCHECK CMD true"

caso rejeitar "USER root no estágio final" \
  "FROM python:3.13-slim AS builder\nUSER 10001\nFROM python:3.13-slim\nUSER root\nHEALTHCHECK CMD true"

caso rejeitar "single-stage build" \
  "FROM python:3.13-slim\nUSER 10001\nHEALTHCHECK CMD true"

caso rejeitar "ausência de .dockerignore" \
  "FROM python:3.13-slim AS builder\nFROM python:3.13-slim\nUSER 10001\nHEALTHCHECK CMD true" "nao"

echo "Resultado: $PASSED passaram, $FAILED falharam."
[ "$FAILED" -eq 0 ]
