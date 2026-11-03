# Especificação de Docker Compose de Produção e Staging

Compose files de produção ou staging devem garantir resiliência de processo, contenção de recursos e isolamento de rede.

---

## 1. Exemplo Canônico com Blindagem Completa

```yaml
services:
  db:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: app_db
      POSTGRES_USER_FILE: /run/secrets/db_user
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_user
      - db_password
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app -d app_db"]
      interval: 5s
      timeout: 3s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: "2.0"
          memory: 1024M
    logging:
      driver: "json-file"
      options:
        max-size: "20m"
        max-file: "3"
    networks:
      - backend

  api:
    build:
      context: .
      dockerfile: Dockerfile
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "127.0.0.1:8000:8000" # Nunca bindar 0.0.0.0 direto sem reverse proxy na frente
    environment:
      DATABASE_URL: postgresql://app:secret@db:5432/app_db
    deploy:
      resources:
        limits:
          cpus: "1.0"
          memory: 512M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - backend

secrets:
  db_user:
    file: ./secrets/db_user.txt
  db_password:
    file: ./secrets/db_password.txt

volumes:
  pgdata:

networks:
  backend:
    driver: bridge
```

---

## 2. Checklist de Validação do Compose
- [ ] **Limites de RAM (`memory: 512M`):** Ausência de limites permite que um vazamento de memória derrube o servidor inteiro por OOM Killer.
- [ ] **Rotação de Logs (`max-size: 10m`):** Padrão do Docker é sem limite; um loop de erro pode esgotar o disco em horas.
- [ ] **Chaining de Healthcheck (`condition: service_healthy`):** Impede que a API suba e tente conectar no banco antes das migrações e sockets estarem abertos.
- [ ] **Bind Local (`127.0.0.1:porta`):** Protege contra exposição direta de portas na internet pública sem passar pelo Nginx/Traefik/Cloudflare.
