-- scripts/seed.sql
-- Datos básicos para inicializar entorno de pruebas académicas

INSERT INTO academico.maestros(nombre, especialidad)
SELECT 'Maestro ' || g, CASE WHEN random() < 0.5 THEN 'Matemáticas' ELSE 'Historia' END
FROM generate_series(1,20) g;

INSERT INTO academico.materias(nombre, creditos)
SELECT 'Materia ' || g, (random()*9+1)::int
FROM generate_series(1,10) g;

INSERT INTO academico.alumnos(nombre, edad, genero)
SELECT 'Alumno ' || g, (random()*10+18)::int,
       CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END
FROM generate_series(1,1000) g;
