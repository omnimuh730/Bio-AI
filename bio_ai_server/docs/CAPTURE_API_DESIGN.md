# Capture API Design

## Overview

Base URL: `/api/capture`
Authentication: Bearer token (user ID extracted from JWT)

The Capture API provides endpoints for food recognition through photo analysis and barcode scanning, enabling users to quickly log meals and track nutrition.

---

## Endpoints

### 1. Photo Analysis (Image Recognition)

**POST** `/api/capture/analyze/image`

Upload an image for AI-powered food recognition and nutritional estimation.

**Content-Type:** `multipart/form-data`

**Form Parameters:**

- `image` (file, required): Image file (jpg, png, heic)
- `user_timezone` (string, optional): User's timezone (e.g., "America/New_York") for meal time context

**Response:** `ImageAnalysisResponse`

```json
{
	"analysis_id": "scan_8823_xyz",
	"uploaded_at": "2023-10-27T14:15:30Z",
	"detected_items": [
		{
			"temp_id": "tmp_01",
			"name": "BBQ Pork Ribs",
			"confidence": 0.96,
			"default_serving": {
				"amount": 1.0,
				"unit": "half-rack"
			},
			"nutrition": {
				"calories": 450,
				"protein": 38,
				"carbs": 12,
				"fat": 28
			},
			"alternative_suggestions": [
				{
					"name": "Baby Back Ribs",
					"confidence": 0.82,
					"nutrition": {
						"calories": 420,
						"protein": 35,
						"carbs": 10,
						"fat": 26
					}
				}
			]
		},
		{
			"temp_id": "tmp_02",
			"name": "Coleslaw",
			"confidence": 0.88,
			"default_serving": {
				"amount": 1.0,
				"unit": "cup"
			},
			"nutrition": {
				"calories": 150,
				"protein": 2,
				"carbs": 18,
				"fat": 8
			}
		}
	],
	"total_nutrition": {
		"calories": 600,
		"protein": 40,
		"carbs": 30,
		"fat": 36
	},
	"meal_context": {
		"suggested_meal_type": "lunch",
		"suggested_time": "14:15"
	}
}
```

**Status Codes:**

- `200 OK`: Analysis successful
- `400 Bad Request`: Invalid image format or missing file
- `413 Payload Too Large`: Image file exceeds size limit (max 10MB)
- `422 Unprocessable Entity`: No food detected, image too blurry, or AI analysis failed

**Error Response:**

```json
{
	"detail": "No food items detected in the image. Please try a clearer photo."
}
```

---

### 2. Barcode Lookup

**GET** `/api/capture/barcode/{code}`

Look up food product information by barcode.

**Path Parameters:**

- `code` (string): Barcode number (UPC, EAN, etc.)

**Response:** `BarcodeResponse`

```json
{
	"found": true,
	"barcode": "5449000000996",
	"item": {
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
			"sugar": 0
		},
		"ingredients": "Carbonated water, caramel color, phosphoric acid, aspartame, ...",
		"allergens": [],
		"image_url": "https://cdn.bioai.com/products/coca-cola-zero.jpg"
	}
}
```

**Status Codes:**

- `200 OK`: Barcode found
- `404 Not Found`: Barcode not in database

**Error Response (404):**

```json
{
	"found": false,
	"barcode": "1234567890123",
	"message": "Product not found. You can manually enter nutrition information.",
	"suggestion": "Try searching by product name instead."
}
```

---

### 3. Confirm & Log Entry

**POST** `/api/capture/confirm`

Save confirmed food entry to user's timeline after review and adjustments.

**Request Body:** `CaptureConfirm`

```json
{
	"date": "2023-10-27",
	"time": "14:15",
	"type": "MEAL",
	"title": "BBQ Pork Ribs",
	"subtitle": "Lunch",
	"value": 450,
	"nutrition": {
		"protein": 38,
		"carbs": 12,
		"fat": 28
	},
	"serving_info": {
		"amount": 1.0,
		"unit": "half-rack"
	},
	"source": "scan_ai",
	"analysis_id": "scan_8823_xyz",
	"temp_id": "tmp_01"
}
```

