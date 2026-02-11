const AuditLogViewer = ({ logs, products }) => {
	return (
		<div className="space-y-4">
			<div className="flex items-center justify-between mb-4">
				<h3 className="text-lg font-bold text-slate-800">
					Change History & Compliance
				</h3>
				<button className="text-xs font-bold text-indigo-600 hover:underline">
					Export Audit PDF
				</button>
			</div>
			<div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
				<div className="divide-y divide-slate-50">
					{logs.map((log) => {
						const product = products.find(
							(p) => p.id === log.productId,
						);
						return (
							<div
								key={log.id}
								className="p-5 hover:bg-slate-50 transition-colors flex items-start space-x-4"
							>
								<div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 shrink-0">
									<i
										className={`fas ${log.user === "system-ai" ? "fa-robot text-indigo-500" : "fa-user"}`}
									></i>
								</div>
								<div className="flex-1 min-w-0">
									<div className="flex justify-between items-start">
										<div>
											<p className="text-sm font-bold text-slate-800">
												{log.action}{" "}
												<span className="text-slate-400 font-medium">
													on
												</span>{" "}
												{product?.product_name ||
													"Unknown Product"}
											</p>
											<p className="text-xs text-slate-500">
												{new Date(
													log.timestamp,
												).toLocaleString()}{" "}
												• {log.user}
											</p>
										</div>
										<span className="text-[10px] bg-slate-200 text-slate-600 px-2 py-0.5 rounded font-black uppercase">
											v1.2
										</span>
									</div>
									<div className="mt-3 grid grid-cols-1 md:grid-cols-2 gap-2">
										{Object.entries(log.changes).map(
											([field, delta]) => (
												<div
													key={field}
													className="bg-white border border-slate-100 p-2 rounded-lg text-[11px]"
												>
													<span className="font-bold text-slate-400 uppercase mr-2">
														{field}:
													</span>
													<span className="line-through text-rose-400">
														{String(delta.from)}
													</span>
													<i className="fas fa-arrow-right mx-2 text-slate-300"></i>
													<span className="text-emerald-500 font-bold">
														{String(delta.to)}
													</span>
												</div>
											),
										)}
									</div>
								</div>
							</div>
						);
					})}
				</div>
			</div>
		</div>
	);
};

export default AuditLogViewer;
