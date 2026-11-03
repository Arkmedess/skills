# Guia de Referência: Pipeline de Dados & Extensões Nativas (FFI)

Este documento aprofunda os padrões e restrições técnicas para projetos de **Processamento de Dados em Lote (Batch)** combinados com **Extensões Nativas de Alta Performance (Rust, C, Go, Python, Ruby)**.

---

## 1. Fronteira Nativa e FFI (Foreign Function Interface)

### A. Gestão de Memória e Zero-Copy
- **Mapeamento de Memória (`mmap`):** Para arquivos massivos (múltiplos gigabytes), delegue a paginação e o cache de leitura para o kernel do sistema operacional. Evite alocar o buffer total em RAM.
- **Intercâmbio de Dados Colunares:** Priorize formatos colunares com suporte a Arrow C Data Interface para transferir buffers de memória entre a linguagem nativa (Rust/C) e a hospedeira (Python/Ruby/Go) com custo zero de serialização e cópia.
- **Liberação de Locks de Runtime:**
  - Em **Python (PyO3/C-API):** Libere explicitamente o GIL (`Python::allow_threads` em Rust ou `Py_BEGIN_ALLOW_THREADS` em C) durante computações numéricas, decodificação de strings ou gravação em disco.
  - Em **Go (cgo):** Minimize chamadas frequentes de fronteira FFI em loops internos quentes (overhead de troca de contexto da pilha do Go). Agrupe o processamento em lotes.

### B. Tratamento de Erros e Estabilidade (Anti-Segfault / Anti-Panic)
- **Zero Panics/Abortos:** Nenhuma falha na camada nativa deve abortar o processo da aplicação hospedeira.
- **Mapeamento Explícito de Erros:**
  - Rust: Converta todo `Result<T, E>` em exceções tipadas na linguagem de alto nível (`PyResult<T>` mapeado para classes customizadas de exceção).
  - C: Retorne códigos de erro explícitos com buffers de mensagem preenchidos de forma segura, sem estouro de pilha.
- **Stubs de Tipagem (.pyi / TypeScript definitions):** Toda extensão nativa compilada deve vir acompanhada de stubs estáticos de tipagem para que linters e IDEs (`mypy`, `pyright`) façam checagem semântica estrita sem requerer o binário em tempo de análise.

---

## 2. Ingestão de Dados e Pipelines em Lote (Batch ETL/ELT)

### A. Idempotência e Reprocessamento
- Toda etapa de ingestão ou conversão em lote deve ser estritamente idempotente. Reprocessar o mesmo lote de entrada com os mesmos dados deve produzir a mesma saída sem duplicação de registros.
- **Atomicidade de Escrita:** Grave arquivos Parquet ou saídas de banco em arquivos temporários (`.tmp`) e execute um *rename* atômico apenas após o fechamento completo do stream de dados.

### B. Segurança em Downloads e Descompressão
- **Integridade Criptográfica:** Todo arquivo de entrada baixado externamente deve ser validado contra seu checksum (SHA-256) antes do início da descompressão.
- **Proteção contra Zip-Slip:** Ao extrair arquivos compactados (ZIP, TAR), valide rigorosamente que o destino final canônico reside dentro do diretório pretendido (`os.path.commonpath` em Python ou verificação de `components()` em Rust), prevenindo travessia de diretório arbitrária.
- **Proteção contra Zip-Bomb:** Limite o tamanho máximo de descompressão e verifique a taxa de compressão antes de inflar o arquivo em disco/memória.

### C. Evolução e Compatibilidade de Schemas (Parquet / Arrow)
- O schema da tabela deve ser versionado e documentado.
- Adições de colunas devem ser marcadas como opcionais/nullable para manter compatibilidade com dados históricos.
- Mudanças de tipo de dados que quebrem retrocompatibilidade exigem incremento no SemVer da aplicação e nova definição no dicionário de dados.

---

## 3. Telemetria e Benchmarks Específicos para Pipelines

- **Métricas Primárias:**
  - **Vazão:** Registros por segundo (`records/sec`) e Megabytes por segundo (`MB/sec`).
  - **Pegada de Memória:** Pico de RSS (Resident Set Size). O uso de RAM deve permanecer constante ao longo do processamento, sem crescimento proporcional ao tamanho do dataset.
  - **Tempo de FFI:** Tempo gasto na fronteira nativa vs. tempo no runtime da linguagem de alto nível.
- **Harness de Benchmark:**
  - Rust: `criterion` em `benches/`.
  - Python: micro-benchmarks com `pytest-benchmark` ou profiling de memória com `scalene` / `memray`.
  - Go: `testing.B` com medições de `-benchmem`.
