from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import time
import psutil
import threading

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/suggest")
def get_suggestions():
    # Simulate a tiny bit of processing
    time.sleep(0.01)
    return {
        "status": "success",
        "items": [
            {"id": 1, "name": "Producto Relacionado A"},
            {"id": 2, "name": "Producto Relacionado B"}
        ]
    }

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

@app.get("/api/cpu")
def get_cpu():
    # Retorno instantáneo (sin sleeps que bloqueen FastAPI)
    return {"cpu": current_cpu_metric}
