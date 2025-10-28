-- Esquema académico (tablas principales + particiones e índices)

-- Catálogos
CREATE TABLE IF NOT EXISTS academico.maestros (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  especialidad TEXT
);

CREATE TABLE IF NOT EXISTS academico.alumnos (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  edad INT CHECK (edad > 0),
  genero CHAR(1) CHECK (genero IN ('M','F'))
);

CREATE TABLE IF NOT EXISTS academico.materias (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  creditos INT CHECK (creditos > 0)
);

-- Grupos por periodo, particionado por LIST
CREATE TABLE IF NOT EXISTS academico.grupos (
  id SERIAL PRIMARY KEY,
  id_materia INT NOT NULL REFERENCES academico.materias(id),
  id_maestro INT NOT NULL REFERENCES academico.maestros(id),
  periodo TEXT NOT NULL,                   -- p.ej. 2024A, 2024B
  fecha_inicio DATE DEFAULT CURRENT_DATE
) PARTITION BY LIST (periodo);

-- Particiones iniciales
CREATE TABLE IF NOT EXISTS academico.grupos_2024A
  PARTITION OF academico.grupos FOR VALUES IN ('2024A');
CREATE TABLE IF NOT EXISTS academico.grupos_2024B
  PARTITION OF academico.grupos FOR VALUES IN ('2024B');

-- Inscripciones
CREATE TABLE IF NOT EXISTS academico.inscripciones (
  id SERIAL PRIMARY KEY,
  id_alumno INT NOT NULL REFERENCES academico.alumnos(id),
  id_grupo INT NOT NULL REFERENCES academico.grupos(id),
  fecha_inscripcion DATE DEFAULT CURRENT_DATE
);

-- Calificaciones 
CREATE TABLE IF NOT EXISTS academico.calificaciones (
  id SERIAL PRIMARY KEY,
  id_alumno INT NOT NULL REFERENCES academico.alumnos(id),
  id_grupo INT NOT NULL REFERENCES academico.grupos(id),
  calificacion NUMERIC(4,2) CHECK (calificacion BETWEEN 0 AND 10),
  fecha_registro DATE DEFAULT CURRENT_DATE,
  UNIQUE(id_alumno, id_grupo)
);

-- Índices de apoyo
CREATE INDEX IF NOT EXISTS idx_insc_grupo   ON academico.inscripciones(id_grupo);
CREATE INDEX IF NOT EXISTS idx_insc_alumno  ON academico.inscripciones(id_alumno);
CREATE INDEX IF NOT EXISTS idx_calif_grupo  ON academico.calificaciones(id_grupo);
CREATE INDEX IF NOT EXISTS idx_calif_alumno ON academico.calificaciones(id_alumno);
CREATE INDEX IF NOT EXISTS idx_grupos_periodo ON academico.grupos(periodo);
CREATE INDEX IF NOT EXISTS idx_grupos_materia ON academico.grupos(id_materia);
