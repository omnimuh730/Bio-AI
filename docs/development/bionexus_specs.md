# BioNexus Service — README & Design 🗄️

**Role**

BioNexus is the authoritative storage and retrieval service for user-centric data: health metrics (time-series), food logs and vision metadata, canonical food references and embeddings, and AI audit logs. It provides a simple API for ingestion and query, offers vector similarity search for recommendation pipelines, and enforces indexing/retention policies to balance performance and cost.

**Architecture Summary**

- Backend: FastAPI (Python) microservice exposing ingest and query endpoints.
- Primary storage: MongoDB Atlas (Time-Series for metrics, Collections for logs and reference data).
- Secondary features: Vector indexes (for semantic/embedding similarity), TTLs for audit data, geospatial indexes for restaurants.

**Responsibilities**

- Ingest and persist high-frequency health metrics efficiently (time-series collection).
- Store vision output and links to media (S3), and provide a mapping from vision results → food logs.
- Maintain a canonical global food catalog with embeddings used by the recommendation pipeline.
- Provide observability/audit logs to trace model predictions and support RLHF workflows.

**Tech Stack**

- Framework: FastAPI (Python 3.11+)
- Database: MongoDB Atlas (Time-Series, Vector/knn indexes)
- Object storage: S3 (media & depth maps)
- Messaging (optional): Redis Streams or Kafka for background processing
- Observability: OpenTelemetry + Prometheus + Loki

**API Surface & Example Endpoints**

- POST /api/v1/metrics/batch — Ingest health metrics (time-series batch).
- POST /api/v1/vision/result — Store vision output and S3 pointers.
- POST /api/v1/food_logs — Create user food log (links to vision metadata if present).
- GET /api/v1/foods/search?query= — Text / embedding search over `Global_Foods`.
- GET /api/v1/users/{id} — Read user profile and metadata.

**Folder Structure (proposed)**

```
bio_nexus/
├── app/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── endpoints/
│   │   │   │   ├── metrics.py
│   │   │   │   ├── vision.py
│   │   │   │   ├── foods.py
│   │   │   │   └── users.py
│   ├── core/
│   │   └── config.py
│   ├── db/
│   │   └── mongodb.py
│   └── services/
└── tests/
```

**Data Model Notes & Indexing Rationale**

- Health metrics: Use MongoDB Time-Series with `timestamp` as the timeField and `metadata` as the metaField for efficient time-range and multi-index queries (user_id + sensor_type).
- Global_Foods: add a text index on `name` and a vector index on `embedding_vector` to support combined text + semantic search.
- AI_Audit_Logs: TTL index (e.g., 365 days) to bound storage and keep recent audit trails available.

**Operational Runbook**

- Backups: Use Atlas scheduled snapshots and periodic exports of vector indexes.
- Index maintenance: Monitor index sizes; re-index during low-traffic windows.
- High write volumes: Horizontally scale shards and buffer writes via Redis Streams when needed.

**Environment Variables**

- MONGODB_URI (Atlas connection)
- S3_BUCKET_NAME
- REDIS_URL (if using streams)
- OAUTH_PUBLIC_KEY_URL (for any auth verification)

**Local Development & Run**

```bash
# 1. Create a venv and install
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt

# 2. Run the service
uvicorn app.main:app --reload --port 8000
```

**Monitoring & Alerts**

- Track ingest lag, time-series write failure rate, vector-index query latency, and TTL purge errors.
- Alert on: sustained increase in write latency, vector query 95th percentile latency > 200ms, sudden drop in incoming metrics.

## Diagram

