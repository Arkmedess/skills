# Técnicas Sistemáticas de Depuração e Rastreamento de Bugs

## 1. Localização de Regressões via Git Bisect
Quando um comportamento funcionava anteriormente e quebrou em commits recentes:

```shell
# Iniciar o processo interativo
git bisect start

# Marcar o commit atual como quebrado
git bisect bad

# Marcar o último commit sabidamente funcional
git bisect good <commit-sha>

# Executar bisect automatizado por teste
git bisect run pytest tests/test_regression.py
# (ou dotnet test, cargo test, npm test)

# Ao finalizar, retornar ao branch original
git bisect reset
```

---

## 2. Inspeção Analítica de Stacktraces
1. **Identificar o Ponto de Entrada Real:** Ignore frames de bibliotecas de terceiros ou wrappers internos do framework até encontrar o último frame de código proprietário do projeto.
2. **Avaliar Exceções Aninhadas / Causas Raiz:** Verifique blocos `Caused by` ou exceções suprimidas (muitas vezes a causa real está na base da pilha).
3. **Mapeamento de Estado e Parâmetros:** Analisar quais argumentos de entrada eram `null`, vazios ou fora do domínio no momento do estouro da exceção.

---

## 3. Isolamento de Estado Efêmero e Concorrência
- **Race Conditions:** Se a falha for intermitente, audite acessos concorrentes sem locks, uso de coleções thread-unsafe ou assincronia sem `await` adequado.
- **Vazamento de Recursos:** Checar conexões ou file descriptors abertos que não atingem blocos `finally`/`using`/`with`.
