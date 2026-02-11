import React, { useState, useMemo } from "react";
import {
	BarChart,
	Bar,
	XAxis,
	YAxis,
	ResponsiveContainer,
	Cell,
	Tooltip,
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
	Factory,
	ShoppingBag,
	Clock,
	Database,
} from "lucide-react";

// --- Utility Components ---

const Badge = ({ children, color = "slate", icon: Icon }) => {
	const colors = {
		slate: "bg-slate-100 text-slate-700 border-slate-200",
		green: "bg-emerald-50 text-emerald-700 border-emerald-200",
		red: "bg-rose-50 text-rose-700 border-rose-200",
		amber: "bg-amber-50 text-amber-700 border-amber-200",
		blue: "bg-blue-50 text-blue-700 border-blue-200",
		indigo: "bg-indigo-50 text-indigo-700 border-indigo-200",
	};
	return (
		<span
			className={`px-3 py-1.5 rounded-lg text-xs font-semibold border ${colors[color] || colors.slate} inline-flex items-center gap-2 shadow-sm`}
		>
			{Icon && <Icon size={12} />}
			{children}
		</span>
	);
};

const InfoRow = ({ label, value, icon: Icon }) => {
	if (!value) return null;
	return (
		<div className="flex flex-col sm:flex-row sm:justify-between sm:items-center py-3 border-b border-slate-100 last:border-0 gap-1">
			<span className="text-slate-500 text-sm flex items-center gap-2">
				{Icon && <Icon size={14} className="text-slate-400" />}
				{label}
			</span>
			<span className="text-slate-800 font-medium text-sm text-right">
				{value}
			</span>
		</div>
	);
};

const ScoreBadge = ({ label, grade, type }) => {
	if (!grade) return null;
	const g = String(grade).toLowerCase();

	let bg = "bg-slate-200";
	let text = "text-slate-600";

	if (type === "nutriscore") {
		if (["a", "b"].includes(g)) {
			bg = "bg-[#038141]";
			text = "text-white";
		} else if (g === "c") {
			bg = "bg-[#FECB02]";
			text = "text-slate-900";
		} else if (["d", "e"].includes(g)) {
			bg = "bg-[#E63E11]";
			text = "text-white";
		}
	} else if (type === "nova") {
		if (g === "1") {
			bg = "bg-emerald-500";
			text = "text-white";
		} else if (g === "3" || g === "4") {
			bg = "bg-rose-500";
			text = "text-white";
		}
	} else if (type === "eco") {
		if (["a", "b"].includes(g)) {
			bg = "bg-teal-600";
			text = "text-white";
		} else if (g === "d" || g === "e") {
			bg = "bg-orange-600";
			text = "text-white";
		}
	}

	return (
		<div className="flex flex-col items-center bg-white p-2 rounded-xl border border-slate-100 shadow-sm min-w-[80px]">
			<span className="text-[10px] uppercase font-bold text-slate-400 mb-1">
				{label}
			</span>
			<div
				className={`h-8 w-12 rounded flex items-center justify-center font-black uppercase text-lg ${bg} ${text}`}
			>
				{grade}
			</div>
		</div>
	);
};