**Fields:**

- `date` (string): ISO-8601 date
- `time` (string): HH:MM format
- `type` (string): Always "MEAL" for food entries
- `title` (string): Food name
- `subtitle` (string, optional): Meal context (breakfast, lunch, snack, etc.)
- `value` (number): Total calories
- `nutrition` (object): Macro breakdown
- `serving_info` (object, optional): Serving size information
- `source` (string): "scan_ai" | "barcode" | "manual"
- `analysis_id` (string, optional): Reference to analysis session
- `temp_id` (string, optional): Reference to specific detected item

**Response:** `CaptureConfirmResponse`

```json
{
	"id": "ent_205",
	"message": "Entry added successfully",
	"entry": {
		"id": "ent_205",
		"date": "2023-10-27",
		"time": "14:15",
		"title": "BBQ Pork Ribs",
		"value": 450,
		"type": "MEAL"
	},
	"daily_totals": {
		"calories": 1840,
		"protein": 118,
		"carbs": 180,
		"fat": 62
	}
}
```

**Status Codes:**

- `201 Created`: Entry logged successfully
- `400 Bad Request`: Invalid input data
- `404 Not Found`: User not found

---

### 4. Analysis History

**GET** `/api/capture/history`

Get recent image analysis sessions (for re-using previous scans).

**Query Parameters:**

- `limit` (integer, optional): Max results (default: 10, max: 50)
- `offset` (integer, optional): Pagination offset (default: 0)

**Response:** `AnalysisHistoryResponse`

```json
{
	"total_count": 25,
	"analyses": [
		{
			"analysis_id": "scan_8823_xyz",
			"uploaded_at": "2023-10-27T14:15:30Z",
			"thumbnail_url": "https://cdn.bioai.com/scans/thumb_8823.jpg",
			"detected_items_count": 2,
			"primary_item": "BBQ Pork Ribs",
			"was_logged": true
		},
		{
			"analysis_id": "scan_8822_abc",
			"uploaded_at": "2023-10-27T08:30:00Z",
			"thumbnail_url": "https://cdn.bioai.com/scans/thumb_8822.jpg",
			"detected_items_count": 1,
			"primary_item": "Oatmeal Bowl",
			"was_logged": true
		}
	]
}
```

---

### 5. Barcode Search (Manual Entry)

**GET** `/api/capture/search`

Search food database by name (fallback when barcode scan fails).

**Query Parameters:**

- `q` (string, required): Search query
- `limit` (integer, optional): Max results (default: 10)

**Response:** `FoodSearchResponse`

```json
{
	"query": "coca cola",
	"results": [
		{
			"id": "food_12345",
			"name": "Coca-Cola Zero Sugar",
			"brand": "Coca-Cola",
			"serving_size": "330ml",
			"calories": 0,
			"image_url": "https://cdn.bioai.com/products/coca-cola-zero.jpg"
		},
		{
			"id": "food_12346",
			"name": "Coca-Cola Classic",
			"brand": "Coca-Cola",
			"serving_size": "330ml",
			"calories": 139,
			"image_url": "https://cdn.bioai.com/products/coca-cola-classic.jpg"
		}
	]
}
```

---

## MongoDB Schema

### Collection: `food_analyses`

Image analysis sessions with detected food items.

```javascript
{
  "_id": "scan_8823_xyz",
  "user_id": "user_123",
  "image_url": "s3://bioai-uploads/user_123/scan_8823.jpg",
  "thumbnail_url": "s3://bioai-uploads/user_123/thumb_8823.jpg",
  "uploaded_at": ISODate("2023-10-27T14:15:30Z"),
  "detected_items": [
    {
      "temp_id": "tmp_01",
      "name": "BBQ Pork Ribs",
      "confidence": 0.96,
      "default_serving": {
        "amount": 1.0,
        "unit": "half-rack"
      },
      "nutrition": {
        "calories": 450,
        "protein": 38,
        "carbs": 12,
        "fat": 28
      },
      "alternative_suggestions": [...]
    }
  ],
  "total_nutrition": {
    "calories": 600,
    "protein": 40,
    "carbs": 30,
    "fat": 36
  },
  "meal_context": {
    "suggested_meal_type": "lunch",
    "suggested_time": "14:15"
  },
  "user_timezone": "America/New_York",
  "was_logged": true,
  "logged_entry_id": "ent_205",
  "created_at": ISODate("2023-10-27T14:15:30Z")
}
```

