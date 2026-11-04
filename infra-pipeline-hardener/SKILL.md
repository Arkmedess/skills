---
name: infra-pipeline-hardener
description: Use esta skill ao revisar ou criar Dockerfiles, docker-compose, pipelines de CI/CD (GitHub Actions, GitLab CI, Azure Pipelines) ou qualquer manifest de build/deploy, em qualquer linguagem. Aciona análise de camadas de imagem, determinismo de dependências, gates de qualidade fail-fast e automação econômica de mutation testing por diff.
---

# Playbook de Infraestrutura, Contêineres e CI/CD

## Modo de Execução: Auditoria Ativa e Validação Estrita

Esta skill padroniza Dockerfiles, Compose files e pipelines de CI/CD com foco em segurança de execução, contenção de recursos e tempos de compilação mínimos.

---

## 1. Auditoria e Validação Determinística de Dockerfiles
Antes de aprovar ou commitar qualquer imagem de contêiner, execute o script de auditoria estática:

```bash
bash <SKILL_DIR>/scripts/audit_dockerfile.sh [caminho/para/Dockerfile]   # <SKILL_DIR> = pasta deste SKILL.md
```

Critérios verificados:
1. **Multi-Stage Build:** Separação rígida de compilação e runtime.
2. **BuildKit Cache Mounts:** Utilização de `--mount=type=cache` para gerenciadores de dependência.
3. **Usuário Não-Root (UID 10001):** Proibido executar processo final como `root`.
4. **Healthcheck Nativo:** Declarado com timeouts e retries curtos.
5. **`.dockerignore`:** Exclusão obrigatória de caches locais, `.git`, arquivos de teste e credenciais.

*Consulte:* [production-dockerfile-patterns.md](./references/production-dockerfile-patterns.md) para templates prontos de Python (uv), Rust (cargo-chef), Go (scratch) e Node (Next.js standalone), e [stack-build-matrix.md](./references/stack-build-matrix.md) para lockfiles determinísticos e imagens base por stack.

---

## 2. Auditoria de Docker Compose de Produção e Staging
Rejeite Compose files sem contenção de recursos:
1. **Limites de RAM e CPU:** Obrigatórios via `deploy.resources.limits.memory` e `cpus`.
2. **Rotação de Logs em Disco:** Obrigatório driver `json-file` com `max-size: 10m` e `max-file: 3`.
3. **Chaining de Dependência:** Uso de `condition: service_healthy` em `depends_on`.
4. **Segurança de Rede:** Bind exclusivo em `127.0.0.1` para serviços atrás de proxy reverso.

*Consulte:* `examples/docker-compose.prod.yml` para manifesto completo pronto para uso.
*Consulte:* `references/docker-compose-production-spec.md`.

---

## 3. Pipelines de CI/CD (GitHub Actions)
Todo workflow deve respeitar a ordem de custo computacional crescente:
1. **Least Privilege & Supply Chain Pinning:** Declarar obrigatoriamente `permissions: contents: read` no topo do workflow e fixar Actions de terceiros por hash SHA completo (`uses: owner/action@<sha> # vX`).
2. **Timeouts Explícitos:** `timeout-minutes` definido em cada job (máximo 10-15 min).
3. **Pipeline Fail-Fast (Ordem de Custo Computacional Crescente):**
   - 1º: Lint, Formatação, Checagem de Tipos e Secret Scan em paralelo.
   - 2º: Testes Unitários rápidos sem I/O.
   - 3º: Build e empacotamento com cache de CI (`cache-from: type=gha`).
   - 4º: Testes de Integração (Testcontainers) e Mutation Testing econômico (restrito ao diff do PR).

*Consulte:* `references/github-actions-hardening.md`.

---

## Handoff

Ao concluir alterações em infraestrutura ou pipelines, emita o bloco de handoff:

```text
HANDOFF
De: infra-pipeline-hardener
Para: test-suite-architect (se os gates de teste ou mutação falharem no CI) | security-vulnerability-warden (auditoria de segredos e SCA de dependências) | git-commit-sentinel (se manifests estiverem prontos para commit) | module-documentation-scribe (atualizar README de deploy e operação)
Motivo: <resumo das alterações em Dockerfile, CI/CD ou manifests de pipeline>
Contexto necessário: <diff de manifests/Dockerfile, novas regras de filtragem por diff no CI e racional técnico>
```
