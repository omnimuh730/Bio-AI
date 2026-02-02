from fastapi import APIRouter, HTTPException
from app.schemas import VisionResult
from .. import deps
from fastapi import status
import uuid

router = APIRouter()

@router.post("/vision/result", status_code=status.HTTP_201_CREATED)
async def store_vision_result(result: VisionResult):
    db = deps.get_db()
    coll = db.get_collection("vision_results")
    doc = result.model_dump()
    doc["created_at"] = doc.get("created_at") or __import__("datetime").datetime.utcnow()
    doc["_id"] = str(uuid.uuid4())
    await coll.insert_one(doc)
    return {"id": doc["_id"]}