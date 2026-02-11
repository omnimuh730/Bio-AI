import React, { useState } from "react";

const CategoryTree = ({ onSelectCategory, selectedCategory }) => {
	// Mock category hierarchy
	const categories = [
		{
			name: "Beverages",
			children: ["Sodas", "Waters", "Energy drinks", "Fruit juices"],
		},
		{
			name: "Snacks",
			children: [
				"Sweet snacks",
				"Salty snacks",
				"Biscuits",
				"Chocolates",
			],
		},
		{
			name: "Dairies",
			children: ["Milks", "Yogurts", "Cheeses", "Creams"],
		},
		{
			name: "Plant-based",
			children: ["Cereals", "Legumes", "Nuts", "Tofu"],
		},
	];

	const [expanded, setExpanded] = useState(new Set(["Beverages"]));

	const toggleExpand = (cat) => {
		const newExpanded = new Set(expanded);
		if (newExpanded.has(cat)) newExpanded.delete(cat);
		else newExpanded.add(cat);
		setExpanded(newExpanded);
	};

	return (
		<div className="w-64 bg-white border-r border-slate-100 p-4 h-full overflow-y-auto hidden md:block">
			<h3 className="text-xs font-bold text-slate-400 uppercase tracking-wider mb-4">
				Categories
			</h3>
			<div className="space-y-1">
				<div
					onClick={() => onSelectCategory("ALL")}
					className={`cursor-pointer px-3 py-2 rounded-lg text-sm font-medium transition-colors ${selectedCategory === "ALL" ? "bg-indigo-50 text-indigo-700" : "text-slate-600 hover:bg-slate-50"}`}
				>
					<i className="fas fa-layer-group w-5 text-center mr-2"></i>
					All Products
				</div>
				{categories.map((cat) => (
					<div key={cat.name}>
						<div
							className={`flex items-center justify-between cursor-pointer px-3 py-2 rounded-lg text-sm font-medium transition-colors hover:bg-slate-50`}
							onClick={() => toggleExpand(cat.name)}
						>
							<div className="flex items-center">
								<i
									className={`fas ${expanded.has(cat.name) ? "fa-folder-open text-indigo-400" : "fa-folder text-slate-300"} w-5 text-center mr-2`}
								></i>
								<span className="text-slate-700">
									{cat.name}
								</span>
							</div>
							<i
								className={`fas fa-chevron-right text-xs text-slate-300 transition-transform ${expanded.has(cat.name) ? "rotate-90" : ""}`}
							></i>
						</div>
						{expanded.has(cat.name) && (
							<div className="ml-4 pl-4 border-l border-slate-100 space-y-1 mt-1">
								{cat.children.map((child) => (
									<div
										key={child}
										onClick={() => onSelectCategory(child)}
										className={`cursor-pointer px-3 py-1.5 rounded-lg text-sm transition-colors ${selectedCategory === child ? "bg-indigo-50 text-indigo-700 font-medium" : "text-slate-500 hover:text-slate-800"}`}
									>
										{child}
									</div>
								))}
							</div>
						)}
					</div>
				))}
			</div>
		</div>
	);
};

export default CategoryTree;
