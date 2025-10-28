#!/usr/bin/env python3
import psycopg
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report

# Conexión a la base de datos
conn = psycopg.connect("postgresql://app:app_password@localhost:5432/payments")

# Consulta: alumnos con su promedio y riesgo (promedio < 6)
query = """
SELECT id_alumno, promedio,
       CASE WHEN promedio < 6 THEN 1 ELSE 0 END AS en_riesgo
FROM marts.alumnos_en_riesgo
UNION
SELECT id_alumno, promedio,
       0 AS en_riesgo
FROM marts.kpi_materia km
JOIN academico.calificaciones c ON c.id_alumno = km.id_materia
LIMIT 1000;
"""

df = pd.read_sql(query, conn)
conn.close()

# Separar variables
X = df[["promedio"]]
y = df["en_riesgo"]

# Entrenamiento
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

# Reporte
print(classification_report(y_test, y_pred))
