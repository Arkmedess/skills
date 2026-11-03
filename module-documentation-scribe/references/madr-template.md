# Template Oficial MADR (Markdown Architectural Decision Records)

Localização no projeto: `docs/adr/NNNN-titulo-em-kebab-case.md`

```markdown
# [Número Sequencial]: [Título Curto da Decisão Arquitetural]

* **Status:** [proposto | aceito | rejeitado | depreciado | substituído por ADR-XXXX]
* **Data:** [YYYY-MM-DD]
* **Decisores:** [Nomes ou papéis dos envolvidos]
* **Módulos Afetados:** [ex.: core, engine, cli, persistence]

## 1. Contexto e Declaração do Problema
[Descreva o contexto técnico ou de negócio e a restrição que motivou esta decisão. Qual problema estamos tentando resolver?]

## 2. Direcionadores de Decisão (Drivers)
* [Driver 1: Ex.: Latência sob alta concorrência de I/O]
* [Driver 2: Ex.: Manutenibilidade e independência entre módulos]
* [Driver 3: Ex.: Conformidade com SemVer estrito]

## 3. Opções Consideradas
* **Opção 1:** [Nome da Opção 1]
* **Opção 2:** [Nome da Opção 2]
* **Opção 3:** [Nome da Opção 3]

## 4. Decisão Escolhida
Escolhida a **[Opção X]**, porque [justificativa central, relacionando diretamente com os direcionadores de decisão].

## 5. Prós e Contras das Opções

### [Opção 1]
* Boa, porque [argumento a favor]
* Ruim, porque [argumento contra]

### [Opção 2]
* Boa, porque [argumento a favor]
* Ruim, porque [argumento contra]

## 6. Consequências e Trade-offs
* **Impacto Positivo:** [Ganhos de performance, clareza ou escalabilidade]
* **Impacto Negativo / Débito Aceito:** [Complexidade adicional, necessidade de novos testes ou treinamento]
* **Ações Mitigatórias:** [Como o time mitigará as consequências negativas]
```
