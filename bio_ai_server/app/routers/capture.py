from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Query, status
from datetime import datetime, timedelta
from typing import Optional
from app.schemas import (
    ImageAnalysisResponse,
    DetectedItem,
    AlternativeSuggestion,
    NutritionInfo,
    ServingInfo,
    MealContext,
    BarcodeResponse,
    BarcodeItem,
    CaptureConfirm,
    CaptureConfirmResponse,
    CaptureEntryPreview,
    DailyTotals,
    AnalysisHistoryResponse,
    AnalysisHistoryItem,
    FoodSearchResponse,
    FoodSearchResult,
)
from app.db.mongodb import get_db, get_next_sequence
import random

router = APIRouter()

# Mock user ID for development
MOCK_USER_ID = "user_123"

# Mock food database
MOCK_BARCODE_DB = {
    "5449000000996": {
        "name": "Coca-Cola Zero Sugar",
        "brand": "Coca-Cola",
        "description": "Sugar-free cola beverage",
        "serving_size": "330ml",
        "servings_per_container": 1.0,
        "nutrition": {
            "calories": 0,
            "protein": 0,
            "carbs": 0,
            "fat": 0,
            "sodium": 40,
            "sugar": 0,
        },
        "ingredients": "Carbonated water, caramel color, phosphoric acid, aspartame, potassium benzoate, natural flavors, citric acid, caffeine",
        "allergens": [],
        "image_url": "https://cdn.bioai.com/products/coca-cola-zero.jpg"
    },
    "012000161551": {
        "name": "Nature Valley Crunchy Granola Bars",
        "brand": "Nature Valley",
        "description": "Oats 'n Honey granola bars",
        "serving_size": "2 bars",
        "servings_per_container": 6.0,
        "nutrition": {
            "calories": 190,
            "protein": 4,
            "carbs": 29,
            "fat": 6,
            "fiber": 2,
            "sugar": 11,
            "sodium": 160,
        },
        "ingredients": "Whole grain oats, sugar, canola oil, rice flour, honey, brown sugar syrup, salt, soy lecithin, baking soda, natural flavor",
        "allergens": ["soy"],
        "image_url": "https://cdn.bioai.com/products/nature-valley-granola.jpg"
    }
}


# Helper functions
def format_time_label(time_str: str) -> str:
    """Convert HH:MM to display format"""
    hour, minute = map(int, time_str.split(":"))
    period = "AM" if hour < 12 else "PM"
    display_hour = hour if hour <= 12 else hour - 12
    display_hour = 12 if display_hour == 0 else display_hour
    return f"{display_hour:02d} {period}"


def get_meal_type_from_time(time_str: str) -> str:
    """Determine meal type from time"""
    hour = int(time_str.split(":")[0])
    if 5 <= hour < 11:
        return "breakfast"
    elif 11 <= hour < 16:
        return "lunch"
    elif 16 <= hour < 22:
        return "dinner"
    else:
        return "snack"


# ============================================================================
# 1. Photo Analysis
# ============================================================================

