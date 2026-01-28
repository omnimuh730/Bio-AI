from fastapi import APIRouter, BackgroundTasks, HTTPException
from fastapi import Depends
from ..schemas import DashboardState

router = APIRouter()

@router.post("/batch")
async def post_sync_batch(background_tasks: BackgroundTasks, payload: dict):
    """Accepts a health sync payload. (Stub)"""
    # In production: validate, store time-series, enqueue energy score calculation
    background_tasks.add_task(lambda: None)
    return {"status": "accepted"}
