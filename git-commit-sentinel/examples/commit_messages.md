# Exemplos Reais de Mensagens de Commit e Payloads GitHub MCP

Modelos em modo imperativo/infinitivo e idioma **Português**, seguindo a especificação Conventional Commits v1.0.0.

---

## 1. Nova Funcionalidade (`feat`)
```text
feat(engine): implementar leitor de streaming batched para tabelas de empresas

- Adicionar suporte a leitura em chunks de 50.000 linhas via polars.read_csv_batched.
- Implementar conversão zero-copy para schema Parquet com tipos uint32 e categoricals.
- Adicionar testes de integração para arquivos de 1GB em tests/test_stream.py.

Refs: #42
```

---

## 2. Correção de Defeito (`fix`)
```text
fix(cli): corrigir vazamento de file descriptor na descompressão zip

- Envolver leitura de ZipFile em contexto gerenciado com fechamento determinístico.
- Tratar EOFError em arquivos truncados retornando exit code POSIX 1.
- Adicionar teste de regressão em tests/test_zip_regression.py.

Fixes: #89
```

---

## 3. Mudança com Quebra de Contrato (`!` + `BREAKING CHANGE`)
> **Obrigatório:** Usar `!` antes de `:` no cabeçalho **e** o bloco `BREAKING CHANGE:` no rodapé para acionamento correto de bump `MAJOR` (ou `MINOR` em `0.y.z`).

```text
perf(converter)!: otimizar parser de datas reduzindo alocações na heap

- Substituir parsing baseado em regex por parser posicional direto de bytes.
- Reduzir consumo de memória RSS de 850MB para 210MB em batches de 500k linhas.

BREAKING CHANGE: O formato de entrada agora exige estritamente ISO 8601 (YYYY-MM-DD). Para migrar, normalize datas legadas DD/MM/YYYY antes da chamada do pipeline.
Refs: #104
```

---

## 4. Commit de Bump de Versão e Preparação de Release (`chore(release)`)
```text
chore(release): lançar versão v1.2.0

- Sincronizar versão 1.2.0 em pyproject.toml, Cargo.toml e package.json.
- Atualizar constante __version__ e saída da flag --version na CLI.
- Consolidar notas de versão v1.2.0 em CHANGELOG.md.

Refs: #120
```

---

## 5. Exemplo de Payload para o Servidor MCP `github` (`push_files`)
Ao comitar remotamente via `call_mcp_tool` (`ServerName: "github"`, `ToolName: "push_files"`), passe a mensagem completa formatada com `\n\n`:

```json
{
  "owner": "organizacao",
  "repo": "nome-do-repo",
  "branch": "feat/paginacao-cursor",
  "message": "feat(orders): implementar paginação keyset na listagem de pedidos\n\n- Substituir OFFSET por cursor composto (created_at, id) com índice dedicado.\n- Adicionar testes de integração com Testcontainers PostgreSQL.\n\nRefs: #58",
  "files": [
    {
      "path": "src/features/orders/repository.ts",
      "content": "..."
    },
    {
      "path": "src/features/orders/repository.test.ts",
      "content": "..."
    }
  ]
}
```
