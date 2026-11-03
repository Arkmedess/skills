# Idiomas de tipagem, imutabilidade e erro por stack

Referência consultada por `vertical-slice-implementer` antes de implementar em uma stack pouco familiar. Não é exaustivo — sirva como ponto de partida e ajuste ao que já é convenção no repositório.

## C# / .NET
- Imutabilidade: `record`/`record struct`, propriedades `init`.
- Erros de domínio: padrão `Result<T>`/`OneOf<T,Error>` para falhas esperadas; exceções reservadas para falhas de infraestrutura.
- Nulidade: nullable reference types habilitado (`<Nullable>enable</Nullable>`), sem `!` de supressão fora de testes.

## Python
- Imutabilidade: `@dataclass(frozen=True)` ou `NamedTuple`/`attrs(frozen=True)`.
- Tipagem: type hints estritos, `mypy --strict` ou `pyright` no CI.
- Erros de domínio: tipos de retorno explícitos (união `Ok | Err`, ou exceções customizadas tipadas por domínio — nunca `Exception` genérica).

## Dart / Flutter
- Imutabilidade: classes `freezed` com `copyWith`, `sealed class`/`enum` exaustivo para estados.
- Erros de domínio: `sealed class Failure` por feature, tratado exaustivamente no `switch`.

## TypeScript / Next.js
- Imutabilidade: `readonly`, `as const`, evitar mutação de props/estado.
- Erros de domínio: união discriminada (`{ ok: true, data } | { ok: false, error }`), `zod`/`valibot` para validação de fronteira (API routes, forms).

## Rust
- Modelagem orientada a tipos: `enum` exaustivo, newtypes para invariantes (`UserId(Uuid)` em vez de `Uuid` cru).
- Erros de domínio: `thiserror` por camada, `Result<T, E>` propagado com `?`, evitar `.unwrap()`/`.clone()` fora de testes.

## PHP 8.3+ / Laravel 12
- Tipagem estrita: `declare(strict_types=1);` obrigatório no topo de todo arquivo PHP; tipagem explícita de parâmetros, propriedades e retornos, complementada por PHPDoc genérico (`/** @return Collection<int, InvoiceData> */`) validado no Larastan/PHPStan (nível 8+).
- Imutabilidade & DTOs: classes `final readonly class` para DTOs/Value Objects (ou `spatie/laravel-data`) e `enum` nativo (*Backed Enums* `enum InvoiceStatus: string`) mapeado via método `casts(): array` nos Models do Laravel 12.
- Arquitetura de Fatia (Actions & Controllers Enxutos):
  - Controllers de ação única (`__invoke`) ou restritos aos 7 verbos RESTful (`arch()->preset()->laravel()`), delegando validação de entrada para `FormRequest` (`$request->validated()`) e regra de negócio para classes `Action` coesas (`CreateInvoiceAction::execute(CreateInvoiceData $data)`).
  - Respostas padronizadas com `JsonResource` / `ResourceCollection` para desacoplar o schema do banco (Eloquent) do contrato público da API.
  - Em aplicações com **Laravel Octane (FrankenPHP / Swoole / RoadRunner)**, proibido armazenar estado mutável da requisição em propriedades estáticas ou singletons registrados no Service Container.
