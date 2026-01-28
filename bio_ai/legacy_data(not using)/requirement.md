### **Name:** **Bio AI**

**Subtitle:** Adaptive Nutrition & Energy

---

**App Store Description**

(Written for the **iOS App Store** and **Google Play Store**. This format focuses on "Benefits" first, then "Features.")

**App Name:** Bio AI: AI Nutrition Sync
**Subtitle:** Real-time meal plans based on your body data.

**[Short Description - 80 Characters]**
The first AI nutritionist that adapts your food to your sleep, stress, and workout data.

**[Long Description]**

**Stop eating for a static goal. Start eating for your dynamic body.**

Bio AI (formerly SmartFuel) is the world’s first Bio-Adaptive Nutrition Engine. Unlike standard calorie counters that give you the same plan every day, Bio AI connects to your **Apple Watch, Garmin, or Google Pixel Watch** to read your real-time biological state.

Did you sleep poorly? Bio AI suggests an energy-boosting breakfast.
High stress levels? We swap your espresso for a magnesium-rich smoothie.
Just ran 5k? We increase your carb intake automatically to fuel recovery.

**Why Bio AI is Different:**

🧬 **It Reads Your Body**
Automatically syncs steps, heart rate, sleep quality, and stress levels (HRV). No manual entry required.

🧠 **It Thinks For You**
Our AI Engine adjusts your nutrition plan _during the day_.

- _Morning:_ "Your recovery is low. Here is an anti-inflammatory breakfast."
- _Evening:_ "You burned 600 active calories. You’ve earned a larger dinner."

📸 **Snap-to-Log (No Typing)**
Forget searching databases. Just snap a photo of your food. Our Computer Vision AI identifies ingredients and estimates calories instantly.

🏠 **Smart Pantry & Menu Coach**

- **Cooking?** Tell us what's in your fridge ("Eggs, Spinach, Rice"), and we’ll generate a recipe that fits your macros.
- **Eating Out?** Walk into Chipotle or Starbucks, and Bio AI will tell you exactly what to order to stay on track.

**Key Features:**

- ✅ **Real-Time Watch Sync** (HealthKit & Google Fit)
- ✅ **AI Food Vision Scanner** (Snap & Go)
- ✅ **Dynamic Macro Adjustments** (Based on daily activity)
- ✅ **Energy Score Tracking** (Focus on feeling good, not just weight)
- ✅ **One-Click Grocery Integration** (Instacart & Amazon Fresh)

**Your body isn't static. Your nutrition shouldn't be either.**
Download Bio AI today and fuel your body with intelligence.

**[Privacy Policy]**
Your health data is yours. We process data securely and never sell your biological information to third parties.

---

### **Keywords for App Store Optimization (ASO)**

- _Primary:_ Nutrition, Calorie Counter, Intermittent Fasting, Meal Planner, AI Diet.
- _Secondary:_ Apple Watch Diet, Macro Tracker, Biohacking, Metabolism, Healthy Recipes, Food Scanner.

## - Functionalities

---

### 1. Module: User Onboarding & Profile (The Foundation)

_Functions related to account creation, data baselining, and personalization._

- **1.1. Account Creation**
    - Sign up via Apple ID, Google, or Email.
    - Data Privacy Consent (GDPR/CCPA opt-in for health data processing).
- **1.2. Biological Profile Setup**
    - Input: Age, Gender, Height, Current Weight, Target Weight.
    - Input: Activity Level (Sedentary to Athlete).
    - Input: Primary Goal (Lose Fat, Build Muscle, Maintain, Cognitive Performance).
- **1.3. Dietary "Rules" Engine**
    - **Dietary Style Selection:** Vegan, Keto, Paleo, Mediterranean, Omnivore.
    - **Allergy Blacklist:** User selects allergens (e.g., Peanuts, Shellfish); App hard-blocks these ingredients.
    - **Taste Preferences:** "Hate" list (e.g., "No Mushrooms"). AI ensures these never appear in suggestions.
- **1.4. Device Syncing (The "Senses")**
    - **Integration:** One-click OAuth connection to Apple Health, Google Fit, Garmin, Fitbit.
    - **Permission Handling:** Request access to HR, Sleep, Steps, Active Energy, HRV.

---

### 2. Module: Dashboard & Bio-Sync (The "Brain")

_Functions related to real-time data processing and state display._

- **2.1. Real-Time Data Ingestion**
    - Background fetch of wearable data (every 15–60 mins).
    - Metrics tracked: Resting Heart Rate, HRV (Stress), Sleep Quality Score, Step Count, Active Calories Burned.
- **2.2. "Bio-State" Logic Engine**
    - **Stress Detection:** If HRV < Baseline -> Trigger "Calming Food" recommendations.
    - **Activity Detection:** If Active Calories > Threshold -> Increase Daily Calorie Target dynamically.
    - **Sleep Analysis:** If Sleep Score < 60 -> Trigger "Energy Boosting" breakfast recommendation.
