from fastapi import APIRouter

router = APIRouter()

from . import sync, dashboard, vision, recommendation, pantry

router.include_router(sync.router, prefix="/sync", tags=["sync"])
router.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])
router.include_router(vision.router, prefix="/vision", tags=["vision"])
router.include_router(recommendation.router, prefix="/recommendation", tags=["recommendation"])
router.include_router(pantry.router, prefix="/pantry", tags=["pantry"])
