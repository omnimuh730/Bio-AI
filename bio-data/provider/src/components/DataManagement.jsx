import React, { useState } from "react";
import { Product } from "../types";

const DataManagement = ({ products }) => {
	const [selectedForMerge, setSelectedForMerge] = useState([]);
	const [normValue, setNormValue] = useState("");

	const brands = Array.from(new Set(products.map((p) => p.brands)));

	return (
		<div className="space-y-8">
			{/* Normalization Tool */}
			<div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
				<h3 className="text-xl font-bold text-slate-800 mb-4 flex items-center">
					<i className="fas fa-wand-magic-sparkles mr-2 text-indigo-500"></i>{" "}
					Batch Normalization
				</h3>
				<p className="text-slate-500 mb-6">
					Standardize brand names or product titles across your
					database to ensure clean analytics.
				</p>

				<div className="flex flex-col md:flex-row gap-4 items-end">
					<div className="flex-1">
						<label className="block text-xs font-bold text-slate-400 uppercase mb-2">
							Target Brand
						</label>
						<select className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl">
							{brands.map((b) => (
								<option key={b} value={b}>
									{b}
								</option>
							))}
						</select>
					</div>
					<div className="flex-1">
						<label className="block text-xs font-bold text-slate-400 uppercase mb-2">
							New Correct Value
						</label>
						<input
							type="text"
							placeholder="e.g. Coca-Cola"
							className="w-full p-3 bg-slate-50 border border-slate-200 rounded-xl"
							value={normValue}
							onChange={(e) => setNormValue(e.target.value)}
						/>
					</div>
					<button className="bg-indigo-600 text-white px-8 py-3 rounded-xl font-bold hover:bg-indigo-700 transition-colors">
						Apply Normalization
					</button>
				</div>
			</div>

			{/* Merging Tool */}
			<div className="bg-white p-8 rounded-2xl shadow-sm border border-slate-100">
				<h3 className="text-xl font-bold text-slate-800 mb-4 flex items-center">
					<i className="fas fa-object-group mr-2 text-emerald-500"></i>{" "}
					Duplicate Merger
				</h3>
				<p className="text-slate-500 mb-6">
					Select two products to merge their data into a single
					verified entry.
				</p>

				<div className="grid grid-cols-1 md:grid-cols-2 gap-8">
					{[0, 1].map((i) => (
						<div
							key={i}
							className="border-2 border-dashed border-slate-200 rounded-2xl p-6 min-h-[150px] flex flex-col items-center justify-center text-center"
						>
							{selectedForMerge[i] ? (
								<div className="w-full flex items-center justify-between">
									<div className="flex items-center space-x-3">
										<img
											src={
												products.find(
													(p) =>
														p.id ===
														selectedForMerge[i],
												)?.image_url
											}
											className="w-12 h-12 rounded object-cover"
											alt=""
										/>
										<div className="text-left">
											<p className="font-bold">
												{
													products.find(
														(p) =>
															p.id ===
															selectedForMerge[i],
													)?.product_name
												}
											</p>
											<p className="text-xs text-slate-400">
												{
													products.find(
														(p) =>
															p.id ===
															selectedForMerge[i],
													)?.brands
												}
											</p>
										</div>
									</div>
									<button
										onClick={() =>
											setSelectedForMerge((s) =>
												s.filter((_, idx) => idx !== i),
											)
										}
										className="text-rose-500 hover:text-rose-700"
									>
										<i className="fas fa-times-circle text-xl"></i>
									</button>
								</div>
							) : (
								<>
									<div className="bg-slate-100 w-12 h-12 rounded-full flex items-center justify-center text-slate-400 mb-2">
										<i className="fas fa-plus"></i>
									</div>
									<p className="text-sm font-medium text-slate-400 uppercase">
										Select product {i + 1}
									</p>
								</>
							)}
						</div>
					))}
				</div>

				<div className="mt-8 flex justify-center">
					<button
						disabled={selectedForMerge.length < 2}
						className="bg-emerald-600 text-white px-12 py-4 rounded-2xl font-bold hover:bg-emerald-700 disabled:bg-slate-200 transition-all flex items-center"
					>
						<i className="fas fa-compress-arrows-alt mr-2"></i>{" "}
						Resolve & Merge
					</button>
				</div>
			</div>
		</div>
	);
};

export default DataManagement;
