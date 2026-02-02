This is **Document 2 of 5**. This document details the server-side logic, database schema, infrastructure, and the specific algorithms that power the "Bio-Adaptive" and "Computer Vision" features.

---

# **Project Bio AI: Backend Architecture & Database Specification (v1.0)**

## **1. Architectural Pattern: Hybrid Event-Driven Microservices**

To satisfy the requirements of **Battery Efficiency**, **Low Latency**, and **High Computational Power** (for Vision), we will use a **BFF (Backend for Frontend)** pattern backed by an Event-Driven architecture on AWS.

### **1.1. High-Level Data Flow**

1.  **The Client (Mobile)** talks _only_ to the **BFF Layer** via REST API.
2.  **The BFF Layer** aggregates data from the **Core Services** (Profile, Nutrition, Sync).
3.  **The Vision Engine** runs asynchronously. The App uploads an image directly to S3, which triggers the heavy GPU processing pipelines without blocking the App UI.
4.  **The Database** is a unified PostgreSQL instance using **JSONB** for flexibility and **TimescaleDB** for high-performance health data.

---

## **2. Infrastructure Specification (AWS Stack)**

### **2.1. Compute Layer**

- **API Gateway:** AWS API Gateway (HTTP API) - Routes requests to the BFF.
- **BFF & Business Logic:** AWS Lambda (Python 3.11 / FastAPI).
    - _Why:_ Scales to zero cost when not in use. Excellent for "bursty" traffic like meal logging.
- **Async Processing:** AWS SQS (Simple Queue Service) + Lambda.
    - _Use Case:_ Processing "Batch Health Sync" and "Background Energy Score Calculation."

### **2.2. The "Vision Cluster" (Serverless GPU)**

- **Provider:** **RunPod Serverless** or **AWS SageMaker Async Inference**.
    - _Recommendation:_ **RunPod** (Cost efficiency is ~4x better than AWS for sporadic usage).
- **Models Hosted:**
    1.  **Segment Anything (SAM):** For object masking.
    2.  **Depth Anything V2:** For Z-axis estimation.
    3.  **Qwen2.5-VL (or GPT-4o via API):** For Classification & Density lookup.
- **Trigger:** S3 Event Notification -> Lambda Orchestrator -> GPU Endpoint.

### **2.3. Storage Layer**

- **Database:** Amazon RDS for PostgreSQL (db.t4g.medium).
    - _Extension:_ **TimescaleDB** (Must be installed for Time-Series health data).
- **Object Storage:** AWS S3.
    - `Bio AI-upload-raw`: Temporary landing zone for images (Lifecycle: Delete after 24h).
    - `Bio AI-training-data`: Permanent storage for user-confirmed images (Intelligent Tiering).
- **Caching:** AWS ElastiCache (Redis).
    - _Use Case:_ Caching the "Today's Meal Plan" JSON to avoid re-querying the AI Logic on every dashboard refresh.

---

## **3. Database Schema Specification (PostgreSQL)**

This schema handles the relational profile data, the "NoSQL" style food metadata, and the high-frequency wearable data.

### **3.1. Core Tables (`users`, `profile`)**

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    cognito_sub VARCHAR(255) UNIQUE, -- AWS Cognito ID
    created_at TIMESTAMPTZ DEFAULT NOW(),
    tier VARCHAR(50) DEFAULT 'free' -- 'free', 'pro_monthly', 'pro_annual'
);

