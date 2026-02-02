from fastapi import APIRouter, HTTPException
from .. import deps
from app.schemas import UserProfile
from fastapi import status
import uuid

router = APIRouter()

@router.get("/users/{user_id}")
async def get_user(user_id: str):
    db = deps.get_db()
    coll = db.get_collection("users")
    doc = await coll.find_one({"_id": user_id})
    if not doc:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return doc

@router.post("/users", status_code=status.HTTP_201_CREATED)
async def create_user(profile: UserProfile):
    db = deps.get_db()
    coll = db.get_collection("users")
    doc = profile.model_dump()
    coll_res = await coll.insert_one(doc)
    return {"id": str(coll_res.inserted_id)}