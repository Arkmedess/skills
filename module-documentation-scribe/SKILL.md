---
name: module-documentation-scribe
description: >-
  Use esta skill SEMPRE ao concluir a implementação de uma feature, mudança de infraestrutura, decisão
  arquitetural (ADRs via MADR) ou sob pedidos como "documente isso", "escreve o README", "registre essa decisão"
  ou "gere changelog". Trata documentação técnica como entregável de primeira classe.
---

# Redator de Documentação de Módulos e Arquitetura

## Passo 1 — Estruturação segundo o Framework Diátaxis
Organize qualquer documentação com base nas necessidades do leitor:
- **Tutoriais:** Lições práticas guiadas para iniciantes.
- **Guias Como-Fazer (How-To):** Resolução direta de problemas específicos para quem já conhece o sistema.
- **Referência Técnica:** Especificações exatas de APIs, flags de CLI, schemas e retornos.
- **Explicação & Arquitetura:** O *porquê* das escolhas, limites de design e registros de decisão.
- *Consulte:* `references/diataxis-framework.md`.

---

## Passo 2 — Topologia de Documentação em 2 Níveis

### Nível 1: Raiz do Projeto (`docs/` e `README.md` raiz) — Visão Macro
1. **`README.md` (Raiz):** Visão executiva, quickstart, instalação e comandos principais.
2. **`docs/architecture/`:** Diagramas C4 (Contexto, Contêineres e Fatias) embutidos via Mermaid.
   - *Consulte:* `references/c4-mermaid-guide.md` para templates de diagramas Mermaid.
3. **`docs/adr/NNNN-titulo.md`:** Registros de Decisão Arquitetural (*Architecture Decision Records*) no formato oficial MADR.
   - *Consulte:* `references/madr-template.md` para o template padronizado de ADR.

### Nível 2: Escopo Local (`<modulo>/README.md` ou `features/<nome>/README.md`) — Visão Micro
Cada módulo ou fatia vertical mantém seu próprio `README.md` conciso:
- **Propósito:** O que a fatia resolve em 2 a 3 frases claras.
- **Contrato Público & Assinaturas:** Inputs, outputs, exceções mapeadas e eventos emitidos/consumidos.
- **Invariantes de Domínio:** Regras de negócio que nunca podem ser violadas.
- **Dependências & Acoplamento:** Módulos consumidos e justificativa.
- **Testes & Comandos:** Como executar a suíte e benchmarks locais daquela fatia.

---

## Passo 3 — Prevenção de Divergência e Changelog
1. **Docstrings em Português:** Tipos e funções públicas documentam parâmetros, retornos e erros no padrão idiomático da linguagem (Google/Sphinx, XML Docs, TSDoc).
2. **Changelog Estrito:** Manter `CHANGELOG.md` no padrão *Keep a Changelog* + *SemVer*. Toda alteração com impacto público alimenta a seção `[Unreleased]`.

---

## Handoff

Ao concluir a execução desta skill, emita obrigatoriamente o bloco de handoff:

```text
HANDOFF
De: module-documentation-scribe
Para: git-commit-sentinel (para autorizar e gerar o commit atômico contendo código, testes e documentação) | issue-milestone-orchestrator (para vincular documentação às issues da milestone)
Motivo: <resumo dos artefatos de documentação gerados ou atualizados nos níveis macro/micro>
Contexto necessário: <links para os arquivos README.md, ADRs, diagramas C4 ou CHANGELOG.md atualizados>
```
