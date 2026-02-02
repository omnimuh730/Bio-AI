Here is the comprehensive technical documentation and system specification for **Bio AI**. This document consolidates the architectural logic, service responsibilities, and data workflows into a single "Master Technical Paper."

---

# **🧬 Bio AI: The Bio-Adaptive Nutrition Engine**

### **Master Technical Documentation & System Architecture**

## **1. Introduction & Philosophy**

**Bio AI** is a closed-loop cyber-biological system designed to optimize human performance through nutrition. Unlike traditional trackers that function as static logbooks (Input $\rightarrow$ Storage), Bio AI functions as a **Real-Time Control System** (Bio-Feedback $\rightarrow$ Processing $\rightarrow$ Dynamic Adjustment).

**The Core Premise:** A user's nutritional needs change hourly based on **Stress (HRV)**, **Sleep Quality**, and **Activity**. Bio AI ingests this data to dynamically adjust calorie and macro targets throughout the day, using Computer Vision to remove the friction of manual tracking.

---

## **2. System Architecture: High-Level Overview**

The system follows a **Microservices Architecture** orchestrated by a **Backend-for-Frontend (BFF)** pattern. It utilizes **Event-Driven Design** for write-heavy operations (health sync) and **Direct-to-Cloud** patterns for heavy media handling.

### **The Service Mesh**

| Service Name        | Type       | Tech Stack       | Responsibility                                                                          |
| :------------------ | :--------- | :--------------- | :-------------------------------------------------------------------------------------- |
| **`bio_ai_server`** | **BFF**    | FastAPI, AsyncIO | The API Gateway. Aggregates data, handles UI logic, validates Auth locally.             |
| **`bio_auth`**      | **IdP**    | FastAPI, RS256   | Identity Provider. Issues JWTs, rotates keys, manages security policies.                |
| **`bio_nexus`**     | **Data**   | MongoDB (Atlas)  | Central data persistence. Stores Time-Series metrics, user profiles, and logs.          |
| **`bio_inference`** | **AI/GPU** | PyTorch, Celery  | The Intelligence Layer. Runs Vision pipelines (Depth/Segmentation) and LLM reasoning.   |
| **`bio_storage`**   | **I/O**    | S3, MinIO        | Manages binary assets via Presigned URLs. Handles image lifecycles.                     |
| **`bio_worker`**    | **Async**  | Python, Redis    | Resource Orchestrator. Uses Max-Flow algorithms to schedule tasks based on system load. |

---

## **3. Detailed Service Breakdown**

### **A. `bio_inference` (The Brain & Eyes)**

This is the heavy-computation unit. It does not store state; it processes inputs and returns insights.

1.  **The "Dragunov" Vision Pipeline:** A multi-stage pipeline to calculate food calories from a 2D image without reference objects (coins/cards).
    - **Stage 1: Segmentation (MobileSAM):** Separates "Food" from "Plate/Table" using binary masking.
    - **Stage 2: Depth Mapping (Depth Anything v2):** Generates a Z-map (grayscale heatmap) to determine the height of the food pile.
    - **Stage 3: Volumetrics (Physics Engine):** combines the User's Gyroscope Pitch (e.g., phone held at 45°) with the Depth Map to calculate volume in cm³.
    - **Stage 4: Density Lookup (VLM):** A Vision Language Model (e.g., Qwen2.5-VL) identifies the food (e.g., "Cooked Jasmine Rice") and looks up its density (1.3g/cm³).
    - **Result:** $Volume \times Density = Mass (g) \rightarrow Calories$.

2.  **The Bio-Adaptive Agent (LLM):**
    - Uses **RAG (Retrieval Augmented Generation)** to combine User Context (high stress) with Nutritional Science (magnesium reduces stress).
    - **Deterministic Output:** The LLM is forced to output strictly structured JSON, not chatty text, ensuring the UI can render specific "Meal Cards."

### **B. `bio_nexus` (The Memory)**

The authoritative source of truth. It uses a Hybrid Database model:

1.  **Time-Series Collections:** optimized for high-frequency writes from wearables (Heart Rate, Steps). Data is clustered by time buckets to allow fast querying of "Today's Stress Load."
2.  **Vector Embeddings:** Stores semantic embeddings of food items in a **Qdrant** or **Atlas Vector Search** index. This allows the AI to understand that "Oatmeal" is semantically similar to "Porridge" for recommendation purposes.
3.  **Entity Storage:** Standard collections for User Profiles, Recipes, and Aggregated Logs.

### **C. `bio_auth` (The Gatekeeper)**

A standalone Identity Provider designed for high performance.

1.  **Stateless Verification (RS256):**
    - `bio_auth` holds a **Private Key** to sign tokens.
    - `bio_ai_server` (BFF) holds the **Public Key**.
    - **Benefit:** The BFF can verify a user's request mathematically without making a network call to the Auth service, reducing latency to near zero.
2.  **Token Rotation:** Refresh tokens are stored in Redis. If a token is reused (indicating theft), the system revokes the entire token family immediately.

### **D. `bio_worker` (The Nervous System)**

A smart orchestration layer that prevents system overload.

1.  **Max-Flow Scheduling:** Unlike standard FIFO queues, this service builds a "Flow Network" graph.
    - It analyzes available resources (e.g., "We have 2 free GPU slots and 50 free CPU slots").
    - It solves the graph to decide _which_ tasks to pull from Redis.
    - **Result:** It prioritizes fast tasks (Data Sync) while carefully slotting in heavy tasks (Vision) so the system never jams.

