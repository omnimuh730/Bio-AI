This document defines the **Service Level Objectives (SLOs)** and **Key Performance Indicators (KPIs)** for the Bio AI Engineering Team.

These metrics represent the "Definition of Done" for system performance. They are divided into **User Experience (Latency)**, **AI Accuracy**, **System Reliability**, and **Resource Efficiency**.

---

## **1. Performance & Latency Metrics**

_Goal: The system must feel "Real-Time" to the user, even when doing heavy processing._

### **A. The "Dragunov" Vision Pipeline (Snap-to-Log)**

This is the most critical flow. Users will abandon the app if logging takes too long.

| Metric                       | Target (P95) | Max Limit (P99) | Notes                                                                                                |
| :--------------------------- | :----------- | :-------------- | :--------------------------------------------------------------------------------------------------- |
| **Camera Gyro-Lock Latency** | **< 16ms**   | 30ms            | The UI overlay (crosshair) must run at 60fps locally.                                                |
| **Presigned URL Generation** | **< 100ms**  | 200ms           | Time for `bio_storage` to return an S3 upload key.                                                   |
| **Image Upload Speed**       | **< 2s**     | 5s              | Assumes 4G connection (optimized binary stream).                                                     |
| **Total Inference Time**     | **< 4s**     | 8s              | Time from "Upload Complete" to "Result on Screen." Includes Segmentation, Depth, and Density lookup. |
| **Feedback Loop**            | **< 500ms**  | 1s              | Time to show a "Processing..." skeleton state so the user isn't staring at a frozen screen.          |

### **B. API & Dashboard (Bio-Hub)**

The dashboard aggregates complex data (Sleep + Stress + Food).

| Metric                        | Target (P95) | Max Limit (P99) | Notes                                                             |
| :---------------------------- | :----------- | :-------------- | :---------------------------------------------------------------- |
| **Dashboard Load Time**       | **< 300ms**  | 800ms           | Heavily relies on Redis caching in the BFF.                       |
| **Auth Verification (Local)** | **< 5ms**    | 20ms            | RS256 local check at the Gateway (no DB hits).                    |
| **Search (Smart Pantry)**     | **< 200ms**  | 500ms           | Text search against MongoDB/Qdrant.                               |
| **Bio-Sync Ingestion**        | **< 50ms**   | 100ms           | Time for API to return `202 Accepted` (processing happens async). |

---

## **2. AI Accuracy & Quality Metrics**

_Goal: The AI must be accurate enough to build trust, but forgiving enough to be usable._

### **A. Vision Precision**

| Metric                       | Target     | Minimum Acceptable | Measurement Method                                                |
| :--------------------------- | :--------- | :----------------- | :---------------------------------------------------------------- |
| **Food Recognition (Top-1)** | **> 90%**  | 80%                | Correctly identifies "Salmon" vs. "Tuna."                         |
| **Segmentation (IoU)**       | **> 0.85** | 0.75               | Intersection over Union. How accurately the mask covers the food. |
| **Volume Error Margin**      | **± 12%**  | ± 20%              | Compared to water-displacement ground truth.                      |
| **Calorie Error Margin**     | **± 15%**  | ± 25%              | Combined error of Volume × Density.                               |

### **B. Bio-Adaptive Intelligence (LLM)**

| Metric                 | Target    | Notes                                                                                                  |
| :--------------------- | :-------- | :----------------------------------------------------------------------------------------------------- |
| **Hallucination Rate** | **< 1%**  | The AI must never invent ingredients not in the pantry or claim a food has 0 calories when it doesn't. |
| **JSON Strictness**    | **99.9%** | The LLM output must be valid parsable JSON. If it breaks, the UI crashes.                              |
| **Context Adherence**  | **100%**  | If User has a "Peanut Allergy" tag, the recommendation engine must return 0 peanut recipes.            |

---

## **3. Infrastructure Reliability (Availability)**

_Goal: The system handles bursts (lunchtime) without crashing._

| Metric                        | Target      | Notes                                                                        |
| :---------------------------- | :---------- | :--------------------------------------------------------------------------- |
| **System Uptime**             | **99.9%**   | Allowable downtime: ~43 minutes per month.                                   |
| **API Error Rate (5xx)**      | **< 0.1%**  | 1 in 1,000 requests can fail (retryable).                                    |
| **Max Concurrent Inferences** | **100/sec** | Number of simultaneous GPU vision jobs before queuing logic kicks in.        |
| **Queue Clearance Time**      | **< 30s**   | If a job is queued during peak load, it must be processed within 30 seconds. |
| **Cold Start (GPU)**          | **< 10s**   | Time to spin up a new GPU node if autoscaling triggers.                      |

---

## **4. Client-Side Efficiency (Mobile App)**

_Goal: The app must not kill the user's phone._

| Metric                  | Target           | Notes                                                                      |
| :---------------------- | :--------------- | :------------------------------------------------------------------------- |
| **Battery Impact**      | **< 2% / day**   | Background sync (Bio-Sync) must be batched efficiently.                    |
| **App Startup Time**    | **< 1.5s**       | From "Tap Icon" to "Interactive UI."                                       |
| **Data Usage (Mobile)** | **< 15MB / day** | For average use (3 scans + sync). Requires heavy image compression (WebP). |
| **Crash Free Users**    | **> 99.5%**      | Percentage of users who never experience a crash.                          |

---

## **5. Security & Compliance Limits**

_Goal: Zero leakage of PII._

| Metric                    | Limit          | Notes                                                          |
| :------------------------ | :------------- | :------------------------------------------------------------- |
| **Image Retention (Raw)** | **24 Hours**   | Raw uncompressed images in S3 `DropZone` must be hard-deleted. |
| **Token Expiry**          | **15 Minutes** | Access tokens must short-lived to minimize theft risk.         |
| **Rate Limiting**         | **60 req/min** | Per user, to prevent DDoS or API abuse.                        |

---

### **Summary of "Must-Haves" for v1.0 Launch**

If we must trade off metrics for the MVP launch, these are the **non-negotiables**:

1.  **Vision Latency < 6s:** Anything longer feels broken.
2.  **Bio-Sync Battery < 5%:** If we drain battery, users uninstall immediately.
3.  **JSON Strictness 100%:** If the UI crashes because the LLM returned bad JSON, the product is unusable.
4.  **Allergy Context 100%:** We cannot recommend allergens. This is a safety liability.
