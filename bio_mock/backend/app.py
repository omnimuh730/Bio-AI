import asyncio
import json
import random
import math
from datetime import datetime
from typing import List, Dict
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

# --- 1. Simulation Logic ---

class Sensor:
    def __init__(self, key, min_v, max_v, volatility, unit, is_int=False):
        self.key = key
        self.val = (min_v + max_v) / 2
        self.min = min_v
        self.max = max_v
        self.vol = volatility
        self.unit = unit
        self.is_int = is_int
        self.trend = 0

    def next(self):
        # Brownian motion with mean reversion
        change = random.uniform(-self.vol, self.vol)
        self.trend = (self.trend * 0.9) + change
        self.val += self.trend
        
        # Wall bouncing
        if self.val > self.max: self.val = self.max; self.trend *= -0.5
        if self.val < self.min: self.val = self.min; self.trend *= -0.5

        res = int(self.val) if self.is_int else round(self.val, 2)
        return {"type": self.key, "value": res, "unit": self.unit}

class StateSensor:
    """For categorical data like Sleep Stages or Activity Mode"""
    def __init__(self, key, states):
        self.key = key
        self.states = states
        self.current = states[0]

    def next(self):
        # 5% chance to change state
        if random.random() < 0.05:
            self.current = random.choice(self.states)
        return {"type": self.key, "value": self.current, "unit": "state"}

# --- 2. Device Profiles (The Ecosystem) ---

def create_apple_watch():
    return [
        Sensor("heart_rate", 60, 180, 2.0, "bpm", True),
        Sensor("hrv_sdnn", 30, 80, 1.5, "ms", True),
        Sensor("walking_asymmetry", 0, 15, 0.5, "%"),
        Sensor("headphone_audio", 40, 95, 2.0, "dB"),
        Sensor("blood_oxygen", 90, 100, 0.1, "%", True),
        StateSensor("ecg_status", ["Sinus Rhythm", "Sinus Rhythm", "Inconclusive"])
    ]

def create_garmin_fenix():
    return [
        Sensor("heart_rate", 50, 170, 1.5, "bpm", True),
        Sensor("running_power", 200, 450, 10, "W", True), # Running Dynamics
        Sensor("vertical_oscillation", 6, 12, 0.2, "cm"),
        Sensor("ground_contact_time", 200, 300, 5, "ms", True),
        Sensor("body_battery", 0, 100, 0.1, "%", True), # Garmin specific
        Sensor("stress_score", 0, 100, 1.0, "index", True)
    ]

def create_samsung_galaxy():
    return [
        Sensor("heart_rate", 60, 140, 1.0, "bpm", True),
        Sensor("systolic_bp", 110, 140, 0.5, "mmHg", True), # Blood Pressure
        Sensor("diastolic_bp", 70, 90, 0.5, "mmHg", True),
        Sensor("body_fat", 15, 25, 0.01, "%"), # BIA Sensor
        Sensor("skeletal_muscle", 30, 40, 0.01, "kg"),
        StateSensor("stress_level", ["Low", "Neutral", "High"])
    ]

def create_fitbit_pixel():
    return [
        Sensor("heart_rate", 55, 150, 1.2, "bpm", True),
        Sensor("eda_response", 0, 20, 0.5, "responses"), # Electrodermal Activity
        Sensor("skin_temp_variation", -2, 2, 0.05, "°C"),
        StateSensor("sleep_stage", ["Awake", "Light", "Deep", "REM"]),
        Sensor("daily_readiness", 0, 100, 0.05, "score", True)
    ]

# Registry of active mock devices
DEVICES = {
    "Apple Watch Series 9": create_apple_watch(),
    "Garmin Fenix 7": create_garmin_fenix(),
    "Samsung Galaxy Watch 6": create_samsung_galaxy(),
    "Google Pixel Watch 2": create_fitbit_pixel()
}

async def master_generator(request: Request):
    """Simulates multiple devices streaming simultaneously"""
    while True:
        if await request.is_disconnected():
            break

        timestamp = datetime.utcnow().isoformat() + "Z"
        batch_events = []

        # Iterate over all devices in the ecosystem
        for device_name, sensors in DEVICES.items():
            # Randomize sample rate (not all devices update all sensors every second)
            active_sensors = [s for s in sensors if random.random() > 0.4]
            
            for sensor in active_sensors:
                data = sensor.next()
                data["timestamp"] = timestamp
                data["device_id"] = device_name
                batch_events.append(data)

        if batch_events:
            yield f"data: {json.dumps(batch_events)}\n\n"
        
        await asyncio.sleep(1.0) # 1Hz Global Tick

@app.get("/api/stream/ecosystem")
async def stream_ecosystem(request: Request):
    return StreamingResponse(master_generator(request), media_type="text/event-stream")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)