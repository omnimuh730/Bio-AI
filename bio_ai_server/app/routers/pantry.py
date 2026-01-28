from fastapi import APIRouter, HTTPException, Depends
from ..schemas import FoodLogIn, LeftoverConsume
from ..database import get_session
from ..models import FoodLog, Leftover

router = APIRouter()


@router.post("/item")
async def add_pantry_item(payload: dict):
    # Stub: In production, validate and insert into pantry table
    return {"status": "ok", "item": payload}


@router.post("/leftovers/consume")
async def consume_leftover(payload: LeftoverConsume, session=Depends(get_session)):
    leftover = session.get(Leftover, payload.leftover_id)
    if not leftover:
        raise HTTPException(status_code=404, detail="Leftover not found")
    leftover.remaining_servings = (leftover.remaining_servings or 0) - payload.consumed_servings
    session.add(leftover)
    session.commit()
    return {"status": "ok", "remaining_servings": leftover.remaining_servings}


@router.post("/log")
async def log_food(payload: FoodLogIn, session=Depends(get_session)):
    fl = FoodLog(
        user_id=payload.user_id,
        food_name=payload.food_name,
        calories=payload.calories,
        protein_g=payload.protein_g,
        carbs_g=payload.carbs_g,
        fats_g=payload.fats_g,
        meta_data=payload.meta_data,
    )
    session.add(fl)
    session.commit()
    session.refresh(fl)
    return {"status": "created", "id": fl.id}
