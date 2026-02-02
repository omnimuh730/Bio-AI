This is **Document 1 of 5**. We will focus strictly on the **Frontend Specification**.

This document serves as the blueprint for Mobile Developers (Flutter/React Native) and Frontend Architects. It details the UI states, local logic, and the interface with the **BFF (Backend for Frontend)** layer.

---

# **Project Bio AI: Frontend Specification Document (v1.0)**

## **1. General Architecture & BFF Pattern**

To ensure battery efficiency and reduce latency, the Mobile App **will not** call microservices directly. It will communicate with a **BFF (Backend for Frontend)** layer.

- **Pattern:** Aggregator Pattern.
- **Protocol:** REST (HTTPS) for standard calls, gRPC (optional) for heavy payload streams if needed, Background Fetch for Health Data.
- **State Management:** Local Database (SQLite/Hive) required for Offline Mode.

---

## **2. Module 1: Dashboard (The "Bio-Hub")**

**Purpose:** Display real-time biological status, dual-ring energy tracking, and the primary AI action.

### **2.1. UI Components & Logic**

| Component             | State / Condition                                                           | Interaction / Logic                                                                                                                                                                                          |
| :-------------------- | :-------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Notification Bell** | **Badge:** Red dot if `unread_count > 0`.                                   | **Tap:** Opens Notification Center (System vs. User alerts).                                                                                                                                                 |
| **Bio-Cards Row**     | Shows `Heart Rate`, `HRV`, `Sleep`, `Steps`.                                | **Pull-to-Refresh:** Triggers `Force Sync`. <br> **Logic:** Color coded. <br> • HRV < Baseline = Orange (Stress). <br> • Sleep < 60 = Red (Recovery).                                                        |
| **Dual-Ring Tracker** | **Outer Ring:** Time passed in day. <br> **Inner Ring:** Calories consumed. | **Rendering Logic:** <br> • **Outer:** `(Now - WakeTime) / (BedTime - WakeTime)`. <br> • **Inner:** `CaloriesEaten / DailyTarget`. <br> • **Fasting:** If `Now` is in Fasting Window, Outer Ring turns Grey. |
| **Status Label**      | Centered inside Rings.                                                      | **Logic:** <br> • If `Inner < Outer` (Eating too slow): Show "Fuel Up". <br> • If `Inner > Outer` (Eating too fast): Show "Slow Down". <br> • If `Fasting`: Show "Fasting Zone".                             |
| **Hydration**         | `+250ml`, `+500ml`, `Custom`.                                               | **Tap:** Animates water fill. <br> **Logic:** Local `current_water += value`. Sends API req in background.                                                                                                   |
| **Caffeine/Alcohol**  | Toggle Icons (Coffee Bean / Wine Glass).                                    | **Interaction:** If toggled ON, clicking `+250ml` does **NOT** add to Water Goal. Adds to Calorie Log + Triggers "Dehydration Alert".                                                                        |
| **AI Suggestion**     | Shows Meal Card.                                                            | **Tap:** Expands "Why this?" logic. <br> **Button 1 (Eat):** Quick Log. <br> **Button 2 (Refresh):** Requests new meal.                                                                                      |

### **2.2. Complex Interactions: The "Refresh" Flow**

When the user clicks the **Refresh Icon** on the AI Meal Card:

1.  **UI Action:** Open Bottom Sheet (Half-height).
2.  **Title:** "Why swap this meal?"
3.  **Options (Chips):**
    - `Too Expensive`
    - `Don't have ingredients`
    - `Don't like the taste`
    - `Just not hungry`
4.  **Action:** User selects option -> Tap "Confirm".
5.  **BFF Call:** `POST /bff/recommendation/swap` with `{ reason: "too_expensive" }`.
6.  **Response:** Returns new Meal JSON.
7.  **UI Update:** Card flips/animates to new suggestion.

### **2.3. Health Sync Logic (Battery Efficient)**

- **Foreground:** When App opens, call `HealthKit.read()`. If data is > 15 mins old, upload to BFF.
- **Background:** Register `BGAppRefreshTask` (iOS) / `WorkManager` (Android). Runs every 60 mins. Fetches aggregated data -> Sends compressed JSON to BFF.

---

## **3. Module 2: The "Dragunov" Camera (Vision & Logging)**

**Purpose:** Accurate volume estimation via gyroscope-guided capture.

### **3.1. Camera Overlay States**

The camera screen has a Finite State Machine (FSM):

1.  **State: INIT** (Camera opens, Gyro active).
2.  **State: GUIDANCE** (Overlay shows "Tilt to 45°").
3.  **State: LOCKED** (Angle is 40°-50°, Shutter Enabled).
4.  **State: PROCESSING** (Image captured, uploading).
5.  **State: RESULT** (Classification returned).

### **3.2. The "Sniper" Overlay Logic**

- **Visuals:** A translucent grid + "Ghost Phone" icon showing required tilt.
- **Sensor Logic (60fps loop):**
    ```dart
    double pitch = gyro.getPitch(); // Degrees
    if (pitch > 40 && pitch < 50) {
       overlayColor = Colors.green.withValues(alpha: 0.3);
       shutterButton.enable();
       hapticFeedback(Light);
    } else {
       overlayColor = Colors.red.withValues(alpha: 0.1);
       shutterButton.disable();
    }
    ```

### **3.3. Offline Mode Logic**

