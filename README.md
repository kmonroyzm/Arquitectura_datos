# Arquitectura_datos — Prueba Técnica (Académico)

Proyecto de arquitectura de datos reproducible con **PostgreSQL**, **RabbitMQ**, **Python (ETL)**, **Prometheus** y **Grafana**.  
Incluye flujo completo de ingestión, transformación, métricas de observabilidad y vistas analíticas (marts).

---

## 1. Ejecución del entorno

Para ejecutar el entorno en una máquina local con Docker instalado:

```bash
cp .env.example .env
bash scripts/bootstrap.sh
```

Servicios disponibles:
- **Grafana:** http://localhost:3000  
- **Prometheus:** http://localhost:9090  
- **RabbitMQ Management:** http://localhost:15672  
- **PostgreSQL:** localhost:5432  
  - Usuario: `app`  
  - Contraseña: `app_password`  
  - Base de datos: `payments`
---

## 2. Estructura del proyecto

---

## 3. Flujo de procesamiento

1. **Ingesta:** mensajes JSON publicados en RabbitMQ (`alumno`, `inscripcion`, `calificacion`).  
2. **Validación:** `worker.py` valida el contenido con Pydantic y lo inserta en tablas `stg.*`.  
3. **Transformación:** funciones SQL (`merge_*`) consolidan los datos en el esquema `academico`.  
4. **Agregación:** vistas y materialized views en `marts.*` calculan KPIs académicos.  
5. **Monitoreo:** Prometheus recolecta métricas del ETL y RabbitMQ; Grafana visualiza paneles.  
6. **Calidad de datos:** reglas de DQ registran inconsistencias en `core.dq_results`.

---

## 4. Consultas de validación

Ejemplos de consultas SQL para verificar la carga de datos y los KPIs generados por los marts:

```sql
SELECT COUNT(*) FROM academico.alumnos;
SELECT * FROM marts.kpi_materia LIMIT 10;
SELECT * FROM marts.ranking_maestros LIMIT 10;
SELECT * FROM marts.alumnos_en_riesgo LIMIT 10;

