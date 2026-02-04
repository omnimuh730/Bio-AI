# Profile API Design - Step 1

**Base Path:** `/api/profile`

## Endpoints Overview

### 1. Profile Information

```
GET  /api/profile/me          # Get user profile (name, basic info)
PATCH /api/profile/me         # Update profile information
```

### 2. Dietary Profile

```
GET  /api/profile/dietary            # Get full dietary profile
PATCH /api/profile/dietary           # Update dietary profile (allergies, dislikes)
GET  /api/profile/dietary/allergies  # Get allergies list
PUT  /api/profile/dietary/allergies  # Set allergies list
GET  /api/profile/dietary/dislikes   # Get dislikes list
PUT  /api/profile/dietary/dislikes   # Set dislikes list
```

### 3. Preferences

```
GET  /api/profile/preferences        # Get all preferences
PATCH /api/profile/preferences       # Update preferences
GET  /api/profile/preferences/units  # Get unit preference (metric: bool)
PUT  /api/profile/preferences/units  # Set unit preference
```

### 4. Goals

```
GET  /api/profile/goals              # Get goal list (string array)
PUT  /api/profile/goals              # Set/replace goals
POST /api/profile/goals              # Add a goal
DELETE /api/profile/goals/{goal}     # Remove a goal
```

### 5. Account Management

```
GET  /api/profile/account/subscription    # Get subscription status
PUT  /api/profile/account/subscription    # Update subscription
DELETE /api/profile/account               # Delete account (requires confirmation)
```

---

## Detailed Endpoint Specifications

### 1. Profile Information

#### GET /api/profile/me

**Description:** Get user profile information

**Response 200:**

```json
{
	"user_id": "user_123",
	"name": "John Doe",
	"email": "john@example.com",
	"created_at": "2026-01-15T10:30:00Z",
	"profile_image_url": "https://..."
}
```

#### PATCH /api/profile/me

**Description:** Update profile information

**Request Body:**

```json
{
	"name": "John Smith",
	"profile_image_url": "https://..."
}
```

**Response 200:** Updated profile object

---

### 2. Dietary Profile

#### GET /api/profile/dietary

**Description:** Get complete dietary profile

**Response 200:**

```json
{
	"allergies": ["peanuts", "shellfish", "dairy"],
	"dislikes": ["cilantro", "mushrooms"],
	"dietary_restrictions": ["vegetarian"],
	"updated_at": "2026-02-01T14:20:00Z"
}
```

#### PATCH /api/profile/dietary

**Description:** Update dietary profile (partial update)

**Request Body:**

```json
{
	"allergies": ["peanuts", "shellfish"],
	"dislikes": ["cilantro"]
}
```

**Response 200:** Updated dietary profile

#### GET /api/profile/dietary/allergies

**Response 200:**

```json
{
	"allergies": ["peanuts", "shellfish", "dairy"]
}
```

#### PUT /api/profile/dietary/allergies

**Description:** Replace allergies list

**Request Body:**

```json
{
	"allergies": ["peanuts", "tree nuts"]
}
```

**Response 200:**

```json
{
	"allergies": ["peanuts", "tree nuts"],
	"updated_at": "2026-02-04T10:15:00Z"
}
```

#### GET /api/profile/dietary/dislikes

**Response 200:**

```json
{
	"dislikes": ["cilantro", "mushrooms", "olives"]
}
```

#### PUT /api/profile/dietary/dislikes

**Description:** Replace dislikes list

**Request Body:**

```json
{
	"dislikes": ["cilantro", "olives"]
}
```

**Response 200:**

```json
{
	"dislikes": ["cilantro", "olives"],
	"updated_at": "2026-02-04T10:16:00Z"
}
```

---

### 3. Preferences

#### GET /api/profile/preferences

**Description:** Get all user preferences

**Response 200:**

```json
{
	"metric_units": true,
	"notifications_enabled": true,
	"offline_mode": false,
	"theme": "light",
	"language": "en"
}
```

#### PATCH /api/profile/preferences

**Description:** Update preferences (partial update)

**Request Body:**

```json
{
	"metric_units": false,
	"notifications_enabled": true
}
```

**Response 200:** Updated preferences object

#### GET /api/profile/preferences/units

**Response 200:**

```json
{
	"metric_units": true
}
```

#### PUT /api/profile/preferences/units

**Description:** Set unit preference

**Request Body:**

```json
{
	"metric_units": false
}
```

**Response 200:**

```json
{
	"metric_units": false,
	"updated_at": "2026-02-04T10:17:00Z"
}
```

---

### 4. Goals

