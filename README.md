# Arquitectura_datos — Prueba Técnica (Académico)

Proyecto de arquitectura de datos reproducible con **PostgreSQL**, **RabbitMQ**, **Python (ETL)**, **Prometheus** y **Grafana**.  
Incluye flujo completo de ingestión, transformación, métricas de observabilidad y vistas analíticas (marts).

---

## 1. Ejecución del entorno

Para ejecutar el entorno en una máquina local con Docker instalado:

```bash
cp .env.example .env
bash scripts/bootstrap.sh

