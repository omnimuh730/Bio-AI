from fastapi import FastAPI
from app.api.v1.files import router as files_router
from app.s3.client import s3_client

app = FastAPI(title="bio_storage")

@app.on_event("startup")
async def startup():
    # Ensure S3 buckets exist on startup (no-op in prod if already present)
    s3_client.ensure_buckets()

app.include_router(files_router, prefix="/api/v1")
