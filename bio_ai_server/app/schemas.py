from typing import List, Optional
from pydantic import BaseModel


class RingState(BaseModel):
    outer_percent: float
    inner_percent: float


class DashboardState(BaseModel):
    rings: RingState
    status_msg: str
    fasting_active: bool
    ai_card: Optional[dict]


class Recommendation(BaseModel):
    meal_name: str
    ingredients_used: List[str]
    macros: dict
    bio_reasoning_tag: str
    explanation_short: str
    preparation_time_min: int


class SwapRequest(BaseModel):
    reason: str


class FoodLogIn(BaseModel):
    user_id: int
    food_name: str
    calories: Optional[int] = None
    protein_g: Optional[int] = None
    carbs_g: Optional[int] = None
    fats_g: Optional[int] = None
    meta_data: Optional[dict] = None


class LeftoverConsume(BaseModel):
    leftover_id: int
    consumed_servings: float
