CREATE SCHEMA IF NOT EXISTS marts;

CREATE OR REPLACE VIEW marts.kpi_grupo AS
SELECT g.id AS id_grupo, g.periodo, m.nombre AS materia, pr.nombre AS profesor,
       count(DISTINCT i.id_alumno) AS alumnos_inscritos,
       round(avg(c.calificacion)::numeric,2) AS promedio
FROM academico.grupos g
JOIN academico.materias m ON m.id=g.id_materia
JOIN academico.maestros pr ON pr.id=g.id_maestro
LEFT JOIN academico.inscripciones i ON i.id_grupo=g.id
LEFT JOIN academico.calificaciones c ON c.id_grupo=g.id
GROUP BY 1,2,3,4;

CREATE MATERIALIZED VIEW IF NOT EXISTS marts.kpi_materia AS
SELECT m.id AS id_materia, m.nombre,
       round(avg(c.calificacion)::numeric,2) AS promedio,
       (sum(CASE WHEN c.calificacion>=6 THEN 1 ELSE 0 END)::numeric / NULLIF(count(c.*),0)) AS tasa_aprob
FROM academico.materias m
LEFT JOIN academico.grupos g ON g.id_materia=m.id
LEFT JOIN academico.calificaciones c ON c.id_grupo=g.id
GROUP BY 1,2;

CREATE INDEX IF NOT EXISTS idx_kpi_materia ON marts.kpi_materia(id_materia);
