CREATE SCHEMA IF NOT EXISTS stg;

CREATE TABLE IF NOT EXISTS stg.alumnos_upsert(
  id_alumno int, nombre text, edad int, genero char(1) CHECK (genero IN ('M','F')),
  ts_ingesta timestamptz DEFAULT now()
);
CREATE TABLE IF NOT EXISTS stg.inscripciones_event(
  id_alumno int, id_grupo int, fecha_inscripcion date, ts_ingesta timestamptz DEFAULT now()
);
CREATE TABLE IF NOT EXISTS stg.calificaciones_event(
  id_alumno int, id_grupo int, calificacion numeric(4,2) CHECK (calificacion BETWEEN 0 AND 10),
  fecha_registro date, ts_ingesta timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stg_alumnos_upsert ON stg.alumnos_upsert(id_alumno);
CREATE INDEX IF NOT EXISTS idx_stg_insc_event    ON stg.inscripciones_event(id_alumno, id_grupo);
CREATE INDEX IF NOT EXISTS idx_stg_calif_event   ON stg.calificaciones_event(id_alumno, id_grupo);

CREATE OR REPLACE FUNCTION academico.merge_alumnos() RETURNS int LANGUAGE plpgsql AS $$
DECLARE v int; BEGIN
  INSERT INTO academico.alumnos(id, nombre, edad, genero)
  SELECT id_alumno, nombre, edad, genero FROM stg.alumnos_upsert
  ON CONFLICT (id) DO UPDATE SET nombre=EXCLUDED.nombre, edad=EXCLUDED.edad, genero=EXCLUDED.genero;
  GET DIAGNOSTICS v = ROW_COUNT; TRUNCATE stg.alumnos_upsert; RETURN v; END $$;

CREATE OR REPLACE FUNCTION academico.merge_inscripciones() RETURNS int LANGUAGE plpgsql AS $$
DECLARE v int; BEGIN
  INSERT INTO academico.inscripciones(id_alumno, id_grupo, fecha_inscripcion)
  SELECT e.id_alumno, e.id_grupo, COALESCE(e.fecha_inscripcion, CURRENT_DATE)
  FROM stg.inscripciones_event e
  LEFT JOIN academico.inscripciones i ON i.id_alumno=e.id_alumno AND i.id_grupo=e.id_grupo
  WHERE i.id IS NULL;
  GET DIAGNOSTICS v = ROW_COUNT; TRUNCATE stg.inscripciones_event; RETURN v; END $$;

CREATE OR REPLACE FUNCTION academico.merge_calificaciones() RETURNS int LANGUAGE plpgsql AS $$
DECLARE v int; BEGIN
  INSERT INTO academico.calificaciones(id_alumno,id_grupo,calificacion,fecha_registro)
  SELECT id_alumno,id_grupo,calificacion,COALESCE(fecha_registro,CURRENT_DATE)
  FROM stg.calificaciones_event
  ON CONFLICT (id_alumno,id_grupo) DO UPDATE
    SET calificacion=EXCLUDED.calificacion, fecha_registro=EXCLUDED.fecha_registro;
  GET DIAGNOSTICS v = ROW_COUNT; TRUNCATE stg.calificaciones_event; RETURN v; END $$;
