import asyncio
import json
import random
import math
from datetime import datetime
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# --- 1. Advanced Metric Generators ---

class MetricGenerator:
    def tick(self):
        raise NotImplementedError

class RandomWalk(MetricGenerator):
    """Organic floating point data (Temp, Weight)"""
    def __init__(self, start, min_v, max_v, volatility, unit):
        self.val = start
        self.min = min_v
        self.max = max_v
        self.vol = volatility
        self.unit = unit
    
    def tick(self):
        change = random.uniform(-self.vol, self.vol)
        self.val += change
        # Wall bounce
        if self.val > self.max: self.val = self.max; self.val -= self.vol
        if self.val < self.min: self.val = self.min; self.val += self.vol
        return {"value": round(self.val, 2), "unit": self.unit}

class VitalSign(MetricGenerator):
    """Heart Rate / SpO2 (Integers with specific behavior)"""
    def __init__(self, start, min_v, max_v, volatility, unit):
        self.val = start
        self.min = min_v
        self.max = max_v
        self.vol = volatility
        self.unit = unit

    def tick(self):
        self.val += random.uniform(-self.vol, self.vol)
        # Clamp
        self.val = max(self.min, min(self.max, self.val))
        return {"value": int(self.val), "unit": self.unit}

class Waveform(MetricGenerator):
    """High Speed Sensor Data (ECG, Accelerometer)"""
    def __init__(self, amplitude, freq, unit):
        self.step = 0
        self.amp = amplitude
        self.freq = freq
        self.unit = unit

    def tick(self):
        self.step += 0.1
        # Simulated sine wave + noise
        val = math.sin(self.step * self.freq) * self.amp
        noise = random.uniform(-self.amp * 0.1, self.amp * 0.1)
        return {"value": round(val + noise, 3), "unit": self.unit}

class GPS(MetricGenerator):
    """Simulates moving in a circle"""
    def __init__(self, lat, lon):
        self.lat = lat
        self.lon = lon
        self.step = 0
    
    def tick(self):
        self.step += 0.05
        # Move in a small circle
        d_lat = math.sin(self.step) * 0.0001
        d_lon = math.cos(self.step) * 0.0001
        return {"value": f"{self.lat + d_lat:.5f}, {self.lon + d_lon:.5f}", "unit": "loc"}

class State(MetricGenerator):
    """Enum states (Sleep, Stress Levels)"""
    def __init__(self, states):
        self.states = states
        self.current = states[0]
    
    def tick(self):
        if random.random() < 0.02: # Low chance to switch
            self.current = random.choice(self.states)
        return {"value": self.current, "unit": ""}

# --- 2. Device Definitions ---

