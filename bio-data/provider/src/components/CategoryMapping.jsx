import { PROD_CATEGORIES } from "../constants";

const CategoryMapping = ({ products, onMap }) => {
	const unmapped = products.filter(
		(p) => !p.mappedCategory || p.mappedCategory === "Unknown",
	);

	return (
		<div className="bg-white rounded-2xl shadow-sm border border-slate-100 overflow-hidden">
			<div className="p-6 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
				<div>
					<h3 className="text-lg font-bold text-slate-800">
						Production Re-mapping
					</h3>
					<p className="text-xs text-slate-500 font-medium">
						Assign raw OFF categories to your 8 production UI tabs.
					</p>
				</div>
				<div className="bg-amber-100 text-amber-700 px-3 py-1 rounded-full text-xs font-bold">
					{unmapped.length} Items Unmapped
				</div>
			</div>
			<div className="divide-y divide-slate-100 max-h-[600px] overflow-y-auto">
				{products.map((p) => (
					<div
						key={p.id}
						className="p-4 flex items-center justify-between hover:bg-slate-50 transition-colors"
					>
						<div className="flex items-center space-x-4">
							<img
								src={p.image_url}
								className="w-10 h-10 rounded object-cover"
								alt=""
							/>
							<div>
								<p className="text-sm font-bold text-slate-800">
									{p.product_name}
								</p>
								<p className="text-[10px] text-slate-400 font-medium truncate max-w-[200px]">
									RAW: {p.categories.join(" > ")}
								</p>
							</div>
						</div>
						<div className="flex items-center space-x-4">
							<i className="fas fa-arrow-right text-slate-300"></i>
							<select
								value={p.mappedCategory}
								onChange={(e) => onMap(p.id, e.target.value)}
								className="bg-slate-50 border border-slate-200 rounded-lg px-3 py-1.5 text-xs font-bold text-slate-700 focus:ring-2 focus:ring-indigo-500 outline-none"
							>
								<option value="Unknown">
									Select Target...
								</option>
								{PROD_CATEGORIES.map((cat) => (
									<option key={cat} value={cat}>
										{cat}
									</option>
								))}
							</select>
						</div>
					</div>
				))}
			</div>
		</div>
	);
};

export default CategoryMapping;
