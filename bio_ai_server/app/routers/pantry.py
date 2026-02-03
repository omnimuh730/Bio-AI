from fastapi import APIRouter, HTTPException, Depends
from ..schemas import FoodLogIn, LeftoverConsume
from ..database import get_db
from ..db.mongodb import get_next_sequence

router = APIRouter()


@router.post("/item")
async def add_pantry_item(payload: dict):
    # Stub: In production, validate and insert into pantry collection
    return {"status": "ok", "item": payload}


@router.post("/leftovers/consume")
async def consume_leftover(payload: LeftoverConsume, db=Depends(get_db)):
    leftovers = db["leftovers"]
    doc = await leftovers.find_one({"id": payload.leftover_id})
    if not doc:
        raise HTTPException(status_code=404, detail="Leftover not found")
    remaining = (doc.get("remaining_servings") or 0) - payload.consumed_servings
    await leftovers.update_one({"id": payload.leftover_id}, {"$set": {"remaining_servings": remaining}})
    return {"status": "ok", "remaining_servings": remaining}


@router.post("/log")
async def log_food(payload: FoodLogIn, db=Depends(get_db)):
    seq = await get_next_sequence("food_logs")
    fl = {
        "id": seq,
        "user_id": payload.user_id,
        "food_name": payload.food_name,
        "calories": payload.calories,
        "protein_g": payload.protein_g,
        "carbs_g": payload.carbs_g,
        "fats_g": payload.fats_g,
        "meta_data": payload.meta_data,
    }
    coll = db["food_logs"]
    await coll.insert_one(fl)
    return {"status": "created", "id": seq}
