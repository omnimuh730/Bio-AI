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
