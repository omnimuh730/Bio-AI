from fastapi import APIRouter, HTTPException, Query, status
from datetime import datetime, timedelta
from typing import Optional, List
from app.schemas import (
    DailySummary,
    EnergyScore,
    EnergyScoreTrend,
    DailyMetrics,
    MetricValue,
    SimpleMetric,
    SleepMetric,
    InsightResponse,
    CorrelationData,
    AxisData,
    DataPoint,
    EntryList,
    Entry,
    EntryCreate,
    EntryUpdate,
    MetricHistory,
    MetricDataPoint,
    MetricStatistics,
    EntryType,
    MetricType,
    PeriodType,
)
from app.db.mongodb import get_db, get_next_sequence
import random

router = APIRouter()

# Mock user ID for development
MOCK_USER_ID = "user_123"


# Helper functions
def format_time_label(time_str: str) -> str:
    """Convert HH:MM to display format like '12 PM'"""
    hour, minute = map(int, time_str.split(":"))
    period = "AM" if hour < 12 else "PM"
    display_hour = hour if hour <= 12 else hour - 12
    display_hour = 12 if display_hour == 0 else display_hour
    return f"{display_hour:02d} {period}"


def parse_period(period: PeriodType) -> int:
    """Convert period string to number of days"""
    periods = {"1W": 7, "1M": 30, "3M": 90, "6M": 180, "1Y": 365}
    return periods.get(period, 30)


def get_date_range(end_date: str, period: PeriodType):
    """Get start and end dates for a period"""
    end = datetime.fromisoformat(end_date)
    days = parse_period(period)
    start = end - timedelta(days=days - 1)
    return start.date().isoformat(), end.date().isoformat()


# ============================================================================
# 1. Dashboard Summary
# ============================================================================

@router.get("/summary", response_model=DailySummary)
async def get_daily_summary(
    date: Optional[str] = Query(None, description="Target date (ISO-8601)")
):
    """Get daily summary including energy score and metrics."""
    if not date:
        date = datetime.utcnow().date().isoformat()
    
    db = get_db()
    
    # Get or create daily metrics
    daily_metric = await db.daily_metrics.find_one({
        "user_id": MOCK_USER_ID,
        "date": date
    })
    
    if not daily_metric:
        # Create mock data for development
        daily_metric = {
            "user_id": MOCK_USER_ID,
            "date": date,
            "energy_score": {
                "value": 88,
                "label": "Excellent Energy",
            },
            "metrics": {
                "calories": {"current": 1840, "goal": 2300},
                "protein": {"current": 118, "goal": 140},
                "carbs": {"current": 180, "goal": 250},
                "fats": {"current": 62, "goal": 75},
                "active_burn": {"value": 620},
                "sleep_score": {"value": 74},
                "hydration": {"current": 1800, "goal": 2500},
                "steps": {"current": 8420, "goal": 10000},
            },
            "trends": {
                "energy_score": {
                    "direction": "up",
                    "percentage": 12,
                }
            }
        }
        await db.daily_metrics.insert_one(daily_metric)
    
    # Build response
    return DailySummary(
        date=date,
        energy_score=EnergyScore(
            value=daily_metric["energy_score"]["value"],
            label=daily_metric["energy_score"]["label"],
            trend=EnergyScoreTrend(
                direction=daily_metric.get("trends", {}).get("energy_score", {}).get("direction", "flat"),
                percentage=daily_metric.get("trends", {}).get("energy_score", {}).get("percentage", 0),
                message=f"Your score {'improved' if daily_metric.get('trends', {}).get('energy_score', {}).get('direction') == 'up' else 'changed'} by {daily_metric.get('trends', {}).get('energy_score', {}).get('percentage', 0)}% this week."
            )
        ),
        metrics=DailyMetrics(
            calories=MetricValue(**daily_metric["metrics"]["calories"], unit="kcal"),
            protein=MetricValue(**daily_metric["metrics"]["protein"], unit="g"),
            carbs=MetricValue(**daily_metric["metrics"]["carbs"], unit="g") if "carbs" in daily_metric["metrics"] else None,
            fats=MetricValue(**daily_metric["metrics"]["fats"], unit="g") if "fats" in daily_metric["metrics"] else None,
            active_burn=SimpleMetric(**daily_metric["metrics"]["active_burn"], unit="kcal"),
            sleep_score=SleepMetric(**daily_metric["metrics"]["sleep_score"]),
            hydration=MetricValue(**daily_metric["metrics"]["hydration"], unit="ml") if "hydration" in daily_metric["metrics"] else None,
            steps=MetricValue(**daily_metric["metrics"]["steps"], unit="steps") if "steps" in daily_metric["metrics"] else None,
        )
    )


