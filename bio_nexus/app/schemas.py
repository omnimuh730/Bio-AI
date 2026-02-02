from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime

# Health metric point
class MetricPoint(BaseModel):
    user_id: str
    timestamp: datetime
    sensor_type: str
    measurements: dict

class MetricBatch(BaseModel):
    points: List[MetricPoint]

# Vision result
class VisionResult(BaseModel):
    user_id: str
    input_image_s3_url: str
    depth_map_s3_url: Optional[str] = None
    gyro_pitch_degrees: Optional[float] = None
    lighting_lux: Optional[int] = None
    ai_confidence_score: Optional[float] = None
    detected_items: Optional[list] = None

# Food log
class FoodLogCreate(BaseModel):
    user_id: str
    timestamp: datetime
    meal_type: Optional[str] = "unspecified"
    summary_macros: Optional[dict] = None
    vision_id: Optional[str] = None
    notes: Optional[str] = None

class FoodLog(FoodLogCreate):
    id: str

# Food item (Global_Foods)
class FoodItem(BaseModel):
    external_source_id: Optional[str]
    name: str
    brand: Optional[str]
    serving_size: Optional[dict]
    macros_per_100g: Optional[dict]
    embedding_vector: Optional[List[float]]
    source: Optional[str] = "user_upload"
    for_ml_training: Optional[bool] = False
    provenance: Optional[dict] = None

# Simple search request
class VectorSearchRequest(BaseModel):
    user_id: Optional[str]
    query_embedding: Optional[List[float]]
    query: Optional[str]
    top_k: Optional[int] = 5
    min_similarity: Optional[float] = 0.6

# User profile
class UserProfile(BaseModel):
    id: str
    email: Optional[str]
    created_at: Optional[datetime]
    profile: Optional[dict] = None
    goals: Optional[dict] = None
    settings: Optional[dict] = None