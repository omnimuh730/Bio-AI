from fastapi import APIRouter
from ..schemas import DashboardState, RingState

router = APIRouter()

@router.get("/state", response_model=DashboardState)
async def get_dashboard_state():
    """Return cached or computed dashboard state. (Stubbed sample)"""
    rings = {"outer_percent": 0.65, "inner_percent": 0.50}
    return {
        "rings": rings,
        "status_msg": "Fuel Up - You are behind schedule.",
        "fasting_active": False,
        "ai_card": {"meal": "Salmon Bowl", "reason": "High Stress"}
    }
