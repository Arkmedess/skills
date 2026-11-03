# Padrões de Dockerfile de Produção por Stack

Regras obrigatórias para qualquer imagem de contêiner:
1. **Multi-stage build:** Separar toolchain de compilação da imagem de execução.
2. **BuildKit cache mounts:** `--mount=type=cache` para acelerar builds em 10x sem poluir a imagem final.
3. **Usuário não-root (UID 10001):** Nunca rodar como `root` em produção.
4. **`.dockerignore` estrito:** Bloquear `.git`, `node_modules`, `.venv`, `target/`, testes e arquivos de segredos.
5. **Healthcheck nativo:** Com timeout, retries e intervalo curtos.

---

## 1. Python (via `uv` e `python:3.13-slim`)

```dockerfile
# syntax=docker/dockerfile:1.7
FROM python:3.13-slim AS builder

WORKDIR /app
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

COPY pyproject.toml uv.lock ./
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-install-project --no-dev

COPY . .
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# --- Stage Final de Produção ---
FROM python:3.13-slim AS runtime

WORKDIR /app
ENV PATH="/app/.venv/bin:$PATH" PYTHONUNBUFFERED=1

RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /bin/false appuser

COPY --from=builder --chown=appuser:appgroup /app/.venv /app/.venv
COPY --from=builder --chown=appuser:appgroup /app/src /app/src

USER 10001:10001
HEALTHCHECK --interval=15s --timeout=3s --retries=3 --start-period=5s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')" || exit 1

ENTRYPOINT ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## 2. Rust (via `cargo-chef` e imagem `distroless/cc-debian12`)

```dockerfile
# syntax=docker/dockerfile:1.7
FROM rust:1.85-slim AS planner
WORKDIR /app
RUN cargo install cargo-chef
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM rust:1.85-slim AS builder
WORKDIR /app
RUN cargo install cargo-chef
COPY --from=planner /app/recipe.json recipe.json
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo chef cook --release --recipe-path recipe.json

COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release --bin server && \
    cp /app/target/release/server /app/server

# --- Stage Final de Produção ---
FROM gcr.io/distroless/cc-debian12:nonroot
WORKDIR /app
COPY --from=builder /app/server /app/server
USER nonroot:nonroot
ENTRYPOINT ["/app/server"]
```

---

## 3. Go (Binário estático com imagem `scratch`)

```dockerfile
# syntax=docker/dockerfile:1.7
FROM golang:1.24-alpine AS builder
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app/server ./cmd/server

# --- Stage Final ---
FROM scratch
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /app/server /server
USER 10001:10001
ENTRYPOINT ["/server"]
```

---

## 4. Node / TypeScript (Next.js Standalone com `node:22-slim`)

```dockerfile
# syntax=docker/dockerfile:1.7
FROM node:22-slim AS base
WORKDIR /app
ENV PNPM_HOME="/pnpm" PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS builder
COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM node:22-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup --system --gid 10001 nodejs && adduser --system --uid 10001 nextjs
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public
USER 10001:10001
HEALTHCHECK --interval=15s --timeout=3s CMD node -e "fetch('http://localhost:3000/api/health').then(r => r.ok ? process.exit(0) : process.exit(1))"
CMD ["node", "server.js"]
```

---

## 5. PHP 8.4 / Laravel 12 (Multi-stage com Composer, Vite e FrankenPHP / Octane)

```dockerfile
# syntax=docker/dockerfile:1.7
FROM composer:2.8 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN --mount=type=cache,target=/tmp/cache \
    composer install --no-dev --no-scripts --no-interaction --prefer-dist --optimize-autoloader

FROM node:22-slim AS assets
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY resources/ ./resources/
COPY vite.config.* ./
RUN npm run build

FROM dunglas/frankenphp:1-php8.4-alpine AS runtime
WORKDIR /app
ENV APP_ENV=production \
    PHP_OPCACHE_ENABLE=1 \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0

RUN addgroup -g 10001 appgroup && adduser -u 10001 -G appgroup -D -s /sbin/nologin appuser

COPY --chown=appuser:appgroup . .
COPY --from=vendor --chown=appuser:appgroup /app/vendor ./vendor
COPY --from=assets --chown=appuser:appgroup /app/public/build ./public/build

RUN chown -R appuser:appgroup /app/storage /app/bootstrap/cache

USER 10001:10001
HEALTHCHECK --interval=15s --timeout=3s --retries=3 --start-period=10s \
    CMD php -r "exit(@file_get_contents('http://127.0.0.1:8000/up') === false ? 1 : 0);"

ENTRYPOINT ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=8000"]
```
