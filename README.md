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

---

## 5. Consideraciones técnicas

- **Lenguajes:** SQL, Python 3.12  
- **Orquestación:** Docker Compose  
- **Mensajería:** RabbitMQ 3.13  
- **Base de datos:** PostgreSQL 16  
- **Observabilidad:** Prometheus + Grafana  
- **Integridad:** constraints, índices, particiones, auditoría y control de calidad  
- **Escalabilidad:** diseño modular de esquemas (raw → stg → core → marts)


---

## 6. Objetivo

Demostrar el diseño e implementación de una arquitectura de datos robusta y auditable, con componentes de ingesta, transformación, almacenamiento, monitoreo y gobierno de datos.  
El proyecto busca reflejar buenas prácticas de ingeniería de datos aplicadas a un caso académico reproducible en un entorno Docker.

---

## 7. Extensión Machine Learning (opcional)

Como complemento a la arquitectura de datos, se incluye un módulo en la carpeta `ml/` que demuestra cómo utilizar los datos transformados (`marts.*`) para un flujo básico de aprendizaje automático.

El archivo `ml/model_train.py` implementa un ejemplo con **Random Forest Classifier** para identificar alumnos en riesgo académico a partir de su promedio histórico.

### Flujo general:
1. Conexión a la base de datos PostgreSQL.
2. Extracción de datos agregados desde el esquema `marts`.
3. Limpieza y preparación del dataset con `pandas`.
4. Entrenamiento y validación de un modelo con `scikit-learn`.
5. Generación de un reporte de desempeño con métricas de clasificación.

Este módulo ilustra la continuidad natural entre la **arquitectura de datos** y la **aplicación de modelos de machine learning** dentro del mismo entorno.

