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

from app.services.fatsecret import lookup_barcode as fatsecret_lookup, FatSecretError

@router.post("/foods/lookup_barcode", status_code=status.HTTP_200_OK)
async def lookup_barcode(barcode: str):
    """Lookup barcode via FatSecret and persist to global_foods collection."""
    db = deps.get_db()
    foods = db.get_collection("global_foods")
    try:
        item = await fatsecret_lookup(barcode)
    except FatSecretError as e:
        # Fallback: return a simple error payload (or re-raise depending on policy)
        raise HTTPException(status_code=status.HTTP_502_BAD_GATEWAY, detail=str(e))

    await foods.update_one({"external_source_id": item["external_source_id"]}, {"$set": item}, upsert=True)
    return item

@router.post("/foods/search", status_code=status.HTTP_200_OK)
async def search_foods(req: VectorSearchRequest):
    db = deps.get_db()
    foods = db.get_collection("global_foods")

    # If embedding provided, prefer MongoDB Atlas $search knn (production). Fallback to naive similarity.
    if req.query_embedding:
        try:
            # $search with knnBeta (Atlas) - production only
            pipeline = [
                {"$search": {"knnBeta": {"vector": req.query_embedding, "path": "embedding_vector", "k": req.top_k}}},
                {"$project": {"score": {"$meta": "searchScore"}, "name": 1, "external_source_id": 1, "brand": 1, "macros_per_100g": 1}},
            ]
            cursor = foods.aggregate(pipeline)
            docs = await cursor.to_list(length=req.top_k)
            return {"results": [{"score": d.get("score"), "item": d} for d in docs]}
        except Exception:
            # fall back to naive method (dev or if Atlas not configured)
            qv = np.array(req.query_embedding, dtype=float)
            cursor = foods.find({"embedding_vector": {"$exists": True}}, {"embedding_vector": 1, "name": 1}).limit(1000)
            candidates = await cursor.to_list(length=1000)
            scored: List[tuple] = []
            for c in candidates:
                vec = np.array(c.get("embedding_vector", []), dtype=float)
                if vec.size != qv.size:
                    continue
                sim = float(np.dot(qv, vec) / (np.linalg.norm(qv) * np.linalg.norm(vec) + 1e-8))
                if sim >= req.min_similarity:
                    scored.append((sim, c))
            scored.sort(key=lambda x: -x[0])
            top = [{"score": s, "item": doc} for s, doc in scored[: req.top_k]]
            return {"results": top}

    # Text search fallback
    if req.query:
        cursor = foods.find({"$text": {"$search": req.query}}, {"score": {"$meta": "textScore"}}).sort([("score", {"$meta": "textScore"})]).limit(req.top_k)
        docs = await cursor.to_list(length=req.top_k)
        return {"results": docs}

    return {"results": []}