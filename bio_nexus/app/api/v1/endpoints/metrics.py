from fastapi import APIRouter, HTTPException
from .. import deps
from app.schemas import MetricBatch
from fastapi import status

router = APIRouter()

@router.post("/metrics/batch", status_code=status.HTTP_202_ACCEPTED)
async def ingest_metrics(batch: MetricBatch):
    db = deps.get_db()
    coll = db.get_collection("health_metrics")
    # Convert to documents
    docs = []
    for p in batch.points:
        docs.append({
            "timestamp": p.timestamp,
            "metadata": {"user_id": p.user_id, "sensor_type": p.sensor_type},
            "measurements": p.measurements,
        })
    if docs:
        await coll.insert_many(docs)
    return {"status": "accepted", "count": len(docs)}