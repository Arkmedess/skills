---
name: release-distribution-engineer
description: >-
  Use esta skill SEMPRE que for checar ou incrementar versões (SemVer), auditar sincronia de manifests e flags
  (--version), preparar ou publicar uma Release/Pre-Release, gerar tags Git anotadas/assinadas, calcular
  breaking changes, gerar checksums (SHA256SUMS/SBOM) ou orquestrar releases via gh CLI e MCP do GitHub.
---

# Engenheiro de Versionamento, Release, Empacotamento e Distribuição

## 1. Regra de Ouro: Diagnóstico de Prontidão Obrigatório (Pre-Release Briefing)
Nenhuma versão é alterada, nenhuma tag é criada e nenhuma release é publicada às cegas. Antes de executar o bump ou a publicação, o agente **deve obrigatoriamente inspecionar o estado atual** e apresentar ao desenvolvedor o **Relatório de Prontidão de Release (Pre-Release Briefing)**:

1. Execute o script determinístico de diagnóstico de versão e commits:
   ```bash
   bash /home/arthur/.gemini/config/skills/release-distribution-engineer/scripts/check_version_and_readiness.sh
   ```
   *(Caso opere exclusivamente via servidor MCP `github`, execute a mesma verificação consultando `list_commits` e `get_file_contents` nos manifests).*

2. Apresente ao desenvolvedor o quadro de decisão antes de publicar:
   - **Versão Atual Detectada:** Última tag Git (`vX.Y.Z`) vs. versões declaradas em cada manifest e na flag `--version` do código.
   - **Inventário de Commits desde a última tag:** Contagem de `BREAKING CHANGE`/`!`, `feat`, `fix`, `perf` e demais tipos.
   - **Versão Alvo Calculada (`vX.Y.Z` ou Pre-Release `-rc.N` / `-beta.N`)** + justificativa SemVer.
   - **Arquivos a Sincronizar:** Lista exata de manifests (`pyproject.toml`, `package.json`, `Cargo.toml`, `*.csproj`, `pubspec.yaml`), constantes internas (`__version__`, `--version`) e `CHANGELOG.md`.
   - **Status de Qualidade e CI:** Confirmação de working tree limpa, testes/linters aprovados e status checks verdes no GitHub (`get_pull_request_status` / `gh run list`).
   - **Flags Exatas da Release:** Confirmação das flags de tag e de publicação (`--verify-tag`, `--target`, `--latest` / `--prerelease` / `--draft`) e artefatos anexados (`SHA256SUMS`, `sbom.json`, binários).

---

## 2. Cálculo SemVer 2.0.0 e Auditoria de Quebra de Contrato

### A. Régua SemVer Estrita e Pre-Releases
- **Fase Inicial (`0.y.z` — Pré-v1.0):**
  - Quebras de contrato (`!` / `BREAKING CHANGE`) ou novas features incrementam **MINOR** (`0.1.0` $\rightarrow$ `0.2.0`).
  - Correções retrocompatíveis incrementam **PATCH** (`0.1.0` $\rightarrow$ `0.1.1`).
- **Fase de Produção Estável (`v1.0.0+`):**
  - **MAJOR (`v2.0.0`):** Qualquer remoção ou alteração incompatível em API pública, rota HTTP, schema de banco/evento ou flag/saída de CLI.
  - **MINOR (`v1.1.0`):** Nova funcionalidade ou campo opcional retrocompatível.
  - **PATCH (`v1.0.1`):** Correção de bug ou segurança 100% retrocompatível.
- **Sufixos de Pre-Release e Build Metadata:**
  - Canais de estabilização seguem `vX.Y.Z-alpha.N`, `vX.Y.Z-beta.N` ou `vX.Y.Z-rc.N` (ex.: `v1.2.0-rc.1`).
  - Toda versão com hífen (`-alpha`, `-beta`, `-rc`) **exige obrigatoriamente** a flag `--prerelease` e nunca deve receber `--latest`.

### B. Detecção Automatizada de Quebra de API Pública
Consulte `references/breaking-changes-tools.md` para validar assinaturas públicas por stack (`cargo-semver-checks`, `griffe`, `gorelease`, `abidiff`, `@arethetypeswrong/cli`).

---

## 3. Sincronização Atômica de Manifests, Flags `--version` e Checksums

