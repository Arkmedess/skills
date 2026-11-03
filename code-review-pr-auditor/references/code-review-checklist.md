# Checklist de Engenharia para Revisão de Pull Requests / Diffs

## 1. Integridade Lógica e Casos de Borda
- [ ] Os fluxos de erro e exceções tratam adequadamente retornos nulos, coleções vazias e timeouts?
- [ ] Há potenciais condições de corrida (*race conditions*) ou estado compartilhado mutável?
- [ ] A lógica implementada atende estritamente à especificação da issue sem escopo excessivo (*scope creep*)?

---

## 2. Clean Code & Legibilidade
- [ ] Os nomes de variáveis, métodos e tipos revelam sua intenção clara e eliminam a necessidade de comentários narrativos?
- [ ] As funções são pequenas e respeitam o Nível Único de Abstração (SLA), sem misturar orquestração com detalhes de formatação/IO?
- [ ] Não há passagem de *flag arguments* (booleanos que bifurcam o comportamento interno de funções)?
- [ ] Foi respeitada a Lei de Demeter, evitando navegações profundas em estruturas de terceiros (`a.b().c().d()`)?
- [ ] Não há resíduos de código morto, logs não estruturados (`print`, `console.log`) ou comentários obsoletos?

---

## 3. Conformidade com Princípios SOLID
- [ ] **SRP:** Cada classe ou módulo alterado possui apenas uma razão para mudar?
- [ ] **OCP:** Extensões de regras foram implementadas via composição/polimorfismo/estratégias em vez de cadeias crescentes de `if/else` no código legado?
- [ ] **LSP:** As classes derivadas ou implementações de interfaces honram os contratos base sem lançar exceções inesperadas (`NotImplementedException`) ou enfraquecer pós-condições?
- [ ] **ISP:** As interfaces são enxutas e focadas no cliente, sem obrigar implementações dummy (no-op)?
- [ ] **DIP:** Classes de negócio dependem de abstrações (interfaces/portas) injetadas e não instanciam diretamente conexões, SDKs ou clientes de I/O?

---

## 4. Design Patterns vs. Sobre-Engenharia (Anti-Patternitis)
- [ ] Padrões de design aplicados (GoF: Strategy, Adapter, Decorator, Builder, etc.) resolvem problemas reais de variação ou isolamento?
- [ ] Foi aplicado YAGNI? Foi evitada a introdução de camadas artificiais de indireção (fábricas de fábricas, interfaces com implementação única sem previsão de variação)?

---

## 5. Compatibilidade e Retrocompatibilidade
- [ ] Contratos de API pública, interfaces ou endpoints existentes foram mantidos ou versionados adequadamente?
- [ ] Há alterações em schemas de banco ou mensagens de fila que exijam estratégia de dupla escrita (*Expand and Contract*)?
- [ ] Flags de configuração ou variáveis de ambiente foram documentadas com valores default seguros?

---

## 6. Qualidade da Suíte de Testes Associada
- [ ] O PR adicionou testes que cobrem os novos caminhos lógicos ou apenas código de produção?
- [ ] Os testes exercitam regras de negócio ou são asserções fracas/tautológicas?
- [ ] Existem sleeps ou esperas artificiais nos testes que introduzam flakiness?

