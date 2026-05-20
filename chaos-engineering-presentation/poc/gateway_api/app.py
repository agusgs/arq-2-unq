from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import redis.asyncio as redis
import os
import time
import httpx
import psutil
import threading
import logging
from contextlib import asynccontextmanager

# Configuración de logs
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("gateway")

# Variable global para el CPU y Monitor en Background
current_cpu_metric = 0.0

def cpu_monitor_worker():
    global current_cpu_metric
    interval = 1.0
    try:
        with open("/sys/fs/cgroup/cpu.max", "r") as f:
            max_val, period_val = f.read().split()
        cpu_quota = None if max_val == "max" else float(max_val) / float(period_val)
    except:
        cpu_quota = None

    def read_usage():
        try:
            with open("/sys/fs/cgroup/cpu.stat", "r") as f:
                for line in f:
                    if line.startswith("usage_usec"):
                        return int(line.split()[1])
        except:
            pass
        return 0

    while True:
        if cpu_quota is None:
            current_cpu_metric = psutil.cpu_percent(interval=interval)
        else:
            usage1 = read_usage()
            t1 = time.time()
            time.sleep(interval)
            usage2 = read_usage()
            t2 = time.time()
            
            delta_usage = usage2 - usage1
            delta_time = (t2 - t1) * 1000000
            
            if delta_time > 0:
                percent = (delta_usage / (delta_time * cpu_quota)) * 100.0
                current_cpu_metric = min(100.0, percent)
            else:
                current_cpu_metric = 0.0

# Iniciar el hilo demonio al arrancar
threading.Thread(target=cpu_monitor_worker, daemon=True).start()

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
SUGGESTIONS_URL = os.getenv("SUGGESTIONS_URL", "http://poc_suggestions:8001")

class CircuitBreaker:
    def __init__(self, failure_threshold=3, recovery_timeout=5.0):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.state = "CLOSED"
        self.last_failure_time = 0

    def record_failure(self):
        self.failures += 1
        if self.failures >= self.failure_threshold:
            self.state = "OPEN"
            self.last_failure_time = time.time()

    def record_success(self):
        self.failures = 0
        self.state = "CLOSED"

    def can_request(self):
        if self.state == "CLOSED":
            return True
        if self.state == "OPEN":
            if time.time() - self.last_failure_time > self.recovery_timeout:
                self.state = "HALF_OPEN"
                return True
            return False
        if self.state == "HALF_OPEN":
            return True

# Clase para mantener el estado global de la app (clientes compartidos)
class AppState:
    http_client: httpx.AsyncClient = None
    redis_client: redis.Redis = None
    cb: CircuitBreaker = CircuitBreaker()
    cached_suggestions: list = []

state = AppState()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Inicializar clientes compartidos
    logger.info("Iniciando clientes de infraestructura...")
    state.http_client = httpx.AsyncClient(timeout=0.2)
    state.redis_client = redis.Redis(host=REDIS_HOST, port=6379, db=0, socket_timeout=2.0)
    yield
    # Shutdown: Cerrar clientes
    logger.info("Cerrando clientes de infraestructura...")
    await state.http_client.aclose()
    await state.redis_client.close()

app = FastAPI(lifespan=lifespan)

# Permitir CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/checkout")
async def checkout():
    start_time = time.time()
    response_data = {
        "status": "success",
        "message": "Checkout exitoso",
        "suggestions_status": "ok",
        "suggestions": [],
        "circuit_state": state.cb.state,
        "suggestions_time_ms": 0,
        "db_hits": 0,
        "response_time_ms": 0
    }

    try:
        # Tarea Crítica: Procesar el checkout en Redis
        await state.redis_client.incr("hits")
        hits = await state.redis_client.get("hits")
        response_data["db_hits"] = hits.decode("utf-8") if hits else 0
    except Exception as e:
        logger.error(f"Fallo crítico conectando a Redis: {e}")
        elapsed = time.time() - start_time
        response_data["status"] = "failed"
        response_data["message"] = "Error crítico conectando a la base de datos de compras."
        response_data["db_hits"] = "N/A"
        response_data["response_time_ms"] = round(elapsed * 1000, 2)
        return response_data
    
    # Tarea Secundaria: Obtener sugerencias (Circuit Breaker + Cache)
    if not state.cb.can_request():
        # Fall-fast (Evitamos latencia y salvamos el sistema)
        response_data["suggestions_status"] = "fallback"
        response_data["suggestions"] = state.cached_suggestions
        response_data["circuit_state"] = state.cb.state
        response_data["suggestions_time_ms"] = 0
    else:
        s_start = time.time()
        try:
            resp = await state.http_client.get(f"{SUGGESTIONS_URL}/api/suggest")
            resp.raise_for_status()
            
            # Éxito: Guardamos en caché y marcamos éxito en CB
            state.cb.record_success()
            suggestions_data = resp.json()
            items = suggestions_data.get("items", [])
            state.cached_suggestions = items
            response_data["suggestions"] = items
            response_data["circuit_state"] = state.cb.state
            
        except (httpx.TimeoutException, httpx.HTTPError) as e:
            logger.warning(f"Timeout o error en sugerencias ({type(e).__name__}).")
            state.cb.record_failure()
            response_data["suggestions_status"] = "fallback"
            response_data["suggestions"] = state.cached_suggestions
            response_data["circuit_state"] = state.cb.state
            
        except Exception as e:
            logger.warning(f"Error inesperado: {e}")
            state.cb.record_failure()
            response_data["suggestions_status"] = "fallback"
            response_data["suggestions"] = state.cached_suggestions
            response_data["circuit_state"] = state.cb.state
            
        response_data["suggestions_time_ms"] = round((time.time() - s_start) * 1000, 2)

    elapsed = time.time() - start_time
    response_data["response_time_ms"] = round(elapsed * 1000, 2)
    return response_data

@app.get("/api/cpu")
def get_cpu():
    return {"cpu": current_cpu_metric}