@router.post("/analyze/image", response_model=ImageAnalysisResponse)
async def analyze_image(
    image: UploadFile = File(...),
    user_timezone: Optional[str] = Form(None)
):
    """
    Upload an image for AI-powered food recognition.
    
    Returns detected food items with nutritional estimates.
    """
    # Validate file
    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail="Invalid image format. Supported formats: jpg, png, heic"
        )
    
    # Check file size (max 10MB)
    contents = await image.read()
    if len(contents) > 10 * 1024 * 1024:
        raise HTTPException(
            status_code=413,
            detail="Image file too large. Maximum size is 10MB"
        )
    
    db = get_db()
    
    # Generate analysis ID
    analysis_id = f"scan_{await get_next_sequence('food_analyses')}_{''.join(random.choices('abcdefghijklmnopqrstuvwxyz', k=3))}"
    now = datetime.utcnow()
    
    # Mock AI detection (in production, call actual ML model)
    detected_items = [
        DetectedItem(
            temp_id="tmp_01",
            name="BBQ Pork Ribs",
            confidence=0.96,
            default_serving=ServingInfo(amount=1.0, unit="half-rack"),
            nutrition=NutritionInfo(
                calories=450,
                protein=38,
                carbs=12,
                fat=28,
                fiber=0,
                sugar=8,
                sodium=850
            ),
            alternative_suggestions=[
                AlternativeSuggestion(
                    name="Baby Back Ribs",
                    confidence=0.82,
                    nutrition=NutritionInfo(
                        calories=420,
                        protein=35,
                        carbs=10,
                        fat=26,
                        fiber=0,
                        sugar=7,
                        sodium=800
                    )
                )
            ]
        ),
        DetectedItem(
            temp_id="tmp_02",
            name="Coleslaw",
            confidence=0.88,
            default_serving=ServingInfo(amount=1.0, unit="cup"),
            nutrition=NutritionInfo(
                calories=150,
                protein=2,
                carbs=18,
                fat=8,
                fiber=2,
                sugar=12,
                sodium=220
            )
        )
    ]
    
    # Calculate total nutrition
    total_nutrition = NutritionInfo(
        calories=sum(item.nutrition.calories for item in detected_items),
        protein=sum(item.nutrition.protein for item in detected_items),
        carbs=sum(item.nutrition.carbs for item in detected_items),
        fat=sum(item.nutrition.fat for item in detected_items),
        fiber=sum(item.nutrition.fiber or 0 for item in detected_items),
        sugar=sum(item.nutrition.sugar or 0 for item in detected_items),
        sodium=sum(item.nutrition.sodium or 0 for item in detected_items)
    )
    
    # Determine meal context
    current_time = now.strftime("%H:%M")
    meal_context = MealContext(
        suggested_meal_type=get_meal_type_from_time(current_time),
        suggested_time=current_time
    )
    
    # Store analysis in database
    analysis_doc = {
        "_id": analysis_id,
        "user_id": MOCK_USER_ID,
        "image_url": f"s3://bioai-uploads/{MOCK_USER_ID}/{analysis_id}.jpg",
        "thumbnail_url": f"s3://bioai-uploads/{MOCK_USER_ID}/thumb_{analysis_id}.jpg",
        "uploaded_at": now,
        "detected_items": [item.dict() for item in detected_items],
        "total_nutrition": total_nutrition.dict(),
        "meal_context": meal_context.dict(),
        "user_timezone": user_timezone,
        "was_logged": False,
        "created_at": now
    }
    
    await db.food_analyses.insert_one(analysis_doc)
    
    return ImageAnalysisResponse(
        analysis_id=analysis_id,
        uploaded_at=now,
        detected_items=detected_items,
        total_nutrition=total_nutrition,
        meal_context=meal_context
    )


# ============================================================================
# 2. Barcode Lookup
# ============================================================================

@router.get("/barcode/{code}", response_model=BarcodeResponse)
async def lookup_barcode(code: str):
    """
    Look up food product by barcode.
    
    Returns product information including nutrition facts.
    """
    db = get_db()
    
    # Check database first
    product = await db.food_products.find_one({"barcode": code})
    
    if not product:
        # Check mock database
        if code in MOCK_BARCODE_DB:
            mock_product = MOCK_BARCODE_DB[code]
            return BarcodeResponse(
                found=True,
                barcode=code,
                item=BarcodeItem(**mock_product)
            )
        
        # Not found
        return BarcodeResponse(
            found=False,
            barcode=code,
            message="Product not found. You can manually enter nutrition information.",
            suggestion="Try searching by product name instead."
        )
    
    # Return found product
    return BarcodeResponse(
        found=True,
        barcode=code,
        item=BarcodeItem(
            name=product["name"],
            brand=product["brand"],
            description=product.get("description"),
            serving_size=product["serving_size"],
            servings_per_container=product.get("servings_per_container", 1.0),
            nutrition=NutritionInfo(**product["nutrition"]),
            ingredients=product.get("ingredients"),
            allergens=product.get("allergens", []),
            image_url=product.get("image_url")
        )
    )


# ============================================================================
# 3. Confirm & Log Entry
# ============================================================================

