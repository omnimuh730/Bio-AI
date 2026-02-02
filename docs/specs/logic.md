This is **Document 4 of 5**. This document focuses on the **Intelligence Layer**. It defines how the Large Language Model (LLM) is structured, the specific prompts used to generate "Bio-Adaptive" advice, and the strict JSON contracts required to make the AI reliable.

---

# **Project Bio AI: AI Logic & Prompt Engineering (v1.0)**

## **1. The AI Strategy: "Deterministic Creativity"**

We are **not** building a chatbot. Users do not want to chat; they want decisions.
The AI in Bio AI acts as a **Decision Engine**. It takes highly structured inputs (HRV, Inventory, Macros) and outputs highly structured JSON (Meal ID, Portion, Reason) that the UI renders natively.

### **1.1. Model Selection Matrix**

| Task                        | Recommended Model                       | Temp  | Why?                                                                          |
| :-------------------------- | :-------------------------------------- | :---- | :---------------------------------------------------------------------------- |
| **Meal Decision (Logic)**   | **GPT-4o** or **Claude 3.5 Sonnet**     | `0.1` | Complex logic required to balance 10+ variables (HRV, Sleep, Pantry, Macros). |
| **Menu Parsing (OCR)**      | **GPT-4o-mini** or **Gemini Flash 1.5** | `0.0` | High speed, low cost. Needs to structure text into JSON.                      |
| **"The Why" (Text)**        | **GPT-4o-mini** or **Claude 3 Haiku**   | `0.7` | Needs natural language generation and empathy.                                |
| **Vision (Classification)** | **Qwen2.5-VL** (Self-hosted)            | `0.2` | Open-source VLM is cheaper for high-volume image analysis.                    |

---

## **2. The Context Payload (The "Input")**

Garbage in, garbage out. The backend must assemble a "Context Object" before calling the LLM. This is the standard data structure sent to the prompt.

```json
{
	"user_profile": {
		"goal": "fat_loss",
		"diet": "paleo",
		"allergies": ["peanuts"],
		"dislikes": ["mushrooms"]
	},
	"bio_state": {
		"sleep_score": 55, // Low
		"stress_level": "high", // Based on HRV
		"activity_level": "post_workout_heavy",
		"hydration_status": "dehydrated_alcohol_detected"
	},
	"constraints": {
		"meal_slot": "dinner",
		"calories_remaining": 600,
		"time_available": 30 // minutes
	},
	"inventory": {
		"leftovers": [{ "name": "Grilled Chicken", "servings": 2 }],
		"pantry": ["Sweet Potato", "Spinach", "Eggs", "Avocado"]
	}
}
```

---

## **3. System Prompts (The "Code")**

### **3.1. The "Bio-Planner" Engine (Main Logic)**

This prompt runs when the Dashboard loads or refreshes. It decides _what_ to eat.

**System Prompt:**

```text
You are Bio AI, an advanced Bio-Adaptive Nutritionist. Your goal is to select the single best meal for the user based on their biological state, inventory, and macro goals.

RULES:
1. BIO-ADAPTATION:
   - If Sleep < 60: Prioritize energy-dense but low-glycemic foods (no sugar crashes).
   - If Stress is High: Prioritize Magnesium/Zinc rich foods (Spinach, Dark Choc, Avocado).
   - If Post-Workout: Prioritize fast-digesting Protein + Carbs.
   - If Alcohol Detected: Prioritize electrolytes and hydration-rich foods.
2. INVENTORY PRIORITY:
   - Priority 1: Eat 'Leftovers' if they fit the macros (reduce waste).
   - Priority 2: 'Smart Pantry' recipes using available ingredients.
3. OUTPUT FORMAT:
   - Return ONLY valid JSON. No markdown. No conversational filler.

Output Schema:
{
  "meal_name": "String",
  "ingredients_used": ["String"],
  "macros": { "c": int, "p": int, "f": int, "kcal": int },
  "bio_reasoning_tag": "String (Max 3 words, e.g., 'Anti-Stress Formula')",
  "explanation_short": "String (1 sentence, e.g., 'Magnesium in spinach helps lower your high cortisol.')",
  "preparation_time_min": int
}
```

**User Prompt:**

```text
Context: [Insert JSON Context Object Here]
Generate the Dinner recommendation.
```

