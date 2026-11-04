#!/usr/bin/env bash
# check_version_and_readiness.sh - Auditoria determinística de versão, manifests, tags e sugestão SemVer
set -euo pipefail

echo "=================================================================="
echo "🔎 AUDITORIA DE VERSIONAMENTO E PRONTIDÃO DE RELEASE (SemVer 2.0)"
echo "=================================================================="

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ ERRO: O diretório atual não é um repositório Git."
  exit 1
fi

# 1. Estado da Working Tree e Branch Atual
CURRENT_BRANCH=$(git branch --show-current || echo "HEAD-detached")
DIRTY_FILES=$(git status --porcelain || true)
echo "🌿 Branch atual: $CURRENT_BRANCH"
if [ -n "$DIRTY_FILES" ]; then
  echo "⚠️  Working tree possui alterações não commitadas:"
  echo "$DIRTY_FILES" | head -n 10 | sed 's/^/   /'
else
  echo "✅ Working tree limpa."
fi
echo ""

# 2. Última Tag SemVer no Git
LAST_TAG=$(git tag -l "v[0-9]*.[0-9]*.[0-9]*" --sort=-v:refname | grep -v -- '-' | head -n 1 || true)
if [ -z "$LAST_TAG" ]; then
  LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
fi

if [ -n "$LAST_TAG" ]; then
  TAG_COMMIT=$(git rev-list -n 1 "$LAST_TAG" 2>/dev/null | cut -c1-8 || echo "unknown")
  echo "🏷️  Última tag Git encontrada: $LAST_TAG (commit $TAG_COMMIT)"
else
  echo "🏷️  Última tag Git encontrada: <nenhuma tag registrada>"
fi
echo ""

# 3. Inspeção de Versões Declaradas em Manifests
echo "📦 Versões detectadas nos manifests do repositório:"
FOUND_VERSIONS=()
MANIFEST_COUNT=0

record_version() {
  local file="$1"
  local ver="$2"
  if [ -n "$ver" ]; then
    local normalized_ver="${ver%%+*}"
    printf "   - %-30s -> %s\n" "$file" "$ver"
    FOUND_VERSIONS+=("$normalized_ver")
    MANIFEST_COUNT=$((MANIFEST_COUNT + 1))
  fi
}

if [ -f "package.json" ]; then
  VER=$(grep -E -m 1 '"version"[[:space:]]*:[[:space:]]*"[^"]+"' package.json | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)
  record_version "package.json" "$VER"
fi

if [ -f "composer.json" ]; then
  VER=$(grep -E -m 1 '"version"[[:space:]]*:[[:space:]]*"[^"]+"' composer.json | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)
  record_version "composer.json" "$VER"
fi

if [ -f "pyproject.toml" ]; then
  VER=$(grep -E -m 1 '^version[[:space:]]*=[[:space:]]*"[^"]+"' pyproject.toml | sed -E 's/^version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/' || true)
  record_version "pyproject.toml" "$VER"
fi

if [ -f "Cargo.toml" ]; then
  VER=$(grep -E -m 1 '^version[[:space:]]*=[[:space:]]*"[^"]+"' Cargo.toml | sed -E 's/^version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/' || true)
  record_version "Cargo.toml" "$VER"
fi

if [ -f "pubspec.yaml" ]; then
  VER=$(grep -E -m 1 '^version:[[:space:]]*[^[:space:]]+' pubspec.yaml | sed -E 's/^version:[[:space:]]*([^[:space:]]+).*/\1/' || true)
  record_version "pubspec.yaml" "$VER"
fi

if [ -f "Directory.Build.props" ]; then
  VER=$(grep -E -m 1 '<Version>[^<]+</Version>' Directory.Build.props | sed -E 's/.*<Version>([^<]+)<\/Version>.*/\1/' || true)
  record_version "Directory.Build.props" "$VER"
fi

while IFS= read -r csproj; do
  [ -z "$csproj" ] && continue
  VER=$(grep -E -m 1 '<Version>[^<]+</Version>' "$csproj" | sed -E 's/.*<Version>([^<]+)<\/Version>.*/\1/' || true)
  record_version "$csproj" "$VER"
done <<< "$(find . -maxdepth 3 -name "*.csproj" 2>/dev/null || true)"

if [ -f "VERSION" ]; then
  VER=$(head -n 1 VERSION | tr -d '[:space:]' || true)
  record_version "VERSION" "$VER"
fi

if [ "$MANIFEST_COUNT" -eq 0 ]; then
  echo "   ⚠️ Nenhum manifest padrão (package.json, pyproject.toml, Cargo.toml, *.csproj, pubspec.yaml, VERSION) encontrado na raiz."
else
  UNIQUE_VERSIONS=$(printf "%s\n" "${FOUND_VERSIONS[@]}" | sort -u | wc -l)
  if [ "$UNIQUE_VERSIONS" -gt 1 ]; then
    echo "   🚨 ALERTA DE DIVERGÊNCIA: Múltiplas versões diferentes detectadas entre os manifests!"
  else
    echo "   ✅ Todos os manifests inspecionados estão sincronizados na versão ${FOUND_VERSIONS[0]}."
  fi
