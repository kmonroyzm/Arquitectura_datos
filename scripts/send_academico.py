import json, random, os, sys, datetime as dt, pika
N_ALUMNOS=int(sys.argv[1]) if len(sys.argv)>1 else 1000
N_INSC=int(sys.argv[2]) if len(sys.argv)>2 else 3000
N_CALIF=int(sys.argv[3]) if len(sys.argv)>3 else 5000
amqp=os.getenv("RABBIT_URL","amqp://guest:guest@localhost:5672/")
ch=pika.BlockingConnection(pika.URLParameters(amqp)).channel()
ch.queue_declare(queue="etl", durable=True)
def pub(o): ch.basic_publish(exchange="", routing_key="etl", body=json.dumps(o).encode(), properties=pika.BasicProperties(delivery_mode=2))
for i in range(1,N_ALUMNOS+1): pub({"entity":"alumno","id_alumno":i,"nombre":f"Alumno {i}","edad":random.randint(18,30),"genero":"M" if random.random()<0.5 else "F"})
for _ in range(N_INSC): pub({"entity":"inscripcion","id_alumno":random.randint(1,N_ALUMNOS),"id_grupo":random.randint(1,500),"fecha_inscripcion":(dt.date.today()-dt.timedelta(days=random.randint(0,60))).isoformat()})
for _ in range(N_CALIF): pub({"entity":"calificacion","id_alumno":random.randint(1,N_ALUMNOS),"id_grupo":random.randint(1,500),"calificacion":round(random.random()*10,2),"fecha_registro":(dt.date.today()-dt.timedelta(days=random.randint(0,10))).isoformat()})
print("ok"); ch.close()
