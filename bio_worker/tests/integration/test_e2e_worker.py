import asyncio
import json
import time
import pytest
from datetime import datetime
from app.db.mongodb import get_client
import aioredis

REDIS_URL = "redis://localhost:6379"
MONGO_DB = "bio_nexus_db"
STREAM_KEY = "ingest:health"

@pytest.mark.asyncio
async def test_worker_processes_stream_locally():
    # Push a message into Redis stream
    r = await aioredis.from_url("redis://redis:6379")
    payload = {"payload": json.dumps({"user_id": "testuser", "timestamp": datetime.utcnow().isoformat(), "sensor_type": "HR", "measurements": {"hr": 72}})}
    await r.xadd(STREAM_KEY, payload)

    # Poll Mongo for the inserted metric (give worker some time)
    client = get_client()
    db = client[MONGO_DB]
    found = False
    for _ in range(20):
        docs = await db["health_metrics"].find({"metadata.user_id": "testuser"}).to_list(length=10)
        if docs:
            found = True
            break
        await asyncio.sleep(1)

    assert found, "Worker did not process stream message into Mongo in time"