# ============================================================================
# 2. AI Insights
# ============================================================================

@router.get("/insights", response_model=InsightResponse)
async def get_insights(
    type: str = Query("weekly", description="Insight type: weekly or monthly"),
    end_date: Optional[str] = Query(None, description="End date (ISO-8601)")
):
    """Get AI-generated insights and recommendations."""
    if not end_date:
        end_date = datetime.utcnow().date().isoformat()
    
    db = get_db()
    
    # Find most recent insight of this type
    insight = await db.ai_insights.find_one(
        {
            "user_id": MOCK_USER_ID,
            "type": type,
            "end_date": {"$lte": end_date}
        },
        sort=[("generated_at", -1)]
    )
    
    if not insight:
        # Create mock insight
        insight = {
            "_id": f"rev_{random.randint(1000, 9999)}",
            "user_id": MOCK_USER_ID,
            "type": type,
            "text": "You hit your protein goal 5 of 7 days. Sleep quality improved by 10%. I will stop suggesting oatmeal for now.",
            "recommendations": [
                "Consider adding more healthy fats to breakfast",
                "Your hydration improves on workout days - keep it consistent"
            ],
            "generated_at": datetime.utcnow(),
        }
        await db.ai_insights.insert_one(insight)
    
    return InsightResponse(
        insight_id=str(insight["_id"]),
        type=insight["type"],
        text=insight["text"],
        generated_at=insight["generated_at"],
        recommendations=insight.get("recommendations", [])
    )


# ============================================================================
# 3. Correlation Analysis
# ============================================================================

@router.get("/correlation", response_model=CorrelationData)
async def get_correlation(
    metric_left: MetricType = Query(..., description="First metric"),
    metric_right: MetricType = Query(..., description="Second metric"),
    period: PeriodType = Query("1M", description="Time period"),
    end_date: Optional[str] = Query(None, description="End date (ISO-8601)")
):
    """Get correlation data between two metrics."""
    if not end_date:
        end_date = datetime.utcnow().date().isoformat()
    
    start_date, end_date = get_date_range(end_date, period)
    
    # Mock data generation
    days = parse_period(period)
    left_data = []
    right_data = []
    
    for i in range(days):
        current_date = (datetime.fromisoformat(start_date) + timedelta(days=i)).date().isoformat()
        left_data.append(DataPoint(
            date=current_date,
            value=round(2000 + random.uniform(-300, 300), 1)
        ))
        right_data.append(DataPoint(
            date=current_date,
            value=round(70 + random.uniform(-15, 15), 1)
        ))
    
    metric_labels = {
        "calorie_intake": "Calorie Intake",
        "protein_intake": "Protein Intake",
        "carb_intake": "Carb Intake",
        "fat_intake": "Fat Intake",
        "active_burn": "Active Burn",
        "hydration": "Hydration",
        "steps": "Steps",
        "sleep_quality": "Sleep Quality",
        "energy_score": "Energy Score",
        "hrv_stress": "HRV Stress",
        "mood": "Mood",
    }
    
    metric_units = {
        "calorie_intake": "kcal",
        "protein_intake": "g",
        "carb_intake": "g",
        "fat_intake": "g",
        "active_burn": "kcal",
        "hydration": "ml",
        "steps": "steps",
        "sleep_quality": "score",
        "energy_score": "score",
        "hrv_stress": "ms",
        "mood": "score",
    }
    
    return CorrelationData(
        period=period,
        start_date=start_date,
        end_date=end_date,
        left_axis=AxisData(
            metric=metric_left,
            label=metric_labels[metric_left],
            unit=metric_units[metric_left],
            data=left_data
        ),
        right_axis=AxisData(
            metric=metric_right,
            label=metric_labels[metric_right],
            unit=metric_units[metric_right],
            data=right_data
        ),
        correlation_coefficient=round(random.uniform(-0.5, 0.8), 2),
        insights=[f"Higher {metric_labels[metric_left].lower()} correlates with {metric_labels[metric_right].lower()}"]
    )


