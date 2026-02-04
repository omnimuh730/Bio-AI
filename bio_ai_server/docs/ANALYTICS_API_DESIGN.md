# Analytics API Design

## Overview

Base URL: `/api/analytics`
Authentication: Bearer token (user ID extracted from JWT)

The Analytics API provides endpoints for tracking and analyzing user health metrics, including daily summaries, correlations between metrics, AI-generated insights, and timeline entries (meals, exercises, hydration, sleep).

---

## Endpoints

### 1. Dashboard Summary

**GET** `/api/analytics/summary`

Get daily summary including energy score, macro progress, and key metrics.

**Query Parameters:**

- `date` (string, ISO-8601): Target date (defaults to today)

**Response:** `DailySummary`

```json
{
	"date": "2023-10-27",
	"energy_score": {
		"value": 88,
		"label": "Excellent Energy",
		"trend": {
			"direction": "up",
			"percentage": 12,
			"message": "Your score improved by 12% this week. Consistent protein intake post-workout has improved your recovery speed."
		}
	},
	"metrics": {
		"calories": {
			"current": 1840,
			"goal": 2300,
			"unit": "kcal"
		},
		"protein": {
			"current": 118,
			"goal": 140,
			"unit": "g"
		},
		"carbs": {
			"current": 180,
			"goal": 250,
			"unit": "g"
		},
		"fats": {
			"current": 62,
			"goal": 75,
			"unit": "g"
		},
		"active_burn": {
			"value": 620,
			"unit": "kcal"
		},
		"sleep_score": {
			"value": 74,
			"max": 100
		},
		"hydration": {
			"current": 1800,
			"goal": 2500,
			"unit": "ml"
		},
		"steps": {
			"current": 8420,
			"goal": 10000
		}
	}
}
```

---

### 2. AI Insights

**GET** `/api/analytics/insights`

Get AI-generated weekly review and recommendations.

**Query Parameters:**

- `type` (string): `weekly` | `monthly` (defaults to `weekly`)
- `end_date` (string, ISO-8601): End date for the period (defaults to today)

**Response:** `InsightResponse`

```json
{
	"insight_id": "rev_9823",
	"type": "weekly",
	"text": "You hit your protein goal 5 of 7 days. Sleep quality improved by 10%. I will stop suggesting oatmeal for now.",
	"generated_at": "2023-10-27T08:00:00Z",
	"recommendations": [
		"Consider adding more healthy fats to breakfast",
		"Your hydration improves on workout days - keep it consistent"
	]
}
```

---

### 3. Correlation Analysis

**GET** `/api/analytics/correlation`

Get correlation data between two metrics over time.

**Query Parameters:**

- `metric_left` (string): First metric (calorie_intake, protein_intake, carb_intake, active_burn, hydration, sleep_quality, energy_score, hrv_stress, steps, mood)
- `metric_right` (string): Second metric (same options)
- `period` (string): `1W` | `1M` | `3M` (defaults to `1M`)
- `end_date` (string, ISO-8601): End date (defaults to today)

**Response:** `CorrelationData`

```json
{
	"period": "1M",
	"start_date": "2023-09-27",
	"end_date": "2023-10-27",
	"left_axis": {
		"metric": "calorie_intake",
		"label": "Calorie Intake",
		"unit": "kcal",
		"data": [
			{ "date": "2023-10-01", "value": 2100 },
			{ "date": "2023-10-02", "value": 2400 },
			{ "date": "2023-10-03", "value": 2250 }
		]
	},
	"right_axis": {
		"metric": "sleep_quality",
		"label": "Sleep Quality",
		"unit": "score",
		"data": [
			{ "date": "2023-10-01", "value": 65 },
			{ "date": "2023-10-02", "value": 72 },
			{ "date": "2023-10-03", "value": 68 }
		]
	},
	"correlation_coefficient": 0.45,
	"insights": [
		"Higher calorie intake correlates moderately with better sleep quality"
	]
}
```

---

### 4. Timeline Entries (History)

**GET** `/api/analytics/entries`

Get all timeline entries (meals, exercise, hydration, sleep) for a specific date.

**Query Parameters:**

- `date` (string, ISO-8601): Target date (defaults to today)
- `type` (string, optional): Filter by entry type (MEAL, EXERCISE, HYDRATION, SLEEP)

**Response:** `EntryList`

