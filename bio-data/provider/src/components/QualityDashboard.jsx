import { ResponsiveContainer, PieChart, Pie, Cell, Tooltip } from "recharts";

const QualityDashboard = ({ products, onReviewProduct }) => {
	const total = products.length;
	const flagged = products.filter((p) => p.status === "flagged").length;
	const good = products.filter((p) => p.quality_score > 90).length;
	const warning = products.filter(
		(p) => p.quality_score <= 90 && p.quality_score > 70,
	).length;
	const critical = products.filter((p) => p.quality_score <= 70).length;

	const qualityData = [
		{ name: "Good", value: good, color: "#10B981" }, // Emerald
		{ name: "Warning", value: warning, color: "#F59E0B" }, // Amber
		{ name: "Critical", value: critical, color: "#EF4444" }, // Red
	];

	const flaggedProducts = products.filter(
		(p) => p.status === "flagged" || p.quality_score < 60,
	);

	return (
		<div className="space-y-8">
			{/* KPI Cards */}
			<div className="grid grid-cols-1 md:grid-cols-3 gap-6">
				<div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
					<div>
						<p className="text-sm font-bold text-slate-400 uppercase tracking-wider">
							Overall Health
						</p>
						<h3 className="text-3xl font-black text-slate-800 mt-1">
							{(
								products.reduce(
									(acc, p) => acc + p.quality_score,
									0,
								) / total
							).toFixed(1)}
							%
						</h3>
						<p className="text-xs text-emerald-600 mt-2 font-bold">
							<i className="fas fa-arrow-up mr-1"></i> 2.4% vs
							last week
						</p>
					</div>
					<div className="h-16 w-16 bg-slate-50 rounded-full flex items-center justify-center">
						<div className="h-12 w-12 border-4 border-emerald-500 rounded-full flex items-center justify-center text-emerald-700 font-bold text-xs">
							A+
						</div>
					</div>
				</div>

				<div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
					<div>
						<p className="text-sm font-bold text-slate-400 uppercase tracking-wider">
							Pending Review
						</p>
						<h3 className="text-3xl font-black text-slate-800 mt-1">
							{flagged}
						</h3>
						<p className="text-xs text-slate-500 mt-2 font-medium">
							Items flagged by AI scan
						</p>
					</div>
					<div className="h-14 w-14 bg-rose-100 rounded-xl flex items-center justify-center text-rose-500 text-2xl">
						<i className="fas fa-flag"></i>
					</div>
				</div>

				<div className="bg-white p-6 rounded-2xl border border-slate-100 shadow-sm flex items-center justify-between">
					<div>
						<p className="text-sm font-bold text-slate-400 uppercase tracking-wider">
							Completeness
						</p>
						<h3 className="text-3xl font-black text-slate-800 mt-1">
							94.2%
						</h3>
						<p className="text-xs text-slate-500 mt-2 font-medium">
							Fields populated
						</p>
					</div>
					<div className="h-14 w-14 bg-indigo-100 rounded-xl flex items-center justify-center text-indigo-500 text-2xl">
						<i className="fas fa-check-double"></i>
					</div>
				</div>
			</div>

			<div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
				{/* Chart */}
				<div className="bg-white p-8 rounded-2xl border border-slate-100 shadow-sm">
					<h3 className="text-lg font-bold text-slate-800 mb-6">
						Data Quality Distribution
					</h3>
					<div className="h-64 relative">
						<ResponsiveContainer width="100%" height="100%">
							<PieChart>
								<Pie
									data={qualityData}
									cx="50%"
									cy="50%"
									innerRadius={60}
									outerRadius={80}
									paddingAngle={5}
									dataKey="value"
								>
									{qualityData.map((entry, index) => (
										<Cell
											key={`cell-${index}`}
											fill={entry.color}
										/>
									))}
								</Pie>
								<Tooltip />
							</PieChart>
						</ResponsiveContainer>
						<div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
							<span className="text-3xl font-bold text-slate-800">
								{total}
							</span>
							<span className="text-xs text-slate-400 font-bold uppercase">
								Products
							</span>
						</div>
					</div>
					<div className="flex justify-center gap-4 mt-4">
						{qualityData.map((d) => (
							<div
								key={d.name}
								className="flex items-center text-xs font-bold text-slate-600"
							>
								<span
									className="w-3 h-3 rounded-full mr-2"
									style={{ backgroundColor: d.color }}
								></span>
								{d.name}
							</div>
						))}
					</div>
				</div>

				{/* Action List */}
				<div className="lg:col-span-2 bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden flex flex-col">
					<div className="p-6 border-b border-slate-100 flex justify-between items-center">
						<h3 className="text-lg font-bold text-slate-800">
							Priority Review Queue
						</h3>
						<button className="text-sm text-indigo-600 font-bold hover:underline">
							View All Issues
						</button>
					</div>
					<div className="overflow-y-auto max-h-96">
						{flaggedProducts.length === 0 ? (
							<div className="p-12 text-center text-slate-400">
								<i className="fas fa-check-circle text-4xl mb-4 text-emerald-300"></i>
								<p>No critical issues found. Great job!</p>
							</div>
						) : (
							<div className="divide-y divide-slate-50">
								{flaggedProducts.map((p) => (
									<div
										key={p.id}
										className="p-4 flex items-center justify-between hover:bg-slate-50 transition-colors"
									>
										<div className="flex items-center space-x-4">
											<div className="relative">
												<img
													src={p.image_url}
													className="w-12 h-12 rounded-lg object-cover bg-slate-100"
												/>
												{p.status === "flagged" && (
													<div className="absolute -top-1 -right-1 w-3 h-3 bg-rose-500 rounded-full border-2 border-white"></div>
												)}
											</div>
											<div>
												<h4 className="font-bold text-slate-700 text-sm">
													{p.product_name}
												</h4>
												<div className="flex gap-2 mt-1">
													{p.tags
														.filter(
															(t) =>
																t ===
																	"missing-image-metadata" ||
																t ===
																	"needs-review",
														)
														.map((t) => (
															<span
																key={t}
																className="text-[10px] bg-rose-50 text-rose-600 px-2 py-0.5 rounded font-bold uppercase"
															>
																{t.replace(
																	/-/g,
																	" ",
																)}
															</span>
														))}
													<span className="text-[10px] bg-slate-100 text-slate-500 px-2 py-0.5 rounded font-bold">
														QS: {p.quality_score}
													</span>
												</div>
											</div>
										</div>
										<div className="flex gap-2">
											<button
												onClick={() =>
													onReviewProduct(p)
												}
												className="px-3 py-1.5 rounded-lg border border-slate-200 text-slate-600 text-xs font-bold hover:bg-white hover:border-slate-300"
											>
												Details
											</button>
											<button className="px-3 py-1.5 rounded-lg bg-indigo-600 text-white text-xs font-bold hover:bg-indigo-700">
												Fix
											</button>
										</div>
									</div>
								))}
							</div>
						)}
					</div>
				</div>
			</div>
		</div>
	);
};

export default QualityDashboard;
