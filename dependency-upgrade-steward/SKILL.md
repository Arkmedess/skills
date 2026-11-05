---
name: dependency-upgrade-steward
description: >-
  Use esta skill SEMPRE que atualizar dependências, pacotes, lockfiles, frameworks ou versões de runtime
  (.NET LTS, Python, Rust, Node, PHP/Laravel, Flutter), configurar Renovate/Dependabot ou resolver conflitos
  de árvore de pacotes. Garante determinismo de lockfiles, separação entre patches de segurança e upgrades
  MAJOR, auditoria de deprecações e validação sem regressão.
---

# Governador de Atualização de Dependências, Lockfiles e Runtimes

## 1. Regra de Ouro: Isolamento e Determinismo de Lockfiles
1. **Nunca misture upgrade de dependências com código de feature:** Atualizações de pacotes ou runtimes devem ocorrer em commits/PRs dedicados (`build(deps): ...`), permitindo `git revert` imediato caso surja regressão em produção.
2. **Integridade do Lockfile:** Todo manifest alterado exige regeneração atômica do lockfile oficial da stack (`uv.lock`, `Cargo.lock`, `pnpm-lock.yaml`/`package-lock.json`, `composer.lock`, `packages.lock.json`, `pubspec.lock`). **Proibido** editar lockfiles manualmente.

---

## 2. Estratégia de Atualização por Impacto SemVer

1. **Patches & Segurança (`x.y.Z` / CVEs):**
   - Prioridade máxima quando acionado por `security-vulnerability-warden`. Atualize para a menor versão que corrige a vulnerabilidade sem introduzir mudanças de API.
2. **Atualizações Minor (`x.Y.z`) e Agrupamento por Ecossistema:**
   - Atualize pacotes da mesma família em conjunto (ex.: todos os pacotes `Microsoft.Extensions.*`, `opentelemetry-*` ou `@tanstack/*` na mesma versão) para evitar *version skew*.
3. **Atualizações Major (`X.0.0`) e Migração de Runtime/Framework:**
   - **Passo 1 — Zero Deprecation Warnings na Versão Atual:** Antes de subir um Major (ex.: Laravel, Next.js, .NET, Python, Flutter), execute a suíte atual e resolva todos os avisos de deprecação (`DeprecationWarning` / `@deprecated`).
   - **Passo 2 — Inspeção do Guia de Migração e Codemods:** Aplique os *codemods* oficiais (`dotnet-upgrade`, `cargo fix --edition`, `flutter fix --apply`, `rector`) em commit separado de ajustes manuais.
   - **Passo 3 — Validação de Contratos e Performance:** Execute 100% da suíte de testes (`test-suite-architect`) e valide que não houve degradação de tempo de build/bundle ou latência.
   - Consulte [runtime-and-lockfile-matrix.md](./references/runtime-and-lockfile-matrix.md) para comandos de auditoria de pacotes desatualizados, resolução de conflitos e automação via Renovate/Dependabot.

---

## 3. Governança contra Inchaço de Dependências (Dependency Hygiene)

- **Avaliação antes de adicionar novo pacote:** Não adicione uma biblioteca externa para algo resolvido em $< 30$ linhas pela biblioteca padrão da linguagem.
- **Remoção de dependências órfãs:** Ao substituir uma biblioteca, remova-a imediatamente do manifest e execute o limpador de pacotes não utilizados (`cargo machete`, `deptry`, `knip`/`depcheck`, `composer-unused`).

---

## Handoff

Ao concluir a atualização de dependências ou runtime, carregue o `SKILL.md` da próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: dependency-upgrade-steward
Para: test-suite-architect (para validar a suíte de regressão completa) | security-vulnerability-warden (para reexecutar SCA e confirmar 0 CVEs) | infra-pipeline-hardener (se a versão do runtime mudar em Dockerfiles/CI) | git-commit-sentinel (para commitar com build(deps): ...)
Motivo: <resumo dos pacotes/runtimes atualizados, breaking changes tratadas e lockfiles sincronizados>
Contexto necessário: <diff de versões, avisos de deprecação resolvidos e resultado da suíte de testes>
```
