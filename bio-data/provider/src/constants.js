export const PROD_CATEGORIES = [
	"Sandwich",
	"Beverage",
	"Omelette",
	"Salad",
	"Snack",
	"Dessert",
	"Entree",
	"Side",
];

export const SAVED_SEGMENTS = [
	{
		id: "s1",
		name: "High Protein Snacks",
		query: "category:Snack protein > 10",
		icon: "fa-dumbbell",
	},
	{
		id: "s2",
		name: "Sugar-Free Drinks",
		query: "category:Beverage sugar < 1",
		icon: "fa-droplet-slash",
	},
	{
		id: "s3",
		name: "Ready to Review",
		query: "status:flagged",
		icon: "fa-clipboard-check",
	},
];

export const MOCK_PRODUCTS = [
	{
		id: "1",
		code: "3017620422003",
		product_name: "Nutella 400g",
		brands: "Ferrero",
		categories: ["Spreads", "Hazelnut spreads"],
		mappedCategory: "Snack",
		nutriscore_grade: "E",
		nova_group: 4,
		image_url: "https://picsum.photos/seed/nutella/400/400",
		ingredients_text:
			"Sugar, Palm Oil, Hazelnuts (13%), Skimmed Milk Powder (8.7%)",
		nutriments: {
			energy_100g: 2252,
			fat_100g: 30.9,
			saturated_fat_100g: 10.6,
			carbohydrates_100g: 57.5,
			sugars_100g: 56.3,
			fiber_100g: 0,
			proteins_100g: 6.3,
			salt_100g: 0.107,
		},
		last_modified: Date.now() - 1000000,
		status: "active",
		tags: ["verified", "high-sugar"],
		quality_score: 95,
	},
	{
		id: "2",
		code: "5449000000996",
		product_name: "Coca-Cola Zero Sugar",
		brands: "Coca-Cola",
		categories: ["Beverages", "Sodas"],
		mappedCategory: "Beverage",
		nutriscore_grade: "B",
		nova_group: 4,
		image_url: "https://picsum.photos/seed/coke/400/400",
		ingredients_text:
			"Carbonated Water, Colour (Caramel E150d), Phosphoric Acid",
		nutriments: {
			energy_100g: 1,
			fat_100g: 0,
			saturated_fat_100g: 0,
			carbohydrates_100g: 0,
			sugars_100g: 0,
			fiber_100g: 0,
			proteins_100g: 0,
			salt_100g: 0.02,
		},
		last_modified: Date.now() - 500000,
		status: "active",
		tags: ["verified", "sugar-free"],
		quality_score: 98,
	},
];

export const MOCK_AUDIT_LOGS = [
	{
		id: "log-1",
		productId: "1",
		timestamp: Date.now() - 86400000,
		user: "admin@foodflow.io",
		action: "Update Nutrition",
		changes: { sugars_100g: { from: 58.2, to: 56.3 } },
	},
	{
		id: "log-2",
		productId: "2",
		timestamp: Date.now() - 3600000,
		user: "system-ai",
		action: "Auto-Classify",
		changes: { mappedCategory: { from: "Unknown", to: "Beverage" } },
	},
];

export const NUTRI_SCORE_COLORS = {
	A: "bg-emerald-600",
	B: "bg-green-500",
	C: "bg-yellow-400",
	D: "bg-orange-500",
	E: "bg-red-600",
};
