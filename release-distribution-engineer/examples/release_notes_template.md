# Exemplo de Notas de Versão (GitHub Release Notes)

Exemplo gerado via `git-cliff` a partir dos Conventional Commits e acompanhado de atestações.

---

## [v0.2.0] - 2026-10-10

### 🚀 Funcionalidades (Features)
- **engine:** adicionar leitor de streaming batched para tabelas de empresas ([#42](https://github.com/Arkmedess/CNPydge/issues/42))
- **cli:** adicionar flag `--format parquet` e saída estruturada de progresso via TTY ([#45](https://github.com/Arkmedess/CNPydge/issues/45))

### 🐛 Correções de Defeito (Bug Fixes)
- **cli:** corrigir vazamento de file descriptor na descompressão de arquivos zip corrompidos ([#89](https://github.com/Arkmedess/CNPydge/issues/89))
- **bridge:** evitar retenção do GIL do Python durante descompressão paralela em Rust ([#91](https://github.com/Arkmedess/CNPydge/issues/91))

### ⚡ Performance (Performance)
- **converter:** otimizar parser de datas reduzindo alocações na heap em 66% ([#104](https://github.com/Arkmedess/CNPydge/issues/104))

### ⚠️ Breaking Changes
- `cnpydge process` agora requer obrigatoriamente a flag `--output-dir` em vez de gravar no diretório atual.

---

### 📦 Integridade e Proveniência de Artefatos

Todos os binários e wheels distribuídos foram compilados em ambiente isolado com procedência SLSA Nível 3.

```text
# SHA256SUMS
a3f2b8... cnpydge-0.2.0-cp313-cp313-manylinux_2_28_x86_64.whl
b9d4e1... cnpydge-0.2.0-x86_64-unknown-linux-musl.tar.gz
c7a1f0... sbom.json
```

Para validar a integridade localmente:
```bash
sha256sum -c SHA256SUMS
```