CREATE TABLE bio_profile (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    height_cm INT,
    weight_kg DECIMAL(5,2),
    birth_date DATE,
    gender VARCHAR(20),

    -- Goals & Rules
    primary_goal VARCHAR(50), -- 'fat_loss', 'hypertrophy'
    dietary_preference VARCHAR(50), -- 'keto', 'vegan'
    allergies TEXT[], -- Array ['peanuts', 'gluten']
    dislikes TEXT[], -- Array ['cilantro']

    -- Fasting Config
    is_fasting_enabled BOOLEAN DEFAULT FALSE,
    fasting_start_time TIME, -- 20:00
    fasting_end_time TIME, -- 12:00

    PRIMARY KEY (user_id)
);
```

### **3.2. Time-Series Health Data (`health_metrics`)**

This uses **TimescaleDB**. We do not store every second. We store "Batch Aggregates" (e.g., 15-minute chunks) synced from the phone.

```sql
CREATE TABLE health_metrics (
    time TIMESTAMPTZ NOT NULL,
    user_id UUID REFERENCES users(id),
    source VARCHAR(50), -- 'apple_health', 'garmin'

    -- Metrics
    steps_delta INT, -- Steps taken in this time block
    active_energy_kcal DECIMAL,
    resting_hr INT,
    hrv_ms INT,
    sleep_score INT, -- Only present in the "Morning" sync

    UNIQUE(time, user_id, source)
);

-- Convert to Hypertable for performance
SELECT create_hypertable('health_metrics', 'time');
```

### **3.3. Smart Kitchen (`pantry`, `leftovers`, `food_logs`)**

The `meta_data` column in `food_logs` is critical for your requirement to store specific food details (e.g., bread vs. butter calories) without creating infinite columns.

```sql
CREATE TABLE pantry_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    item_name VARCHAR(100),
    category VARCHAR(50), -- 'veg', 'protein'
    expiry_date DATE,
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE leftovers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    recipe_name VARCHAR(150),

    -- Tracking
    total_servings DECIMAL(4,1),
    remaining_servings DECIMAL(4,1),
    calories_per_serving INT,
    macros_json JSONB, -- {"p": 20, "c": 30, "f": 10}

    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN GENERATED ALWAYS AS (remaining_servings > 0) STORED
);

CREATE TABLE food_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    log_time TIMESTAMPTZ DEFAULT NOW(),

    -- Core Data
    food_name VARCHAR(200),
    calories INT,
    protein_g INT,
    carbs_g INT,
    fats_g INT,

    -- Context
    meal_type VARCHAR(20), -- 'breakfast', 'snack'
    is_caffeine BOOLEAN DEFAULT FALSE,
    is_alcohol BOOLEAN DEFAULT FALSE,

    -- The "Meta" Requirement
    -- Stores breakdown: {"bread": 120, "butter": 50}
    -- Stores evidence: {"image_url": "s3://...", "scan_depth_map": "..."}
    meta_data JSONB
);
```

### **3.4. AI Recommendations (`daily_plan`)**

This table stores the state of the "AI Brain" so we don't have to regenerate the plan every time the user opens the app.

```sql
CREATE TABLE daily_plan (
    id UUID PRIMARY KEY,
    user_id UUID,
    date DATE,

    -- The Dynamic Targets (Adjusted by Bio-Data)
    target_calories INT,
    target_protein INT,

    -- The Current Suggestion
    next_meal_suggestion JSONB, -- {"food": "Salmon", "reason": "High Stress"}

    -- Feedback Loop
    rejected_suggestions JSONB[] -- History of what user said "No" to today
);
```

---

## **4. The BFF Layer (Logic & Algorithms)**

The BFF acts as the orchestrator. Here are the key endpoints and their underlying logic.

### **4.1. Endpoint: `POST /sync/batch` (The Bio-Loop)**

- **Input:** Gzipped JSON from Mobile (Last 60 mins of HealthKit data).
- **Logic:**
    1.  **Ingest:** Unzip and `INSERT` into `health_metrics`.
    2.  **Trigger:** Fire an Async Event `CalculateEnergyScore`.
    3.  **Algorithm (Energy Score):**
        - Fetch today's `sleep_score` (0-100).
        - Fetch avg `hrv` for last 4 hours vs 30-day baseline.
        - `Score = (Sleep * 0.4) + ((HRV / Baseline) * 30) + (Subj_Feel * 0.3) - (Activity_Fatigue_Factor)`.
    4.  **Reaction:**
        - If `Score` drops below threshold (e.g., 40), trigger `UpdateDailyPlan`.
        - `UpdateDailyPlan`: Change Dinner suggestion to "High Carb / Low Cortisol" (e.g., Sweet Potato & Poultry).

### **4.2. Endpoint: `GET /dashboard/state`**

- **Logic:**
    1.  **Fetch Cache:** Check Redis for `user:123:dashboard`. If exists, return.
    2.  **Fetch DB:** Query `daily_plan`, `food_logs` (sum), `bio_profile` (fasting window).
    3.  **Calculate Rings:**
        - _Outer:_ Time progression logic.
        - _Inner:_ `Sum(food_logs.calories) / daily_plan.target_calories`.
    4.  **Determine Status:** Compare Inner vs Outer ring.
    5.  **Return JSON:**
        ```json
        {
          "rings": { "outer_percent": 0.65, "inner_percent": 0.50 },
          "status_msg": "Fuel Up - You are behind schedule.",
          "fasting_active": false,
          "ai_card": { ... }
        }
        ```

### **4.3. Endpoint: `POST /pantry/leftovers/consume`**

- **Input:** `{ leftover_id: "...", consumed_servings: 1.5 }`
- **Logic:**
    1.  **DB Update:**
        ```sql
        UPDATE leftovers
        SET remaining_servings = remaining_servings - 1.5
        WHERE id = ...
        RETURNING calories_per_serving, macros_json;
        ```
    2.  **Log Food:** Create entry in `food_logs` with calculated macros (`1.5 * calories_per_serving`).

---

## **5. The "Dragunov" Vision Pipeline (Backend)**

This is the system design for the Volume/Calorie estimation.

### **5.1. The Flow**

1.  **Upload:** Mobile uploads image to `s3://Bio AI-input/user_123/scan_ID.jpg`.
    - _Metadata:_ `x-amz-meta-pitch: 45.2` (Gyro angle).
