from fastapi import FastAPI
from app.api.v1.router import api_router
from app.core.config import settings
from app.db.mongodb import get_client
from app.s3.client import s3_client

app = FastAPI(title=settings.app_name)
app.include_router(api_router, prefix="/api")

@app.on_event("startup")
async def startup_event():
    # Initialize S3 buckets
    s3_client.ensure_buckets()
    
    # Establish DB connection (Motor) and create base indexes if needed
    client = get_client()
    db = client[settings.mongo_db]
    # Ensure collections exist & create recommended indexes
    await db.create_collection("health_metrics", timeseries={"timeField": "timestamp", "metaField": "metadata", "granularity": "minutes"}, expireAfterSeconds=None) if "health_metrics" not in await db.list_collection_names() else None
    await db.get_collection("global_foods").create_index([("name", "text")])
    await db.get_collection("global_foods").create_index([("external_source_id", 1)], unique=True)
    
    # Create files collection indexes
    await db.get_collection("files").create_index([("key", 1)], unique=True)
    await db.get_collection("files").create_index([("archived", 1)])

@app.get("/health")
async def health():
    return {"status": "ok"}