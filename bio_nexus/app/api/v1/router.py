from fastapi import APIRouter
from .endpoints import metrics, vision, food, users, storage

api_router = APIRouter()
api_router.include_router(metrics.router, prefix="/v1", tags=["metrics"]) 
api_router.include_router(vision.router, prefix="/v1", tags=["vision"]) 
api_router.include_router(food.router, prefix="/v1", tags=["food"]) 
api_router.include_router(users.router, prefix="/v1", tags=["users"])
api_router.include_router(storage.router, prefix="/v1", tags=["storage"]) 
