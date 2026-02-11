const APP_NOW = Date.now();

function getWeekKey(ts) {
	const d = new Date(ts);
	const onejan = new Date(d.getFullYear(), 0, 1);
	const days = Math.floor((d - onejan) / (24 * 60 * 60 * 1000));
	const week = Math.ceil((days + onejan.getDay() + 1) / 7);
	return `${d.getFullYear()}-W${String(week).padStart(2, "0")}`;
}

const COMPLETENESS_FIELDS = [
	"image_url",
	"nutriscore_grade",
	"nutriments",
	"ingredients_text",
];

export function useDashboardMetrics(products) {
	const totalProducts = products.length;
	const avgQuality = (
		products.reduce(
			(sum, p) => sum + (p.quality_score ? Number(p.quality_score) : 0),
			0,
		) / Math.max(1, totalProducts)
	).toFixed(1);

	const completeness = (() => {
		let totalChecks = 0;
		let present = 0;
		for (const p of products) {
			for (const field of COMPLETENESS_FIELDS) {
				totalChecks += 1;
				if (p[field] !== undefined && p[field] !== null && p[field] !== "")
					present += 1;
			}
		}
		return totalChecks === 0
			? 100
			: Math.round((present / totalChecks) * 100);
	})();

	const flaggedCount = products.filter(
		(p) =>
			p.status === "flagged" || (p.quality_score && p.quality_score < 60),
	).length;
	const flaggedPct = Math.round(
		(flaggedCount / Math.max(1, totalProducts)) * 100,
	);

	const nutriChartData = (() => {
		const counts = products.reduce((acc, p) => {
			const g = p.nutriscore_grade || "Unknown";
			acc[g] = (acc[g] || 0) + 1;
			return acc;
		}, {});
		return ["A", "B", "C", "D", "E", "Unknown"].map((g) => ({
			grade: g,
			count: counts[g] || 0,
		}));
	})();

	const qualitySeries = (() => {
		const map = new Map();
		for (const p of products) {
			const ts = p.last_modified || p.created_at || p.updated_at || APP_NOW;
			const key = getWeekKey(ts);
			if (!map.has(key)) map.set(key, { sum: 0, count: 0 });
			map.get(key).sum += p.quality_score ? Number(p.quality_score) : 0;
			map.get(key).count += 1;
		}
		const entries = Array.from(map.entries()).sort((a, b) =>
			a[0] > b[0] ? 1 : -1,
		);
		const series = entries.map(([key, v]) => ({
			week: key,
			avg: v.count ? +(v.sum / v.count).toFixed(1) : 0,
		}));
		return series.slice(-12);
	})();

	const avgMacros = products.reduce(
		(acc, p) => {
			acc.fat += p.nutriments?.fat_100g || 0;
			acc.carbs += p.nutriments?.carbohydrates_100g || 0;
			acc.protein += p.nutriments?.proteins_100g || 0;
			acc.sugar += p.nutriments?.sugars_100g || 0;
			acc.salt += (p.nutriments?.salt_100g || 0) * 10;
			return acc;
		},
		{ fat: 0, carbs: 0, protein: 0, sugar: 0, salt: 0 },
	);

	const radarData = [
		{
			subject: "Fat",
			A: avgMacros.fat / Math.max(1, totalProducts),
			fullMark: 100,
		},
		{
			subject: "Carbs",
			A: avgMacros.carbs / Math.max(1, totalProducts),
			fullMark: 100,
		},
		{
			subject: "Protein",
			A: avgMacros.protein / Math.max(1, totalProducts),
			fullMark: 100,
		},
		{
			subject: "Sugar",
			A: avgMacros.sugar / Math.max(1, totalProducts),
			fullMark: 100,
		},
		{
			subject: "Salt (x10)",
			A: avgMacros.salt / Math.max(1, totalProducts),
			fullMark: 100,
		},
	];

	return {
		totalProducts,
		avgQuality,
		completeness,
		flaggedPct,
		nutriChartData,
		qualitySeries,
		radarData,
	};
}
