---
name: git-commit-sentinel
description: >-
  Use esta skill SEMPRE antes de gerar, sugerir ou executar um commit Git (local ou via MCP github),
  criar branches, abrir/fazer merge de Pull Requests ou inspecionar diffs staged. Garante atomicidade,
  validação determinística de segurança/higiene, Conventional Commits em português com flags padronizadas
  e conformidade estrita com o servidor MCP do GitHub.
---

# Sentinela de Commits, Branches, PRs e Conformidade GitHub MCP

## 1. Regra de Atomicidade e Portão de Qualidade
Nenhum commit deve misturar refatoração com correção de bug ou nova funcionalidade. Cada commit representa uma transição de estado única, atômica, reversível, testável e acompanhada de sua respectiva documentação.

---

## 2. Validação Determinística Pré-Commit (Local e Remota)
Antes de redigir a mensagem ou executar o commit local, valide o staged diff (`git diff --cached`):

```bash
bash /home/arthur/.gemini/config/skills/git-commit-sentinel/scripts/verify_staged_diff.sh
```

Critérios de bloqueio aplicados pelo script (e obrigatórios em inspeção manual via MCP):
1. **Ausência de Staged:** Bloqueia se não houver arquivos adicionados (`git add` pendente).
2. **Conflitos de Merge Residual:** Bloqueia marcadores `<<<<<<<` e `>>>>>>>` (o `=======` isolado é ignorado por colidir com títulos Markdown).
3. **Segredos de Arquivos e Tokens Inline:** Bloqueia arquivos confidenciais (`.env*`, `*.pem`, `*.key`, `*.pfx`, `*.p12`, `id_rsa`, `id_ed25519`, `credentials.json`) e chaves/tokens expostos no diff (`BEGIN … PRIVATE KEY`, `ghp_`/`gho_`/…, `sk-` incluindo `sk-proj-`/`sk-ant-`, `AKIA`, `AIza`, `xox*-`). Se `gitleaks` estiver no PATH, ele roda adicionalmente (`NO_GITLEAKS=1` desativa). Testes: `bash tests/test_verify_staged_diff.sh`.
4. **Resíduos de Debug em Produção:** Bloqueia `print(`, `console.log(`, `println!(`, `fmt.Println(`, `debugger` em código de produção (`.py`, `.ts`, `.tsx`, `.js`, `.jsx`, `.vue`, `.svelte`, `.cs`, `.rs`, `.go`, `.dart`, etc.), exceto em CLIs, docs e testes.
5. **Sincronia de Versão e Cobertura de Testes:** Alerta se código de produção foi alterado sem testes correspondentes ou se um manifest de versão mudou sem sincronizar os demais.

---

## 3. Estrutura Conventional Commits v1.0.0 e Flags do `git commit`

### A. Anatomia Obrigatória da Mensagem (Sempre em Português Imperativo)
```text
<tipo>(<escopo>)[!]: <descrição no imperativo, minúscula, máx 72 chars, sem ponto final>

- <mudança técnica 1 explicando o 'porquê' e o impacto>
- <mudança técnica 2 com invariantes preservadas e validações executadas>

[BREAKING CHANGE: <descrição exata da quebra de contrato e guia de migração>]
[Fixes: #123 | Closes: #123 | Refs: #123]
```

- **Regra de Breaking Change (`!` + Footer):** Qualquer quebra de compatibilidade pública exige **simultaneamente** o sufixo `!` antes dos dois-pontos no cabeçalho (ex.: `feat(api)!: remover suporte a auth v1`) **e** o footer `BREAKING CHANGE:` no rodapé. Isso garante que calculadores SemVer (`git-cliff`, `release-distribution-engineer`) detectem o incremento `MAJOR` (ou `MINOR` em `0.y.z`) sem ambiguidade.
- **Tipos Aceitos:** `feat`, `fix`, `perf`, `refactor`, `docs`, `test`, `build`, `ci`, `chore`, `style`, `revert`.
- **Commits de Bump de Release:** Use estritamente `chore(release): lançar versão vX.Y.Z`.

