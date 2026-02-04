from fastapi import APIRouter, HTTPException, status
from datetime import datetime
from app.schemas import (
    ProfileInfo,
    ProfileUpdate,
    DietaryProfile,
    DietaryProfileUpdate,
    AllergiesList,
    DislikesList,
    Preferences,
    PreferencesUpdate,
    UnitPreference,
    Goals,
    GoalsUpdate,
    GoalAdd,
    Subscription,
    SubscriptionUpdate,
    AccountDeletion,
    AccountDeletionResponse,
)
from app.db.mongodb import get_db

router = APIRouter()

# Mock user ID for development (in production, extract from JWT)
MOCK_USER_ID = "user_123"


# ============================================================================
# 1. Profile Information
# ============================================================================

@router.get("/me", response_model=ProfileInfo)
async def get_profile():
    """Get user profile information."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        # Create mock user if doesn't exist (dev only)
        user = {
            "_id": MOCK_USER_ID,
            "email": "demo@bioai.com",
            "name": "Demo User",
            "created_at": datetime.utcnow(),
            "profile_image_url": None,
        }
        await db.users.insert_one(user)
    
    return ProfileInfo(
        user_id=user["_id"],
        name=user.get("name", ""),
        email=user.get("email", ""),
        created_at=user.get("created_at", datetime.utcnow()),
        profile_image_url=user.get("profile_image_url"),
    )


@router.patch("/me", response_model=ProfileInfo)
async def update_profile(update: ProfileUpdate):
    """Update user profile information."""
    db = get_db()
    
    update_data = {k: v for k, v in update.dict(exclude_unset=True).items() if v is not None}
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    update_data["updated_at"] = datetime.utcnow()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {"$set": update_data},
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    return ProfileInfo(
        user_id=result["_id"],
        name=result.get("name", ""),
        email=result.get("email", ""),
        created_at=result.get("created_at", datetime.utcnow()),
        profile_image_url=result.get("profile_image_url"),
    )


# ============================================================================
# 2. Dietary Profile
# ============================================================================

@router.get("/dietary", response_model=DietaryProfile)
async def get_dietary_profile():
    """Get complete dietary profile."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    dietary = user.get("dietary_profile", {})
    return DietaryProfile(
        allergies=dietary.get("allergies", []),
        dislikes=dietary.get("dislikes", []),
        dietary_restrictions=dietary.get("dietary_restrictions", []),
        updated_at=dietary.get("updated_at"),
    )


@router.patch("/dietary", response_model=DietaryProfile)
async def update_dietary_profile(update: DietaryProfileUpdate):
    """Update dietary profile (partial update)."""
    db = get_db()
    
    update_data = update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    # Prefix all fields with dietary_profile
    set_data = {f"dietary_profile.{k}": v for k, v in update_data.items()}
    set_data["dietary_profile.updated_at"] = datetime.utcnow()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {"$set": set_data},
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    dietary = result.get("dietary_profile", {})
    return DietaryProfile(
        allergies=dietary.get("allergies", []),
        dislikes=dietary.get("dislikes", []),
        dietary_restrictions=dietary.get("dietary_restrictions", []),
        updated_at=dietary.get("updated_at"),
    )


@router.get("/dietary/allergies", response_model=AllergiesList)
async def get_allergies():
    """Get allergies list."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    allergies = user.get("dietary_profile", {}).get("allergies", [])
    return AllergiesList(allergies=allergies)


@router.put("/dietary/allergies", response_model=AllergiesList)
async def set_allergies(data: AllergiesList):
    """Set allergies list (replace)."""
    db = get_db()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {
            "$set": {
                "dietary_profile.allergies": data.allergies,
                "dietary_profile.updated_at": datetime.utcnow(),
            }
        },
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    return AllergiesList(allergies=result.get("dietary_profile", {}).get("allergies", []))


@router.get("/dietary/dislikes", response_model=DislikesList)
async def get_dislikes():
    """Get dislikes list."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    dislikes = user.get("dietary_profile", {}).get("dislikes", [])
    return DislikesList(dislikes=dislikes)


@router.put("/dietary/dislikes", response_model=DislikesList)
async def set_dislikes(data: DislikesList):
    """Set dislikes list (replace)."""
    db = get_db()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {
            "$set": {
                "dietary_profile.dislikes": data.dislikes,
                "dietary_profile.updated_at": datetime.utcnow(),
            }
        },
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    return DislikesList(dislikes=result.get("dietary_profile", {}).get("dislikes", []))


# ============================================================================
# 3. Preferences
# ============================================================================

