This is the full design and documentation for **`bio_storage`**.

In a production AI system, handling binary files (images) through your main API server is a bottleneck. It consumes RAM, blocks threads, and wastes bandwidth.

**`bio_storage`** is designed to solve this using the **Direct-to-Cloud (Presigned URL)** pattern.

> **UPDATED (MongoDB + S3 Architecture):** As of Feb 2026, `bio_storage` uses **MongoDB as canonical metadata store** with native vector search, and **S3 exclusively for file storage** (hot for recent, archive bucket for cold storage).

---

### **System Design: `bio_storage`**

```mermaid
classDiagram
    direction TB

    %% ==========================================
    %% 1. API & ACCESS CONTROL
    %% ==========================================
    namespace Storage_Interface {
        class File_Gateway {
            <<FastAPI>>
            +POST /upload/sign-url
            +GET /file/file_id/download-url
            +DELETE /file/file_id
        }

        class Access_Policy {
            <<Logic>>
            +validate_user_quota()
            +check_file_ownership()
            +generate_s3_policy()
        }
    }

    %% ==========================================
    %% 2. CLOUD STORAGE (AWS S3 / MINIO)
    %% ==========================================
    namespace Cloud_Bucket {
        class Bucket_Zone_A {
            <<S3: Temporary>>
            +Folder: /raw_scans/
            +Lifecycle: Delete after 24h
            +Purpose: Computer Vision Input
        }

        class Bucket_Zone_B {
            <<S3: Permanent>>
            +Folder: /user_gallery/
            +Format: WebP (Optimized)
            +Class: Intelligent Tiering (Cheaper)
            +Purpose: Food Logs / Memories
        }
    }

    %% ==========================================
    %% 3. POST-PROCESSING (ASYNC)
    %% ==========================================
    namespace Image_Processor {
        class Event_Listener {
            <<SQS Consumer / Webhook>>
            +on_file_uploaded()
        }

        class Optimizer {
            <<Pillow / FFmpeg>>
            +resize_to_thumbnail()
            +compress_to_webp()
            +strip_metadata(exif)
        }
    }

    %% ==========================================
    %% 4. METADATA TRACKING
    %% ==========================================
    class File_Registry_DB {
        <<MongoDB Collection>>
        +file_id (UUID)
        +user_id
        +s3_key
        +mime_type
        +size_bytes
        +is_public
        +embedding_vector (optional)
    }

    %% ==========================================
    %% 5. FLOWS
    %% ==========================================

    %% Upload Flow
    class Mobile_App {
        client
    }

    Mobile_App --> File_Gateway : 1. Request Upload Permit
    File_Gateway --> Access_Policy : 2. Check Quota
    Access_Policy --> File_Gateway : 3. Generate Presigned URL
    File_Gateway --> Mobile_App : 4. Return URL
    Mobile_App --> Bucket_Zone_A : 5. PUT Binary (Direct Upload)

    %% Processing Flow
    Bucket_Zone_A --> Event_Listener : 6. Trigger Event (S3 Notification)
    Event_Listener --> Optimizer : 7. Process Image
    Optimizer --> Bucket_Zone_B : 8. Save Optimized Version
    Event_Listener --> File_Registry_DB : 9. Register File

    %% Consumption Flow
    Mobile_App --> File_Gateway : 10. Get Image URL
    File_Gateway --> File_Registry_DB : 11. Lookup Key
    File_Gateway --> Mobile_App : 12. Return CDN Link

    note for Mobile_App "Performance Win:\nImages never pass through the server.\nThey go straight to AWS S3."
    note for Bucket_Zone_A "Cost Saving:\nRaw 4K photos are deleted automatically\nafter the Vision AI finishes."
```

---

### **Detailed README: `bio_storage`**

Below is the documentation for the `bio_storage` service folder.

---

# **📦 Bio Storage Service**

**Asset Management & Blob Handling**

`bio_storage` is a stateless microservice responsible for managing User Generated Content (UGC), specifically food images. It abstracts the underlying Object Storage (AWS S3, Google Cloud Storage, or MinIO) and provides secure, temporary access credentials.

It enforces the **Direct-to-Cloud** pattern, ensuring our backend API servers never handle heavy binary upload streams.

---

## **1. Architectural Role**

1.  **The Gatekeeper:** Instead of users uploading files to us, we give them a specific, time-limited "key" (Presigned URL) to upload directly to the bucket.
2.  **The Librarian:** Maintains a database registry of every file, its owner, size, and location. If a file isn't in the registry, it's considered "garbage" and cleaned up.
3.  **The Optimizer:** Listens for new uploads and automatically creates thumbnails and highly compressed WebP versions for the UI, keeping the high-res version only if needed.

---

## **2. Tech Stack**

