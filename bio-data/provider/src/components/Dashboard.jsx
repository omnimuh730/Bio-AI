import {
	BarChart,
	Bar,
	XAxis,
	YAxis,
	CartesianGrid,
	Tooltip,
	ResponsiveContainer,
	Cell,
	Radar,
	RadarChart,
	PolarGrid,
	PolarAngleAxis,
	PolarRadiusAxis,
	LineChart,
	Line,
	PieChart,
	Pie,
	Legend,
} from "recharts";
import { NUTRI_SCORE_COLORS } from "../constants";
import {
	Box,
	Grid,
	Card,
	CardContent,
	Typography,
	Button,
	Table,
	TableBody,
	TableCell,
	TableHead,
	TableRow,
} from "@mui/material";

const APP_NOW = Date.now();

function getWeekKey(ts) {
	const d = new Date(ts);
	const onejan = new Date(d.getFullYear(), 0, 1);
	const days = Math.floor((d - onejan) / (24 * 60 * 60 * 1000));
	const week = Math.ceil((days + onejan.getDay() + 1) / 7);
	return `${d.getFullYear()}-W${String(week).padStart(2, "0")}`;
}

const Dashboard = ({ products }) => {
	// Derived metrics
	const totalProducts = products.length;
	const avgQuality = (
		products.reduce(
			(s, p) => s + (p.quality_score ? Number(p.quality_score) : 0),
			0,
		) / Math.max(1, totalProducts)
	).toFixed(1);

	// Completeness (fields presence)
	const completeness = (() => {
		const fields = [
			"image_url",
			"nutriscore_grade",
			"nutriments",
			"ingredients_text",
		];
		let totalChecks = 0;
		let present = 0;
		for (const p of products) {
			for (const f of fields) {
				totalChecks++;
				if (p[f] !== undefined && p[f] !== null && p[f] !== "")
					present++;
			}
		}
		return totalChecks === 0
			? 100
			: Math.round((present / totalChecks) * 100);
	})();

	// Flagged percentage
	const flaggedCount = products.filter(
		(p) =>
			p.status === "flagged" || (p.quality_score && p.quality_score < 60),
	).length;
	const flaggedPct = Math.round(
		(flaggedCount / Math.max(1, totalProducts)) * 100,
	);

	// Nutri-score distribution
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

	// Time-series: avg quality per week (last 12 weeks)
	const qualitySeries = (() => {
		const map = new Map();
		for (const p of products) {
			const ts =
				p.last_modified || p.created_at || p.updated_at || APP_NOW;
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

	// 2. Average Macros for Radar Chart
	const avgMacros = products.reduce(
		(acc, p) => {
			acc.fat += p.nutriments?.fat_100g || 0;
			acc.carbs += p.nutriments?.carbohydrates_100g || 0;
			acc.protein += p.nutriments?.proteins_100g || 0;
			acc.sugar += p.nutriments?.sugars_100g || 0;
			acc.salt += (p.nutriments?.salt_100g || 0) * 10; // scaled
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





	return (
		<Box className="space-y-6">
			{/* Top Stats */}
			<Grid container spacing={2}>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Total Products
							</Typography>
							<Typography variant="h5">
								{totalProducts}
							</Typography>
						</CardContent>
					</Card>
				</Grid>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Avg Quality Score
							</Typography>
							<Typography variant="h5">{avgQuality}%</Typography>
						</CardContent>
					</Card>
				</Grid>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Completeness
							</Typography>
							<Typography variant="h5">
								{completeness}%
							</Typography>
						</CardContent>
					</Card>
				</Grid>
				<Grid item xs={12} md={3}>
					<Card>
						<CardContent>
							<Typography variant="caption" color="textSecondary">
								Flagged
							</Typography>
							<Typography variant="h5">{flaggedPct}%</Typography>
						</CardContent>
					</Card>
				</Grid>
			</Grid>

			<div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
				{/* Nutri-Score Chart */}
				<div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
					<h3 className="text-lg font-bold text-slate-800 mb-6 flex items-center">
						<i className="fas fa-chart-bar mr-2 text-indigo-500"></i>{" "}
						Quality Distribution
					</h3>
					<div className="h-64">
						<ResponsiveContainer width="100%" height="100%">
							<BarChart data={nutriChartData}>
								<CartesianGrid
									strokeDasharray="3 3"
									vertical={false}
									stroke="#f1f5f9"
								/>
								<XAxis
									dataKey="grade"
									axisLine={false}
									tickLine={false}
								/>
								<YAxis axisLine={false} tickLine={false} />
								<Tooltip cursor={{ fill: "#f8fafc" }} />
								<Bar dataKey="count" radius={[6, 6, 0, 0]}>
									{nutriChartData.map((entry, index) => (
										<Cell
											key={`cell-${index}`}
											fill={
												entry.grade === "A"
													? "#059669"
													: entry.grade === "B"
														? "#10B981"
														: entry.grade === "C"
															? "#FACC15"
															: entry.grade ===
																  "D"
																? "#F97316"
																: "#DC2626"
											}
										/>
									))}
								</Bar>
							</BarChart>
						</ResponsiveContainer>
					</div>
					<div className="mt-3" style={{ height: 60 }}>
						<ResponsiveContainer width="100%" height="100%">
							<LineChart data={qualitySeries}>
								<Line
									dataKey="avg"
									stroke="#059669"
									strokeWidth={2}
									dot={false}
								/>
								<Tooltip />
							</LineChart>
						</ResponsiveContainer>
					</div>
				</div>

				{/* Radar Chart */}
				<div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
					<h3 className="text-lg font-bold text-slate-800 mb-6 flex items-center">
						<i className="fas fa-bullseye mr-2 text-rose-500"></i>{" "}
						Aggregate Nutrient Profile
					</h3>
					<div className="h-64">
						<ResponsiveContainer width="100%" height="100%">
							<RadarChart
								cx="50%"
								cy="50%"
								outerRadius="80%"
								data={radarData}
							>
								<PolarGrid stroke="#e2e8f0" />
								<PolarAngleAxis dataKey="subject" />
								<PolarRadiusAxis angle={30} domain={[0, 100]} />
								<Radar
									name="Avg 100g"
									dataKey="A"
									stroke="#4f46e5"
									fill="#4f46e5"
									fillOpacity={0.5}
								/>
								<Tooltip />
							</RadarChart>
						</ResponsiveContainer>
						<CartesianGrid stroke="#f1f5f9" vertical={false} />
						<XAxis
							dataKey="name"
							axisLine={false}
							tickLine={false}
						/>
						<YAxis axisLine={false} tickLine={false} />
						<Tooltip />
						<Area
							type="monotone"
							dataKey="count"
							fill="#fee2e2"
							stroke="#ef4444"
						/>
						<Bar
							dataKey="count"
							fill="#4f46e5"
							radius={[4, 4, 0, 0]}
							barSize={40}
						/>
					</div>
				</div>
			</div>
		</Box>
	);
};

export default Dashboard;