# ============================================================================
# 4. Timeline Entries
# ============================================================================

@router.get("/entries", response_model=EntryList)
async def get_entries(
    date: Optional[str] = Query(None, description="Target date (ISO-8601)"),
    type: Optional[EntryType] = Query(None, description="Filter by entry type")
):
    """Get timeline entries for a specific date."""
    if not date:
        date = datetime.utcnow().date().isoformat()
    
    db = get_db()
    
    query = {
        "user_id": MOCK_USER_ID,
        "date": date,
        "is_deleted": False
    }
    if type:
        query["type"] = type
    
    cursor = db.analytics_entries.find(query).sort("time", 1)
    entries = await cursor.to_list(length=100)
    
    entry_list = []
    for entry in entries:
        entry_list.append(Entry(
            id=str(entry["_id"]),
            type=entry["type"],
            title=entry["title"],
            subtitle=entry.get("subtitle", ""),
            time=entry["time"],
            time_label=format_time_label(entry["time"]),
            value=entry["value"],
            value_display=entry.get("value_display", str(entry["value"])),
            unit=entry["unit"],
            metadata=entry.get("metadata"),
            is_editable=True,
            created_at=entry["created_at"],
            updated_at=entry["updated_at"]
        ))
    
    return EntryList(
        date=date,
        total_count=len(entry_list),
        entries=entry_list
    )


# ============================================================================
# 5. Entry Management
# ============================================================================

@router.post("/entries", response_model=Entry, status_code=status.HTTP_201_CREATED)
async def create_entry(data: EntryCreate):
    """Create a new timeline entry."""
    db = get_db()
    
    entry_id = f"ent_{await get_next_sequence('analytics_entries')}"
    now = datetime.utcnow()
    
    # Format value display based on type
    value_display = str(data.value)
    if data.type == "EXERCISE":
        value_display = f"-{data.value}"
    elif data.type == "HYDRATION":
        value_display = f"+{data.value}ml"
    
    entry = {
        "_id": entry_id,
        "user_id": MOCK_USER_ID,
        "date": data.date,
        "time": data.time,
        "type": data.type,
        "title": data.title,
        "subtitle": data.subtitle or "",
        "value": data.value,
        "value_display": value_display,
        "unit": "kcal" if data.type in ["MEAL", "EXERCISE"] else ("ml" if data.type == "HYDRATION" else "score"),
        "metadata": data.metadata or {},
        "is_deleted": False,
        "created_at": now,
        "updated_at": now
    }
    
    await db.analytics_entries.insert_one(entry)
    
    return Entry(
        id=entry["_id"],
        type=entry["type"],
        title=entry["title"],
        subtitle=entry["subtitle"],
        time=entry["time"],
        time_label=format_time_label(entry["time"]),
        value=entry["value"],
        value_display=entry["value_display"],
        unit=entry["unit"],
        metadata=entry["metadata"],
        is_editable=True,
        created_at=entry["created_at"],
        updated_at=entry["updated_at"]
    )