- **Framework:** [FastAPI](https://fastapi.tiangolo.com/)
- **Storage SDK:** `boto3` (Standard Python interface for AWS S3 & MinIO)
- **Image Processing:** `Pillow` (PIL) for resizing and conversion.
- **Database:** MongoDB Atlas (File metadata, vector embeddings, time-series archive logs).
- **Events:** Redis Streams (event notifications for file uploads/archival).
- **Vector Search:** MongoDB Atlas Vector Search (native, no separate component).

---

## **3. Folder Structure**

```bash
bio_storage/
├── app/
│   ├── api/
│   │   └── v1/
│   │       ├── upload.py          # Generates Presigned URLs + stores metadata
│   │       ├── download.py        # Retrieves metadata + generates CDN links
│   │       ├── vector_search.py   # Vector similarity search
│   │       ├── archive.py         # Archive status and rehydration
│   │       └── webhooks.py        # S3 Event Listeners
│   ├── core/
│   │   ├── config.py              # AWS + MongoDB connection
│   │   └── security.py            # Token validation
│   ├── db/
│   │   └── mongodb.py             # MongoDB client & schema
│   ├── services/
│   │   ├── s3_provider.py         # Wrapper around Boto3
│   │   ├── image_optim.py         # Compression logic
│   │   ├── vector_engine.py       # Vector embedding & search
│   │   └── archive_manager.py     # Export to S3, cleanup, rehydrate
│   └── main.py
├── scripts/
│   ├── init_mongo.py              # Initialize collections & indexes
│   └── init_buckets.py            # Creates S3 buckets
├── tests/
├── Dockerfile
└── README.md
```

---

## **4. Key Workflows**

### **A. The "Presigned" Upload (Mobile -> S3)**

This is the only way to get a file into the system.

- **Endpoint:** `POST /api/v1/upload/sign`
- **Request:** `{ "filename": "steak.jpg", "content_type": "image/jpeg", "use_case": "vision_scan" }`
- **Logic:**
    1.  Validate file type (only allow images).
    2.  Determine bucket path (e.g., `temp/user_123/UUID.jpg`).
    3.  Call S3 `generate_presigned_url('put_object', ...)` with 60-second expiry.
    4.  Create a "Pending" entry in the DB.
- **Response:** `{ "upload_url": "https://s3.aws.com/...", "file_id": "UUID" }`
- **Mobile Action:** Uses standard `PUT` request to that URL.

### **B. Lifecycle Management (Cost Optimization)**

We implement two "Zones" of storage logic:

1.  **The Drop Zone (`bio-ai-raw`):**
    - Where images land initially.
    - **Lifecycle Policy:** Objects expire (delete) after 24 hours.
    - _Why:_ The Computer Vision engine needs the high-res 10MB photo to calculate volume. Once calculated, we don't need that massive file.

2.  **The Gallery Zone (`bio-ai-gallery`):**
    - Where images live permanently.
    - **Format:** Compressed WebP (Quality 80).
    - **Size:** Max 1080p.
    - _Why:_ This is what the user sees in their "Food Log" history. It costs 90% less to store than the raw file.

---

## **5. Environment Variables**

```ini
# App Config
PORT=8004
ENV="dev"

# Database (MongoDB)
MONGODB_URI="mongodb+srv://user:pass@cluster.mongodb.net/bio_ai_storage"
MONGO_DB_NAME="bio_ai_storage"

# Storage Provider (AWS or MinIO)
STORAGE_TYPE="minio"
AWS_ACCESS_KEY_ID="minioadmin"
AWS_SECRET_ACCESS_KEY="minioadmin"
AWS_REGION="us-east-1"
S3_ENDPOINT_URL="http://minio:9000"

# Buckets (Hot + Cold Archive)
BUCKET_HOT="bio-ai-hot"
BUCKET_ARCHIVE="bio-ai-archive"

# Vector Search Config
VECTOR_EMBEDDING_DIM=1536
VECTOR_SIMILARITY_THRESHOLD=0.75

# Archival Policy
ARCHIVE_THRESHOLD_DAYS=30
RETENTION_DAYS=90

# CDN (Optional)
CDN_DOMAIN="https://cdn.bioai.com"
```

---

## **6. Setup & Run**

### **Local Development (MinIO)**

We use MinIO to simulate AWS S3 locally so you don't pay cloud bills during development.

1.  **Start Infrastructure:**
    ```bash
    docker-compose up -d minio mongo
    ```
2.  **Initialize MongoDB Collections & Indexes:**
    ```bash
    python scripts/init_mongo.py
    # Output: Created collection 'files_metadata', created collection 'archive_log'
    ```
3.  **Initialize Buckets:**
    ```bash
    python scripts/init_buckets.py
    # Output: Created bucket 'bio-ai-hot', Created bucket 'bio-ai-archive'
    ```
4.  **Run Service:**
    ```bash
    poetry install
    uvicorn app.main:app --port 8004
    ```

### **Testing the Flow (cURL)**

```bash
# 1. Get a presigned URL
curl -X POST http://localhost:8004/api/v1/upload/sign \
     -H "Content-Type: application/json" \
     -d '{"filename": "test.jpg", "content_type": "image/jpeg", "user_id": "123"}'

# Response: {"upload_url": "http://minio:9000/...", "file_id": "UUID"}

# 2. Upload actual file
curl -X PUT -T ~/Desktop/test.jpg "http://minio:9000/..."

# 3. Search similar files by vector
curl -X POST http://localhost:8004/api/v1/files/search/vector \
     -H "Content-Type: application/json" \
     -d '{
       "user_id": "123",
       "query_embedding": [0.1, -0.2, 0.3, ...],
       "top_k": 5
     }'

# 4. Check archive status
curl http://localhost:8004/api/v1/archive/status
```

---

## **7. MongoDB Schema Overview**

### **files_metadata (Collection)**

Stores all file metadata with vector embeddings for similarity search.

```json
{
  "_id": "ObjectId",
  "user_id": "ObjectId",
  "file_id": "UUID",
  "s3_key": "hot/user_123/UUID.jpg",
  "mime_type": "image/jpeg",
  "size_bytes": 2500000,
  "upload_timestamp": "ISODate",
  "use_case": "vision_scan",
  "is_archived": false,
  "archive_s3_key": null,
  "archive_timestamp": null,
  "embedding_vector": [0.123, -0.456, ...],
  "embedding_model": "ada-002",
  "checksum_sha256": "abc123",
  "ttl_expire_at": "ISODate"
}
```

### **archive_log (Time-Series Collection)**

Tracks archival operations and metrics.

```json
{
	"timestamp": "ISODate",
	"metadata": {
		"user_id": "ObjectId",
		"operation": "archive|restore|purge"
	},
	"files_count": 42,
	"total_bytes_freed": 5000000,
	"s3_path_prefix": "archive/2026-02-02/",
	"status": "success|failed"
}
```

### **Recommended Indexes**

- `user_id + upload_timestamp` (compound, file history queries)
- `s3_key` (unique, locate by key)
- `embedding_vector` (vector index for similarity search)
- `ttl_expire_at` (TTL index for auto-cleanup at 90 days)
- `is_archived + archive_timestamp` (archive state queries)

---

## **8. New Endpoints (Vector Search + Archive)**

### **Vector Similarity Search**

- **POST** `/api/v1/files/search/vector`
- **Request:** `{ "user_id": "...", "query_embedding": [...], "top_k": 5, "min_similarity": 0.7 }`
- **Response:** Matching files with scores. **Use case:** Find visually similar meals to deduplicate logs or suggest recipes.

### **Archive Status**

- **GET** `/api/v1/archive/status`
- **Response:** `{ "total_archived": 1200, "pending_archive": 45, "next_purge_at": "2026-03-04T00:00:00Z" }`

### **Manual Rehydrate from Cold Storage**

- **POST** `/api/v1/archive/rehydrate`
- **Request:** `{ "s3_archive_key": "archive/2026-01-15/file.jpg", "user_id": "..." }`
- **Response:** File moved back to hot bucket; metadata updated.

---

## **9. Archival & Lifecycle Workflow**

### **Phase 1: Hot Storage (Days 0–30)**

- **Location:** S3 `bio-ai-hot` (Standard storage class)
- **MongoDB:** Full metadata + vector embedding indexed
- **Access:** Instant (milliseconds)
- **Use:** Recent meals, AI inference input, analytics

### **Phase 2: Cold Archive (Days 30–90)**

- **Location:** S3 `bio-ai-archive` (Glacier Flexible Retrieval or Standard-IA)
- **MongoDB:** Metadata retained but marked `is_archived=true`; TTL set to expire at day 90
- **Access:** On-demand rehydrate (~1–5 mins for Glacier, ~100ms for Standard-IA)
- **Cost:** ~90% cheaper storage; retrieval time trade-off

### **Phase 3: Purge (Day 90+)**

- **MongoDB:** Record deleted via TTL index
- **S3:** Object deleted by lifecycle policy
- **State:** Unrecoverable unless backed up via snapshots

---

## **10. Integration with `bio_inference` & BFF**

**Workflow:**

1. User captures meal photo → Mobile calls BFF `/api/vision/upload` for presigned URL
2. BFF delegates to `bio_storage` `/api/v1/upload/sign` → returns presigned URL
3. Mobile uploads directly to S3 hot bucket
4. S3 triggers webhook → `bio_storage` creates MongoDB metadata record
5. BFF calls `bio_inference` to analyze image (downloads from hot bucket)
6. After inference completes & user confirms → BFF writes to `bio_nexus` food log
7. `bio_storage` schedules archival job:
    - Computes image embedding (ada-002)
    - Stores embedding in MongoDB vector index
    - Marks file for archive after 30 days of inactivity
8. **Day 30+:** Archival job exports file to `bio-ai-archive` bucket (S3 Glacier), marks MongoDB `is_archived=true`
9. **User later queries old meal:** App calls `/api/v1/archive/rehydrate` → file moves back to hot bucket
