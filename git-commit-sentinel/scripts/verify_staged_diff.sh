#!/usr/bin/env bash
# verify_staged_diff.sh - Validador determinístico de pré-commit (Segurança, Higiene, Conflitos e Sincronia)
set -euo pipefail

# 1. Verificar se o diretório atual está dentro de um repositório Git
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ ERRO: O diretório atual não é um repositório Git válido."
  exit 1
fi

# 2. Verificar se há alterações em staged (--cached)
STAGED_FILES=$(git diff --cached --name-only || true)
if [ -z "$STAGED_FILES" ]; then
  echo "❌ ERRO: Nenhuma alteração encontrada em staged ('git add' pendente)."
  exit 1
fi

echo "🔍 Inspecionando arquivos em staged..."

# 3. Bloquear arquivos de segredos reais (permitindo templates .example/.sample/.template/.dist)
IS_SECRET_FILE=0
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if echo "$file" | grep -E -q "(\.example|\.sample|\.template|\.dist)$"; then
    continue
  fi
  if echo "$file" | grep -E -q "(^|/)(\.env(\.[a-zA-Z0-9_-]+)?|\.pem|\.key|id_rsa|id_ed25519|credentials\.json|\.pfx|\.p12)$"; then
    echo "🚨 BLOQUEIO DE SEGURANÇA: Arquivo confidencial/segredo detectado no staged: $file"
    IS_SECRET_FILE=1
  fi
done <<< "$STAGED_FILES"

if [ "$IS_SECRET_FILE" -eq 1 ]; then
  echo "💡 Remova o arquivo do staged com 'git restore --staged <arquivo>' e adicione ao .gitignore."
  exit 1
fi

# 4. Bloquear marcadores de conflito de merge e tokens/chaves privadas inline no diff
FULL_STAGED_DIFF=$(git diff --cached || true)

if echo "$FULL_STAGED_DIFF" | grep -E -q "^\+(<<<<<<<|=======|>>>>>>>)"; then
  echo "🚨 BLOQUEIO DE INTEGRIDADE: Marcadores de conflito de merge (<<<<<<< / ======= / >>>>>>>) detectados no staged!"
  exit 1
fi

SECRET_TOKEN_REGEX="^\+.*(BEGIN (RSA |OPENSSH |EC |PRIVATE )?KEY|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{22,}|sk-[a-zA-Z0-9]{20,}|xox[baprs]-[a-zA-Z0-9-]+)"
if echo "$FULL_STAGED_DIFF" | grep -E -q "$SECRET_TOKEN_REGEX"; then
  echo "🚨 BLOQUEIO DE SEGURANÇA: Possível chave privada ou token de API detectado inline no diff staged!"
  echo "💡 Remova a credencial hardcoded e utilize variáveis de ambiente ou cofre de segredos."
  exit 1
fi

# 5. Bloquear impressões cruas de debug APENAS em código-fonte de produção (incluindo PHP/Laravel e Frontend TSX/JSX/Vue/Svelte)
CODE_EXTENSIONS="(\.py|\.php|\.ts|\.tsx|\.js|\.jsx|\.vue|\.svelte|\.cs|\.rs|\.go|\.dart|\.java|\.rb|\.cpp|\.c|\.h)$"
TEST_OR_DOC_PATH_REGEX="(^|/)(tests?|specs?|__tests__|docs|scripts|examples|benchmarks)/|(^|/)test_[^/]+$|_test\.(go|py|rs|dart)$|Test\.php$|\.(test|spec)\.[^.]+$|\.(md|rst)$"
STAGED_CODE_FILES=$(echo "$STAGED_FILES" | grep -E "$CODE_EXTENSIONS" | grep -v -E "$TEST_OR_DOC_PATH_REGEX" || true)

if [ -n "$STAGED_CODE_FILES" ]; then
  FORBIDDEN_DEBUG_REGEX="^\+[[:space:]]*(print\(|console\.(log|debug)\(|println!\(|fmt\.Println\(|debugger;?|dd\(|dump\(|var_dump\(|print_r\(|ray\()"

  while IFS= read -r file; do
    [ -z "$file" ] && continue
    IS_CLI=$(echo "$file" | grep -E "(^|/)(cli|commands?|console|Console/Commands)/|(^|/)(cli|main|artisan)\.[^/]+$" || true)

    FILE_DIFF=$(git diff --cached -- "$file" || true)
    if echo "$FILE_DIFF" | grep -E -q "$FORBIDDEN_DEBUG_REGEX"; then
      if [ -n "$IS_CLI" ]; then
        echo "ℹ️ NOTA: Saída de console detectada no arquivo CLI: $file (permitido se fizer parte da saída padrão do terminal)."
      else
        echo "🚨 BLOQUEIO DE HIGIENE: Resíduo de debug (print/console.log/dd/dump/debugger) detectado em $file:"
        echo "$FILE_DIFF" | grep -E -n "$FORBIDDEN_DEBUG_REGEX" | head -n 5
        echo "💡 Substitua por logging estruturado ou remova antes do commit."
        exit 1
      fi
    fi
  done <<< "$STAGED_CODE_FILES"
fi

# 6. Verificar sincronia de manifests de versão caso algum manifest tenha sido alterado
MANIFEST_REGEX="(^|/)(package\.json|composer\.json|pyproject\.toml|Cargo\.toml|pubspec\.yaml|Directory\.Build\.props|VERSION)$|\.csproj$"
STAGED_MANIFESTS=$(echo "$STAGED_FILES" | grep -E "$MANIFEST_REGEX" || true)
if [ -n "$STAGED_MANIFESTS" ]; then
  echo "📦 Manifest(s) alterado(s) no staged:"
  echo "$STAGED_MANIFESTS" | sed 's/^/  - /'
  echo "ℹ️ Se este commit alterar a versão do projeto, execute 'check_version_and_readiness.sh' da skill release-distribution-engineer para garantir sincronia."
fi

# 7. Avaliar cobertura de testes em alterações de lógica de produção (excluindo docs, configs e scripts de tooling)
NON_PROD_PATH_REGEX="(^|/)(tests?|specs?|__tests__|docs|config|scripts|migrations|database/migrations|\.github|tools|examples|benchmarks)/|(^|/)test_[^/]+$|_test\.(go|py|rs|dart)$|Test\.php$|\.(test|spec)\.[^.]+$|\.(md|rst)$"
TEST_FILE_REGEX="(^|/)(tests?|specs?|__tests__)/|(^|/)test_[^/]+$|_test\.(go|py|rs|dart)$|Test\.php$|\.(test|spec)\.[^.]+$|Tests\.cs$"
HAS_PROD_CODE=$(echo "$STAGED_FILES" | grep -E "$CODE_EXTENSIONS" | grep -v -E "$NON_PROD_PATH_REGEX" || true)
HAS_TEST=$(echo "$STAGED_FILES" | grep -E "$TEST_FILE_REGEX" || true)

if [ -n "$HAS_PROD_CODE" ] && [ -z "$HAS_TEST" ]; then
  echo "⚠️ ALERTA DE COBERTURA: Arquivos de produção alterados sem arquivos de testes correspondentes no staged."
  echo "💡 Se esta mudança alterar comportamento ou corrigir bug, inclua os testes no mesmo commit atômico."
fi

echo "✅ Verificação de staged diff aprovada com sucesso!"
exit 0