const ProductDetail = ({ product, onClose }) => {
	const [activeTab, setActiveTab] = useState("highlights");

	// --- Smart Data Processing ---
	const data = useMemo(() => {
		if (!product) return null;
		const n = product.nutriments || {};

		// 1. Nutrient Table Generation
		// We define a list of potential nutrients to look for.
		const nutrientKeys = [
			"energy-kcal",
			"energy-kj",
			"fat",
			"saturated-fat",
			"trans-fat",
			"cholesterol",
			"carbohydrates",
			"sugars",
			"fiber",
			"proteins",
			"salt",
			"sodium",
			"vitamin-a",
			"vitamin-c",
			"vitamin-d",
			"calcium",
			"iron",
			"potassium",
		];

		const nutritionTable = nutrientKeys
			.map((key) => {
				// Logic: If _100g, _serving, or _prepared exists, we show the row.
				const val100 = n[`${key}_100g`];
				const valServing = n[`${key}_serving`];
				const valPrepared =
					n[`${key}_prepared_100g`] || n[`${key}_prepared`]; // Sometimes raw value
				const unit =
					n[`${key}_unit`] || (key.includes("energy") ? "" : "g");

				if (
					val100 === undefined &&
					valServing === undefined &&
					valPrepared === undefined
				)
					return null;

				return {
					key,
					label: key.replace(/-/g, " ").replace("energy ", ""),
					unit,
					val100:
						val100 !== undefined ? Number(val100).toFixed(1) : "-",
					valServing:
						valServing !== undefined
							? Number(valServing).toFixed(1)
							: "-",
					valPrepared:
						valPrepared !== undefined
							? Number(valPrepared).toFixed(1)
							: null,
				};
			})
			.filter(Boolean);

		// 2. Chart Data (Macros)
		const chartData = [
			{ name: "Fat", value: n.fat_100g || 0, color: "#F59E0B" },
			{
				name: "Carbs",
				value: n.carbohydrates_100g || 0,
				color: "#3B82F6",
			},
			{ name: "Protein", value: n.proteins_100g || 0, color: "#10B981" },
		].filter((d) => d.value > 0);

		// 3. Clean Lists
		const cleanList = (arr) =>
			(arr || []).map((i) =>
				i.replace("en:", "").replace(/-/g, " ").toUpperCase(),
			);

		return {
			nutritionTable,
			chartData,
			categories: cleanList(product.categories_tags),
			labels: cleanList(product.labels_tags),
			allergens: cleanList(product.allergens_tags),
			traces: cleanList(product.traces_tags),
			additives: cleanList(product.additives_tags),
			countries: cleanList(product.countries_tags).join(", "),
			packagings: cleanList(product.packaging_tags).join(", "),
			origins: product.origins || "Not specified",
			stores: product.stores || "Not specified",
			editors: cleanList(product.editors_tags),
		};
	}, [product]);

	if (!product || !data) return null;

	return (
		<div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 font-sans">
			<div
				className="absolute inset-0 bg-slate-900/70 backdrop-blur-sm transition-opacity"
				onClick={onClose}
			/>

			<div className="relative bg-[#f8fafc] w-full max-w-7xl max-h-[95vh] rounded-[2rem] shadow-2xl overflow-hidden flex flex-col lg:flex-row animate-in zoom-in-95 duration-300">
				{/* ================= LEFT SIDEBAR (Identity) ================= */}
				<div className="w-full lg:w-[360px] bg-white border-r border-slate-200 flex flex-col shrink-0 overflow-y-auto custom-scrollbar z-10">
					<div className="p-6">
						<button
							onClick={onClose}
							className="mb-6 flex items-center text-slate-400 hover:text-slate-800 transition-colors text-sm font-bold uppercase tracking-wider group"
						>
							<div className="p-2 rounded-full bg-slate-100 group-hover:bg-slate-200 mr-2 transition-colors">
								<X size={16} />
							</div>
							Close
						</button>

						{/* Product Image */}
						<div className="relative aspect-square bg-white rounded-3xl border border-slate-100 shadow-lg p-6 flex items-center justify-center mb-6 group">
							<img
								src={
									product.image_url ||
									"https://placehold.co/400?text=No+Image"
								}
								alt={product.product_name}
								className="max-h-full max-w-full object-contain mix-blend-multiply group-hover:scale-110 transition-transform duration-500"
							/>
						</div>

						{/* Titles */}
						<div className="text-center mb-6">
							<div className="text-xs font-bold text-indigo-500 uppercase tracking-widest mb-2">
								{product.brands}
							</div>
							<h1 className="text-2xl font-black text-slate-800 leading-tight mb-2">
								{product.product_name}
							</h1>
							<p className="text-slate-500 font-medium">
								{product.quantity || product.product_quantity
									? `${product.product_quantity || product.quantity}g`
									: ""}
								{product.serving_size && (
									<span className="mx-2">•</span>
								)}
								{product.serving_size && (
									<span>{product.serving_size}</span>
								)}
							</p>
						</div>

						{/* Scores */}
						<div className="flex justify-center gap-3 mb-8">
							<ScoreBadge
								label="Nutri-Score"
								grade={product.nutriscore_grade}
								type="nutriscore"
							/>
							<ScoreBadge
								label="NOVA"
								grade={product.nova_group}
								type="nova"
							/>
							<ScoreBadge
								label="Eco-Score"
								grade={
									product.ecoscore_grade !== "unknown"
										? product.ecoscore_grade
										: "?"
								}
								type="eco"
							/>
						</div>

						{/* Barcode Section (Issue 3 Fixed) */}
						<div className="bg-slate-50 p-4 rounded-2xl border border-slate-200 flex flex-col items-center">
							<div className="flex items-center gap-2 text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-3">
								<Barcode size={14} /> Unique Product Code
							</div>
							<img
								src={`https://bwipjs-api.metafloor.com/?bcid=ean13&text=${product.code}&scale=3&incltext=false&barcolor=334155&height=10`}
								alt="Barcode"
								className="w-full h-16 object-contain mix-blend-multiply opacity-80"
							/>
							{/* Human Readable Number */}
							<div className="text-center font-mono text-lg tracking-[0.2em] font-bold text-slate-700 mt-2">
								{product.code}
							</div>
						</div>
					</div>
				</div>

				{/* ================= RIGHT MAIN (Details) ================= */}
				<div className="flex-1 flex flex-col min-h-0 bg-[#f8fafc]">
					{/* Navigation Tabs */}
					<div className="flex px-6 pt-4 border-b border-slate-200 bg-white/80 backdrop-blur sticky top-0 z-20 overflow-x-auto no-scrollbar gap-8">
						{[
							{
								id: "highlights",
								label: "Highlights",
								icon: Activity,
							},
							{ id: "nutrition", label: "Nutrition", icon: Info },
							{
								id: "ingredients",
								label: "Ingredients",
								icon: Leaf,
							},
							{
								id: "supply",
								label: "Supply Chain",
								icon: Factory,
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
								<tab.icon size={16} /> {tab.label}
							</button>
						))}
					</div>

					{/* Tab Content Area */}
					<div className="flex-1 overflow-y-auto p-6 lg:p-10 custom-scrollbar">
						{/* --- TAB 1: HIGHLIGHTS --- */}
						{activeTab === "highlights" && (
							<div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-300">
								{/* Nutrient Traffic Light */}
								<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
									{Object.entries(
										product.nutrient_levels || {},
									).map(([key, value]) => (
										<div
											key={key}
											className="bg-white p-4 rounded-2xl border border-slate-100 shadow-sm flex items-center gap-3"
										>
											<div
												className={`w-2 h-10 rounded-full ${value === "en:high" ? "bg-rose-500" : value === "en:low" ? "bg-emerald-500" : "bg-amber-400"}`}
											></div>
											<div>
												<div className="text-[10px] text-slate-400 font-bold uppercase tracking-wider">
													{key.replace(/-/g, " ")}
												</div>
												<div className="text-sm font-bold text-slate-700 capitalize">
													{value.replace("en:", "")}{" "}
													quantity
												</div>
											</div>
										</div>
									))}
								</div>

								<div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
									{/* Macro Chart */}
									<div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm">
										<h3 className="text-sm font-bold text-slate-900 mb-6 flex items-center gap-2">
											<Activity
												size={16}
												className="text-indigo-500"
											/>{" "}
											Macro Distribution (100g)
										</h3>
										<div className="h-48 w-full">
											<ResponsiveContainer
												width="100%"
												height="100%"
											>
												<BarChart
													data={data.chartData}
													layout="vertical"
													margin={{ left: 10 }}
												>
													<XAxis type="number" hide />
													<YAxis
														dataKey="name"
														type="category"
														axisLine={false}
														tickLine={false}
														width={70}
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
															borderRadius:
																"12px",
															border: "none",
															boxShadow:
																"0 10px 15px -3px rgb(0 0 0 / 0.1)",
														}}
													/>
													<Bar
														dataKey="value"
														radius={[0, 6, 6, 0]}
														barSize={24}
													>
														{data.chartData.map(
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
									</div>

									{/* Labels & Categories */}
									<div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm">
										<h3 className="text-sm font-bold text-slate-900 mb-6 flex items-center gap-2">
											<Tag
												size={16}
												className="text-indigo-500"
											/>{" "}
											Tags & Labels
										</h3>
										<div className="flex flex-wrap gap-2 mb-6">
											{data.labels.length > 0 ? (
												data.labels.map((l, i) => (
													<Badge
														key={i}
														color="green"
														icon={Leaf}
													>
														{l}
													</Badge>
												))
											) : (
												<span className="text-slate-400 italic text-sm">
													No specific labels
												</span>
											)}
										</div>
										<div className="w-full h-px bg-slate-100 my-4"></div>
										<h4 className="text-xs font-bold text-slate-400 uppercase mb-3">
											Categories
										</h4>
										<div className="flex flex-wrap gap-2">
											{data.categories.map((c, i) => (
												<span
													key={i}
													className="px-2 py-1 bg-slate-50 border border-slate-200 rounded text-[11px] font-medium text-slate-600"
												>
													{c}
												</span>
											))}
										</div>
									</div>
								</div>
							</div>
						)}

						{/* --- TAB 2: NUTRITION (Smart Table) --- */}
						{activeTab === "nutrition" && (
							<div className="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden animate-in fade-in slide-in-from-bottom-4 duration-300">
								<table className="w-full text-sm text-left">
									<thead className="bg-slate-50 text-slate-500 font-bold uppercase text-[11px] tracking-wider border-b border-slate-100">
										<tr>
											<th className="px-6 py-4">
												Nutrient
											</th>
											<th className="px-6 py-4 text-right">
												Per 100g/ml
											</th>
											<th className="px-6 py-4 text-right">
												Per Serving
											</th>
											<th className="px-6 py-4 text-right text-indigo-600">
												Prepared (100g)
											</th>
										</tr>
									</thead>
									<tbody className="divide-y divide-slate-50">
										{data.nutritionTable.map((row, i) => (
											<tr
												key={i}
												className="hover:bg-slate-50/80 transition-colors"
											>
												<td className="px-6 py-3.5 font-semibold text-slate-700 capitalize">
													{row.label}
													{row.key.includes(
														"energy",
													) && (
														<span className="ml-1 text-[10px] text-slate-400 font-normal">
															(
															{row.key.includes(
																"kj",
															)
																? "kJ"
																: "kcal"}
															)
														</span>
													)}
												</td>
												<td className="px-6 py-3.5 text-right font-mono text-slate-600">
													{row.val100}
													{row.unit}
												</td>
												<td className="px-6 py-3.5 text-right font-mono text-slate-600">
													{row.valServing}
													{row.unit}
												</td>
												<td className="px-6 py-3.5 text-right font-mono text-indigo-600 font-medium">
													{row.valPrepared ? (
														`${row.valPrepared}${row.unit}`
													) : (
														<span className="text-slate-200">
															-
														</span>
													)}
												</td>
											</tr>
										))}
									</tbody>
								</table>
								{data.nutritionTable.length === 0 && (
									<div className="p-12 text-center text-slate-400 italic">
										No structured nutrition data available
										for this product.
									</div>
								)}
							</div>
						)}

						{/* --- TAB 3: INGREDIENTS --- */}
						{activeTab === "ingredients" && (
							<div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-300">
								{/* Text Blob */}
								<div className="bg-white p-8 rounded-3xl border border-slate-200 shadow-sm">
									<h3 className="text-sm font-bold text-slate-400 uppercase tracking-widest mb-4">
										Ingredients Declaration
									</h3>
									<p className="text-slate-700 leading-8 text-sm font-medium">
										{product.ingredients_text || (
											<span className="italic text-slate-400">
												No ingredients text available.
											</span>
										)}
									</p>
								</div>

								<div className="grid grid-cols-1 md:grid-cols-2 gap-6">
									{/* Allergens & Traces */}
									<div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm">
										<h4 className="text-rose-600 font-bold flex items-center gap-2 mb-4">
											<AlertTriangle size={18} />{" "}
											Allergens & Traces
										</h4>
										<div className="space-y-4">
											<div>
												<span className="text-xs font-bold text-slate-400 uppercase block mb-2">
													Contains
												</span>
												<div className="flex flex-wrap gap-2">
													{data.allergens.length ? (
														data.allergens.map(
															(a) => (
																<Badge
																	key={a}
																	color="red"
																>
																	{a}
																</Badge>
															),
														)
													) : (
														<span className="text-sm text-slate-400">
															None listed
														</span>
													)}
												</div>
											</div>
											<div>
												<span className="text-xs font-bold text-slate-400 uppercase block mb-2">
													May Contain (Traces)
												</span>
												<div className="flex flex-wrap gap-2">
													{data.traces.length ? (
														data.traces.map((t) => (
															<Badge
																key={t}
																color="amber"
															>
																{t}
															</Badge>
														))
													) : (
														<span className="text-sm text-slate-400">
															None listed
														</span>
													)}
												</div>
											</div>
										</div>
									</div>

									{/* Additives & Palm Oil */}
									<div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm">
										<h4 className="text-amber-600 font-bold flex items-center gap-2 mb-4">
											<Box size={18} /> Technical Details
										</h4>

										<div className="mb-6">
											<span className="text-xs font-bold text-slate-400 uppercase block mb-2">
												Additives
											</span>
											<div className="flex flex-wrap gap-2">
												{data.additives.length ? (
													data.additives.map((a) => (
														<Badge
															key={a}
															color="slate"
														>
															{a}
														</Badge>
													))
												) : (
													<span className="text-sm text-slate-400">
														None detected
													</span>
												)}
											</div>
										</div>

										<div>
											<span className="text-xs font-bold text-slate-400 uppercase block mb-2">
												Analysis
											</span>
											<div className="flex flex-wrap gap-2">
												{product.ingredients_analysis_tags?.map(
													(tag, i) => {
														const t = tag
															.replace("en:", "")
															.replace(/-/g, " ");
														const isBad =
															t.includes(
																"non-vegan",
															) ||
															t.includes(
																"palm-oil",
															);
														const isUnknown =
															t.includes(
																"unknown",
															);
														return (
															<span
																key={i}
																className={`text-xs px-2 py-1 rounded border capitalize ${
																	isBad
																		? "bg-rose-50 border-rose-100 text-rose-700"
																		: isUnknown
																			? "bg-slate-50 border-slate-100 text-slate-500"
																			: "bg-emerald-50 border-emerald-100 text-emerald-700"
																}`}
															>
																{t}
															</span>
														);
													},
												)}
											</div>
										</div>
									</div>
								</div>
							</div>
						)}

						{/* --- TAB 4: SUPPLY CHAIN (Meta) --- */}
						{activeTab === "supply" && (
							<div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-300">
								<div className="grid grid-cols-1 md:grid-cols-2 gap-6">
									<div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm">
										<h3 className="text-sm font-bold text-slate-900 mb-4 flex items-center gap-2">
											<Globe
												size={16}
												className="text-indigo-500"
											/>{" "}
											Origin & Logistics
										</h3>
										<InfoRow
											label="Origin of Ingredients"
											value={data.origins}
										/>
										<InfoRow
											label="Manufacturing Places"
											value={product.manufacturing_places}
											icon={Factory}
										/>
										<InfoRow
											label="Countries Sold"
											value={data.countries}
										/>
										<InfoRow
											label="Packaging"
											value={data.packagings}
											icon={Box}
										/>
									</div>

									<div className="bg-white p-6 rounded-3xl border border-slate-200 shadow-sm">
										<h3 className="text-sm font-bold text-slate-900 mb-4 flex items-center gap-2">
											<ShoppingBag
												size={16}
												className="text-indigo-500"
											/>{" "}
											Purchase & Data
										</h3>
										<InfoRow
											label="Stores"
											value={data.stores}
										/>
										<InfoRow
											label="Purchase Places"
											value={product.purchase_places}
										/>
										<InfoRow
											label="Last Modified"
											value={new Date(
												product.last_modified_t * 1000,
											).toLocaleDateString()}
											icon={Clock}
										/>
										<InfoRow
											label="Data Quality"
											value={
												product.data_quality_tags
													?.length
													? `${product.data_quality_tags.length} checks`
													: "Unknown"
											}
											icon={Database}
										/>
									</div>
								</div>

								{/* Gallery Preview */}
								<div className="bg-slate-900 p-8 rounded-3xl shadow-xl">
									<h3 className="text-white font-bold mb-6 flex items-center gap-2">
										<ImageIcon size={18} /> Product Gallery
									</h3>
									<div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
										{[
											"front_en",
											"ingredients_en",
											"nutrition_fr",
											"front_fr",
										].map((key, i) => {
											const imgObj =
												product.selected_images?.[
													key.split("_")[0]
												]?.display?.[
													key.split("_")[1]
												] ||
												product.images?.[key] ||
												(i === 0
													? product.image_url
													: null);

											if (!imgObj) return null;

											return (
												<div
													key={i}
													className="aspect-square bg-white rounded-xl overflow-hidden p-2 opacity-90 hover:opacity-100 transition-opacity cursor-pointer"
												>
													<img
														src={
															typeof imgObj ===
															"string"
																? imgObj
																: imgObj.url ||
																	imgObj
														}
														className="w-full h-full object-contain"
														alt={key}
													/>
												</div>
											);
										})}
									</div>
									<div className="mt-4 text-slate-500 text-xs font-mono">
										Data Source:{" "}
										{product.data_sources ||
											"Open Food Facts"}
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
