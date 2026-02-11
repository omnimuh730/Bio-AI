- User Profile

```
{
	"_id": "user_abc123", // App internal anonymous ID (not linked to actual personal information)
	"createdAt": "2026-02-01T10:00:00Z",
	"updatedAt": "2026-02-09T13:45:00Z", // Last profile modification time
	// 1. Activity Pattern (Selected once during onboarding, can be modified anytime)
	"activityPattern": {
		"dailyMainPosture": "mostly_sitting", // Example options
		// mostly_sitting / mostly_standing / mixed_standing_sitting / mostly_walking / physically_active
		"dailyStepsEstimate": "low", // low (~4,000) / medium (~7,000) / high (~10,000+) / very_high
		"exerciseFrequency": "1-2_times_week", // none / 1-2 / 3-4 / 5+ / almost_every_day
		"typicalDailyEnergyLevel": "medium" // low / medium / high (subjective fatigue level)
	},
	// 2. Goal Setting – Relative and change-oriented, not absolute values
	"goals": {
		"weightDirection": "lose", // lose / maintain / gain
		"desiredWeightChangeKg": 10, // Total desired weight loss/gain (kg) – relative
		"desiredTimelineMonths": 4, // How many months to reach the goal (onboarding question)
		"calculatedDailyDeficitKcal": -550, // Automatically calculated by the system (e.g., 10kg ÷ 4 months ≈ 0.625kg per week → approximately -550kcal per day)
		"macroPreference": "balanced", // balanced / higher_protein / lower_carb / custom_ratio
		"customMacroRatio": { // Optional
			"protein": 0.30,
			"carbs": 0.40,
			"fat": 0.30
		},
		"toleranceRangePercent": 15 // Tolerance range (15% recommended by default, user can modify)
	},
	// 3. Constraints (Hard filter – medically necessary)
	"restrictions": {
		"allergies": [
			"nuts",
			"shellfish"
		],
		"avoidIngredients": [
			"cilantro",
			"raw_onion"
		],
		"avoidCategories": [
			"deep_fried"
		]
	},
	// 4. Preferences (Soft preference – score-based)
	"preferences": {
		"likedFoods": [
			{
				"foodId": "openfacts_abc123",
				"score": 0.92
			},
			{
				"foodId": "usda_45678",
				"score": 0.85
			}
		],
		"dislikedFoods": [
			{
				"foodId": "...",
				"score": -0.70
			}
		],
		"mealTimePreference": [
			"breakfast_heavy",
			"light_dinner"
		]
	},
	// 5. Behavior & Feedback History (Maintain only for the last 60 days)
	"history": {
		"recentMeals": [
			{
				"date": "2026-02-08",
				"mealType": "lunch",
				"foodIds": [
					"abc123",
					"def456"
				],
				"estimatedCalories": 680
			}
		],
		"feedbacks": [
			{
				"foodId": "xyz789",
				"liked": true,
				"reasonCategory": "nutrition_match",
				"reasonText": "I liked it because it was high in protein.",
				"timestamp": "2026-02-08T14:30:00Z"
			},
			{
				"liked": false,
				"reasonCategory": "ingredient_dislike",
				"reasonText": "The onion taste was too strong."
			}
		]
	},
	// 6. Summary Vector for ML (To improve real-time recommendation speed)
	"profileEmbedding": [
		0.021,
		-0.145,
		0.378, ...
	], // 384-768 dimensional vector
	"lastEmbeddingUpdate": "2026-02-09T13:45:00Z",
	// 7. User control settings
	"settings": {
		"recommendationDiversity": 0.65, // Between 0 and 1 (higher value suggests a wider variety of food)
		"dailySuggestionLimit": 12,
		"toleranceOverride": true, // "It's okay to exceed the goal" toggle
		"allowSlightOverCalories": 80 // Can be set directly in kcal (default is system calculation)
	}
}
```