@router.patch("/entries/{entry_id}", response_model=Entry)
async def update_entry(entry_id: str, data: EntryUpdate):
    """Update an existing entry."""
    db = get_db()
    
    # Verify ownership
    entry = await db.analytics_entries.find_one({
        "_id": entry_id,
        "user_id": MOCK_USER_ID,
        "is_deleted": False
    })
    
    if not entry:
        raise HTTPException(status_code=404, detail="Entry not found")
    
    update_data = data.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    update_data["updated_at"] = datetime.utcnow()
    
    # Update value_display if value changed
    if "value" in update_data:
        if entry["type"] == "EXERCISE":
            update_data["value_display"] = f"-{update_data['value']}"
        elif entry["type"] == "HYDRATION":
            update_data["value_display"] = f"+{update_data['value']}ml"
        else:
            update_data["value_display"] = str(update_data["value"])
    
    result = await db.analytics_entries.find_one_and_update(
        {"_id": entry_id, "user_id": MOCK_USER_ID},
        {"$set": update_data},
        return_document=True
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Entry not found")
    
    return Entry(
        id=result["_id"],
        type=result["type"],
        title=result["title"],
        subtitle=result["subtitle"],
        time=result["time"],
        time_label=format_time_label(result["time"]),
        value=result["value"],
        value_display=result["value_display"],
        unit=result["unit"],
        metadata=result.get("metadata"),
        is_editable=True,
        created_at=result["created_at"],
        updated_at=result["updated_at"]
    )


@router.delete("/entries/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_entry(entry_id: str):
    """Delete a timeline entry (soft delete)."""
    db = get_db()
    
    result = await db.analytics_entries.update_one(
        {
            "_id": entry_id,
            "user_id": MOCK_USER_ID,
            "is_deleted": False
        },
        {
            "$set": {
                "is_deleted": True,
                "deleted_at": datetime.utcnow()
            }
        }
    )
    
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Entry not found")
    
    return None


# ============================================================================
# 6. Metric History
# ============================================================================

@router.get("/metrics/history", response_model=MetricHistory)
async def get_metric_history(
    metric: MetricType = Query(..., description="Metric name"),
    period: PeriodType = Query("1M", description="Time period"),
    end_date: Optional[str] = Query(None, description="End date (ISO-8601)")
):
    """Get historical data for a specific metric."""
    if not end_date:
        end_date = datetime.utcnow().date().isoformat()
    
    start_date, end_date = get_date_range(end_date, period)
    
    # Mock data generation
    days = parse_period(period)
    data = []
    values = []
    
    for i in range(days):
        current_date = (datetime.fromisoformat(start_date) + timedelta(days=i)).date().isoformat()
        value = round(2000 + random.uniform(-400, 400), 1)
        goal = 2300
        values.append(value)
        
        data.append(MetricDataPoint(
            date=current_date,
            value=value,
            goal=goal,
            percentage=round((value / goal) * 100, 1)
        ))
    
    metric_labels = {
        "calorie_intake": "Calorie Intake",
        "protein_intake": "Protein Intake",
        "carb_intake": "Carb Intake",
        "fat_intake": "Fat Intake",
        "active_burn": "Active Burn",
        "hydration": "Hydration",
        "steps": "Steps",
        "sleep_quality": "Sleep Quality",
        "energy_score": "Energy Score",
        "hrv_stress": "HRV Stress",
        "mood": "Mood",
    }
    
    metric_units = {
        "calorie_intake": "kcal",
        "protein_intake": "g",
        "carb_intake": "g",
        "fat_intake": "g",
        "active_burn": "kcal",
        "hydration": "ml",
        "steps": "steps",
        "sleep_quality": "score",
        "energy_score": "score",
        "hrv_stress": "ms",
        "mood": "score",
    }
    
    return MetricHistory(
        metric=metric,
        label=metric_labels[metric],
        unit=metric_units[metric],
        period=period,
        start_date=start_date,
        end_date=end_date,
        data=data,
        statistics=MetricStatistics(
            average=round(sum(values) / len(values), 1),
            min=round(min(values), 1),
            max=round(max(values), 1),
            goal_achievement_rate=round(sum(1 for v in values if v >= 2300) / len(values), 2)
        )
    )