- **2.3. Dynamic Visualization**
    - **Fuel Gauge:** Visual representation of "Body Battery" or current energy state.
    - **Macro Progress:** Daily progress bars for Protein, Carbs, Fats (updates based on consumption vs. dynamic need).

---

### 3. Module: AI Nutrition Engine (The "planner")

_Functions related to generating meal plans and explanations._

- **3.1. Context-Aware Recommendation**
    - Generates a specific meal suggestion for the current time block (Breakfast, Lunch, Snack, Dinner).
    - **Logic:** Matches User Rules + Biological State + Time of Day.
- **3.2. The "Why" Engine (Educational AI)**
    - Generates a natural language explanation for every suggestion.
    - _Example:_ "Eat this banana because your potassium is low after your run."
- **3.3. Meal Swap**
    - "Reroll" feature: User rejects suggestion -> AI provides alternative with similar macros.

---

### 4. Module: Vision & Logging (The "Input")

_Functions related to capturing food data._

- **4.1. Camera Interface**
    - In-app camera with AR reticle.
    - Flash control and focus lock.
- **4.2. "Snap-to-Log" Processing (Server-Side)**
    - **Image Compression:** Client-side resizing to <500KB.
    - **Food Detection:** AI identifies ingredients (e.g., "Salmon," "Rice").
    - **Volume Estimation:** AI generates a depth map to estimate portion size (Small/Medium/Large).
- **4.3. Data Confirmation**
    - **Slider Interface:** User adjusts portion size visually if AI is slightly off.
    - **Manual Override:** User can add missing items or edit incorrectly detected items.
- **4.4. Barcode Scanner**
    - Scanning UPC/EAN codes for packaged goods.
- **4.5. Quick-Log History**
    - "Copy Yesterday's Breakfast" button for recurring meals.

---

### 5. Module: Smart Kitchen & Dining (The "Context")

_Functions related to cooking and eating out._

- **5.1. Smart Pantry (Home Mode)**
    - **Input:** User enters available ingredients (e.g., "Eggs, Avocado, Bread").
    - **Recipe Generator:** AI creates a valid recipe using _only_ available items that fit the user's macro goals.
- **5.2. Menu Coach (Restaurant Mode)**
    - **Geolocation:** Auto-detects restaurant via GPS/Google Places API.
    - **Menu Filtering:** Retrieves restaurant menu -> Filters out non-compliant items -> Ranks top 3 choices.
    - **Recommendation:** Displays "Best Order" (e.g., "Order the Power Bowl, ask for dressing on the side").
- **5.3. Grocery Integration**
    - **List Generation:** Aggregates ingredients from planned meals.
    - **Export:** Text copy or deep-link integration to Instacart/Amazon Fresh.

---

### 6. Module: Analytics & Feedback (The "Loop")

_Functions related to long-term data tracking._

- **6.1. Trend Analysis**
    - Correlate Food vs. Bio-Metrics (e.g., "Sugar intake vs. Sleep Quality" graph).
    - Weekly/Monthly views.
- **6.2. Energy Score Calculation**
    - Proprietary algorithm scoring daily performance (0–100) based on workout intensity and subjective energy logs.
- **6.3. Weekly AI Review**
    - Chat-style summary: "You hit your protein goal 5/7 days. Your sleep improved by 10%."
    - Adaptive Learning: "You never eat the suggested oatmeal. I will stop suggesting it."

---

### 7. Module: Settings & System (The "Backbone")

_Functions related to app management._

- **7.1. Unit Preferences**
    - Metric (kg/ml) vs. Imperial (lbs/oz).
- **7.2. Notification Engine**
    - **Smart Reminders:** "Lunch time approach. Eat high protein today."
    - **Bio-Alerts:** "High stress detected. Take a breath and drink water."
- **7.3. Offline Mode**
    - Queue image uploads when no internet is available.
    - Local caching of today's meal plan.
- **7.4. Subscription Management**
    - Free vs. Pro tier locking (e.g., Limit AI Scans for free users).

---

### 8. Admin & Infrastructure (Internal)

_Functions invisible to the user but necessary for the app to work._

- **8.1. Admin Panel**
    - User management dashboard.
    - Content management for global food database updates.
- **8.2. Security**
    - Data encryption at rest (DB) and in transit (TLS).
    - Anonymization of health data for AI training.

This is the **Functional Specification Document**. It focuses strictly on data input, logic, and user actions for each page.

---

### **1. Page: Dashboard (Home)**

_The central hub. Displays real-time status and the "Next Best Action."_

**A. Biological Status Section**

- **Data Display:** Fetches and displays most recent sync data from HealthKit/Google Fit.
    - _Metrics:_ Heart Rate (Current), Steps (Daily Total), Sleep Score (Last Night), HRV (Stress).
- **Logic:**
    - If `HRV < Baseline`, trigger "High Stress" mode.
    - If `Steps > Goal`, trigger "High Activity" mode.
    - **Pull-to-Refresh:** Manually triggers a sync with the wearable API.

**B. AI Meal Recommendation Module**

