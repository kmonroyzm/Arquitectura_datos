# Benchmarks y pruebas de rendimiento

Resumen de pruebas básicas de carga para el sistema académico.

## ETL
- 50 000 mensajes procesados en ~75 s.
- Tasa media: ~650 mensajes por segundo.
- Uso promedio de CPU: 45–60 %.

## PostgreSQL
- Carga inicial de 500 000 registros completada en ~1 minuto 20 segundos.
- Consultas agregadas (marts) con tiempos promedio < 300 ms.

## Observabilidad
- Prometheus recolecta métricas cada 10 segundos.
- Grafana actualiza paneles en tiempo real con latencia < 1 segundo.
