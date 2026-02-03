from dotenv import load_dotenv
import os

# Load environment variables FIRST, before importing config
env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(env_path)

from fastapi import FastAPI
from app.routers import router as api_router
from app.config import DEBUG
from contextlib import asynccontextmanager
from app.db.mongodb import get_client


@asynccontextmanager
async def lifespan(app):
    # Ensure MongoDB is reachable on startup
    client = get_client()
    try:
        await client.admin.command("ping")
    except Exception:
        # let the app start; operations will fail if DB is unavailable
        pass
    yield


app = FastAPI(title="Bio AI BFF (dev)", lifespan=lifespan)

app.include_router(api_router, prefix="/api")


@app.get("/")
def root():
    return {"status": "ok", "debug": DEBUG}
