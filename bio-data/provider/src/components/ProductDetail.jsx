import React, { useState, useMemo } from "react";
import {
	PieChart,
	Pie,
	Cell,
	ResponsiveContainer,
	Tooltip,
	Legend,
	BarChart,
	Bar,
	XAxis,
	YAxis,
} from "recharts";
import {
	X,
	Leaf,
	Activity,
	Info,
	Image as ImageIcon,
	Barcode,
	Globe,
	Tag,
	Box,
	AlertTriangle,
} from "lucide-react";

// --- Helper Components ---

const Badge = ({ children, color = "slate" }) => {
	const colors = {
		slate: "bg-slate-100 text-slate-700 border-slate-200",
		green: "bg-emerald-50 text-emerald-700 border-emerald-200",
		red: "bg-rose-50 text-rose-700 border-rose-200",
		amber: "bg-amber-50 text-amber-700 border-amber-200",
		blue: "bg-blue-50 text-blue-700 border-blue-200",
	};
	return (
		<span
			className={`px-2.5 py-1 rounded-md text-xs font-semibold border ${colors[color] || colors.slate} inline-flex items-center gap-1`}
		>
			{children}
		</span>
	);
};

const ScoreCard = ({ label, value, grade, type }) => {
	// Logic to determine color based on grade (a,b,c,d,e or 1,2,3,4)
	let bgClass = "bg-slate-100";
	let textClass = "text-slate-500";

	const g = String(grade).toLowerCase();

	if (type === "nutriscore") {
		if (["a", "b"].includes(g)) {
			bgClass = "bg-[#038141]";
			textClass = "text-white";
		} else if (g === "c") {
			bgClass = "bg-[#FECB02]";
			textClass = "text-slate-900";
		} else if (["d", "e"].includes(g)) {
			bgClass = "bg-[#E63E11]";
			textClass = "text-white";
		}
	} else if (type === "nova") {
		if (g === "1") {
			bgClass = "bg-emerald-500";
			textClass = "text-white";
		} else if (g === "3" || g === "4") {
			bgClass = "bg-rose-500";
			textClass = "text-white";
		}
	}

	return (
		<div className="flex flex-col items-center p-3 bg-white rounded-xl border border-slate-100 shadow-sm flex-1">
			<span className="text-[10px] uppercase tracking-wider font-bold text-slate-400 mb-2">
				{label}
			</span>
			<div
				className={`h-10 w-10 flex items-center justify-center rounded-lg font-black text-xl uppercase ${bgClass} ${textClass}`}
			>
				{value || "?"}
			</div>
		</div>
	);
};

