import React, { useState, useEffect } from "react";
import { Product } from "../types";
import {
	PieChart,
	Pie,
	Cell,
	ResponsiveContainer,
	Tooltip,
	Legend,
} from "recharts";
import NutriScoreBadge from "./NutriScoreBadge";
import { analyzeProductHealth } from "../services/geminiService";

const ProductDetail = ({ product, onClose }) => {
	const [analysis, setAnalysis] = useState(null);
	const [loading, setLoading] = useState(false);

	const macroData = [
		{ name: "Fat", value: product.nutriments.fat_100g, color: "#F59E0B" },
		{
			name: "Carbs",
			value: product.nutriments.carbohydrates_100g,
			color: "#3B82F6",
		},
		{
			name: "Protein",
			value: product.nutriments.proteins_100g,
			color: "#10B981",
		},
		{
			name: "Fiber",
			value: product.nutriments.fiber_100g,
			color: "#8B5CF6",
		},
	].filter((d) => d.value > 0);

	useEffect(() => {
		const fetchAnalysis = async () => {
			setLoading(true);
			const result = await analyzeProductHealth(product);
			setAnalysis(result || "No analysis available.");
			setLoading(false);
		};
		fetchAnalysis();
	}, [product]);

	return (
		<div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
			<div className="bg-white rounded-2xl shadow-2xl w-full max-w-5xl max-h-[90vh] overflow-hidden flex flex-col md:flex-row">
				{/* Left Side: Basic Info & Image */}
				<div className="w-full md:w-1/3 bg-slate-50 border-r border-slate-100 flex flex-col">
					<div className="p-6">
						<button
							onClick={onClose}
							className="mb-4 text-slate-400 hover:text-slate-600 transition-colors"
						>
							<i className="fas fa-arrow-left mr-2"></i> Back to
							Inventory
						</button>
						<img
							src={product.image_url}
							alt={product.product_name}
							className="w-full aspect-square object-cover rounded-xl shadow-md mb-6"
						/>
						<h2 className="text-2xl font-bold text-slate-800">
							{product.product_name}
						</h2>
						<p className="text-slate-500 font-medium mb-4">
							{product.brands}
						</p>

						<div className="flex gap-4 items-center">
							<div className="flex flex-col items-center">
								<span className="text-[10px] uppercase font-bold text-slate-400 mb-1">
									Nutri-Score
								</span>
								<NutriScoreBadge
									score={product.nutriscore_grade}
									size="md"
								/>
							</div>
							<div className="flex flex-col items-center">
								<span className="text-[10px] uppercase font-bold text-slate-400 mb-1">
									NOVA Group
								</span>
								<div className="w-10 h-10 flex items-center justify-center rounded-lg bg-orange-100 text-orange-600 font-bold">
									{product.nova_group}
								</div>
							</div>
						</div>
					</div>
				</div>

				{/* Right Side: Nutrients, Charts, AI */}
				<div className="flex-1 overflow-y-auto p-6 md:p-8">
					<div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
						{/* Macro Chart */}
						<div className="bg-white rounded-xl border border-slate-100 p-4">
							<h3 className="text-lg font-semibold text-slate-700 mb-4 border-b pb-2">
								Macro Distribution (per 100g)
							</h3>
							<div className="h-64">
								<ResponsiveContainer width="100%" height="100%">
									<PieChart>
										<Pie
											data={macroData}
											cx="50%"
											cy="50%"
											innerRadius={60}
											outerRadius={80}
											paddingAngle={5}
											dataKey="value"
										>
											{macroData.map((entry, index) => (
												<Cell
													key={`cell-${index}`}
													fill={entry.color}
												/>
											))}
										</Pie>
										<Tooltip />
										<Legend />
									</PieChart>
								</ResponsiveContainer>
							</div>
						</div>

						{/* Nutrition List */}
						<div className="bg-white rounded-xl border border-slate-100 p-4">
							<h3 className="text-lg font-semibold text-slate-700 mb-4 border-b pb-2">
								Full Nutrition Profile
							</h3>
							<div className="space-y-3">
								{Object.entries(product.nutriments).map(
									([key, val]) => (
										<div
											key={key}
											className="flex justify-between items-center py-1 border-b border-slate-50 last:border-0"
										>
											<span className="text-slate-500 capitalize">
												{key
													.replace("_100g", "")
													.replace("_", " ")}
											</span>
											<span className="font-semibold text-slate-700">
												{val}{" "}
												{key.includes("energy")
													? "kJ"
													: "g"}
											</span>
										</div>
									),
								)}
							</div>
						</div>
					</div>

					<div className="mt-8">
						<h3 className="text-lg font-semibold text-slate-700 mb-4 flex items-center">
							<i className="fas fa-robot text-indigo-500 mr-2"></i>{" "}
							AI Nutritionist Insight
						</h3>
						<div className="bg-indigo-50 rounded-xl p-6 border border-indigo-100 min-h-[100px] relative">
							{loading ? (
								<div className="flex items-center justify-center py-8">
									<div className="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600"></div>
								</div>
							) : (
								<div className="prose prose-indigo max-w-none text-slate-700 whitespace-pre-wrap">
									{analysis}
								</div>
							)}
						</div>
					</div>

					<div className="mt-8">
						<h3 className="text-lg font-semibold text-slate-700 mb-2">
							Ingredients
						</h3>
						<p className="text-slate-600 text-sm italic leading-relaxed bg-slate-50 p-4 rounded-lg border border-slate-100">
							{product.ingredients_text}
						</p>
					</div>
				</div>
			</div>
		</div>
	);
};

export default ProductDetail;
