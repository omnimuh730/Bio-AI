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
} from "recharts";
import {
	Box,
	Grid,
	Card,
	CardContent,
	Typography,
} from "@mui/material";
import { useDashboardMetrics } from "./dashboard/useDashboardMetrics";

const Dashboard = ({ products }) => {
	const {
		totalProducts,
		avgQuality,
		completeness,
		flaggedPct,
		nutriChartData,
		qualitySeries,
		radarData,
	} = useDashboardMetrics(products);


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
