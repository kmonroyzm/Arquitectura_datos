# Estrategia de alertamiento

Reglas de monitoreo configuradas en Prometheus y visualizadas en Grafana.

## Tipos de alertas

- **WorkerDown:** el proceso ETL no responde por más de 2 minutos.  
- **HighErrorRate:** la tasa de errores supera el 5 % durante 5 minutos.  
- **RabbitLagHigh:** más de 1000 mensajes pendientes en la cola ETL.  
- **PostgresHighConnections:** más de 120 conexiones activas a la base de datos.

## Severidad

- **Critical:** notificación inmediata a los responsables del sistema.  
- **Warning:** requiere revisión programada.  
- **Info:** seguimiento de métricas no críticas.

## Integración

Estas alertas se pueden integrar con canales de notificación externos (correo, Slack o Webhooks) mediante la configuración de Prometheus Alertmanager.
