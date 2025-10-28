-- Datos sintéticos para pruebas (escala razonable)

-- Maestros (100)
INSERT INTO academico.maestros(nombre, especialidad)
SELECT 'Maestro ' || g,
       CASE WHEN random() < 0.5 THEN 'Matemáticas' ELSE 'Historia' END
FROM generate_series(1,100) g;

-- Materias (50)
INSERT INTO academico.materias(nombre, creditos)
SELECT 'Materia ' || g, (random()*9+1)::int
FROM generate_series(1,50) g;

-- Alumnos (50,000 aprox.)
INSERT INTO academico.alumnos(nombre, edad, genero)
SELECT 'Alumno ' || g,
       (random()*10+18)::int,
       CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END
FROM generate_series(1,50000) g;

-- Grupos (500) repartidos entre 2024A y 2024B
INSERT INTO academico.grupos(id_materia, id_maestro, periodo, fecha_inicio)
SELECT (random()*49+1)::int,
       (random()*99+1)::int,
       CASE WHEN random() < 0.5 THEN '2024A' ELSE '2024B' END,
       CURRENT_DATE - ((random()*60)::int || ' days')::interval
FROM generate_series(1,500) g;

-- Inscripciones (500,000)
INSERT INTO academico.inscripciones(id_alumno, id_grupo, fecha_inscripcion)
SELECT (random()*49999+1)::int,
       (random()*499+1)::int,
       CURRENT_DATE - ((random()*60)::int || ' days')::interval
FROM generate_series(1,500000) g;

-- Calificaciones (1,000,000) coherentes con inscripciones 
INSERT INTO academico.calificaciones(id_alumno, id_grupo, calificacion, fecha_registro)
SELECT i.id_alumno,
       i.id_grupo,
       round(random()*10, 2),
       CURRENT_DATE - ((random()*10)::int || ' days')::interval
FROM academico.inscripciones i
JOIN LATERAL (SELECT 1) x
ON true
LIMIT 1000000;