1. **Sincronia Total (Manifests + Runtime `--version` + Lockfiles):**
   - Atualize no mesmo commit atômico (`chore(release): lançar versão vX.Y.Z`) todos os manifests do repositório, os lockfiles afetados (`Cargo.lock`, `package-lock.json`, `uv.lock`) e a constante de versão exposta pela flag `--version` (CLI) ou endpoint `/health` / OpenAPI (Web API).
   - Consulte `references/manifest-sync-and-packaging.md` para a lista completa de arquivos por linguagem.
2. **Geração e Validação de `SHA256SUMS`:**
   - Sempre que houver artefatos empacotados em `dist/`, gere e valide o manifesto criptográfico:
     ```bash
     bash /home/arthur/.gemini/config/skills/release-distribution-engineer/scripts/generate_checksums.sh [dist/]
     ```

---

## 4. Governança de Tags Git, Flags de Release e Integração MCP `github` + `gh CLI`

### A. Papel do Servidor MCP `github` vs. `gh CLI`
- **Via MCP `github` (`call_mcp_tool`):**
  - Use `list_commits` e `get_file_contents` para auditar o histórico remoto e ler versões dos manifests na branch principal.
  - Use `create_branch` (`release/vX.Y.Z`), `push_files` (sincronizando manifests + `CHANGELOG.md`), `create_pull_request` e `get_pull_request_status` para conduzir o PR de release com CI 100% verde.
- **Via Git Local + `gh CLI` (Publicação de Tag e Release):**
  - Como o servidor MCP `github` padrão não possui ferramenta de criação de Releases ou upload de binários de release, utilize o Git local e o `gh release create` para selar a tag e publicar a release com os artefatos.

### B. Criação de Tag Git (Proibido Lightweight Tags)
Nunca crie tags leves (`git tag vX.Y.Z`). Crie sempre **tags anotadas (`-a`) ou assinadas (`-s`)** apontando para o commit de release já validado:
```bash
# Tag anotada padrão (ou use -s para assinatura GPG/SSH)
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

### C. Criação da Release no GitHub com Flags Explícitas
1. **Gerar Notas de Versão Estruturadas:**
   - Via `git-cliff --latest --strip header > release-notes.md` ou seguindo o modelo em `examples/release_notes_template.md` (Destaque de Novidades, Breaking Changes e Guia de Migração, Correções, Checksums `SHA256SUMS` e link de comparação `Full Changelog`).
2. **Executar `gh release create` com as Flags Corretas para o Cenário:**
   - **Release Estável Principal (Latest):**
     ```bash
     gh release create vX.Y.Z ./dist/* SHA256SUMS sbom.json \
       --verify-tag \
       --target main \
       --title "vX.Y.Z - <Título Conciso da Release>" \
       --notes-file release-notes.md \
       --latest
     ```
   - **Pre-Release (`-alpha.N`, `-beta.N`, `-rc.N`):**
     ```bash
     gh release create vX.Y.Z-rc.1 ./dist/* SHA256SUMS \
       --verify-tag \
       --target main \
       --title "vX.Y.Z-rc.1 (Release Candidate 1)" \
       --notes-file release-notes.md \
       --prerelease
     ```
   - **Patch de Manutenção em Versão Anterior (Não sobrescrever Latest):**
     - Ao lançar um patch em uma linha antiga (ex.: `v1.4.2` quando a `v2.0.0` já existe), passe obrigatoriamente **`--latest=false`**.
   - **Release em Rascunho para Aprovação Manual:** Adicione a flag **`--draft`**.

---

## 5. Segurança da Cadeia de Suprimentos (SLSA, Sigstore e SBOM)
- **SLSA Level 3 & Sigstore (Cosign):** Assinatura keyless vinculada ao OIDC do CI e atestação de proveniência (`references/slsa-and-sigstore-guide.md`).
- **SBOM:** Geração de `sbom.json` (CycloneDX) via `syft` anexado aos assets da release.

---

## Handoff

Ao concluir o diagnóstico ou a publicação da release, acione via `view_file` a próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: release-distribution-engineer
Para: git-commit-sentinel (para o commit atômico chore(release) e push) | issue-milestone-orchestrator (para fechar a milestone da versão lançada) | module-documentation-scribe (para consolidar o CHANGELOG.md)
Motivo: <versão calculada (SemVer), status de sincronia dos manifests, flags de release aplicadas e artefatos validados>
Contexto necessário: <tag gerada (vX.Y.Z), arquivos sincronizados, SHA256SUMS e URL/notas da release>
```
