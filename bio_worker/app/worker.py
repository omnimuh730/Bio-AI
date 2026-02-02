import asyncio
import json
from typing import Any
import logging
import threading
from prometheus_client import start_http_server, Counter

import aioredis
from .db.mongodb import get_db
from .core.config import settings
from .services.archive_manager import archive_old_files

logger = logging.getLogger("bio_worker")

# Prometheus metrics
METRICS_PORT = settings.metrics_port
ARCHIVE_RUNS = Counter("bio_worker_archive_runs_total", "Total archival runs")
ARCHIVE_FILES = Counter("bio_worker_archive_files_total", "Total files archived")


async def process_health_point(point: dict, db) -> None:
    """Process a single health metric point and write to MongoDB time-series collection."""
    coll = db.get_collection("health_metrics")
    doc = {
        "timestamp": point.get("timestamp"),
        "metadata": {"user_id": point.get("user_id"), "sensor_type": point.get("sensor_type")},
        "measurements": point.get("measurements", {}),
    }
    await coll.insert_one(doc)
    logger.debug("Inserted health metric for user %s", point.get("user_id"))


async def handle_stream_message(message: Any, db) -> None:
    """Handle raw XREAD-style message. Message is assumed to be dict with fields."""
    # message expected: {"user_id":..., "timestamp":..., "sensor_type":..., "measurements": {...}}
    await process_health_point(message, db)


class Worker:
    def __init__(self):
        self.redis_url = settings.redis_url
        self.redis: aioredis.Redis | None = None
        self.db = get_db()
        self.stream_key = "ingest:health"
        self.group = settings.worker_group

    async def ensure_group(self):
        # Ensure consumer group exists
        try:
            await self.redis.xgroup_create(self.stream_key, self.group, id="$", mkstream=True)
            logger.info("Created consumer group %s on %s", self.group, self.stream_key)
        except aioredis.exceptions.RedisError:
            # Group may already exist
            pass

    async def start(self):
        self.redis = await aioredis.from_url(self.redis_url)
        await self.ensure_group()
        consumer_name = f"worker-{asyncio.get_event_loop().time()}"
        logger.info("Worker %s starting (group=%s stream=%s)", consumer_name, self.group, self.stream_key)

        # Start metrics server in a background thread
        threading.Thread(target=lambda: start_http_server(METRICS_PORT), daemon=True).start()

        # Schedule periodic archival task (runs every 24 hours)
        async def periodic_archive():
            while True:
                try:
                    result = await archive_old_files(self.db)
                    ARCHIVE_RUNS.inc()
                    ARCHIVE_FILES.inc(result.get("archived", 0))
                except Exception as e:
                    logger.exception("Periodic archive failed: %s", e)
                # Sleep for 24h in production, shorter in dev for testing
                sleep_seconds = 3600 * 24 if settings.env == "prod" else 60 * 10
                await asyncio.sleep(sleep_seconds)

        asyncio.create_task(periodic_archive())

        while True:
            try:
                # XREADGROUP BLOCK 5s COUNT 10
                resp = await self.redis.xreadgroup(self.group, consumer_name, {self.stream_key: ">"}, count=10, block=5000)
                if not resp:
                    # no messages
                    continue
                # resp is list of (stream_name, [(id, {b'field': b'value'}), ...])
                for stream_name, messages in resp:
                    for msg_id, fields in messages:
                        # Convert bytes keys/values to string
                        data = {k.decode() if isinstance(k, bytes) else k: v.decode() if isinstance(v, bytes) else v for k, v in fields.items()}
                        try:
                            # assume a JSON payload under "payload" or direct fields
                            if "payload" in data:
                                payload = json.loads(data["payload"])
                            else:
                                payload = data
                            await handle_stream_message(payload, self.db)
                            # Acknowledge
                            await self.redis.xack(self.stream_key, self.group, msg_id)
                        except Exception as e:
                            logger.exception("Failed to process message %s: %s", msg_id, e)
                            # Do not ack so the message can be retried/inspected
            except Exception as e:
                logger.exception("Worker loop error: %s", e)
                await asyncio.sleep(5)


async def run_worker():
    w = Worker()
    await w.start()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(run_worker())