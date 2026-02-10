import NutriScoreBadge from "./NutriScoreBadge";

const DataTableView = ({
	products,
	selectedIds,
	onSelect,
	onSelectAll,
	onViewProduct,
	sortField,
	sortOrder,
	onSort,
}) => {
	const allSelected =
		products.length > 0 && selectedIds.size === products.length;
	const isIndeterminate =
		selectedIds.size > 0 && selectedIds.size < products.length;

	const renderSortIcon = (field) => {
		if (sortField !== field)
			return (
				<i className="fas fa-sort text-slate-300 ml-1 text-[10px]"></i>
			);
		return sortOrder === "asc" ? (
			<i className="fas fa-sort-up ml-1 text-indigo-500"></i>
		) : (
			<i className="fas fa-sort-down ml-1 text-indigo-500"></i>
		);
	};

	const getStatusColor = (status) => {
		switch (status) {
			case "active":
				return "bg-emerald-100 text-emerald-700 border-emerald-200";
			case "flagged":
				return "bg-rose-100 text-rose-700 border-rose-200";
			case "draft":
				return "bg-amber-100 text-amber-700 border-amber-200";
			default:
				return "bg-slate-100 text-slate-700 border-slate-200";
		}
	};

	return (
		<div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden flex flex-col h-full">
			<div className="overflow-auto flex-1">
				<table className="w-full text-left border-collapse relative">
					<thead className="bg-slate-50 sticky top-0 z-10 shadow-sm">
						<tr>
							<th className="p-4 w-10">
								<input
									type="checkbox"
									className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4"
									checked={allSelected}
									ref={(input) => {
										if (input)
											input.indeterminate =
												isIndeterminate;
									}}
									onChange={(e) =>
										onSelectAll(e.target.checked)
									}
								/>
							</th>
							<th
								className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider cursor-pointer hover:bg-slate-100"
								onClick={() => onSort("product_name")}
							>
								Product / Brand {renderSortIcon("product_name")}
							</th>
							<th className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider">
								Status
							</th>
							<th
								className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider cursor-pointer hover:bg-slate-100"
								onClick={() => onSort("quality_score")}
							>
								Quality {renderSortIcon("quality_score")}
							</th>
							<th className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider">
								Nutri/NOVA
							</th>
							<th
								className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider hidden md:table-cell cursor-pointer"
								onClick={() => onSort("energy_100g")}
							>
								Energy {renderSortIcon("energy_100g")}
							</th>
							<th className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider hidden lg:table-cell">
								Tags
							</th>
							<th className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider text-right">
								Action
							</th>
						</tr>
					</thead>
					<tbody className="divide-y divide-slate-100 bg-white">
						{products.map((product) => (
							<tr
								key={product.id}
								className={`hover:bg-indigo-50/30 transition-colors group ${selectedIds.has(product.id) ? "bg-indigo-50/50" : ""}`}
							>
								<td className="p-4">
									<input
										type="checkbox"
										className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4"
										checked={selectedIds.has(product.id)}
										onChange={(e) =>
											onSelect(
												product.id,
												e.target.checked,
											)
										}
									/>
								</td>
								<td className="p-4">
									<div className="flex items-center space-x-3">
										<img
											src={product.image_url}
											alt=""
											className="w-10 h-10 rounded-lg object-cover border border-slate-200 shadow-sm"
										/>
										<div>
											<div className="font-semibold text-slate-800 text-sm">
												{product.product_name}
											</div>
											<div className="text-xs text-slate-500">
												{product.brands}
											</div>
										</div>
									</div>
								</td>
								<td className="p-4">
									<span
										className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wide border ${getStatusColor(product.status)}`}
									>
										{product.status}
									</span>
								</td>
								<td className="p-4">
									<div className="flex items-center space-x-2">
										<div className="w-16 h-1.5 bg-slate-100 rounded-full overflow-hidden">
											<div
												className={`h-full ${product.quality_score > 90 ? "bg-emerald-500" : product.quality_score > 70 ? "bg-amber-400" : "bg-rose-500"}`}
												style={{
													width: `${product.quality_score ?? 0}%`,
												}}
											></div>
										</div>
										<span className="text-xs font-medium text-slate-600">
											{product.quality_score ?? 0}%
										</span>
									</div>
								</td>
								<td className="p-4">
									<div className="flex items-center space-x-3">
										<NutriScoreBadge
											score={product.nutriscore_grade}
											size="sm"
										/>
										<span className="text-[10px] font-bold text-slate-400 bg-slate-100 px-1.5 py-0.5 rounded">
											NOVA {product.nova_group}
										</span>
									</div>
								</td>
								<td className="p-4 text-sm text-slate-600 hidden md:table-cell font-mono">
									{product.nutriments?.energy_100g ?? 0} kJ
								</td>
								<td className="p-4 hidden lg:table-cell">
									<div className="flex flex-wrap gap-1">
										{(product.tags || [])
											.slice(0, 2)
											.map((tag) => (
												<span
													key={tag}
													className="text-[10px] text-indigo-600 bg-indigo-50 border border-indigo-100 px-2 py-0.5 rounded-md font-medium"
												>
													#{tag}
												</span>
											))}
										{(product.tags || []).length > 2 && (
											<span className="text-[10px] text-slate-400 px-1">
												+{" "}
												{(product.tags || []).length -
													2}
											</span>
										)}
									</div>
								</td>
								<td className="p-4 text-right">
									{product.remote ? (
										<button
											className="text-white bg-indigo-600 px-3 py-1 rounded-full text-xs font-bold hover:bg-indigo-700 transition-all"
											onClick={async (e) => {
												e.stopPropagation();
												try {
													const btn = e.currentTarget;
													btn.disabled = true;
													const res = await fetch(
														"http://localhost:4000/api/products/import",
														{
															method: "POST",
															headers: {
																"Content-Type":
																	"application/json",
															},
															body: JSON.stringify(
																{
																	barcode:
																		product.code,
																},
															),
														},
													);
													if (!res.ok)
														throw new Error(
															"import_failed",
														);
													const json =
														await res.json();
													if (window.reloadProducts)
														await window.reloadProducts();
													alert(
														`Synced ${json.product.product_name}`,
													);
												} catch (err) {
													console.error(err);
													alert(
														"Sync failed: " +
															(err.message ||
																err),
													);
												}
											}}
										>
											Sync
										</button>
									) : (
										<button
											onClick={() =>
												onViewProduct(product)
											}
											className="text-slate-400 hover:text-indigo-600 p-2 rounded-full hover:bg-slate-100 transition-all"
										>
											<i className="fas fa-chevron-right"></i>
										</button>
									)}
								</td>
							</tr>
						))}
					</tbody>
				</table>
			</div>
		</div>
	);
};

export default DataTableView;