---

## **4. Core Workflows**

### **Workflow 1: The "Snap & Log" (Vision Pipeline)**

_The user takes a photo of their lunch._

1.  **Upload Request:** Mobile App requests a **Presigned URL** from `bio_storage`.
2.  **Direct Upload:** Mobile App uploads the image directly to AWS S3 (Raw Bucket). The App sends the `S3_Key` + `Gyroscope_Data` to the BFF.
3.  **Queuing:** BFF pushes a `vision_analysis` job to Redis Streams.
4.  **Orchestration:** `bio_worker` detects the job and assigns it to a GPU-enabled worker.
5.  **Inference:**
    - Worker downloads image from S3.
    - Runs Segmentation & Depth mapping.
    - Calculates Calories/Macros.
6.  **Persistence:** Result is saved to `bio_nexus`.
7.  **Cleanup:** `bio_storage` moves the image to a "Gallery Bucket" (compressed WebP) and deletes the heavy Raw file.
8.  **Notification:** BFF pushes the result to the Client via WebSocket or Long-Polling.

### **Workflow 2: The Bio-Sync Loop (Passive Data)**

_The user walks, sleeps, and breathes. Data flows from Apple Health/Garmin._

1.  **Ingestion:** Mobile App batches 30 minutes of HealthKit data (HR, HRV, Steps).
2.  **Fire-and-Forget:** App posts payload to `bio_ai_server`. Server returns `202 Accepted` immediately.
3.  **Processing:** `bio_worker` picks up the payload.
    - Normalizes data formats (Apple vs. Garmin).
    - Writes raw points to `bio_nexus` Time-Series.
4.  **Analysis:** Worker triggers a `recalc_state` event.
    - _Logic:_ If `Current_HRV` < `Baseline_HRV` by 20% $\rightarrow$ Set State to **High Stress**.
5.  **Reaction:** The Semantic Cache for "Next Meal Recommendation" is invalidated, forcing the AI to generate a new, stress-reducing suggestion next time the user opens the app.

---

## **5. Client-Side Functionality (Mobile App)**

The app is a "Remote Control" for the backend intelligence.

### **A. The Dashboard (Bio-Hub)**

- **Dual-Ring Viz:**
    - **Outer Ring:** Time (Wake $\rightarrow$ Sleep).
    - **Inner Ring:** Calories Consumed.
    - **Logic:** If Inner Ring > Outer Ring, user is "Over-fueling" relative to time of day.
- **Bio-State Cards:** Live widgets showing "Recovery Mode" or "Peak Performance" based on the latest sync.

### **B. The "Dragunov" Camera UI**

- **Gyro-Lock:** A UI overlay (crosshair) that turns green only when the phone is held at the correct angle (40-50°). This ensures the Computer Vision model gets consistent perspective for volume math.

### **C. The Adaptive Planner**

- **Contextual Slotting:** Instead of generic "Lunch," the slot is labeled dynamically, e.g., "Post-Workout Refuel" or "Stress-Relief Snack."
- **Smart Pantry:** Recipes are generated based strictly on ingredients the user actually has (stored in `bio_nexus`).

---

## **6. Data Model (Schema Design)**

### **User Profile (`bio_nexus`)**

```json
{
	"_id": "uuid",
	"baselines": {
		"hrv_avg": 45,
		"resting_hr": 60
	},
	"current_state": {
		"stress_level": "high", // Derived from HRV
		"recovery_score": 30 // Derived from Sleep
	},
	"inventory": ["salmon", "rice", "avocado"]
}
```

### **Food Log Entry**

```json
{
	"user_id": "uuid",
	"timestamp": "ISO_DATE",
	"vision_meta": {
		"s3_ref": "gallery/steak.webp",
		"volume_cm3": 250,
		"density_factor": 1.1
	},
	"nutrition": {
		"calories": 450,
		"protein": 40,
		"verified": false // "True" if user manually corrected AI
	}
}
```

---

## **7. Infrastructure & Scalability**

### **Deployment Strategy**

- **Kubernetes (EKS):** The system runs on a K8s cluster with distinct Node Pools.
    - **General Pool:** Runs API/BFF (CPU optimized).
    - **Inference Pool:** Runs `bio_inference` (GPU optimized, Tainted nodes).
    - **Memory Pool:** Runs `bio_worker` and Redis (RAM optimized).

### **Observability (BioTrace)**

- **Distributed Tracing:** Every request generates a `TraceID`. We can track a request from Mobile $\rightarrow$ BFF $\rightarrow$ Worker $\rightarrow$ GPU $\rightarrow$ DB.
- **Metrics:** Prometheus scrapes "Inference Latency" and "Model Drift" (confidence scores dropping over time).

### **Caching Strategy**

- **Semantic Caching:** We don't just cache by ID. We cache by "Meaning."
    - _Query:_ "Lunch for high stress."
    - _Cache:_ If another user with similar biometrics asked this recently, return the cached calculation instead of burning GPU credits.

---

## **8. Security & Privacy**

1.  **Data Isolation:** Health data (`bio_nexus`) is stored separately from Identity data (`bio_auth`). If the health DB is leaked, it contains no emails or passwords.
2.  **Ephemeral Processing:** Raw images of food are deleted after 24 hours. We only keep the low-res, compressed version for the user's log history.
3.  **Local Validation:** The BFF verifies JWT signatures locally, preventing "Chatty" internal network traffic during attacks.
