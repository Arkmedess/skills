---
name: cli-development
description: Guia decisões e convenções para projetar e construir interfaces de linha de comando (CLIs) robustas e idiomáticas. Use sempre que o usuário pedir para criar, revisar ou melhorar uma CLI, um comando de terminal, um script executável com flags/argumentos, ou mencionar parsing de argumentos, subcomandos, exit codes, ou empacotamento de ferramenta de linha de comando — mesmo que não diga explicitamente "CLI".
---

# Desenvolvimento de CLI

Esta skill existe para guiar decisões de design, ergonomia de terminal e convenções POSIX essenciais para ferramentas de linha de comando profissionais.

---

## Antes de Escrever Código
1. **Quem consome a saída?** Humano em terminal interativo ou scripts via pipe? (Determina suporte obrigatório a `--json`/`--quiet`).
2. **Ciclo de Execução:** Execução pontual rápida ou em loops de CI? (Determina impacto de tempo de startup e necessidade de cache local).
3. **Estrutura de Comandos:** Mapear a árvore de comandos (`ferramenta [grupo] <verbo> [args]`) antes de implementar.

---

## Convenções Obrigatórias de Design
- **Exit Codes Padronizados:**
  - `0`: Sucesso total.
  - `1`: Erro de runtime / falha de execução.
  - `2`: Erro de sintaxe ou parâmetros inválidos.
  - `130`: Interrupção limpa por sinal do usuário (`SIGINT` / `Ctrl+C`, sem despejar stacktrace bruto no terminal).
  - *Nunca encerre o processo com código 0 em caso de erro.*
- **Separação Rigorosa stdout / stderr:** Dados de negócio vão para `stdout`; mensagens informativas, logs de progresso e warnings vão para `stderr`. Isso garante que pipelines com `jq` funcionem limpos.
- **Ajuda e Versão:** Flags `--help` e `--version` devem ser sempre providas automaticamente pela biblioteca de parsing.
- **Saída para Máquinas (`--json`):** Quando aplicável para scripts, ofereça `--json` com esquema previsível e sem poluição de logs.
- **Cores e Terminal TTY:** Aplique cores apenas se `stdout` estiver conectado a um TTY. Respeite sempre a variável `NO_COLOR` e adicione flag `--no-color`.
- **Ações Destrutivas:** Solicite confirmação interativa com opção de bypass obrigatória via flag `--yes` / `-y` (necessário para pipelines de CI).
- **Precedência de Configuração:** Flag de linha de comando > Variável de ambiente > Arquivo de configuração ($XDG_CONFIG_HOME) > Valor padrão.

---

## Bibliotecas e Empacotamento por Stack
Consulte `references/cli-libraries-by-stack.md` para a seleção idiomática de parsing de argumentos, renderizadores de terminal (Rich, Spectre.Console) e estratégias de empacotamento/distribuição standalone por ecossistema.

---

## Handoff

Ao concluir o design ou implementação da CLI, emita obrigatoriamente o bloco de handoff:

```text
HANDOFF
De: cli-development
Para: vertical-slice-implementer (para implementar a lógica de negócio desacoplada do terminal) | test-suite-architect (testes de parsing, exit codes e contrato --json) | security-vulnerability-warden (se a CLI executar subprocessos ou manipular credenciais) | observability-logging-auditor (logs em stderr e modo --debug) | module-documentation-scribe (referência de comandos e guia de instalação)
Motivo: <resumo das decisões de design da CLI: árvore de comandos, saída, configuração e empacotamento>
Contexto necessário: <árvore de subcomandos, flags globais, exit codes e canal de distribuição escolhido>
```
