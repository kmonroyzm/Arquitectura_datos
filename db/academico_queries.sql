CREATE OR REPLACE VIEW marts.materia_periodo_stats AS
SELECT g.periodo, m.id AS id_materia, m.nombre AS materia,
       ROUND(AVG(c.calificacion)::numeric,2) AS promedio,
       (SUM(CASE WHEN c.calificacion>=6 THEN 1 ELSE 0 END)::numeric / NULLIF(COUNT(c.*),0)) AS tasa_aprob
FROM academico.grupos g
JOIN academico.materias m ON m.id=g.id_materia
LEFT JOIN academico.calificaciones c ON c.id_grupo=g.id
GROUP BY 1,2,3;

CREATE OR REPLACE FUNCTION marts.top_materias(periodo_in TEXT, n INT DEFAULT 10)
RETURNS TABLE(periodo TEXT, id_materia INT, materia TEXT, promedio numeric, tasa_aprob numeric)
LANGUAGE sql AS $$
  SELECT periodo, id_materia, materia, promedio, tasa_aprob
  FROM marts.materia_periodo_stats WHERE periodo=periodo_in
  ORDER BY promedio DESC NULLS LAST, tasa_aprob DESC NULLS LAST
  LIMIT n;
$$;

CREATE OR REPLACE VIEW marts.ranking_maestros AS
SELECT pr.id AS id_maestro, pr.nombre AS maestro,
       ROUND(AVG(c.calificacion)::numeric,2) AS promedio, COUNT(c.*) AS evaluaciones
FROM academico.maestros pr
LEFT JOIN academico.grupos g ON g.id_maestro=pr.id
LEFT JOIN academico.calificaciones c ON c.id_grupo=g.id
GROUP BY 1,2 HAVING COUNT(c.*)>=30
ORDER BY promedio DESC NULLS LAST, evaluaciones DESC;

CREATE OR REPLACE VIEW marts.alumnos_en_riesgo AS
WITH cp AS (
  SELECT c.id_alumno, g.periodo, AVG(c.calificacion) AS prom
  FROM academico.calificaciones c JOIN academico.grupos g ON g.id=c.id_grupo
  GROUP BY 1,2
)
SELECT cp.periodo, a.id AS id_alumno, a.nombre, ROUND(cp.prom::numeric,2) AS promedio
FROM cp JOIN academico.alumnos a ON a.id=cp.id_alumno
WHERE cp.prom < 6
ORDER BY cp.periodo, promedio ASC;
