import asyncio
import logging
from .services.archive_manager import archive_old_files
from .db.mongodb import get_db
from .core.config import settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("bio_worker.cli")

async def run_archive_once():
    db = get_db()
    res = await archive_old_files(db)
    logger.info("Archive result: %s", res)

if __name__ == "__main__":
    logger.info("Running CLI in env=%s", settings.env)
    asyncio.run(run_archive_once())