# Guia de Diagramas C4 com Mermaid

Para documentar arquiteturas vivas sem depender de ferramentas visuais externas, utilize diagramas Mermaid embutidos nos arquivos markdown.

---

## 1. Nível 1: Diagrama de Contexto de Sistema (System Context)
Mostra os atores humanos, o sistema sob análise e as integrações externas fundamentais:

```mermaid
graph TD
    User["Desenvolvedor / Usuário"]
    System["Nosso Sistema (CLI / Engine)"]
    GitHub["GitHub API"]
    Registry["Package Registry (PyPI / Crates.io)"]

    User -->|"Executa comandos"| System
    System -->|"Sincroniza issues/releases"| GitHub
    System -->|"Publica artefatos"| Registry
```

---

## 2. Nível 2: Diagrama de Contêineres / Módulos (Container / Top-Level Architecture)
Mostra como os módulos de alto nível se organizam e comunicam:

```mermaid
graph LR
    subgraph Monorepo / Aplicação
        CLI["Interface CLI (Terminal / Arg Parser)"]
        Engine["Core Engine (Lógica de Domínio / Fatias)"]
        Native["Extensão Nativa / FFI (C / Rust)"]
    end
    DB[("Banco de Dados / Persistência")]

    CLI -->|"Invoca serviços"| Engine
    Engine -->|"Delega computação CPU-bound"| Native
    Engine -->|"Armazena dados"| DB
```

---

## 3. Nível 3: Diagrama de Fatias Verticais e Componentes
Mostra o isolamento entre features e a camada core:

```mermaid
graph TD
    subgraph Features
        F1["Feature A (ex.: Appointments)"]
        F2["Feature B (ex.: Billing)"]
    end
    
    subgraph Core Shared
        Events["Event Bus / Contratos de Domínio"]
        Infra["Driver de Persistência / I/O"]
    end

    F1 -->|"Emite evento de negócio"| Events
    Events -->|"Consome evento"| F2
    F1 -->|"Usa repositório injetado"| Infra
    F2 -->|"Usa repositório injetado"| Infra
```
