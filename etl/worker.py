import json, time, psycopg, pika
from contextlib import contextmanager
from pydantic import BaseModel, Field, ValidationError, condecimal, conint, constr
from metrics import messages_processed, messages_failed, latency_seconds, serve_metrics
import config

# ====== Modelos de validación ======
class AlumnoMsg(BaseModel):
    entity: constr(strip_whitespace=True, to_lower=True) = "alumno"
    id_alumno: conint(gt=0)
    nombre: str
    edad: conint(gt=0)
    genero: constr(strip_whitespace=True)  # 'M'/'F'

class InscripcionMsg(BaseModel):
    entity: str = "inscripcion"
    id_alumno: conint(gt=0)
    id_grupo: conint(gt=0)
    fecha_inscripcion: str | None = None  # ISO date opcional

class CalificacionMsg(BaseModel):
    entity: str = "calificacion"
    id_alumno: conint(gt=0)
    id_grupo: conint(gt=0)
    calificacion: condecimal(ge=0, le=10, max_digits=4, decimal_places=2)
    fecha_registro: str | None = None

@contextmanager
def pg_conn():
    with psycopg.connect(config.DATABASE_URL) as conn:
        yield conn

def ensure_db():
    with pg_conn() as conn:
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")

# ====== Inserts en STAGING ======
def stg_upsert_alumno(conn, m: AlumnoMsg):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO stg.alumnos_upsert(id_alumno,nombre,edad,genero)
            VALUES (%s,%s,%s,%s)
        """, (m.id_alumno, m.nombre, int(m.edad), m.genero))
    conn.commit()

def stg_append_inscripcion(conn, m: InscripcionMsg):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO stg.inscripciones_event(id_alumno,id_grupo,fecha_inscripcion)
            VALUES (%s,%s,%s::date)
        """, (m.id_alumno, m.id_grupo, m.fecha_inscripcion))
    conn.commit()

def stg_append_calificacion(conn, m: CalificacionMsg):
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO stg.calificaciones_event(id_alumno,id_grupo,calificacion,fecha_registro)
            VALUES (%s,%s,%s,%s::date)
        """, (m.id_alumno, m.id_grupo, str(m.calificacion), m.fecha_registro))
    conn.commit()

# ====== MERGE a core (funciones SQL) ======
def run_merges(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT academico.merge_alumnos();")
        cur.execute("SELECT academico.merge_inscripciones();")
        cur.execute("SELECT academico.merge_calificaciones();")
    conn.commit()

def main():
    # métricas Prometheus
    serve_metrics(8000)
    ensure_db()

    # conexión y cola
    rb = pika.BlockingConnection(pika.URLParameters(config.RABBIT_URL))
    ch = rb.channel()
    ch.queue_declare(queue=config.QUEUE_NAME, durable=True)
    ch.basic_qos(prefetch_count=20)

    def handle(ch, method, props, body):
        start = time.time()
        try:
            payload = json.loads(body.decode("utf-8"))
            entity = str(payload.get("entity","")).lower()
            with pg_conn() as conn:
                if entity == "alumno":
                    stg_upsert_alumno(conn, AlumnoMsg(**payload))
                elif entity == "inscripcion":
                    stg_append_inscripcion(conn, InscripcionMsg(**payload))
                elif entity == "calificacion":
                    stg_append_calificacion(conn, CalificacionMsg(**payload))
                else:
                    raise ValueError(f"Unknown entity: {entity}")
                run_merges(conn)

            messages_processed.inc()
            ch.basic_ack(delivery_tag=method.delivery_tag)

        except (ValidationError, Exception) as e:
            messages_failed.inc()
            with open("/app/dlq.txt","a",encoding="utf-8") as f:
                f.write(json.dumps({"error":str(e), "body":body.decode('utf-8')})+"\n")
            ch.basic_ack(delivery_tag=method.delivery_tag)
        finally:
            latency_seconds.observe(time.time() - start)

    ch.basic_consume(queue=config.QUEUE_NAME, on_message_callback=handle)
    print("[worker] waiting messages (alumno/inscripcion/calificacion)...")
    ch.start_consuming()

if __name__ == "__main__":
    main()