const ProductDetail = ({ product, onClose }) => {
	const [activeTab, setActiveTab] = useState("overview");

	// --- Data Processing ---
	const {
		chartData,
		nutrientLevels,
		cleanCategories,
		nutrientsTable,
		images,
		additives,
	} = useMemo(() => {
		if (!product) return {};

		const n = product.nutriments || {};

		// 1. Chart Data
		const cData = [
			{ name: "Fat", value: n.fat_100g || 0, color: "#F59E0B" },
			{
				name: "Carbs",
				value: n.carbohydrates_100g || 0,
				color: "#3B82F6",
			},
			{ name: "Protein", value: n.proteins_100g || 0, color: "#10B981" },
			{ name: "Salt", value: n.salt_100g || 0, color: "#64748B" },
		].filter((d) => d.value > 0);

		// 2. Nutrient Levels (Traffic Light)
		const levels = product.nutrient_levels || {};
		const levelMap = Object.entries(levels).map(([key, val]) => ({
			key,
			label: key.replace(/-/g, " "),
			value: val, // low, moderate, high
		}));

		// 3. Categories
		const cats = (product.categories_tags || [])
			.map((c) =>
				c
					.replace("en:", "")
					.replace(/-/g, " ")
					.replace(/\b\w/g, (l) => l.toUpperCase()),
			)
			.slice(0, 10);

		// 4. Full Nutrient Table
		const importantKeys = [
			"energy-kcal",
			"fat",
			"saturated-fat",
			"carbohydrates",
			"sugars",
			"fiber",
			"proteins",
			"salt",
			"sodium",
			"fruits-vegetables-nuts-estimate-from-ingredients",
		];
		const tableData = importantKeys.map((key) => {
			const val100 = n[`${key}_100g`];
			const valServing = n[`${key}_serving`];
			const unit =
				n[`${key}_unit`] || (key.includes("energy") ? "kcal" : "g");
			return {
				label: key
					.replace(/-/g, " ")
					.replace("estimate from ingredients", "est."),
				val100:
					val100 !== undefined
						? `${Number(val100).toFixed(1)}${unit}`
						: "-",
				valServing:
					valServing !== undefined
						? `${Number(valServing).toFixed(1)}${unit}`
						: "-",
			};
		});

		// 5. Images
		const imgs = [
			{ label: "Front", url: product.image_front_url },
			{ label: "Ingredients", url: product.image_ingredients_url },
			{ label: "Nutrition", url: product.image_nutrition_url },
		].filter((i) => i.url);

		return {
			chartData: cData,
			nutrientLevels: levelMap,
			cleanCategories: cats,
			nutrientsTable: tableData,
			images: imgs,
			additives:
				product.additives_tags?.map((a) =>
					a.replace("en:", "").toUpperCase(),
				) || [],
		};
	}, [product]);

	if (!product) return null;

	return (
		<div className="fixed inset-0 z-[9999] flex items-center justify-center p-4 sm:p-6 font-sans">
			<div
				className="absolute inset-0 bg-slate-900/60 backdrop-blur-sm transition-opacity"
				onClick={onClose}
			/>

			<div className="relative bg-[#fafafa] w-full max-w-7xl max-h-[90vh] rounded-[2rem] shadow-2xl overflow-hidden flex flex-col md:flex-row animate-in zoom-in-95 duration-300">
				{/* === SIDEBAR (Identity) === */}
				<div className="w-full md:w-[380px] bg-white border-r border-slate-200 flex flex-col shrink-0 overflow-y-auto custom-scrollbar">
					{/* Header / Back */}
					<div className="p-6 pb-2">
						<button
							onClick={onClose}
							className="group flex items-center text-slate-400 hover:text-slate-800 transition-colors text-sm font-semibold uppercase tracking-wide"
						>
							<div className="p-1.5 rounded-full bg-slate-100 group-hover:bg-slate-200 mr-2 transition-colors">
								<X size={16} />
							</div>
							Close View
						</button>
					</div>

					{/* Product Hero */}
					<div className="px-8 py-4 flex flex-col items-center text-center">
						<div className="relative w-48 h-48 sm:w-64 sm:h-64 mb-6 bg-white rounded-3xl shadow-lg border border-slate-100 p-6 flex items-center justify-center group">
							<img
								src={
									product.image_url ||
									"https://via.placeholder.com/300?text=No+Image"
								}
								alt={product.product_name}
								className="max-h-full max-w-full object-contain group-hover:scale-110 transition-transform duration-500 ease-out"
							/>
							{product.labels_tags?.includes("en:organic") && (
								<div
									className="absolute top-4 right-4 bg-emerald-500 text-white p-1.5 rounded-full shadow-md"
									title="Organic"
								>
									<Leaf size={16} />
								</div>
							)}
						</div>

						<div className="mb-1 text-slate-400 text-xs font-bold uppercase tracking-widest">
							{product.brands}
						</div>
						<h1 className="text-2xl sm:text-3xl font-extrabold text-slate-800 leading-tight mb-2">
							{product.product_name}
						</h1>
						<p className="text-slate-500 font-medium">
							{product.quantity || product.product_quantity
								? `${product.product_quantity || product.quantity} g`
								: ""}
							{product.serving_size && (
								<span className="text-slate-400 text-sm">
									{" "}
									• Serving: {product.serving_size}
								</span>
							)}
						</p>
					</div>

					{/* Scores Row */}
					<div className="px-6 py-4 grid grid-cols-3 gap-3">
						<ScoreCard
							label="Nutri-Score"
							value={product.nutriscore_grade?.toUpperCase()}
							grade={product.nutriscore_grade}
							type="nutriscore"
						/>
						<ScoreCard
							label="NOVA"
							value={product.nova_group}
							grade={product.nova_group}
							type="nova"
						/>
						<ScoreCard
							label="Eco-Score"
							value={
								product.ecoscore_grade !== "unknown"
									? product.ecoscore_grade?.toUpperCase()
									: "?"
							}
							grade={product.ecoscore_grade}
							type="nutriscore" // reusing color logic roughly
						/>
					</div>

					{/* Barcode Section (Bottom of Sidebar) */}
					<div className="mt-auto p-6 bg-slate-50 border-t border-slate-200">
						<div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col items-center">
							<div className="flex items-center gap-2 text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 w-full">
								<Barcode size={14} />
								<span>Product Code</span>
							</div>
							{/* Generates a real barcode image */}
							<img
								src={`https://bwipjs-api.metafloor.com/?bcid=ean13&text=${product.code}&scale=3&incltext&textxalign=center&barcolor=1e293b&textcolor=64748b`}
								alt={product.code}
								className="h-16 w-full object-contain mix-blend-multiply"
							/>
						</div>
					</div>
				</div>

				{/* === MAIN CONTENT (Tabs) === */}
				<div className="flex-1 flex flex-col overflow-hidden bg-[#fafafa]">
					{/* Tabs Header */}
					<div className="flex items-center px-6 pt-6 border-b border-slate-200 bg-white/50 backdrop-blur-md sticky top-0 z-10 gap-6 overflow-x-auto no-scrollbar">
						{[
							{
								id: "overview",
								label: "Overview",
								icon: Activity,
							},
							{ id: "nutrition", label: "Nutrition", icon: Info },
							{
								id: "ingredients",
								label: "Ingredients",
								icon: Leaf,
							},
							{
								id: "gallery",
								label: "Gallery & Meta",
								icon: ImageIcon,
							},
						].map((tab) => (
							<button
								key={tab.id}
								onClick={() => setActiveTab(tab.id)}
								className={`flex items-center gap-2 pb-4 text-sm font-bold border-b-2 transition-all whitespace-nowrap ${
									activeTab === tab.id
										? "text-indigo-600 border-indigo-600"
										: "text-slate-400 border-transparent hover:text-slate-600"
								}`}
							>
								<tab.icon size={16} />
								{tab.label}
							</button>
						))}
					</div>

					{/* Scrollable Content */}
					<div className="flex-1 overflow-y-auto p-6 md:p-10 custom-scrollbar">
						{/* --- TAB: OVERVIEW --- */}
						{activeTab === "overview" && (
							<div className="animate-in fade-in slide-in-from-bottom-4 duration-300 space-y-8">
								{/* Nutrient Levels */}
								<section>
									<h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-4 flex items-center gap-2">
										<Activity
											size={16}
											className="text-indigo-500"
										/>{" "}
										Nutrient Levels
									</h3>
									<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
										{nutrientLevels.map((level, idx) => {
											const isHigh =
												level.value === "en:high";
											const isLow =
												level.value === "en:low";
											return (
												<div
													key={idx}
													className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-3"
												>
													<div
														className={`w-3 h-full rounded-full ${isHigh ? "bg-rose-500" : isLow ? "bg-emerald-500" : "bg-amber-400"}`}
													></div>
													<div>
														<div className="text-xs text-slate-400 font-bold uppercase">
															{level.label}
														</div>
														<div className="text-sm font-semibold capitalize text-slate-700">
															{level.value.replace(
																"en:",
																"",
															)}
														</div>
													</div>
												</div>
											);
										})}
									</div>
								</section>

								{/* Macro Chart */}
								<section className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm">
									<h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-6">
										Macro Distribution (per 100g)
									</h3>
									<div className="h-64 w-full">
										<ResponsiveContainer
											width="100%"
											height="100%"
										>
											<BarChart
												data={chartData}
												layout="vertical"
												margin={{ left: 20 }}
											>
												<XAxis type="number" hide />
												<YAxis
													dataKey="name"
													type="category"
													axisLine={false}
													tickLine={false}
													width={60}
													tick={{
														fill: "#64748B",
														fontSize: 12,
														fontWeight: 600,
													}}
												/>
												<Tooltip
													cursor={{
														fill: "transparent",
													}}
													contentStyle={{
														borderRadius: "12px",
														border: "none",
														boxShadow:
															"0 10px 15px -3px rgb(0 0 0 / 0.1)",
													}}
												/>
												<Bar
													dataKey="value"
													radius={[0, 4, 4, 0]}
													barSize={20}
												>
													{chartData.map(
														(entry, index) => (
															<Cell
																key={`cell-${index}`}
																fill={
																	entry.color
																}
															/>
														),
													)}
												</Bar>
											</BarChart>
										</ResponsiveContainer>
									</div>
								</section>

								{/* Labels / Tags */}
								<section>
									<h3 className="text-sm font-bold text-slate-900 uppercase tracking-wider mb-4 flex items-center gap-2">
										<Tag
											size={16}
											className="text-indigo-500"
										/>{" "}
										Categories & Labels
									</h3>
									<div className="flex flex-wrap gap-2">
										{cleanCategories.map((cat, i) => (
											<span
												key={i}
												className="px-3 py-1.5 bg-white border border-slate-200 rounded-lg text-xs font-semibold text-slate-600 shadow-sm hover:shadow-md transition-shadow cursor-default"
											>
												{cat}
											</span>
										))}
										{product.labels_tags?.map((l, i) => (
											<span
												key={`l-${i}`}
												className="px-3 py-1.5 bg-indigo-50 border border-indigo-100 rounded-lg text-xs font-semibold text-indigo-600 shadow-sm"
											>
												{l
													.replace("en:", "")
													.replace(/-/g, " ")}
											</span>
										))}
									</div>
								</section>
							</div>
						)}

						{/* --- TAB: NUTRITION --- */}
						{activeTab === "nutrition" && (
							<div className="animate-in fade-in slide-in-from-bottom-4 duration-300">
								<div className="bg-white rounded-2xl border border-slate-200 overflow-hidden shadow-sm">
									<table className="w-full text-sm text-left">
										<thead className="bg-slate-50 text-slate-500 font-semibold uppercase text-xs tracking-wider">
											<tr>
												<th className="px-6 py-4">
													Nutrient
												</th>
												<th className="px-6 py-4">
													Per 100g/ml
												</th>
												<th className="px-6 py-4">
													Per Serving
												</th>
											</tr>
										</thead>
										<tbody className="divide-y divide-slate-100">
											{nutrientsTable.map((row, i) => (
												<tr
													key={i}
													className="hover:bg-slate-50/50 transition-colors"
												>
													<td className="px-6 py-4 font-medium text-slate-700 capitalize">
														{row.label}
													</td>
													<td className="px-6 py-4 text-slate-600 font-mono">
														{row.val100}
													</td>
													<td className="px-6 py-4 text-slate-600 font-mono">
														{row.valServing}
													</td>
												</tr>
											))}
										</tbody>
									</table>
									{nutrientsTable.length === 0 && (
										<div className="p-8 text-center text-slate-400 italic">
											No detailed nutrition data
											available.
										</div>
									)}
								</div>
							</div>
						)}

						{/* --- TAB: INGREDIENTS --- */}
						{activeTab === "ingredients" && (
							<div className="animate-in fade-in slide-in-from-bottom-4 duration-300 space-y-8">
								<div className="bg-white p-8 rounded-3xl border border-slate-200 shadow-sm relative overflow-hidden">
									<div className="absolute top-0 left-0 w-1 h-full bg-indigo-500"></div>
									<h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest mb-4">
										Full Ingredients List
									</h3>
									<p className="text-slate-700 leading-loose text-sm font-medium">
										{product.ingredients_text ? (
											product.ingredients_text
										) : (
											<span className="italic text-slate-400">
												Ingredients text not available.
											</span>
										)}
									</p>
								</div>

								<div className="grid grid-cols-1 md:grid-cols-2 gap-6">
									{/* Allergens */}
									<div className="bg-rose-50 p-6 rounded-2xl border border-rose-100">
										<h4 className="text-rose-800 font-bold flex items-center gap-2 mb-3">
											<AlertTriangle size={18} />{" "}
											Allergens
										</h4>
										<div className="flex flex-wrap gap-2">
											{product.allergens_tags?.length >
											0 ? (
												product.allergens_tags.map(
													(a, i) => (
														<Badge
															key={i}
															color="red"
														>
															{a.replace(
																"en:",
																"",
															)}
														</Badge>
													),
												)
											) : (
												<span className="text-rose-400 text-sm italic">
													No allergens listed
												</span>
											)}
										</div>
									</div>

									{/* Additives */}
									<div className="bg-amber-50 p-6 rounded-2xl border border-amber-100">
										<h4 className="text-amber-800 font-bold flex items-center gap-2 mb-3">
											<Box size={18} /> Additives
										</h4>
										<div className="flex flex-wrap gap-2">
											{additives.length > 0 ? (
												additives.map((a, i) => (
													<Badge
														key={i}
														color="amber"
													>
														{a}
													</Badge>
												))
											) : (
												<span className="text-amber-400 text-sm italic">
													No additives detected
												</span>
											)}
										</div>
									</div>
								</div>
							</div>
						)}

						{/* --- TAB: GALLERY & META --- */}
						{activeTab === "gallery" && (
							<div className="animate-in fade-in slide-in-from-bottom-4 duration-300 space-y-8">
								{/* Gallery Grid */}
								<div className="grid grid-cols-1 sm:grid-cols-3 gap-6">
									{images.map((img, idx) => (
										<div
											key={idx}
											className="group relative aspect-[4/3] bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden"
										>
											<div className="absolute top-3 left-3 bg-black/60 backdrop-blur text-white text-[10px] font-bold px-2 py-1 rounded">
												{img.label}
											</div>
											<img
												src={img.url}
												alt={img.label}
												className="w-full h-full object-contain p-4 group-hover:scale-105 transition-transform duration-500"
											/>
										</div>
									))}
								</div>

								{/* Meta Data */}
								<div className="bg-slate-900 text-slate-300 p-8 rounded-3xl shadow-xl">
									<h3 className="text-white font-bold flex items-center gap-2 mb-6">
										<Globe size={20} /> Product Metadata
									</h3>
									<div className="grid grid-cols-1 md:grid-cols-2 gap-x-12 gap-y-6 text-sm">
										<div>
											<span className="block text-slate-500 text-xs uppercase font-bold mb-1">
												Countries
											</span>
											<p className="text-white">
												{product.countries
													?.split(",")
													.join(", ")}
											</p>
										</div>
										<div>
											<span className="block text-slate-500 text-xs uppercase font-bold mb-1">
												Packaging
											</span>
											<p className="text-white">
												{product.packaging || "Unknown"}
											</p>
										</div>
										<div>
											<span className="block text-slate-500 text-xs uppercase font-bold mb-1">
												Manufacturing Places
											</span>
											<p className="text-white">
												{product.manufacturing_places ||
													"Unknown"}
											</p>
										</div>
										<div>
											<span className="block text-slate-500 text-xs uppercase font-bold mb-1">
												Last Modified
											</span>
											<p className="text-white font-mono">
												{new Date(
													product.last_modified_t *
														1000,
												).toLocaleDateString()}
											</p>
										</div>
										<div className="col-span-full">
											<span className="block text-slate-500 text-xs uppercase font-bold mb-1">
												Raw Keywords
											</span>
											<p className="text-slate-400 text-xs leading-relaxed">
												{product._keywords?.join(", ")}
											</p>
										</div>
									</div>
								</div>
							</div>
						)}
					</div>
				</div>
			</div>
		</div>
	);
};

export default ProductDetail;
