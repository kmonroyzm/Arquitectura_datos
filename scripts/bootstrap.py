#!/usr/bin/env python3
import os
import subprocess

print("[+] Inicializando entorno Docker...")

# Levantar los contenedores
os.system("docker compose -f compose/docker-compose.yml up -d")

print("[+] Ejecutando scripts de base de datos...")

scripts = [
    "00_init.sql",
    "academico_schema.sql",
    "academico_seed.sql",
    "academico_stg_core.sql",
    "academico_marts.sql",
    "academico_queries.sql"
]

for script in scripts:
    print(f"    → Ejecutando {script}")
    subprocess.run([
        "docker", "exec", "-i", "pg",
        "psql", "-U", "app", "-d", "payments",
        "-f", f"db/{script}"
    ])

print("[✓] Inicialización completada con éxito.")
