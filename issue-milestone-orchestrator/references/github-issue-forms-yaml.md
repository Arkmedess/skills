# Templates Declarativos de GitHub Issue Forms (YAML)

Configurados em `.github/ISSUE_TEMPLATE/*.yml` para garantir que tickets abertos pela equipe ou agentes contenham dados técnicos acionáveis.

---

## 1. `.github/ISSUE_TEMPLATE/feature.yml`
```yaml
name: "🚀 Nova Capacidade Técnica (Feature)"
description: Especificação de nova funcionalidade ou expansão de arquitetura.
title: "feat(escopo): "
labels: ["type: feat", "status: ready-for-dev"]
body:
  - type: textarea
    id: context
    attributes:
      label: "Contexto e Motivação Técnica"
      description: "Qual limitação técnica ou requisito arquitetural motiva esta entrega?"
    validations:
      required: true
  - type: textarea
    id: contract
    attributes:
      label: "Contrato e Proposta de Implementação"
      description: "Descreva entradas, processamento e saídas (tipos, schemas, flags)."
      placeholder: "Input: Payload ou args\nProcessamento: Fluxo de dados\nOutput: DTO ou arquivo gerado"
    validations:
      required: true
  - type: textarea
    id: validation
    attributes:
      label: "Comando de Validação em Terminal"
      description: "Comando de teste unitário ou integração para validar a entrega."
      render: shell
      placeholder: "pytest tests/features/test_feature.py"
    validations:
      required: true
```

---

## 2. `.github/ISSUE_TEMPLATE/bug.yml`
```yaml
name: "🐛 Defeito Técnico (Bug)"
description: Reportar falha observada, segfault, timeout ou quebra de contrato.
title: "fix(escopo): "
labels: ["type: bug", "status: triage"]
body:
  - type: dropdown
    id: priority
    attributes:
      label: "Prioridade / SLA"
      options:
        - "priority: critical (P0 - Incidente crítico / parada de produção)"
        - "priority: high (P1 - Falha grave sem contorno)"
        - "priority: medium (P2 - Falha parcial com contorno)"
        - "priority: low (P3 - Polimento / baixa gravidade)"
    validations:
      required: true
  - type: textarea
    id: reproduction
    attributes:
      label: "Passos Determinísticos de Reprodução"
      description: "Comandos e inputs exatos que geram o erro."
      render: shell
    validations:
      required: true
  - type: textarea
    id: evidence
    attributes:
      label: "Evidência / Stacktrace / Logs"
      description: "Logs estruturados ou stacktrace limpo."
      render: text
    validations:
      required: true
```
