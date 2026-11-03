# Framework Diátaxis para Documentação de Software

O Diátaxis organiza a documentação em 4 quadrantes estritos com base nas necessidades reais do leitor, evitando misturar explicações teóricas com guias de comandos práticos.

```text
                  ORIENTADO AO APRENDIZADO
                             ▲
                             │
            Tutoriais        │       Explicações
         (Passo a passo)     │   (Arquitetura & Porquês)
                             │
    PRÁTICO ─────────────────┼───────────────── TEÓRICO
                             │
          Guias Como-Fazer   │       Referência
        (Problema concreto)  │    (APIs & Parâmetros)
                             │
                             ▼
                   ORIENTADO À TAREFA
```

---

## 1. Tutoriais (Orientados ao Aprendizado Inicial)
- **Objetivo:** Ensinar um novato através de uma experiência guiada de ponta a ponta.
- **Formato:** Lição com início, meio e fim reproduzível. Deve sempre produzir um resultado visível e gratificante.
- **Exemplo:** *"Primeiros passos: criando sua primeira extensão nativa em 5 minutos"*.

---

## 2. Guias Como-Fazer / How-To (Orientados a Problemas Concretos)
- **Objetivo:** Resolver um problema específico enfrentado por quem já conhece o básico do sistema.
- **Formato:** Sequência direta de passos sem enrolação teórica.
- **Exemplo:** *"Como configurar pooling de conexões PostgreSQL para ambientes de alta concorrência"*.

---

## 3. Referência Técnica (Orientada à Informação Pura)
- **Objetivo:** Descrever o funcionamento das ferramentas de forma exata, neutra e completa.
- **Formato:** Dicionários de API, listas de flags de CLI, tipos de dados, retornos e códigos de erro.
- **Exemplo:** *"Especificação de Flags do comando `cnpydge build` e códigos de retorno POSIX"*.

---

## 4. Explicação & Arquitetura (Orientada ao Entendimento)
- **Objetivo:** Iluminar o contexto, o histórico, as restrições de design e o modelo mental do sistema.
- **Formato:** Textos reflexivos, diagramas C4 e Architecture Decision Records (ADRs).
- **Exemplo:** *"Por que adotamos fatias verticais e isolamento via eventos em vez de camadas horizontais"*.
