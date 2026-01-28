from fastapi import FastAPI
from .routers import router as api_router
from .database import init_db
from .config import DEBUG

app = FastAPI(title="Bio AI BFF (dev)")


@app.on_event("startup")
def on_startup():
    init_db()


app.include_router(api_router, prefix="/api")


@app.get("/")
def root():
    return {"status": "ok", "debug": DEBUG}
