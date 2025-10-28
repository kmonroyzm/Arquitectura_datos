from prometheus_client import Counter, Histogram, start_http_server

# Contadores del worker
messages_processed = Counter("worker_messages_processed_total", "Total processed messages")
messages_failed    = Counter("worker_messages_failed_total", "Total failed messages")
latency_seconds    = Histogram("worker_message_latency_seconds", "Latency per message")

def serve_metrics(port: int = 8000):
    """Exponer /metrics en el puerto indicado."""
    start_http_server(port)