### **3.2. The "Menu Coach" (Restaurant Logic)**

This prompt runs when the user is at a restaurant and needs a recommendation.

**System Prompt:**

```text
You are an expert Menu Auditor. You will receive a raw OCR text dump of a restaurant menu and the User's remaining macro budget.

TASK:
1. Parse the menu items.
2. Filter out items containing allergens: [User Allergies].
3. Identify the TOP 3 items that fit the user's remaining calories: [Remaining Calories].
4. If an item is slightly unhealthy, suggest a modification (e.g., "Ask for dressing on the side").

Output JSON:
{
  "recommendations": [
    {
      "item_name": "String",
      "estimated_macros": { "c": int, "p": int, "f": int, "kcal": int },
      "match_score": int (0-100),
      "modification_tip": "String or null"
    }
  ]
}
```

### **3.3. The "Why No?" Feedback Loop (Learning)**

This prompt runs when the user clicks "Refresh" -> "Too Expensive" or "Not Hungry".

**System Prompt:**

```text
The user rejected your previous suggestion: "{Previous_Meal}".
Reason for rejection: "{User_Reason}".
Current Context: [Insert Context Object].

TASK:
Generate a NEW suggestion that respects the rejection reason.
- If "Too Expensive": Use cheaper ingredients (Eggs, Rice, Beans).
- If "Not Hungry": Suggest a nutrient-dense snack or smoothie instead of a full meal.
- If "Don't like taste": Avoid the primary flavor profile of the rejected meal.

Return JSON matching the standard schema.
```

---

## **4. The "Educational AI" Logic**

Bio AI distinguishes itself by explaining _why_. We use a dedicated, lightweight LLM call to generate the "Insight Card" on the Dashboard.

**Prompt Logic:**

- **Input:** Bio-Metrics + Selected Food.
- **Template:**
    > "Translate this biological fact into a motivating, 1-sentence insight for a user."
    > _Fact:_ User HRV is low (20ms). Food contains Spinach (Magnesium).
    > _Tone:_ Encouraging, Scientific.
- **Example Output:**
    > "Your stress markers are elevated today; the magnesium in this spinach will help relax your nervous system for better sleep."

---

## **5. The Vision-to-Calorie Logic (Qwen-VL)**

This runs on the Serverless GPU (Self-hosted VLM). It's not a text prompt, but a **Visual Question Answering (VQA)** prompt.

**Image:** [User's Photo cropped by SAM mask]
**Prompt:**

```text
Identify the food item in this image.
Estimate its density type:
1. "Airy" (e.g., Popcorn, Leafy Salad) - ~0.1-0.3 g/cm3
2. "Porous" (e.g., Bread, Cake) - ~0.4-0.6 g/cm3
3. "Solid" (e.g., Meat, Cheese, Fruit) - ~0.9-1.1 g/cm3
4. "Dense" (e.g., Chocolate, Butter) - ~1.2+ g/cm3

Return JSON:
{
  "food_name": "String",
  "density_category": "String",
  "estimated_density_g_cm3": float
}
```

_Note:_ We use the _Volume_ (calculated via Depth/Geometry) multiplied by this _Density_ to get the Grams. Then we lookup Grams -> Calories in a standard SQL database (USDA). We do _not_ ask the LLM to guess calories directly, as LLMs are bad at math. We only ask it to identify the substance properties.

---

## **6. Handling Edge Cases (Safety Rails)**

The AI must have hard-coded safety rails in the backend code (not just prompts) to prevent dangerous advice.

1.  **The "Starvation" Rail:**
    - _Logic:_ If `Calories_Remaining` < 200 but user has high activity.
    - _Override:_ AI must suggest a minimum viable snack (e.g., 200kcal), even if it goes over the "Target." Never suggest "Water for dinner."
2.  **The "Alcohol" Rail:**
    - _Logic:_ If `is_alcohol` is true.
    - _Override:_ Never suggest more alcohol. Suggest Water + Electrolytes + B-Vitamins.
3.  **The "Allergy" Rail:**
    - _Logic:_ String matching check on the LLM output _before_ sending to Frontend.
    - _Check:_ If `User.allergy = 'Peanut'` and `LLM.response contains 'Peanut'`, discard and regenerate.

---