@router.post("/confirm", response_model=CaptureConfirmResponse, status_code=status.HTTP_201_CREATED)
async def confirm_entry(data: CaptureConfirm):
    """
    Confirm and save food entry to user's timeline.
    
    Creates a new entry in analytics_entries and updates daily metrics.
    """
    db = get_db()
    
    # Generate entry ID
    entry_id = f"ent_{await get_next_sequence('analytics_entries')}"
    now = datetime.utcnow()
    
    # Create entry document
    entry_doc = {
        "_id": entry_id,
        "user_id": MOCK_USER_ID,
        "date": data.date,
        "time": data.time,
        "type": data.type,
        "title": data.title,
        "subtitle": data.subtitle or "",
        "value": data.value,
        "value_display": str(int(data.value)),
        "unit": "kcal",
        "metadata": {
            "protein": data.nutrition.protein,
            "carbs": data.nutrition.carbs,
            "fat": data.nutrition.fat,
            "fiber": data.nutrition.fiber,
            "sugar": data.nutrition.sugar,
            "sodium": data.nutrition.sodium,
            "serving_info": data.serving_info.dict() if data.serving_info else None,
            "source": data.source,
            "analysis_id": data.analysis_id,
            "temp_id": data.temp_id
        },
        "is_deleted": False,
        "created_at": now,
        "updated_at": now
    }
    
    await db.analytics_entries.insert_one(entry_doc)
    
    # Mark analysis as logged if from image scan
    if data.analysis_id:
        await db.food_analyses.update_one(
            {"_id": data.analysis_id},
            {
                "$set": {
                    "was_logged": True,
                    "logged_entry_id": entry_id
                }
            }
        )
    
    # Calculate daily totals
    pipeline = [
        {
            "$match": {
                "user_id": MOCK_USER_ID,
                "date": data.date,
                "is_deleted": False
            }
        },
        {
            "$group": {
                "_id": None,
                "total_calories": {"$sum": "$value"},
                "total_protein": {"$sum": "$metadata.protein"},
                "total_carbs": {"$sum": "$metadata.carbs"},
                "total_fat": {"$sum": "$metadata.fat"}
            }
        }
    ]
    
    result = await db.analytics_entries.aggregate(pipeline).to_list(length=1)
    
    if result:
        totals = result[0]
        daily_totals = DailyTotals(
            calories=totals["total_calories"],
            protein=totals["total_protein"],
            carbs=totals["total_carbs"],
            fat=totals["total_fat"]
        )
    else:
        daily_totals = DailyTotals(
            calories=data.value,
            protein=data.nutrition.protein,
            carbs=data.nutrition.carbs,
            fat=data.nutrition.fat
        )
    
    return CaptureConfirmResponse(
        id=entry_id,
        message="Entry added successfully",
        entry=CaptureEntryPreview(
            id=entry_id,
            date=data.date,
            time=data.time,
            title=data.title,
            value=data.value,
            type=data.type
        ),
        daily_totals=daily_totals
    )


# ============================================================================
# 4. Analysis History
# ============================================================================

@router.get("/history", response_model=AnalysisHistoryResponse)
async def get_analysis_history(
    limit: int = Query(10, ge=1, le=50),
    offset: int = Query(0, ge=0)
):
    """
    Get recent image analysis sessions.
    
    Useful for re-using previous scans or reviewing detection results.
    """
    db = get_db()
    
    # Get total count
    total_count = await db.food_analyses.count_documents({"user_id": MOCK_USER_ID})
    
    # Get analyses
    cursor = db.food_analyses.find(
        {"user_id": MOCK_USER_ID}
    ).sort("uploaded_at", -1).skip(offset).limit(limit)
    
    analyses_list = await cursor.to_list(length=limit)
    
    analyses = []
    for analysis in analyses_list:
        primary_item = analysis["detected_items"][0]["name"] if analysis["detected_items"] else "Unknown"
        
        analyses.append(AnalysisHistoryItem(
            analysis_id=analysis["_id"],
            uploaded_at=analysis["uploaded_at"],
            thumbnail_url=analysis.get("thumbnail_url"),
            detected_items_count=len(analysis["detected_items"]),
            primary_item=primary_item,
            was_logged=analysis.get("was_logged", False)
        ))
    
    return AnalysisHistoryResponse(
        total_count=total_count,
        analyses=analyses
    )


# ============================================================================
# 5. Food Search
# ============================================================================

@router.get("/search", response_model=FoodSearchResponse)
async def search_food(
    q: str = Query(..., min_length=2),
    limit: int = Query(10, ge=1, le=50)
):
    """
    Search food database by name.
    
    Fallback option when barcode scan fails or manual entry needed.
    """
    db = get_db()
    
    # Text search on food products
    cursor = db.food_products.find(
        {"$text": {"$search": q}},
        {"score": {"$meta": "textScore"}}
    ).sort([("score", {"$meta": "textScore"})]).limit(limit)
    
    products = await cursor.to_list(length=limit)
    
    results = []
    for product in products:
        results.append(FoodSearchResult(
            id=str(product["_id"]),
            name=product["name"],
            brand=product.get("brand"),
            serving_size=product["serving_size"],
            calories=product["nutrition"]["calories"],
            image_url=product.get("image_url")
        ))
    
    # If no results, add mock results
    if not results:
        results = [
            FoodSearchResult(
                id="food_mock_1",
                name="Coca-Cola Zero Sugar",
                brand="Coca-Cola",
                serving_size="330ml",
                calories=0,
                image_url="https://cdn.bioai.com/products/coca-cola-zero.jpg"
            ),
            FoodSearchResult(
                id="food_mock_2",
                name="Nature Valley Granola Bar",
                brand="Nature Valley",
                serving_size="2 bars",
                calories=190,
                image_url="https://cdn.bioai.com/products/nature-valley-granola.jpg"
            )
        ]
    
    return FoodSearchResponse(
        query=q,
        results=results
    )
