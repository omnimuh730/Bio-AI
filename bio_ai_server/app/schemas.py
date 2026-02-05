from typing import List, Optional, Dict, Any, Literal
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


# ============================================================================
# Analytics Schemas
# ============================================================================

# Enums and Types
EntryType = Literal["MEAL", "EXERCISE", "HYDRATION", "SLEEP"]
MetricType = Literal[
    "calorie_intake", "protein_intake", "carb_intake", "fat_intake",
    "active_burn", "hydration", "steps",
    "sleep_quality", "energy_score", "hrv_stress", "mood"
]
PeriodType = Literal["1W", "1M", "3M", "6M", "1Y"]
TrendDirection = Literal["up", "down", "flat"]


# Dashboard Summary Schemas
class EnergyScoreTrend(BaseModel):
    """Energy score trend information"""
    direction: TrendDirection
    percentage: float
    message: str


class EnergyScore(BaseModel):
    """Energy score with trend"""
    value: int
    label: str
    trend: EnergyScoreTrend


class MetricValue(BaseModel):
    """Metric with current and goal values"""
    current: float
    goal: float
    unit: str


class SimpleMetric(BaseModel):
    """Simple metric with just value and unit"""
    value: float
    unit: str


class SleepMetric(BaseModel):
    """Sleep score metric"""
    value: int
    max: int = 100


class DailyMetrics(BaseModel):
    """All daily metrics"""
    calories: MetricValue
    protein: MetricValue
    carbs: Optional[MetricValue] = None
    fats: Optional[MetricValue] = None
    active_burn: SimpleMetric
    sleep_score: SleepMetric
    hydration: Optional[MetricValue] = None
    steps: Optional[MetricValue] = None


class DailySummary(BaseModel):
    """Daily summary response"""
    date: str
    energy_score: EnergyScore
    metrics: DailyMetrics


# AI Insights Schemas
class InsightResponse(BaseModel):
    """AI-generated insight"""
    insight_id: str
    type: str  # "weekly", "monthly"
    text: str
    generated_at: datetime
    recommendations: Optional[List[str]] = None


# Correlation Schemas
class DataPoint(BaseModel):
    """Single data point for charts"""
    date: str
    value: float


class AxisData(BaseModel):
    """Data for one axis of correlation chart"""
    metric: MetricType
    label: str
    unit: str
    data: List[DataPoint]


class CorrelationData(BaseModel):
    """Correlation analysis response"""
    period: PeriodType
    start_date: str
    end_date: str
    left_axis: AxisData
    right_axis: AxisData
    correlation_coefficient: Optional[float] = None
    insights: Optional[List[str]] = None


# Timeline Entry Schemas
class Entry(BaseModel):
    """Timeline entry (meal, exercise, hydration, sleep)"""
    id: str
    type: EntryType
    title: str
    subtitle: str
    time: str  # HH:MM format
    time_label: str  # Display format like "12 PM"
    value: float
    value_display: str
    unit: str
    metadata: Optional[Dict[str, Any]] = None
    is_editable: bool = True
    created_at: datetime
    updated_at: datetime


class EntryList(BaseModel):
    """List of timeline entries"""
    date: str
    total_count: int
    entries: List[Entry]


class EntryCreate(BaseModel):
    """Create new timeline entry"""
    date: str
    time: str  # HH:MM format
    type: EntryType
    title: str
    subtitle: Optional[str] = None
    value: float
    metadata: Optional[Dict[str, Any]] = None


class EntryUpdate(BaseModel):
    """Update timeline entry (partial)"""
    title: Optional[str] = None
    subtitle: Optional[str] = None
    value: Optional[float] = None
    time: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


# Metric History Schemas
class MetricDataPoint(BaseModel):
    """Data point with goal tracking"""
    date: str
    value: float
    goal: Optional[float] = None
    percentage: Optional[float] = None


class MetricStatistics(BaseModel):
    """Statistics for metric history"""
    average: float
    min: float
    max: float
    goal_achievement_rate: Optional[float] = None


