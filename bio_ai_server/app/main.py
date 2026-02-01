from dotenv import load_dotenv
import os

# Load environment variables FIRST, before importing config
env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), '.env')
load_dotenv(env_path)

from fastapi import FastAPI
from app.routers import router as api_router
from app.database import init_db
from app.config import DEBUG
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app):
    init_db()
    yield

app = FastAPI(title="Bio AI BFF (dev)", lifespan=lifespan)

app.include_router(api_router, prefix="/api")


@app.get("/")
def root():
    return {"status": "ok", "debug": DEBUG}
