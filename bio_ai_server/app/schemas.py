from typing import List, Optional
from pydantic import BaseModel, EmailStr
from datetime import datetime


# ============================================================================
# Profile & User Management Schemas
# ============================================================================

class ProfileInfo(BaseModel):
    """User profile information"""
    user_id: str
    name: str
    email: EmailStr
    created_at: datetime
    profile_image_url: Optional[str] = None


class ProfileUpdate(BaseModel):
    """Update user profile"""
    name: Optional[str] = None
    profile_image_url: Optional[str] = None


class DietaryProfile(BaseModel):
    """Complete dietary profile"""
    allergies: List[str] = []
    dislikes: List[str] = []
    dietary_restrictions: List[str] = []
    updated_at: Optional[datetime] = None


class DietaryProfileUpdate(BaseModel):
    """Partial update for dietary profile"""
    allergies: Optional[List[str]] = None
    dislikes: Optional[List[str]] = None
    dietary_restrictions: Optional[List[str]] = None


class AllergiesList(BaseModel):
    """Allergies list"""
    allergies: List[str]


class DislikesList(BaseModel):
    """Dislikes list"""
    dislikes: List[str]


class Preferences(BaseModel):
    """User preferences"""
    metric_units: bool = True
    notifications_enabled: bool = True
    offline_mode: bool = False
    theme: str = "light"
    language: str = "en"


class PreferencesUpdate(BaseModel):
    """Partial update for preferences"""
    metric_units: Optional[bool] = None
    notifications_enabled: Optional[bool] = None
    offline_mode: Optional[bool] = None
    theme: Optional[str] = None
    language: Optional[str] = None


class UnitPreference(BaseModel):
    """Unit preference"""
    metric_units: bool


class Goals(BaseModel):
    """User goals"""
    goals: List[str]
    primary_goal: Optional[str] = None
    updated_at: Optional[datetime] = None


class GoalsUpdate(BaseModel):
    """Update goals list"""
    goals: List[str]
    primary_goal: Optional[str] = None


class GoalAdd(BaseModel):
    """Add a single goal"""
    goal: str


class Subscription(BaseModel):
    """Subscription information"""
    tier: str  # "free", "pro", "premium"
    status: str  # "active", "cancelled", "expired"
    started_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    auto_renew: bool = True
    payment_method: Optional[str] = None


class SubscriptionUpdate(BaseModel):
    """Update subscription"""
    tier: Optional[str] = None
    auto_renew: Optional[bool] = None


class AccountDeletion(BaseModel):
    """Account deletion request"""
    confirmation: str  # Must be "DELETE_MY_ACCOUNT"
    reason: Optional[str] = None


class AccountDeletionResponse(BaseModel):
    """Account deletion confirmation"""
    status: str
    deleted_at: datetime
    data_retention_days: int = 30


# ============================================================================
# Existing Schemas
# ============================================================================

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
