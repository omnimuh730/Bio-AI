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

export const MOCK_PRODUCTS = [];

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