```json
{
	"date": "2023-10-27",
	"total_count": 12,
	"entries": [
		{
			"id": "ent_101",
			"type": "MEAL",
			"title": "Magnesium Power Bowl",
			"subtitle": "Quinoa, Avocado, Kale",
			"time": "12:00",
			"time_label": "12 PM",
			"value": 450,
			"value_display": "450",
			"unit": "kcal",
			"metadata": {
				"protein": 28,
				"carbs": 45,
				"fats": 18
			},
			"is_editable": true,
			"created_at": "2023-10-27T12:00:00Z",
			"updated_at": "2023-10-27T12:00:00Z"
		},
		{
			"id": "ent_102",
			"type": "EXERCISE",
			"title": "Morning Run",
			"subtitle": "Active Burn",
			"time": "07:00",
			"time_label": "07 AM",
			"value": 240,
			"value_display": "-240",
			"unit": "kcal",
			"metadata": {
				"duration_minutes": 30,
				"distance_km": 5.2,
				"avg_heart_rate": 145
			},
			"is_editable": true,
			"created_at": "2023-10-27T07:00:00Z",
			"updated_at": "2023-10-27T07:00:00Z"
		},
		{
			"id": "ent_103",
			"type": "HYDRATION",
			"title": "Hydration",
			"subtitle": "Water intake",
			"time": "06:00",
			"time_label": "06 AM",
			"value": 500,
			"value_display": "+500ml",
			"unit": "ml",
			"is_editable": true,
			"created_at": "2023-10-27T06:00:00Z",
			"updated_at": "2023-10-27T06:00:00Z"
		},
		{
			"id": "ent_104",
			"type": "SLEEP",
			"title": "Sleep Summary",
			"subtitle": "7h 25m, Restorative",
			"time": "06:00",
			"time_label": "06 AM",
			"value": 74,
			"value_display": "74",
			"unit": "score",
			"metadata": {
				"duration_minutes": 445,
				"deep_sleep_minutes": 120,
				"rem_sleep_minutes": 90,
				"quality": "restorative"
			},
			"is_editable": true,
			"created_at": "2023-10-27T06:00:00Z",
			"updated_at": "2023-10-27T06:00:00Z"
		}
	]
}
```

---

### 5. Entry Management (CRUD)

#### Create Entry

**POST** `/api/analytics/entries`

Add a new timeline entry.

**Request Body:** `EntryCreate`

```json
{
	"date": "2023-10-27",
	"time": "14:30",
	"type": "MEAL",
	"title": "Protein Bar",
	"subtitle": "Chocolate Peanut Butter",
	"value": 200,
	"metadata": {
		"protein": 20,
		"carbs": 15,
		"fats": 8
	}
}
```

**Response:** `Entry` (same as in GET entries list)

**Status Codes:**

- `201 Created`: Entry created successfully
- `400 Bad Request`: Invalid input data
- `404 Not Found`: User not found

---

#### Update Entry

**PATCH** `/api/analytics/entries/{entry_id}`

Update an existing entry (partial update).

**Path Parameters:**

- `entry_id` (string): Entry ID

**Request Body:** `EntryUpdate`

```json
{
	"title": "Oatmeal Bowl",
	"value": 350,
	"subtitle": "Rolled oats, Blueberry, Honey",
	"metadata": {
		"protein": 12,
		"carbs": 60,
		"fats": 8
	}
}
```

**Response:** `Entry`

**Status Codes:**

- `200 OK`: Entry updated successfully
- `404 Not Found`: Entry not found
- `403 Forbidden`: User doesn't own this entry

---

#### Delete Entry

**DELETE** `/api/analytics/entries/{entry_id}`

Delete a timeline entry.

**Path Parameters:**

- `entry_id` (string): Entry ID

**Response:** Empty body

**Status Codes:**

- `204 No Content`: Entry deleted successfully
- `404 Not Found`: Entry not found
- `403 Forbidden`: User doesn't own this entry

---

### 6. Metric History

**GET** `/api/analytics/metrics/history`

Get historical data for a specific metric over time.

**Query Parameters:**

- `metric` (string): Metric name (calorie_intake, protein_intake, etc.)
- `period` (string): `1W` | `1M` | `3M` | `6M` | `1Y`
- `end_date` (string, ISO-8601): End date (defaults to today)

**Response:** `MetricHistory`

```json
{
	"metric": "calorie_intake",
	"label": "Calorie Intake",
	"unit": "kcal",
	"period": "1M",
	"start_date": "2023-09-27",
	"end_date": "2023-10-27",
	"data": [
		{
			"date": "2023-10-01",
			"value": 2100,
			"goal": 2300,
			"percentage": 91
		},
		{
			"date": "2023-10-02",
			"value": 2400,
			"goal": 2300,
			"percentage": 104
		}
	],
	"statistics": {
		"average": 2250,
		"min": 1850,
		"max": 2600,
		"goal_achievement_rate": 0.75
	}
}
```

---

## MongoDB Schema

