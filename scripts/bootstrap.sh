#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Si no hay .env, usa el de ejemplo
[ -f .env ] || cp .env.example .env

echo "[+] Starting services..."
docker compose -f compose/docker-compose.yml up -d

echo "[+] Applying SQL..."
docker exec -i pg psql -U app -d payments < db/00_init.sql
docker exec -i pg psql -U app -d payments < db/academico_schema.sql
docker exec -i pg psql -U app -d payments < db/academico_seed.sql
docker exec -i pg psql -U app -d payments < db/academico_stg_core.sql
docker exec -i pg psql -U app -d payments < db/academico_marts.sql
docker exec -i pg psql -U app -d payments < db/academico_queries.sql || true

echo "[✓] Ready."
