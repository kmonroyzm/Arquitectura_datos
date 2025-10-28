FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir pika psycopg[binary] prometheus-client pydantic
COPY config.py metrics.py worker.py /app/
EXPOSE 8000
CMD ["python", "-u", "worker.py"]