- **Check:** `Connectivity.checkConnectivity()`.
- **If Offline:**
    - On Shutter Tap -> Save Image to App Sandbox (`/app_data/pending_scans/`).
    - Save Metadata: `{ timestamp: Now, gyro_pitch: 45.2 }`.
    - UI: Show Toast "Saved to Pending. Syncs when online."
    - Limit: If `pending_count >= 10`, disable camera, warn user.
- **Restoration:** When connection restored, BFF uploads images in queue sequentially.

### **3.4. Manual & Meta-Image Flow**

- **Meta Image:** On the "Confirm Scan" screen (after AI analyzes), add button `[+] Add Context Photo`.
    - Allows user to snap a secondary photo (e.g., the restaurant menu or cooking process).
    - Linked to the main food log ID but marked `is_training_data: true`.

---

## **4. Module 3: Planner (Kitchen & Dining)**

**Purpose:** Manage inventory, leftovers, and restaurant choices.

### **4.1. Tab: Smart Pantry**

- **Input:** Text Field with Voice Icon.
    - **Voice Action:** User holds mic -> "Carrots, Olive Oil, and three Eggs." -> Speech-to-Text (Device native) -> Parse -> Add chips to list.
- **Recipe Matching:**
    - List of recipes.
    - **Missing Ingredients Logic:**
        - Green Check: All items in pantry.
        - Yellow Alert: "Missing Lemon".
    - **"I Hate This" Button:** Long press on a recipe -> "Don't show this again" -> Updates `User Profile (Dislikes)`.

### **4.2. Tab: Leftovers (New Feature)**

- **UI Layout:** List of "Cooked Batches".
- **Action: Log Leftover:**
    - Tap "Eat This".
    - **Slider Modal:** "How much did you eat?"
    - **Visual Feedback:** Slider moves from 0% to 100%.
    - **Text Feedback:**
        - If unit = 'potatoes': "1.5 potatoes" (Decimal allowed).
        - If unit = 'servings': "1 serving".
    - **Rounding Logic:**
        - `DisplayValue = (TotalAmount * SliderPercentage).toStringAsFixed(1)`

### **4.3. Tab: Eat Out (Geolocation)**

- **Permission:** Request `Location.WhenInUse`.
- **Loading State:** "Scanning nearby menus..." (Skeleton Loader).
- **Data Flow:**
    1.  Get Lat/Long.
    2.  BFF Call: `GET /bff/restaurants/nearby?lat=x&long=y`.
    3.  BFF orchestrates Google Places + AI Analysis.
    4.  Frontend renders list sorted by **"Bio-Match Score"** (e.g., "98% Match - High Protein").

---

## **5. Module 4: Analytics**

**Purpose:** Long-term insights and Energy Score visualization.

### **5.1. Energy Score Chart**

- **Visual:** Line chart with gradient fill.
- **Interaction:**
    - Tap a data point: Shows popup tooltip `{ Score: 82, Why: "Good Sleep" }`.
    - **Correlations:** Dropdown to overlay second metric.
        - "Show Score vs. Sugar Intake".
        - Frontend overlays a second line (dashed) on a secondary Y-axis.

---

## **6. Module 5: Profile & Settings**

### **6.1. Device Management**

- **View:** List of connected sources (HealthKit, Garmin, etc.).
- **Find Devices Modal:**
    - **Tab 1: Added:** List of authed devices with "Unlink" button.
    - **Tab 2: Available:** Scans for BLE devices (if applicable) or lists supported API integrations.

### **6.2. Goal Setting**

- **Goal Selector:** Card selection (Fat Loss, Muscle, etc.).
- **Explanation:** Dynamic text area below selection.
    - _Logic:_ Updates instantly based on selection. "Setting Goal to 'Build Muscle' means we will prioritize Protein suggestions post-workout."

---

## **7. BFF Interface (API Contract Stubs)**

The Frontend expects these endpoints from the BFF layer.

### **Auth & Profile**

- `POST /auth/login`
- `GET /user/profile` (Includes Macros, Rules, Fasting settings)
- `PUT /user/profile/devices` (Link/Unlink)

### **Dashboard & Sync**

- `POST /sync/batch` (Upload HealthKit JSON)
- `GET /dashboard/state`
    - _Returns:_ `{ rings: { outer: 0.6, inner: 0.4 }, fasting_mode: true, status_text: "Fasting Zone", hydration: 1200 }`

### **Nutrition Engine**

- `GET /recommendation/current` (Context-aware meal)
- `POST /recommendation/swap` (Reasoning engine)
- `POST /log/food` (Manual or Quick add)

### **Vision (The Heavy Lifter)**

- `POST /vision/upload`
    - _Body:_ Multipart File + `{ pitch: 45.0, timestamp: ... }`
    - _Response:_ `{ food_items: [...], estimated_calories: 450, requires_confirmation: true }`

### **Planner**

- `GET /pantry/recipes`
- `POST /pantry/item`
- `POST /leftovers/consume` (Update amount)
- `GET /restaurants/search` (Geo-based)

---

## **8. Frontend Tech Recommendations**

- **Framework:** **Flutter** (Dart).
    - _Reason:_ Superior performance for the Camera Overlay (60fps painting) and unified codebase for iOS/Android.
- **State Management:** **Riverpod** or **BLoC**.
    - _Reason:_ We need strict separation of UI and Business Logic, especially for the Offline Sync queues.
- **Local DB:** **Isar** or **Hive**.
    - _Reason:_ Extremely fast NoSQL local storage for caching food logs and offline images.
- **Charts:** `fl_chart` library.

---