**Indexes:**

- `{ "user_id": 1, "uploaded_at": -1 }` - Recent analyses
- `{ "user_id": 1, "was_logged": 1 }` - Filter logged/unlogged

---

### Collection: `food_products`

Barcode database with product information.

```javascript
{
  "_id": "prod_5449000000996",
  "barcode": "5449000000996",
  "name": "Coca-Cola Zero Sugar",
  "brand": "Coca-Cola",
  "description": "Sugar-free cola beverage",
  "category": "beverages",
  "serving_size": "330ml",
  "servings_per_container": 1.0,
  "nutrition": {
    "calories": 0,
    "protein": 0,
    "carbs": 0,
    "fat": 0,
    "fiber": 0,
    "sugar": 0,
    "sodium": 40
  },
  "ingredients": "Carbonated water, caramel color, phosphoric acid, aspartame, ...",
  "allergens": [],
  "image_url": "https://cdn.bioai.com/products/coca-cola-zero.jpg",
  "verified": true,
  "source": "openfoodfacts",
  "created_at": ISODate("2023-01-15T00:00:00Z"),
  "updated_at": ISODate("2023-10-01T00:00:00Z")
}
```

**Indexes:**

- `{ "barcode": 1 }` - Unique barcode lookup
- `{ "name": "text", "brand": "text" }` - Text search
- `{ "category": 1, "verified": 1 }` - Category browsing

---

## AI Integration

### Image Analysis Pipeline

1. **Upload**: Image uploaded to S3, URL stored in MongoDB
2. **AI Processing**: Image sent to ML model (YOLOv8 + nutrition estimator)
3. **Detection**: Multiple food items detected with bounding boxes
4. **Nutrition Estimation**: Portion size + nutritional values calculated
5. **Response**: Results returned to client with confidence scores

### Supported Image Formats

- JPEG, PNG, HEIC
- Max file size: 10MB
- Recommended resolution: 1080p or higher
- Supports multiple food items per image

---

## Error Responses

All endpoints return standard error responses:

**400 Bad Request:**

```json
{
	"detail": "Invalid image format. Supported formats: jpg, png, heic"
}
```

**404 Not Found:**

```json
{
	"detail": "Barcode not found in database"
}
```

**413 Payload Too Large:**

```json
{
	"detail": "Image file too large. Maximum size is 10MB"
}
```

**422 Unprocessable Entity:**

```json
{
	"detail": "No food items detected in the image. Please try a clearer photo or adjust lighting."
}
```

---

## Integration Notes

1. **Frontend Flow:**
    - Camera/gallery → Upload image → Show detected items
    - User adjusts servings (frontend calculation)
    - User confirms → `POST /api/capture/confirm`
    - Navigate to Dashboard with updated totals

2. **Barcode Flow:**
    - Scan barcode → `GET /api/capture/barcode/{code}`
    - If not found, offer manual search
    - User reviews → confirms → `POST /api/capture/confirm`

3. **Offline Support:**
    - Cache recent barcode lookups
    - Queue image uploads when offline
    - Sync when connection restored

4. **Performance:**
    - Image analysis: ~2-4 seconds
    - Barcode lookup: <100ms (cached)
    - Confirm entry: <200ms

5. **Privacy:**
    - Images stored encrypted in S3
    - Auto-delete after 30 days (configurable)
    - Users can delete analysis history

---

## Data Sources

- **Barcode Database**: OpenFoodFacts API + proprietary database
- **AI Model**: Custom YOLOv8 + ResNet-based nutrition estimator
- **Nutrition Data**: USDA FoodData Central + manual curation