class MetricHistory(BaseModel):
    """Historical data for a metric"""
    metric: MetricType
    label: str
    unit: str
    period: PeriodType
    start_date: str
    end_date: str
    data: List[MetricDataPoint]
    statistics: MetricStatistics


# ============================================================================
# Capture (Photo & Barcode Scan) Schemas
# ============================================================================

# Nutrition breakdown
class NutritionInfo(BaseModel):
    """Nutritional information"""
    calories: float
    protein: float
    carbs: float
    fat: float
    fiber: Optional[float] = None
    sugar: Optional[float] = None
    sodium: Optional[float] = None


# Serving information
class ServingInfo(BaseModel):
    """Serving size information"""
    amount: float
    unit: str


# Photo Analysis Schemas
class AlternativeSuggestion(BaseModel):
    """Alternative food suggestion"""
    name: str
    confidence: float
    nutrition: NutritionInfo


class DetectedItem(BaseModel):
    """Detected food item from image analysis"""
    temp_id: str
    name: str
    confidence: float
    default_serving: ServingInfo
    nutrition: NutritionInfo
    alternative_suggestions: Optional[List[AlternativeSuggestion]] = None


class MealContext(BaseModel):
    """Suggested meal context"""
    suggested_meal_type: str  # breakfast, lunch, dinner, snack
    suggested_time: str  # HH:MM format


class ImageAnalysisResponse(BaseModel):
    """Response from image analysis"""
    analysis_id: str
    uploaded_at: datetime
    detected_items: List[DetectedItem]
    total_nutrition: NutritionInfo
    meal_context: MealContext


# Barcode Schemas
class BarcodeItem(BaseModel):
    """Food product from barcode"""
    name: str
    brand: str
    description: Optional[str] = None
    serving_size: str
    servings_per_container: float = 1.0
    nutrition: NutritionInfo
    ingredients: Optional[str] = None
    allergens: Optional[List[str]] = None
    image_url: Optional[str] = None


class BarcodeResponse(BaseModel):
    """Response from barcode lookup"""
    found: bool
    barcode: str
    item: Optional[BarcodeItem] = None
    message: Optional[str] = None
    suggestion: Optional[str] = None


# Confirm Entry Schemas
class CaptureConfirm(BaseModel):
    """Confirm and log food entry"""
    date: str
    time: str
    type: str = "MEAL"
    title: str
    subtitle: Optional[str] = None
    value: float  # calories
    nutrition: NutritionInfo
    serving_info: Optional[ServingInfo] = None
    source: str  # scan_ai, barcode, manual
    analysis_id: Optional[str] = None
    temp_id: Optional[str] = None


class CaptureEntryPreview(BaseModel):
    """Preview of created entry"""
    id: str
    date: str
    time: str
    title: str
    value: float
    type: str


class DailyTotals(BaseModel):
    """Daily nutrition totals"""
    calories: float
    protein: float
    carbs: float
    fat: float


class CaptureConfirmResponse(BaseModel):
    """Response after confirming entry"""
    id: str
    message: str
    entry: CaptureEntryPreview
    daily_totals: DailyTotals


# Analysis History Schemas
class AnalysisHistoryItem(BaseModel):
    """Single analysis history item"""
    analysis_id: str
    uploaded_at: datetime
    thumbnail_url: Optional[str] = None
    detected_items_count: int
    primary_item: str
    was_logged: bool


class AnalysisHistoryResponse(BaseModel):
    """Analysis history list"""
    total_count: int
    analyses: List[AnalysisHistoryItem]


# Food Search Schemas
class FoodSearchResult(BaseModel):
    """Single food search result"""
    id: str
    name: str
    brand: Optional[str] = None
    serving_size: str
    calories: float
    image_url: Optional[str] = None


class FoodSearchResponse(BaseModel):
    """Food search results"""
    query: str
    results: List[FoodSearchResult]
