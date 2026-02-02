from fastapi import APIRouter, HTTPException, Query
from app.schemas import FoodLogCreate, FoodItem, VectorSearchRequest
from .. import deps
import uuid
from fastapi import status
from typing import List, Optional
import numpy as np

router = APIRouter()

@router.post("/food_logs", status_code=status.HTTP_201_CREATED)
async def create_food_log(payload: FoodLogCreate):
    db = deps.get_db()
    coll = db.get_collection("food_logs")
    doc = payload.model_dump()
    doc["_id"] = str(uuid.uuid4())
    await coll.insert_one(doc)
    return {"id": doc["_id"]}

@router.post("/foods/lookup_barcode", status_code=status.HTTP_200_OK)
async def lookup_barcode(barcode: str):
    """Stub integration for FatSecret Platform API. Stores result into Global_Foods with provenance."""
    db = deps.get_db()
    foods = db.get_collection("global_foods")
    # Placeholder: in prod this calls FatSecret and maps the response
    fake = {
        "external_source_id": f"fatsecret:{barcode}",
        "name": "Generic Granola",
        "brand": "FatSecret Mock",
        "serving_size": {"qty": 30, "unit": "g"},
        "macros_per_100g": {"kcal": 450, "p": 8, "c": 60, "f": 18},
        "source": "fatsecret",
        "for_ml_training": True,
        "provenance": {"retrieved_at": __import__("datetime").datetime.utcnow().isoformat(), "confidence": 0.95}
    }
    res = await foods.update_one({"external_source_id": fake["external_source_id"]}, {"$set": fake}, upsert=True)
    return fake

@router.post("/foods/search", status_code=status.HTTP_200_OK)
async def search_foods(req: VectorSearchRequest):
    db = deps.get_db()
    foods = db.get_collection("global_foods")
    # If embedding provided, do naive in-memory similarity (dev fallback)
    if req.query_embedding:
        # pull candidates with embedding present (limit 1000)
        cursor = foods.find({"embedding_vector": {"$exists": True}}, {"embedding_vector": 1, "name": 1}).limit(1000)
        candidates = await cursor.to_list(length=1000)
        qv = np.array(req.query_embedding, dtype=float)
        scored: List[tuple] = []
        for c in candidates:
            vec = np.array(c.get("embedding_vector", []), dtype=float)
            if vec.size != qv.size:
                continue
            # cosine similarity
            sim = float(np.dot(qv, vec) / (np.linalg.norm(qv) * np.linalg.norm(vec) + 1e-8))
            if sim >= req.min_similarity:
                scored.append((sim, c))
        scored.sort(key=lambda x: -x[0])
        top = [ {"score": s, "item": doc} for s, doc in scored[: req.top_k]]
        return {"results": top}
    # Text search fallback
    if req.query:
        cursor = foods.find({"$text": {"$search": req.query}}, {"score": {"$meta": "textScore"}}).sort([("score", {"$meta": "textScore"})]).limit(req.top_k)
        docs = await cursor.to_list(length=req.top_k)
        return {"results": docs}
    return {"results": []}