### B. Execução Profissional via Terminal (`git commit` Flags)
- **Separação Estruturada por Parágrafos (`-m` múltiplos):**
  ```bash
  git commit \
    -m "feat(auth): implementar rotação automática de refresh tokens" \
    -m "- Adicionar invalidação em cascata de família de tokens no Redis.
  - Cobrir cenários de replay attack em tests/auth/refresh.spec.ts." \
    -m "Refs: #42"
  ```
- **Proibição de Bypass:** É **estritamente proibido** usar `--no-verify` (`-n`) para pular hooks de pre-commit ou commit-msg. Se um hook falhar, corrija a causa raiz.
- **Assinatura Criptográfica:** Se o repositório utilizar assinatura GPG/SSH (`commit.gpgsign`), preserve ou passe `-S`.

---

## 4. Conformidade de Operação via Servidor MCP do GitHub (`mcp:github`)

Quando operar diretamente sobre repositórios remotos usando as ferramentas do servidor MCP `github` (via `call_mcp_tool`), siga rigorosamente o contrato de cada ferramenta:

1. **`create_branch` (`owner`, `repo`, `branch`, `from_branch`):**
   - Sempre crie branches seguindo a taxonomia `<tipo>/<escopo>-<slug>` (ex.: `feat/payments-pix`, `fix/auth-token-ttl`, `release/v1.2.0`).
2. **`create_or_update_file` (`owner`, `repo`, `path`, `content`, `message`, `branch`, `sha`):**
   - **Regra Crítica do `sha`:** Ao atualizar um arquivo já existente, invoque **obrigatoriamente antes** `get_file_contents` no mesmo `path` e `branch` para obter o `sha` atual do blob.
   - O campo `message` deve conter o cabeçalho e o corpo completo em Conventional Commits.
3. **`push_files` (`owner`, `repo`, `branch`, `files`, `message`):**
   - Preferível a `create_or_update_file` sempre que o commit atômico envolver **múltiplos arquivos** (ex.: código + teste + documentação no mesmo commit), garantindo atomicidade transacional em um único SHA.
4. **`create_pull_request` (`owner`, `repo`, `title`, `body`, `head`, `base`, `draft`):**
   - `title`: No formato exato Conventional Commits (`<tipo>(<escopo>)[!]: <descrição>`).
   - `body`: Estruturado com `## Resumo`, `## Alterações Técnicas`, `## Validação Executada` e footer `Fixes #<id>` / `Refs #<id>`.
5. **`merge_pull_request` (`owner`, `repo`, `pull_number`, `merge_method`, `commit_title`, `commit_message`):**
   - **Pre-Flight Obrigatório:** Chame `get_pull_request_status` e `get_pull_request` antes do merge. Bloqueie o merge se `state != "success"` nos status checks ou se houver conflitos.
   - Ao usar `merge_method: "squash"`, preencha explicitamente `commit_title` (`<tipo>(<escopo>): <título> (#<PR>)`) e `commit_message` (bullets técnicos + footers).

*Consulte:* `examples/commit_messages.md` para exemplos reais completos.

---

## Handoff

Ao concluir a validação ou execução do commit/PR, acione via `view_file` a próxima skill aplicável e emita o bloco:

```text
HANDOFF
De: git-commit-sentinel
Para: release-distribution-engineer (se o commit fechar ciclo para tag/release) | issue-milestone-orchestrator (para atualizar/fechar issues vinculadas) | code-review-pr-auditor (se um PR foi aberto para revisão)
Motivo: <resumo objetivo da transição de estado commitada ou motivo do bloqueio>
Contexto necessário: <hash/branch/PR gerado, modo utilizado (Git local vs MCP github) e arquivos modificados>
```
