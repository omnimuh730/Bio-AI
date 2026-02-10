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
	ComposedChart,
	Line,
	Area,
} from "recharts";
import { NUTRI_SCORE_COLORS } from "../constants";

const Dashboard = ({ products }) => {
	// 1. Nutri-Score Distribution
	const nutriCounts = products.reduce((acc, p) => {
		acc[p.nutriscore_grade] = (acc[p.nutriscore_grade] || 0) + 1;
		return acc;
	}, {});

	const nutriChartData = ["A", "B", "C", "D", "E"].map((grade) => ({
		grade,
		count: nutriCounts[grade] || 0,
	}));

	// 2. Average Macros for Radar Chart
	const avgMacros = products.reduce(
		(acc, p) => {
			acc.fat += p.nutriments.fat_100g;
			acc.carbs += p.nutriments.carbohydrates_100g;
			acc.protein += p.nutriments.proteins_100g;
			acc.sugar += p.nutriments.sugars_100g;
			acc.salt += p.nutriments.salt_100g * 10; // Scaled for visibility
			return acc;
		},
		{ fat: 0, carbs: 0, protein: 0, sugar: 0, salt: 0 },
	);

	const radarData = [
		{ subject: "Fat", A: avgMacros.fat / products.length, fullMark: 100 },
		{
			subject: "Carbs",
			A: avgMacros.carbs / products.length,
			fullMark: 100,
		},
		{
			subject: "Protein",
			A: avgMacros.protein / products.length,
			fullMark: 100,
		},
		{
			subject: "Sugar",
			A: avgMacros.sugar / products.length,
			fullMark: 100,
		},
		{
			subject: "Salt (x10)",
			A: avgMacros.salt / products.length,
			fullMark: 100,
		},
	];

	return (
		<div className="space-y-8">
			{/* Top Stats */}
			<div className="grid grid-cols-1 md:grid-cols-4 gap-6">
				{[
					{
						label: "Total Products",
						val: products.length,
						icon: "fa-boxes-stacked",
						color: "bg-blue-100 text-blue-600",
					},
					{
						label: "Avg Nutri-Score",
						val: "B+",
						icon: "fa-heart-pulse",
						color: "bg-emerald-100 text-emerald-600",
					},

					{
						label: "Unique Brands",
						val: new Set(products.map((p) => p.brands)).size,
						icon: "fa-tag",
						color: "bg-purple-100 text-purple-600",
					},
				].map((stat, i) => (
					<div
						key={i}
						className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100"
					>
						<div className="flex items-center space-x-4">
							<div className={`${stat.color} p-3 rounded-lg`}>
								<i className={`fas ${stat.icon} text-xl`}></i>
							</div>
							<div>
								<p className="text-xs font-bold text-slate-400 uppercase tracking-wider">
									{stat.label}
								</p>
								<h3 className="text-2xl font-bold text-slate-800">
									{stat.val}
								</h3>
							</div>
						</div>
					</div>
				))}
			</div>

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
		</div>
	);
};

export default Dashboard;
