# Estrategia de respaldo y restauración

Procedimiento básico para la recuperación del sistema académico.

## Respaldos

- El volumen Docker `pg_data` garantiza la persistencia de datos de PostgreSQL.  
- También se recomienda una exportación periódica con `pg_dump`:

```bash
docker exec pg pg_dump -U app -d payments > backups/backup_$(date +%F).sql
