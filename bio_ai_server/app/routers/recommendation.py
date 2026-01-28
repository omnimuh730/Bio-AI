from fastapi import APIRouter
from ..schemas import Recommendation, SwapRequest

router = APIRouter()


@router.get("/current")
async def get_current_recommendation():
    """Return a context-aware meal suggestion (stub)."""
    return {
        "meal_name": "Salmon & Sweet Potato",
        "ingredients_used": ["Salmon", "Sweet Potato", "Spinach"],
        "macros": {"c": 45, "p": 35, "f": 18, "kcal": 520},
        "bio_reasoning_tag": "Anti-Stress",
        "explanation_short": "Magnesium-rich spinach may help lower cortisol.",
        "preparation_time_min": 20
    }


@router.post("/swap")
async def post_swap(req: SwapRequest):
    """Return a new suggestion based on rejection reason (stub)."""
    reason = req.reason.lower()
    if "expens" in reason:
        meal = "Egg Fried Rice"
    elif "hungry" in reason or "not hungry" in reason:
        meal = "Protein Smoothie"
    else:
        meal = "Turkey Sandwich"
    return {"meal_name": meal, "ingredients_used": [], "macros": {}, "bio_reasoning_tag": "Swap", "explanation_short": "Swapped per preference.", "preparation_time_min": 10}
