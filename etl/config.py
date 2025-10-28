import os

# Configuración de conexiones
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://app:app_password@postgres:5432/payments"
)

RABBIT_URL = os.getenv(
    "RABBIT_URL",
    "amqp://guest:guest@rabbitmq:5672/"
)

QUEUE_NAME = os.getenv("QUEUE_NAME", "etl")