2.  **Trigger:** S3 Event -> **Lambda Orchestrator**.
3.  **GPU Processing (RunPod/SageMaker):**
    - **Input:** Image + Pitch Angle.
    - **Stage 1 (Segmentation):** Run **SAM**. Returns masks for food items.
    - **Stage 2 (Depth):** Run **Depth Anything V2**. Returns relative depth map (0-255).
    - **Stage 3 (Scale Logic):**
        - _Geometry:_ Using the Phone Camera FOV (extracted from EXIF) and the Pitch Angle (45°), we estimate the distance to the table center.
        - _Pixel Scale:_ `1 pixel = X cm`.
        - _Volume Integration:_ Sum the volume of the "Food Mask" above the "Table Plane".
    - **Stage 4 (Identification):** Run **VLM (Qwen/GPT)** to identify "Fried Rice".
        - _Density Lookup:_ Query DB for "Fried Rice Density" (~0.65 g/cm³).
    - **Calculation:** `Mass = Volume * Density`. `Calories = Mass * Kcal_per_g`.
4.  **Result:** Save JSON to `food_logs` (status: `pending_confirmation`).
5.  **Notify:** Send Push Notification / Websocket msg to App: "Scan Complete. Tap to Confirm."

---

## **6. External Integrations (API Management)**

### **6.1. Restaurant Search (Perplexity/Google)**

- **Endpoint:** `GET /bff/restaurant/menu?name=Starbucks`
- **Cache Strategy:**
    - Check `restaurant_cache` table first.
    - If miss:
        1.  Call **Google Places API** to get details.
        2.  Call **LLM Agent** (Perplexity/Gemini) with prompt: _"Extract menu items with macros for Starbucks. Return JSON."_
        3.  Save to Cache (TTL: 7 days).

---

## **7. Security & Compliance**

1.  **Data Privacy:** All health data in `health_metrics` is encrypted at rest (AWS KMS).
2.  **Anonymization:** When training our custom AI models later, `user_id` is stripped from `food_logs`.
3.  **Authentication:** AWS Cognito or Firebase Auth. The BFF validates the JWT token on every request.

---