- **Display:** Shows one primary meal suggestion based on current time and biological status.
- **Functionality:**
    - **"Why" Toggle:** Tapping reveals the logic string (e.g., "suggested because sleep was poor").
    - **Swap Button:** Requests a new suggestion from the AI if the user dislikes the first one.
    - **"I Ate This" Action:** One-tap logging. Automatically adds the suggested meal's macros to the daily total.

**C. Daily Progress Tracker**

- **Visualizer:** Linear or circular progress bars for Calories, Protein, Carbs, Fats.
- **Logic:** Updates dynamically as food is logged. Shows "Remaining" values.

**D. Hydration Tracker**

- **Input:** Quick-add buttons (+250ml, +500ml).
- **Logic:** Updates daily water total.

---

### **2. Page: Camera Log (The "Snap")**

_The primary data entry point._

**A. Capture View**

- **Camera Feed:** Live preview.
- **Flash Toggle:** On/Off/Auto.
- **Shutter Action:** Captures image -> Compresses to <500KB -> Uploads to `POST /analyze/image`.

**B. Analysis/Confirmation View (Post-Capture)**

- **Food List:** Displays items detected by the AI (e.g., "Steak," "Potatoes").
- **Correction Tools:**
    - **Add/Remove Item:** User can manually type a missing item.
    - **Portion Slider:** User adjusts the estimated size (Small [0.75x] - Medium [1.0x] - Large [1.5x]).
    - _Logic:_ Changing the slider updates the Calorie/Macro calculation instantly using client-side math.
- **Save Action:** Commits the data to the user's daily log and returns to Dashboard.

**C. Manual Entry (Fallback)**

- **Search Bar:** Text search against a standard nutrition database (USDA/Nutritionix).
- **Barcode Scanner:** Scans UPC codes for packaged foods.

---

### **3. Page: Planner (Meals & Restaurants)**

_Decision support for future meals._

**A. Toggle Switch**

- **Function:** Switches view between "Cook at Home" and "Eat Out."

**B. View: Cook at Home (Smart Pantry)**

- **Ingredient Input:** Text field or tag selection (e.g., "Chicken," "Rice").
- **Recipe Generation:**
    - _Logic:_ Sends ingredients + User Dietary Rules to LLM.
    - _Output:_ List of valid recipes.
- **Recipe Detail:**
    - Shows instructions.
    - **"Shop" Action:** Adds missing ingredients to the Shopping List.

**C. View: Eat Out (Menu Coach)**

- **Location Service:** Auto-detects current venue via GPS.
- **Manual Search:** Search box for restaurant names (e.g., "Starbucks").
- **Menu Filter:**
    - _Logic:_ Filters the restaurant's menu against the user's _remaining_ daily macros.
    - _Display:_ Shows top 3 compliant menu items.

**D. Shopping List**

- **List View:** Aggregates ingredients from planned meals.
- **Checkbox Action:** Mark items as bought.
- **Export Action:** Copy to clipboard or deep-link to Instacart/Amazon Fresh.

---

### **4. Page: Analysis (Insights)**

_Long-term data visualization._

**A. Trend Graphs**

- **Selectors:** Week / Month / 3 Months.
- **Data Overlays:** Allows user to plot two metrics to see correlations.
    - _Example:_ Plot "Sugar Intake" vs. "Sleep Quality."
    - _Example:_ Plot "Calorie Intake" vs. "Weight."

**B. Energy Score**

- **Calculation:** Proprietary score (0-100) based on workout performance and subjective energy logs.
- **Feedback:** Text summary explaining _why_ the score went up or down (e.g., "Score increased due to consistent protein intake").

**C. History Log**

- **List View:** Chronological list of all meals eaten.
- **Edit Action:** Allow user to modify past entries (timestamp, portion, food item).

---

### **5. Page: Settings (Profile)**

_Configuration and Rules._

**A. Device Integration**

- **Toggles:** Apple Health, Google Fit, Garmin, Fitbit.
- **Status:** Shows "Last Synced: 2 mins ago" or "Disconnected."
- **Re-Auth Action:** Button to refresh OAuth tokens.

**B. Dietary Profile (The "Rules")**

- **Preferences:** Multi-select (Vegan, Keto, Paleo, Pescatarian).
- **Allergies:** Text input or common tags (Peanuts, Gluten, Dairy).
- **Dislikes:** List of foods to _never_ suggest (e.g., "Mushrooms").

**C. Biological Profile**

- **Input Fields:** Height, Weight, Age, Gender, Activity Level.
- **Goal Setting:**
    - _Primary Goal:_ Lose Fat / Maintain / Build Muscle.
    - _Target Speed:_ 0.5 lbs/week, 1 lb/week, etc.
    - _Logic:_ These inputs calculate the Daily Calorie Target (TDEE).

**D. Account & Data**

- **Subscription:** Manage Pro/Free status.
- **Data Export:** Download all user data as CSV (GDPR requirement).
- **Delete Account:** Hard delete of all health data (GDPR requirement).
