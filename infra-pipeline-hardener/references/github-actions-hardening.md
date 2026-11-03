# Diretrizes de Hardening para GitHub Actions

Regras obrigatórias para qualquer workflow em `.github/workflows/*.yml`.

---

## 1. Princípio do Menor Privilégio (`permissions: contents: read`)
Todo workflow deve declarar permissões explícitas no topo para desativar o token default com acesso de escrita:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  contents: read

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

---

## 2. Timeouts Obrigatórios em Todos os Jobs
Impedir que jobs travados em loops consumam minutos de runner:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 10 # Obrigatório em todo job
```

---

## 3. Matriz Fail-Fast e Ordem de Custo Crescente

```yaml
jobs:
  # 1. Rápido: Lint e Checagem Estática (< 1 min)
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v4
      - run: ruff check .

  # 2. Rápido: Testes Unitários puros (< 2 min)
  unit-tests:
    needs: [lint]
    runs-on: ubuntu-latest
    timeout-minutes: 8
    steps:
      - uses: actions/checkout@v4
      - run: pytest tests/unit

  # 3. Econômico: Mutation Testing apenas no Diff do PR
  mutation-diff:
    if: github.event_name == 'pull_request'
    needs: [unit-tests]
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - run: |
          MODIFIED_FILES=$(git diff --name-only origin/main...HEAD -- 'src/**/*.py' | tr '\n' ',')
          if [ -n "$MODIFIED_FILES" ]; then
            mutmut run --paths-to-mutate="$MODIFIED_FILES"
          fi

  # 4. Médio: Build do Contêiner
  build:
    needs: [unit-tests]
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: docker/setup-buildx-action@v3
      - uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # 5. Mais lento: Testes de Integração e Testcontainers
  integration-tests:
    needs: [build]
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v4
      - run: pytest tests/integration
```