### Collection: `analytics_entries`

Timeline entries (meals, exercise, hydration, sleep).

```javascript
{
  "_id": "ent_101",
  "user_id": "user_123",
  "date": "2023-10-27",
  "time": "12:00",
  "type": "MEAL", // MEAL, EXERCISE, HYDRATION, SLEEP
  "title": "Magnesium Power Bowl",
  "subtitle": "Quinoa, Avocado, Kale",
  "value": 450,
  "unit": "kcal",
  "metadata": {
    "protein": 28,
    "carbs": 45,
    "fats": 18
    // Type-specific fields
  },
  "is_deleted": false,
  "created_at": ISODate("2023-10-27T12:00:00Z"),
  "updated_at": ISODate("2023-10-27T12:00:00Z")
}
```

**Indexes:**

- `{ "user_id": 1, "date": -1, "is_deleted": 1 }` - Query entries by user and date
- `{ "user_id": 1, "type": 1, "date": -1 }` - Filter by entry type
- `{ "user_id": 1, "created_at": -1 }` - Recent entries

---

### Collection: `daily_metrics`

Aggregated daily metrics for dashboard summary.

```javascript
{
  "_id": ObjectId("..."),
  "user_id": "user_123",
  "date": "2023-10-27",
  "energy_score": {
    "value": 88,
    "label": "Excellent Energy",
    "calculated_at": ISODate("2023-10-27T23:59:00Z")
  },
  "metrics": {
    "calories": { "current": 1840, "goal": 2300 },
    "protein": { "current": 118, "goal": 140 },
    "carbs": { "current": 180, "goal": 250 },
    "fats": { "current": 62, "goal": 75 },
    "active_burn": { "value": 620 },
    "sleep_score": { "value": 74 },
    "hydration": { "current": 1800, "goal": 2500 },
    "steps": { "current": 8420, "goal": 10000 }
  },
  "trends": {
    "energy_score": {
      "direction": "up",
      "percentage": 12,
      "comparison_period": "1W"
    }
  },
  "created_at": ISODate("2023-10-27T00:00:00Z"),
  "updated_at": ISODate("2023-10-27T23:59:00Z")
}
```

**Indexes:**

- `{ "user_id": 1, "date": -1 }` - Unique compound index
- `{ "user_id": 1, "date": 1 }` - Time-series queries

---

### Collection: `ai_insights`

AI-generated insights and recommendations.

```javascript
{
  "_id": "rev_9823",
  "user_id": "user_123",
  "type": "weekly", // weekly, monthly
  "start_date": "2023-10-20",
  "end_date": "2023-10-27",
  "text": "You hit your protein goal 5 of 7 days...",
  "recommendations": [
    "Consider adding more healthy fats to breakfast",
    "Your hydration improves on workout days - keep it consistent"
  ],
  "metrics_analyzed": ["protein", "sleep_quality", "hydration"],
  "generated_at": ISODate("2023-10-27T08:00:00Z"),
  "expires_at": ISODate("2023-11-03T08:00:00Z")
}
```

**Indexes:**

- `{ "user_id": 1, "generated_at": -1 }` - Recent insights
- `{ "expires_at": 1 }` - TTL index for auto-cleanup

---

## Error Responses

All endpoints return standard error responses:

**400 Bad Request:**

```json
{
	"detail": "Invalid metric type: invalid_metric"
}
```

**404 Not Found:**

```json
{
	"detail": "Entry not found"
}
```

**403 Forbidden:**

```json
{
	"detail": "You do not have permission to modify this entry"
}
```

---

## Notes

1. **Real-time Updates**: After creating/updating/deleting an entry, frontend should:
    - Re-fetch `GET /api/analytics/summary` to update dashboard
    - Re-fetch `GET /api/analytics/entries` to refresh timeline

2. **Caching**: Daily summaries can be cached for 5 minutes as they're expensive to calculate.

3. **Authentication**: All endpoints require valid JWT token. User ID is extracted from token.

4. **Entry Types**:
    - `MEAL`: Food intake with macros
    - `EXERCISE`: Physical activity with calorie burn
    - `HYDRATION`: Water/fluid intake
    - `SLEEP`: Sleep records with quality scores

5. **Metric Types** (for correlations):
    - `calorie_intake`, `protein_intake`, `carb_intake`, `fat_intake`
    - `active_burn`, `hydration`, `steps`
    - `sleep_quality`, `energy_score`, `hrv_stress`, `mood`

6. **Period Formats**:
    - `1W`: Last 7 days
    - `1M`: Last 30 days
    - `3M`: Last 90 days
    - `6M`: Last 180 days
    - `1Y`: Last 365 days
