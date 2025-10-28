#!/usr/bin/env bash
set -euo pipefail

echo "[+] Publicando mensajes de ejemplo en la cola 'etl'..."
# Usa la variable RABBIT_URL si está definida; si no, asume localhost.
export RABBIT_URL="${RABBIT_URL:-amqp://guest:guest@localhost:5672/}"

python scripts/send_academico.py 1000 3000 5000

echo "[✓] Mensajes publicados. Verifica en RabbitMQ Management (http://localhost:15672)."
