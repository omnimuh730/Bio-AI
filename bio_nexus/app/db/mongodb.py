from motor.motor_asyncio import AsyncIOMotorClient
from ..core.config import settings

client: AsyncIOMotorClient | None = None

def get_client() -> AsyncIOMotorClient:
    global client
    if client is None:
        client = AsyncIOMotorClient(settings.mongo_uri)
    return client


def get_db():
    return get_client()[settings.mongo_db]