def build_ecosystem():
    """Returns a dict of devices with their Hz and Sensor Package"""
    return {
        # --- HIGH PERF (Apple / Garmin / Huawei) ---
        "Apple Watch Ultra 2": {
            "hz": 20.0,
            "sensors": {
                "heart_rate": VitalSign(75, 50, 190, 2.0, "bpm"),
                "blood_oxygen": VitalSign(98, 92, 100, 0.5, "%"),
                "ecg_waveform": Waveform(500, 2.0, "µV"),
                "accel_x": Waveform(1.2, 0.5, "g"),
                "env_noise": VitalSign(45, 30, 90, 5.0, "dB"),
                "wrist_temp": RandomWalk(36.6, 35.0, 38.0, 0.02, "°C")
            }
        },
        "Garmin Fenix 7 Pro": {
            "hz": 10.0,
            "sensors": {
                "heart_rate": VitalSign(145, 120, 175, 1.0, "bpm"), # Runner mode
                "cadence": VitalSign(170, 160, 180, 2.0, "spm"),
                "vert_oscillation": RandomWalk(9.2, 6.0, 12.0, 0.5, "cm"),
                "ground_contact": VitalSign(240, 200, 300, 5.0, "ms"),
                "running_power": VitalSign(320, 200, 450, 10.0, "W"),
                "gps_track": GPS(37.7749, -122.4194),
                "body_battery": VitalSign(65, 0, 100, 0.1, "%")
            }
        },
        "Huawei Watch Ultimate": {
            "hz": 5.0,
            "sensors": {
                "heart_rate": VitalSign(70, 50, 120, 1.0, "bpm"),
                "arterial_stiffness": RandomWalk(7.5, 6.0, 9.0, 0.1, "m/s"),
                "spo2": VitalSign(97, 94, 100, 0.2, "%"),
                "stress_score": VitalSign(42, 10, 90, 1.0, "idx")
            }
        },

        # --- HEALTH FOCUSED (Samsung / Withings / OnePlus) ---
        "Samsung Galaxy Watch 6": {
            "hz": 5.0,
            "sensors": {
                "heart_rate": VitalSign(72, 60, 100, 1.5, "bpm"),
                "systolic_bp": VitalSign(120, 110, 140, 2.0, "mmHg"),
                "diastolic_bp": VitalSign(80, 70, 90, 1.5, "mmHg"),
                "bia_body_fat": RandomWalk(18.5, 18.0, 19.0, 0.05, "%"),
                "bia_muscle": RandomWalk(32.0, 31.5, 32.5, 0.05, "kg"),
                "skin_temp": RandomWalk(35.2, 34.0, 36.5, 0.1, "°C")
            }
        },
        "Withings ScanWatch 2": {
            "hz": 1.0,
            "sensors": {
                "heart_rate": VitalSign(62, 50, 80, 0.5, "bpm"),
                "temp_baseline": RandomWalk(0.0, -2.0, 2.0, 0.1, "°C"),
                "ecg_afib_check": State(["Normal", "Normal", "Normal", "Inconclusive"]),
                "resp_rate": VitalSign(14, 12, 18, 0.5, "br/min")
            }
        },
        "OnePlus Watch 2": {
            "hz": 2.0,
            "sensors": {
                "heart_rate": VitalSign(75, 60, 110, 1.2, "bpm"),
                "vo2_max_est": RandomWalk(45.0, 44.5, 45.5, 0.01, "ml/kg"),
                "stress": VitalSign(30, 1, 100, 2.0, "%")
            }
        },

        # --- LIFESTYLE / RECOVERY (Fitbit / Oura / Whoop / Amazfit) ---
        "Fitbit Charge 6": {
            "hz": 1.0,
            "sensors": {
                "heart_rate": VitalSign(68, 55, 130, 1.0, "bpm"),
                "eda_stress": VitalSign(3, 0, 15, 1.0, "evts"), # Electrodermal Activity
                "daily_readiness": VitalSign(85, 0, 100, 0.05, "scr"),
                "azm_minutes": VitalSign(42, 42, 100, 0.0, "min") # Active Zone Mins
            }
        },
        "Oura Ring Gen3": {
            "hz": 0.5,
            "sensors": {
                "readiness_score": VitalSign(88, 50, 100, 0.1, "scr"),
                "sleep_score": VitalSign(92, 50, 100, 0.0, "scr"),
                "body_temp_dev": RandomWalk(0.2, -0.5, 1.5, 0.05, "°C"),
                "activity_cal": VitalSign(350, 350, 800, 0.5, "cal")
            }
        },
        "Whoop 4.0": {
            "hz": 0.5,
            "sensors": {
                "strain": RandomWalk(12.4, 0, 21, 0.1, "idx"),
                "recovery": VitalSign(65, 0, 100, 0.2, "%"),
                "hrv_rmssd": VitalSign(55, 30, 110, 3.0, "ms"),
                "skin_temp": RandomWalk(36.1, 35.0, 37.0, 0.05, "°C")
            }
        },
        "Amazfit GTR 4": {
            "hz": 1.0,
            "sensors": {
                "pai_score": VitalSign(110, 50, 150, 0.1, "pts"),
                "heart_rate": VitalSign(72, 60, 100, 1.0, "bpm"),
                "blood_oxygen": VitalSign(98, 90, 100, 0.5, "%")
            }
        }
    }

msg_queue = asyncio.Queue()

async def run_device(name, hz, sensors):
    """Independent loop for each device"""
    delay = 1.0 / hz
    while True:
        # Tick all sensors
        snapshot = {k: v.tick() for k, v in sensors.items()}
        
        payload = {
            "device": name,
            "hz": hz,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "metrics": snapshot
        }
        await msg_queue.put(payload)
        await asyncio.sleep(delay)

@app.on_event("startup")
async def start_ecosystem():
    devices = build_ecosystem()
    for name, config in devices.items():
        print(f"Booting {name} @ {config['hz']}Hz")
        asyncio.create_task(run_device(name, config['hz'], config['sensors']))

@app.get("/api/stream/all")
async def sse_endpoint(request: Request):
    async def generator():
        while True:
            if await request.is_disconnected(): break
            data = await msg_queue.get()
            yield f"data: {json.dumps(data)}\n\n"
    
    return StreamingResponse(generator(), media_type="text/event-stream")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)