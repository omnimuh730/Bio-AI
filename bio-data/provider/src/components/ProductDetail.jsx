import React, { useState, useEffect, useMemo } from "react";
import {
	PieChart,
	Pie,
	Cell,
	ResponsiveContainer,
	Tooltip,
	Legend,
} from "recharts";
import NutriScoreBadge from "./NutriScoreBadge";

const ProductDetail = ({ product, onClose }) => {
	const [analysis, setAnalysis] = useState(null);
	const [loading, setLoading] = useState(false);

	// --- 1. Smart Data Extraction ---
	const { chartData, cleanCategories, nutrientsList } = useMemo(() => {
		if (!product || !product.nutriments) return {};

		const n = product.nutriments;

		// A. Chart Data (Visuals)
		const cData = [
			{
				name: "Fat",
				value: n.fat_100g || n.fat || 0,
				color: "#F59E0B",
			}, // Amber
			{
				name: "Carbs",
				value: n.carbohydrates_100g || n.carbohydrates || 0,
				color: "#3B82F6",
			}, // Blue
			{
				name: "Protein",
				value: n.proteins_100g || n.proteins || 0,
				color: "#10B981",
			}, // Emerald
		].filter((d) => d.value > 0);

		// B. Categories Cleaning
		const cats = (product.categories || []).map((cat) =>
			cat
				.replace("en:", "")
				.replace(/-/g, " ")
				.replace(/\b\w/g, (l) => l.toUpperCase()),
		);

		// C. Nutrition List
		const keyFields = [
			{
				key: "energy-kcal_100g",
				label: "Energy (kcal)",
				unit: "kcal",
			},
			{ key: "energy_100g", label: "Energy (kJ)", unit: "kJ" },
			{ key: "fat_100g", label: "Fat", unit: "g" },
			{
				key: "saturated-fat_100g",
				label: "Saturated Fat",
				unit: "g",
			},
			{
				key: "carbohydrates_100g",
				label: "Carbohydrates",
				unit: "g",
			},
			{ key: "sugars_100g", label: "Sugars", unit: "g" },
			{ key: "fiber_100g", label: "Fiber", unit: "g" },
			{ key: "proteins_100g", label: "Proteins", unit: "g" },
			{ key: "salt_100g", label: "Salt", unit: "g" },
			{ key: "sodium_100g", label: "Sodium", unit: "g" },
		];

		const mappedNutrients = keyFields
			.map((field) => {
				const val = n[field.key] ?? n[field.key.replace("_100g", "")];
				return val !== undefined
					? {
							label: field.label,
							value: val,
							unit: field.unit,
							isMain: true,
						}
					: null;
			})
			.filter(Boolean);

		return {
			chartData: cData,
			cleanCategories: cats,
			nutrientsList: mappedNutrients,
			mainMacros: {
				energy: n["energy-kcal_100g"] || n["energy-kcal"],
				grade: product.nutriscore_grade,
			},
		};
	}, [product]);

	// --- 2. AI Simulation ---
	useEffect(() => {
		const fetchAnalysis = async () => {
			setLoading(true);
			setTimeout(() => {
				const highSugar = (product.nutriments?.sugars_100g || 0) > 10;
				const highProtein =
					(product.nutriments?.proteins_100g || 0) > 10;

				let text = `This product contains ${product.nutriments?.energy_100g || 0} kJ per 100g. `;
				if (highProtein)
					text += "It is a significant source of protein. ";
				if (highSugar)
					text += "However, keep an eye on the sugar content. ";

				setAnalysis(text + "It pairs well with a balanced diet.");
				setLoading(false);
			}, 800);
		};
		fetchAnalysis();
	}, [product]);

	return (
		<div className="fixed inset-0 z-50 flex items-center justify-center p-4">
			{/* 
                UPDATED BACKDROP: 
                1. Removed 'backdrop-blur-sm'
                2. Changed opacity from /60 to /40 so you can see behind better
            */}
			<div
				className="absolute inset-0 bg-slate-900/40 transition-opacity"
				onClick={onClose}
			></div>

			{/* Main Card */}
			<div className="bg-white w-full max-w-6xl max-h-[90vh] rounded-3xl shadow-2xl flex flex-col md:flex-row overflow-hidden animate-in fade-in zoom-in-95 duration-200 z-10">
				{/* === LEFT COLUMN: Identity, Barcode, Meta === */}
				<div className="w-full md:w-[350px] lg:w-[400px] bg-slate-50 border-r border-slate-200 flex flex-col overflow-y-auto">
					<div className="p-6">
						<button
							onClick={onClose}
							className="mb-6 flex items-center text-slate-500 hover:text-indigo-600 transition-colors text-sm font-semibold"
						>
							<i className="fas fa-arrow-left mr-2"></i> Back to
							Inventory
						</button>

						{/* Product Image */}
						<div className="relative aspect-square w-full rounded-2xl bg-white shadow-sm border border-slate-100 p-4 mb-6 flex items-center justify-center">
							<img
								src={product.image_url}
								alt={product.product_name}
								className="max-h-full max-w-full object-contain drop-shadow-md"
							/>
						</div>

						{/* Title & Brand */}
						<h1 className="text-2xl font-extrabold text-slate-800 leading-tight mb-2">
							{product.product_name}
						</h1>
						<p className="text-slate-500 font-medium mb-6">
							{product.brands?.split(",").join(", ")}
						</p>

						{/* Badges */}
						<div className="flex gap-4 mb-8">
							<div className="flex flex-col">
								<span className="text-[10px] uppercase font-bold text-slate-400 mb-1">
									Nutri-Score
								</span>
								<NutriScoreBadge
									score={product.nutriscore_grade}
									size="md"
								/>
							</div>
							<div className="flex flex-col">
								<span className="text-[10px] uppercase font-bold text-slate-400 mb-1">
									NOVA
								</span>
								<div
									className={`h-10 px-3 rounded-lg flex items-center justify-center text-lg font-bold border ${product.nova_group === 4 ? "bg-orange-50 border-orange-200 text-orange-600" : "bg-green-50 border-green-200 text-green-600"}`}
								>
									{product.nova_group}
								</div>
							</div>
						</div>

						{/* Categories / Meta Chips */}
						{cleanCategories.length > 0 && (
							<div className="mb-8">
								<h3 className="text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3">
									Categories
								</h3>
								<div className="flex flex-wrap gap-2">
									{cleanCategories.map((cat, i) => (
										<span
											key={i}
											className="px-3 py-1 bg-white border border-slate-200 rounded-full text-xs font-semibold text-slate-600 shadow-sm whitespace-nowrap"
										>
											{cat}
										</span>
									))}
								</div>
							</div>
						)}

						{/* BARCODE SECTION - UPDATED: Removed opacity/blending for clarity */}
						<div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col items-center">
							<h3 className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2 self-start">
								Product Code
							</h3>
							<img
								src={`https://bwipjs-api.metafloor.com/?bcid=code128&text=${product.code}&scale=2&incltext&textxalign=center`}
								alt={`Barcode ${product.code}`}
								className="w-full h-16 object-contain"
							/>
						</div>
					</div>
				</div>

				{/* === RIGHT COLUMN: Data & Analytics === */}
				<div className="flex-1 bg-white p-6 md:p-10 overflow-y-auto custom-scrollbar">
					<div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
						{/* Chart */}
						<div className="bg-slate-50 rounded-2xl p-6 border border-slate-100 relative">
							<h3 className="text-sm font-bold text-slate-700 mb-4">
								Macro Distribution
							</h3>
							<div className="h-64">
								<ResponsiveContainer width="100%" height="100%">
									<PieChart>
										<Pie
											data={chartData}
											cx="50%"
											cy="50%"
											innerRadius={60}
											outerRadius={80}
											paddingAngle={5}
											dataKey="value"
											stroke="none"
										>
											{chartData.map((entry, index) => (
												<Cell
													key={`cell-${index}`}
													fill={entry.color}
												/>
											))}
										</Pie>
										<Tooltip
											contentStyle={{
												borderRadius: "8px",
												border: "none",
												boxShadow:
													"0 4px 6px -1px rgb(0 0 0 / 0.1)",
											}}
										/>
										<Legend
											verticalAlign="bottom"
											height={36}
											iconType="circle"
										/>
									</PieChart>
								</ResponsiveContainer>
							</div>
						</div>

						{/* Nutrition Table */}
						<div className="bg-slate-50 rounded-2xl p-6 border border-slate-100">
							<h3 className="text-sm font-bold text-slate-700 mb-4 flex justify-between items-center">
								<span>Nutrition Facts</span>
								<span className="text-xs font-normal text-slate-400 bg-white px-2 py-1 rounded border">
									per 100g
								</span>
							</h3>

							<div className="space-y-0 text-sm">
								{nutrientsList.map((item, idx) => (
									<div
										key={idx}
										className={`flex justify-between items-center py-2.5 border-b border-slate-200/60 last:border-0 ${item.label.includes("Energy") ? "font-bold text-slate-800" : "text-slate-600"}`}
									>
										<span>{item.label}</span>
										<span className="font-mono">
											{item.value} {item.unit}
										</span>
									</div>
								))}
								{nutrientsList.length === 0 && (
									<div className="text-slate-400 italic py-4 text-center">
										No nutrition data available
									</div>
								)}
							</div>
						</div>
					</div>

					{/* Ingredients & AI */}
					<div className="grid grid-cols-1 gap-8">
						{/* AI Insight */}
						<div className="bg-indigo-600 rounded-2xl p-6 text-white shadow-lg shadow-indigo-200">
							<h3 className="font-bold flex items-center mb-2">
								<i className="fas fa-robot mr-2 text-indigo-200"></i>{" "}
								AI Insight
							</h3>
							{loading ? (
								<div className="animate-pulse flex space-x-2">
									<div className="h-2 w-2 bg-indigo-300 rounded-full"></div>
									<div className="h-2 w-2 bg-indigo-300 rounded-full"></div>
									<div className="h-2 w-2 bg-indigo-300 rounded-full"></div>
								</div>
							) : (
								<p className="text-indigo-100 leading-relaxed text-sm">
									{analysis}
								</p>
							)}
						</div>

						{/* Ingredients Text */}
						<div>
							<h3 className="text-[11px] font-bold text-slate-400 uppercase tracking-widest mb-3">
								Ingredients List
							</h3>
							<div className="p-5 bg-slate-50 rounded-xl border border-slate-100 text-slate-600 text-sm leading-relaxed italic">
								{product.ingredients_text ||
									"No ingredients information found."}
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	);
};

export default ProductDetail;