```mermaid
classDiagram
direction TB

    %% ==========================================
    %% 1. SYSTEM CONTEXT (THE GATEKEEPER)
    %% ==========================================
    class BioNexus_Service {
        <<Microservice>>
        +Ingest_Health_Metrics()
        +Log_Vision_Result()
        +Query_Food_Vector()
        +Get_User_State()
    }

    %% ==========================================
    %% 2. DATA STORAGE LAYER (MONGODB ATLAS)
    %% ==========================================

    namespace Identity_and_Profile {
        class Users {
            <<Collection>>
            +_id: ObjectId [PK]
            +email: String [Unique]
            +auth_provider_id: String
            +created_at: ISODate
            +subscription_tier: Enum [Free, Pro]
            +profile: Object
            +goals: Object
            +settings: Object
        }

        class User_Profile_SubDoc {
            <<Embedded>>
            +height_cm: Int
            +weight_kg: Float
            +birth_date: ISODate
            +allergies: List[String]
            +dislikes: List[String]
            +fasting_window: start: "20:00", end: "12:00"
        }
    }

    namespace Health_TimeSeries_Engine {
        class Health_Metrics {
            <<Time-Series Collection>>
            %% Clustered by time, granularity: 'minutes'
            +timestamp: ISODate [TimeSeries Key]
            +metadata: Object [Meta Key]
            +measurements: Object
        }

        class Health_Meta {
            <<Meta Field>>
            +user_id: String [Indexed]
            +device_source: Enum [AppleHealth, Garmin]
            +sensor_type: Enum [HR, Steps, Sleep]
        }

        class Health_Measurements {
            <<Data Field>>
            +heart_rate_bpm: Int
            +hrv_ms: Int
            +step_count_delta: Int
            +stress_score: Int (0-100)
            +sleep_quality: Int (0-100)
        }
    }

    namespace Nutrition_and_Vision {
        class Food_Logs {
            <<Collection>>
            %% The Master Record of "What I Ate"
            +_id: ObjectId
            +user_id: ObjectId [Indexed]
            +timestamp: ISODate
            +meal_type: Enum [Breakfast, Lunch, Dinner, Snack]
            +is_verified_by_user: Boolean
            +summary_macros: kcal, p, c, f
            +vision_data: Object
        }

        class Vision_Metadata {
            <<Embedded>>
            +input_image_s3_url: String
            +depth_map_s3_url: String
            +gyro_pitch_degrees: Float
            +lighting_lux: Int
            +ai_confidence_score: Float
            +detected_items: List[Object]
        }

        class Global_Foods {
            <<Collection>>
            %% Reference DB (FatSecret Cache + User Custom)
            +_id: ObjectId
            +external_source_id: String [Unique]
            +name: String [Text Index]
            +brand: String
            +serving_size: qty: Float, unit: String
            +macros_per_100g: kcal, p, c, f
            +embedding_vector: Array[Float] [Vector Index]
        }
    }

    namespace AI_and_Learning {
        class AI_Audit_Logs {
            <<Collection>>
            %% "Black Box" Recorder for RLHF
            +_id: ObjectId
            +trace_id: String [Indexed]
            +model_version: String
            +timestamp: ISODate [TTL Index: 365 Days]
            +input_context: JSON
            +output_prediction: JSON
            +user_feedback_action: Enum [Accepted, Rejected, Edited]
        }
    }

    namespace Spatial_Context {
        class Restaurants {
            <<Collection>>
            +_id: ObjectId
            +name: String
            +location: GeoJSON Point [2dsphere Index]
            +menu_last_updated: ISODate
            +menu_items: List[Object]
        }

        class Menu_Item {
            <<Embedded>>
            +name: String
            +price: Float
            +macros: kcal, p, c, f
            +tags: List[String] [Indexed]
            +vector_embedding: Array[Float] [Vector Index]
        }
    }

    %% ==========================================
    %% 3. RELATIONSHIPS & FLOW
    %% ==========================================

    BioNexus_Service --> Users : Read/Write Profile
    BioNexus_Service --> Health_Metrics : Batch Write (TimeSeries)
    BioNexus_Service --> Food_Logs : Insert Log
    BioNexus_Service --> Global_Foods : Cache/Upsert
    BioNexus_Service --> AI_Audit_Logs : Log Inference
    BioNexus_Service --> Restaurants : Geo-Spatial Search

    Users "1" *-- "1" User_Profile_SubDoc : Embeds
    Health_Metrics *-- Health_Meta : Groups By
    Health_Metrics *-- Health_Measurements : Stores
    Food_Logs "1" *-- "1" Vision_Metadata : Embeds Link to S3
    Food_Logs --> Users : Belongs To
    AI_Audit_Logs --> Food_Logs : Links via Context
    Restaurants "1" *-- "N" Menu_Item : Embeds & Indexes

    %% Note on Infrastructure
    note for Health_Metrics "Config: timeseries: { timeField: 'timestamp', metaField: 'metadata', granularity: 'minutes' }"
    note for Restaurants "Index: location (2dsphere)"
    note for Menu_Item "Index: vector_embedding (knnVector)"
    note for AI_Audit_Logs "Index: timestamp (expireAfterSeconds: 31536000)"

```