@router.get("/preferences", response_model=Preferences)
async def get_preferences():
    """Get all user preferences."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    prefs = user.get("preferences", {})
    return Preferences(
        metric_units=prefs.get("metric_units", True),
        notifications_enabled=prefs.get("notifications_enabled", True),
        offline_mode=prefs.get("offline_mode", False),
        theme=prefs.get("theme", "light"),
        language=prefs.get("language", "en"),
    )


@router.patch("/preferences", response_model=Preferences)
async def update_preferences(update: PreferencesUpdate):
    """Update preferences (partial update)."""
    db = get_db()
    
    update_data = update.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    # Prefix all fields with preferences
    set_data = {f"preferences.{k}": v for k, v in update_data.items()}
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {"$set": set_data},
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    prefs = result.get("preferences", {})
    return Preferences(
        metric_units=prefs.get("metric_units", True),
        notifications_enabled=prefs.get("notifications_enabled", True),
        offline_mode=prefs.get("offline_mode", False),
        theme=prefs.get("theme", "light"),
        language=prefs.get("language", "en"),
    )


@router.get("/preferences/units", response_model=UnitPreference)
async def get_unit_preference():
    """Get unit preference."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    metric = user.get("preferences", {}).get("metric_units", True)
    return UnitPreference(metric_units=metric)


@router.put("/preferences/units", response_model=UnitPreference)
async def set_unit_preference(data: UnitPreference):
    """Set unit preference."""
    db = get_db()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {"$set": {"preferences.metric_units": data.metric_units}},
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    return UnitPreference(metric_units=result.get("preferences", {}).get("metric_units", True))


# ============================================================================
# 4. Goals
# ============================================================================

@router.get("/goals", response_model=Goals)
async def get_goals():
    """Get user goals."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    goals = user.get("goals", {})
    return Goals(
        goals=goals.get("list", []),
        primary_goal=goals.get("primary"),
        updated_at=goals.get("updated_at"),
    )


@router.put("/goals", response_model=Goals)
async def set_goals(data: GoalsUpdate):
    """Set/replace goals."""
    db = get_db()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {
            "$set": {
                "goals.list": data.goals,
                "goals.primary": data.primary_goal,
                "goals.updated_at": datetime.utcnow(),
            }
        },
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    goals = result.get("goals", {})
    return Goals(
        goals=goals.get("list", []),
        primary_goal=goals.get("primary"),
        updated_at=goals.get("updated_at"),
    )


@router.post("/goals", response_model=Goals, status_code=status.HTTP_201_CREATED)
async def add_goal(data: GoalAdd):
    """Add a goal to the list."""
    db = get_db()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {
            "$addToSet": {"goals.list": data.goal},
            "$set": {"goals.updated_at": datetime.utcnow()},
        },
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    goals = result.get("goals", {})
    return Goals(
        goals=goals.get("list", []),
        primary_goal=goals.get("primary"),
        updated_at=goals.get("updated_at"),
    )


@router.delete("/goals/{goal}", response_model=Goals)
async def remove_goal(goal: str):
    """Remove a goal from the list."""
    db = get_db()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {
            "$pull": {"goals.list": goal},
            "$set": {"goals.updated_at": datetime.utcnow()},
        },
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    goals = result.get("goals", {})
    return Goals(
        goals=goals.get("list", []),
        primary_goal=goals.get("primary"),
        updated_at=goals.get("updated_at"),
    )


# ============================================================================
# 5. Account Management
# ============================================================================

@router.get("/account/subscription", response_model=Subscription)
async def get_subscription():
    """Get subscription information."""
    db = get_db()
    user = await db.users.find_one({"_id": MOCK_USER_ID})
    
    if not user:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    sub = user.get("subscription", {})
    return Subscription(
        tier=sub.get("tier", "free"),
        status=sub.get("status", "active"),
        started_at=sub.get("started_at"),
        expires_at=sub.get("expires_at"),
        auto_renew=sub.get("auto_renew", True),
        payment_method=sub.get("payment_method"),
    )


@router.put("/account/subscription", response_model=Subscription)
async def update_subscription(data: SubscriptionUpdate):
    """Update subscription."""
    db = get_db()
    
    update_data = data.dict(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")
    
    set_data = {f"subscription.{k}": v for k, v in update_data.items()}
    set_data["subscription.updated_at"] = datetime.utcnow()
    
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {"$set": set_data},
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    sub = result.get("subscription", {})
    return Subscription(
        tier=sub.get("tier", "free"),
        status=sub.get("status", "active"),
        started_at=sub.get("started_at"),
        expires_at=sub.get("expires_at"),
        auto_renew=sub.get("auto_renew", True),
        payment_method=sub.get("payment_method"),
    )


@router.delete("/account", response_model=AccountDeletionResponse)
async def delete_account(data: AccountDeletion):
    """Delete user account (soft delete with 30-day retention)."""
    if data.confirmation != "DELETE_MY_ACCOUNT":
        raise HTTPException(
            status_code=400,
            detail="Confirmation string must be 'DELETE_MY_ACCOUNT'",
        )
    
    db = get_db()
    deleted_at = datetime.utcnow()
    
    # Soft delete: mark as deleted, keep data for 30 days
    result = await db.users.find_one_and_update(
        {"_id": MOCK_USER_ID},
        {
            "$set": {
                "deleted_at": deleted_at,
                "deletion_reason": data.reason,
                "status": "deleted",
            }
        },
        return_document=True,
    )
    
    if not result:
        raise HTTPException(status_code=404, detail="Profile not found")
    
    return AccountDeletionResponse(
        status="account_deleted",
        deleted_at=deleted_at,
        data_retention_days=30,
    )