#### GET /api/profile/goals

**Description:** Get user goals list

**Response 200:**

```json
{
	"goals": ["Lose Fat", "Build Muscle", "Improve Sleep"],
	"primary_goal": "Lose Fat",
	"updated_at": "2026-02-01T09:00:00Z"
}
```

#### PUT /api/profile/goals

**Description:** Replace goals list

**Request Body:**

```json
{
	"goals": ["Maintain & Cognitive", "Improve Energy"],
	"primary_goal": "Maintain & Cognitive"
}
```

**Response 200:**

```json
{
	"goals": ["Maintain & Cognitive", "Improve Energy"],
	"primary_goal": "Maintain & Cognitive",
	"updated_at": "2026-02-04T10:18:00Z"
}
```

#### POST /api/profile/goals

**Description:** Add a goal to the list

**Request Body:**

```json
{
	"goal": "Better Digestion"
}
```

**Response 201:**

```json
{
	"goals": ["Lose Fat", "Build Muscle", "Better Digestion"],
	"updated_at": "2026-02-04T10:19:00Z"
}
```

#### DELETE /api/profile/goals/{goal}

**Description:** Remove a specific goal

**Response 200:**

```json
{
	"goals": ["Lose Fat", "Build Muscle"],
	"updated_at": "2026-02-04T10:20:00Z"
}
```

---

### 5. Account Management

#### GET /api/profile/account/subscription

**Description:** Get subscription information

**Response 200:**

```json
{
	"tier": "pro",
	"status": "active",
	"started_at": "2026-01-15T00:00:00Z",
	"expires_at": "2027-01-15T00:00:00Z",
	"auto_renew": true,
	"payment_method": "card_****1234"
}
```

#### PUT /api/profile/account/subscription

**Description:** Update subscription (upgrade/downgrade/cancel)

**Request Body:**

```json
{
	"tier": "free",
	"auto_renew": false
}
```

**Response 200:**

```json
{
	"tier": "free",
	"status": "active",
	"auto_renew": false,
	"updated_at": "2026-02-04T10:21:00Z"
}
```

#### DELETE /api/profile/account

**Description:** Delete user account (requires confirmation token)

**Request Body:**

```json
{
	"confirmation": "DELETE_MY_ACCOUNT",
	"reason": "No longer needed"
}
```

**Response 200:**

```json
{
	"status": "account_deleted",
	"deleted_at": "2026-02-04T10:22:00Z",
	"data_retention_days": 30
}
```

---

## Error Responses

All endpoints return standard error responses:

**400 Bad Request:**

```json
{
	"detail": "Invalid request body"
}
```

**401 Unauthorized:**

```json
{
	"detail": "Authentication required"
}
```

**404 Not Found:**

```json
{
	"detail": "Profile not found"
}
```

**422 Validation Error:**

```json
{
	"detail": [
		{
			"loc": ["body", "allergies"],
			"msg": "field required",
			"type": "value_error.missing"
		}
	]
}
```

---

## MongoDB Collection Schema

**Collection:** `users`

```json
{
	"_id": "user_123",
	"email": "john@example.com",
	"name": "John Doe",
	"profile_image_url": "https://...",
	"created_at": "2026-01-15T10:30:00Z",
	"updated_at": "2026-02-04T10:00:00Z",

	"dietary_profile": {
		"allergies": ["peanuts", "shellfish"],
		"dislikes": ["cilantro"],
		"dietary_restrictions": []
	},

	"preferences": {
		"metric_units": true,
		"notifications_enabled": true,
		"offline_mode": false,
		"theme": "light",
		"language": "en"
	},

	"goals": {
		"list": ["Lose Fat", "Build Muscle"],
		"primary": "Lose Fat"
	},

	"subscription": {
		"tier": "pro",
		"status": "active",
		"started_at": "2026-01-15T00:00:00Z",
		"expires_at": "2027-01-15T00:00:00Z",
		"auto_renew": true
	}
}
```

---

## Authentication & Authorization

- All endpoints require valid JWT token in `Authorization: Bearer <token>` header
- User ID is extracted from JWT claims
- Users can only access/modify their own profile
- Admin endpoints (if needed) will have separate routes with role checks

---

## Implementation Notes

1. **Atomic Updates:** Use MongoDB `$set` for partial updates
2. **Validation:** Validate allergies/dislikes against known lists
3. **Audit Trail:** Log all profile modifications
4. **Caching:** Cache profile data with TTL for performance
5. **Rate Limiting:** Apply rate limits to prevent abuse
6. **Soft Delete:** Account deletion should be soft delete with 30-day grace period
