# Exemplo Real de Relatório de Diagnóstico de Performance

Modelo oficial de relatório empírico pré e pós-otimização.

---

## 1. Identificação do Cenário
- **Módulo / Ponto Crítico:** `engine/converter.py:process_csv_batch`
- **Ambiente:** Linux x86_64, 8 vCPUs, Python 3.13 + Extensão Rust
- **Carga de Teste:** Arquivo de 2.500.000 linhas de Estabelecimentos (tamanho: 1.2 GB)

---

## 2. Baseline Medido (Antes da Otimização)
- **Ferramentas Utilizadas:** `measure_rss_memory.py` e `py-spy dump`
- **Tempo de Execução:** 18.420 ms (18,42 s)
- **Pico de Memória RSS:** 1.420 MB (1,42 GB)
- **Gargalo Identificado:** Desserialização completa do CSV em memória antes da conversão para Arrow/Parquet e alocação de milhões de strings temporárias.

---

## 3. Proposta de Otimização
- Substituição da leitura `read_csv` por leitura batched em chunks de 50.000 linhas via `polars.read_csv_batched`.
- Conversão direta para tipos nativos `uint32` e `categorical` em Rust sem alocar objetos de string Python.
- **Trade-off:** Leve aumento no uso de CPU em paralelo (threads), com redução drástica no uso de memória física.

---

## 4. Resultado Pós-Otimização (Validação)
- **Tempo de Execução:** 6.120 ms (6,12 s) $\rightarrow$ **Redução de 66,7% (3x mais rápido)**
- **Pico de Memória RSS:** 215 MB $\rightarrow$ **Redução de 84,8% (consumo de RAM caiu 6,6x)**
- **Teste de Regressão Criado:** `tests/benchmarks/test_converter_rss.py` travando o limite de RSS em < 300MB no CI.
