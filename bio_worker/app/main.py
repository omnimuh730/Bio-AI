import asyncio
import logging
from .worker import run_worker
from .core.config import settings

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    logging.info("Starting bio_worker (env=%s)", settings.env)
    asyncio.run(run_worker())