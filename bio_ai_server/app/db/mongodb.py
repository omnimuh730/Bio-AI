from motor.motor_asyncio import AsyncIOMotorClient
from pymongo import ReturnDocument
from app.config import MONGODB_URI, MONGO_DB_NAME

_client: AsyncIOMotorClient | None = None

def get_client() -> AsyncIOMotorClient:
    global _client
    if _client is None:
        _client = AsyncIOMotorClient(MONGODB_URI)
    return _client


def get_db():
    return get_client()[MONGO_DB_NAME]


async def get_next_sequence(name: str) -> int:
    db = get_db()
    res = await db.counters.find_one_and_update(
        {"_id": name}, {"$inc": {"seq": 1}}, upsert=True, return_document=ReturnDocument.AFTER
    )
    return int(res["seq"]) if res and "seq" in res else 1
