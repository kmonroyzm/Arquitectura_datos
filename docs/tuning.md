# Tuning y optimización

Parámetros considerados para mejorar el rendimiento del sistema.

## PostgreSQL
- `shared_buffers = 256MB`
- `work_mem = 4MB`
- `maintenance_work_mem = 64MB`
- Índices en columnas clave (`id_alumno`, `id_grupo`).

## Python ETL
- Inserciones en batch para reducir commits.
- Prefetch controlado de RabbitMQ (`prefetch_count=20`).
- Métricas Prometheus optimizadas con histogramas para latencia.

## Docker
- Límites de memoria definidos en `docker-compose.yml`.
- Variables de entorno configurables mediante `.env`.