fi
echo ""

# 4. Análise de Commits desde a última Tag e Cálculo SemVer Sugerido
if [ -n "$LAST_TAG" ]; then
  RANGE="${LAST_TAG}..HEAD"
  echo "📊 Análise de commits no intervalo $RANGE:"
else
  RANGE="HEAD"
  echo "📊 Análise de todos os commits do repositório (sem tag anterior):"
fi

TOTAL_COMMITS=$(git rev-list --count $RANGE 2>/dev/null || echo "0")
echo "   Total de commits no ciclo: $TOTAL_COMMITS"

if [ "$TOTAL_COMMITS" -gt 0 ]; then
  SUBJECTS=$(git log $RANGE --format="%s" || true)

  # Contar commits únicos que contenham '!' no cabeçalho OU 'BREAKING CHANGE:' no corpo (evita contagem dupla do mesmo commit)
  BREAKING_COUNT=0
  while IFS= read -r sha; do
    [ -z "$sha" ] && continue
    COMMIT_SUBJ=$(git show -s --format="%s" "$sha" || true)
    COMMIT_BODY=$(git show -s --format="%b" "$sha" || true)
    if echo "$COMMIT_SUBJ" | grep -E -q "^[a-z]+(\([^)]+\))?!:" || echo "$COMMIT_BODY" | grep -E -q "BREAKING[ -]CHANGE:"; then
      BREAKING_COUNT=$((BREAKING_COUNT + 1))
    fi
  done <<< "$(git rev-list $RANGE 2>/dev/null || true)"

  FEAT_COUNT=$(echo "$SUBJECTS" | grep -E -c "^feat(\([^)]+\))?!?:" || true)
  FIX_COUNT=$(echo "$SUBJECTS" | grep -E -c "^fix(\([^)]+\))?!?:" || true)
  PERF_COUNT=$(echo "$SUBJECTS" | grep -E -c "^perf(\([^)]+\))?!?:" || true)
  OTHER_COUNT=$((TOTAL_COMMITS - FEAT_COUNT - FIX_COUNT - PERF_COUNT))
  [ "$OTHER_COUNT" -lt 0 ] && OTHER_COUNT=0

  echo "   - 💥 Breaking Changes (! / footer): $BREAKING_COUNT"
  echo "   - 🚀 Features (feat):               $FEAT_COUNT"
  echo "   - 🐛 Correções (fix):               $FIX_COUNT"
  echo "   - ⚡ Performance (perf):            $PERF_COUNT"
  echo "   - 🔧 Outros (refactor/docs/ci/...): $OTHER_COUNT"

  # Cálculo da próxima versão SemVer
  BASE_VER="${LAST_TAG#v}"
  if [ -z "$BASE_VER" ] && [ "${#FOUND_VERSIONS[@]}" -gt 0 ]; then
    BASE_VER="${FOUND_VERSIONS[0]#v}"
  fi
  BASE_VER="${BASE_VER:-0.1.0}"

  if [[ "$BASE_VER" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    MAJ="${BASH_REMATCH[1]}"
    MIN="${BASH_REMATCH[2]}"
    PAT="${BASH_REMATCH[3]}"

    if [ "$MAJ" -eq 0 ]; then
      # Regra 0.y.z (Pré-v1.0): breaking ou feat incrementa MINOR
      if [ "$BREAKING_COUNT" -gt 0 ] || [ "$FEAT_COUNT" -gt 0 ]; then
        NEXT_VER="0.$((MIN + 1)).0"
        BUMP_TYPE="MINOR (fase 0.y.z)"
      else
        NEXT_VER="0.${MIN}.$((PAT + 1))"
        BUMP_TYPE="PATCH"
      fi
    else
      # Regra >= 1.0.0 (Produção Estável)
      if [ "$BREAKING_COUNT" -gt 0 ]; then
        NEXT_VER="$((MAJ + 1)).0.0"
        BUMP_TYPE="MAJOR (Breaking Change detectada)"
      elif [ "$FEAT_COUNT" -gt 0 ]; then
        NEXT_VER="${MAJ}.$((MIN + 1)).0"
        BUMP_TYPE="MINOR (Novas funcionalidades)"
      else
        NEXT_VER="${MAJ}.${MIN}.$((PAT + 1))"
        BUMP_TYPE="PATCH (Correções/Performance/Manutenção)"
      fi
    fi
    echo ""
    echo "🎯 RECOMENDAÇÃO SEMVER: v${NEXT_VER} — Incremento: ${BUMP_TYPE}"
  fi
else
  echo "   ℹ️ Nenhum commit novo desde a última tag ($LAST_TAG)."
fi

echo ""
if [ -f "CHANGELOG.md" ]; then
  echo "📄 CHANGELOG.md: Presente na raiz."
else
  echo "⚠️  CHANGELOG.md: Ausente na raiz (acionar module-documentation-scribe antes da release)."
fi
echo "=================================================================="

