---
name: systematic-debugging
description: Use esta skill sempre que houver um bug, falha em testes, stacktrace inesperado, comportamento anômalo ou erro em tempo de execução. Proíbe modificação de código por tentativa e erro — exige reprodução mínima determinística, isolamento da causa raiz e formulação de hipótese antes de alterar qualquer código de produção.
---

# Investigador Sistemático de Causa Raiz e Depuração

## Passo 1 — Reprodução Mínima Determinística (Obrigatória)
Antes de inspecionar ou alterar a implementação:
1. **Escrever um Teste Reproduzindo a Falha:** Crie um teste unitário ou de integração automatizado que falhe comprovadamente pelo exato motivo do bug reportado (*Red*).
2. **Isolar o Caso de Borda:** Reduza o payload, parâmetros ou sequência de passos ao menor exemplo viável que ainda dispare o defeito.

---

## Passo 2 — Diagnóstico da Causa Raiz
- **Leitura Analítica de Stacktrace:** Localize o primeiro frame sob controle do projeto e as exceções encapsuladas.
- **Rastreamento de Regressões:** Se o erro não existia em versões anteriores, utilize `git bisect` conforme detalhado em `references/debugging-techniques.md`.
- **Formulação da Hipótese:** Declare em uma frase: *"O bug ocorre porque sob condição X, o componente Y assume que Z é válido, mas recebe W."*

---

## Passo 3 — Correção Cirúrgica e Validação
1. Implemente a correção estritamente necessária para fazer o teste de reprodução passar (*Green*).
2. Execute a suíte de testes completa do módulo para certificar **zero efeitos colaterais** ou quebras em fatias adjacentes.
3. Se a causa raiz apontar para um Test Smell ou falta de invariante, consulte `test-suite-architect`.

---

## Handoff

Ao concluir a investigação e resolução do defeito, emita o bloco obrigatório de handoff:

```text
HANDOFF
De: systematic-debugging
Para: vertical-slice-implementer (para refatorar ou expandir a fatia estabilizada) | test-suite-architect (para auditar a robustez do novo teste de regressão) | git-commit-sentinel (para criar o commit com type: fix e referência à issue do defeito) | module-documentation-scribe (se a correção esclarecer comportamento anteriormente não documentado)
Motivo: <resumo do defeito, causa raiz identificada e teste de regressão criado>
Contexto necessário: <arquivo de teste de reprodução, teste passando e commit do bisect (se aplicável)>
```
