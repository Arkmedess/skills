# Matriz de build determinístico por stack

## .NET
- Lockfile: `packages.lock.json` (`dotnet restore --locked-mode`).
- Runtime final: imagem `aspnet` ou, para APIs mínimas/AOT, `mcr.microsoft.com/dotnet/runtime-deps` (distroless/chainguard quando aplicável).
- Multi-stage: `sdk` para build/publish → `runtime`/`aspnet` só com o output publicado.

## Python
- Lockfile: `uv.lock` ou `poetry.lock`, instalar com `uv sync --frozen` / `poetry install --no-root --sync`.
- Runtime final: `python:X-slim` (evitar `-alpine` se houver dependências com extensão C sem wheel musl).
- Multi-stage: estágio de build compila wheels, estágio final só copia o virtualenv/site-packages resolvido.

## Node / Next.js
- Lockfile: `pnpm-lock.yaml`/`package-lock.json`, instalar com `--frozen-lockfile`/`npm ci`.
- Runtime final: `node:X-slim`, usar `output: "standalone"` do Next.js para minimizar `node_modules` copiado.

## Flutter (build de app, não de imagem de servidor)
- Lockfile: `pubspec.lock` versionado, `flutter pub get --enforce-lockfile`.
- CI: `flutter analyze` + `flutter test` antes de `flutter build`.

## Rust
- Lockfile: `Cargo.lock` versionado sempre (mesmo em bibliotecas, para builds reprodutíveis do workspace).
- Cache: `cargo-chef` para separar cache de dependências do cache de código próprio.
- Runtime final: `scratch` (binário estático, musl) ou `distroless/cc-debian` (binário dinâmico glibc).

## PHP / Laravel 12
- Lockfile: `composer.lock` versionado; instalar com `composer install --no-dev --prefer-dist --no-interaction --no-progress --optimize-autoloader --classmap-authoritative`.
- Assets Frontend (Vite): compilados em estágio Node isolado (`npm ci && npm run build`) e copiados para `public/build`.
- Runtime final: `dunglas/frankenphp` (com **Laravel Octane**) ou `php:8.4-fpm-alpine` não-root com `opcache.validate_timestamps=0` em produção e aquecimento no boot (`php artisan optimize`).

## Banco de dados / migrações (qualquer stack)
- Migrações versionadas e aplicadas em etapa própria do CI/CD (nunca `migrate` implícito no boot da aplicação em produção).
