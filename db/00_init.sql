-- 00_init.sql  |  Inicialización  la BD
-- Extensiones 
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Esquemas base
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS marts;
CREATE SCHEMA IF NOT EXISTS academico;

-- Bitácora simple de corridas ETL
CREATE TABLE IF NOT EXISTS core.etl_run_log(
  run_id bigserial PRIMARY KEY,
  started_at timestamptz DEFAULT now(),
  finished_at timestamptz,
  status text,
  processed_count int DEFAULT 0,
  error_count int DEFAULT 0
);

-- Resultados de Data Quality 
CREATE TABLE IF NOT EXISTS core.dq_results (
  id bigserial PRIMARY KEY,
  check_name text NOT NULL,
  schema_name text,
  table_name text,
  passed boolean,
  details text,
  check_time timestamptz DEFAULT now()
);
