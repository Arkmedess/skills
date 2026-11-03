#!/usr/bin/env bash
# sync_github_labels.sh - Sincronizador idempotente de labels do GitHub
set -euo pipefail

if ! command -v gh &> /dev/null; then
  echo "❌ ERRO: gh CLI não encontrada no PATH."
  exit 1
fi

echo "🏷️ Sincronizando taxonomia canônica de labels no repositório GitHub..."

# Formato: "nome|cor_hex|descrição" (usa '|' como delimitador pois os nomes das labels contêm ':')
LABELS=(
  "type: feat|1D76DB|Nova funcionalidade ou capacidade técnica orientada a valor."
  "type: bug|D93F0B|Falha, regressão ou comportamento divergente da especificação."
  "type: refactor|F9D0C4|Reestruturação interna sem alteração de comportamento público."
  "type: docs|0075CA|Documentação técnica, especificações, ADRs ou guias."
  "type: test|0E8A16|Criação ou ajuste de testes (unitários, integração, mutação)."
  "type: perf|5319E7|Melhoria de desempenho comprovada por medição/benchmark."
  "type: infra|E99695|CI/CD, contêineres, automação e manifests de build."
  "type: security|B60205|Correção de vulnerabilidade, auditoria de segredos ou SCA."
  "priority: critical|B60205|P0: Parada total de produção, corrupção de dados (SLA < 2h)."
  "priority: high|D93F0B|P1: Bloqueio de fluxo core sem contorno (SLA < 24h)."
  "priority: medium|FBCA04|P2: Falha parcial com contorno disponível (Fluxo normal)."
  "priority: low|0E8A16|P3: Baixo impacto, melhoria cosmética ou menor."
  "status: triage|EDC240|Sob investigação ou aguardando detalhamento/reprodução."
  "status: ready-for-dev|0E8A16|Especificação técnica aprovada e pronta para desenvolvimento."
  "status: in-progress|FBCA04|Em desenvolvimento ativo pelo time ou agente."
  "status: blocked|000000|Impedimento externo ou dependência técnica pendente."
)

for entry in "${LABELS[@]}"; do
  IFS='|' read -r name color desc <<< "$entry"
  name=$(echo "$name" | xargs)
  color=$(echo "$color" | xargs)
  desc=$(echo "$desc" | xargs)
  
  echo "  -> Sincronizando label: '$name'"
  gh label create "$name" --color "$color" --description "$desc" --force 2>/dev/null || \
  gh label edit "$name" --color "$color" --description "$desc"
done

echo "✅ Todas as labels canônicas foram sincronizadas com sucesso!"
