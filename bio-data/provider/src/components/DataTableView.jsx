import React, { useMemo } from "react";
import NutriScoreBadge from "./NutriScoreBadge";

const PAGE_SIZE_OPTIONS = [10, 20, 50, 100, 200, 500];

const DataTableView = ({
	products,
	selectedIds,
	onSelect,
	onSelectAll,
	onViewProduct,
	sortField,
	sortOrder,
	onSort,
	pageSize = 20,
	onPageSizeChange,
	currentPage = 1,
	onPageChange,
	totalProducts = 0,
	onSyncAll,
	isSyncingAll = false,
	onCreateEmbeddings,
	isCreatingEmbeddings = false,
	isLoading = false,
	syncProgress,
	embeddingProgress,
	activityLog = [],
}) => {
	// Server-side pagination: products is already the current page
	const total = totalProducts || products.length;
	const totalPages = Math.max(1, Math.ceil(total / pageSize));
	const safePage = Math.min(currentPage, totalPages);
	const pagedProducts = products; // already paginated by server

	const allSelected =
		pagedProducts.length > 0 &&
		pagedProducts.every((p) => selectedIds.has(p.id));
	const isIndeterminate =
		!allSelected && pagedProducts.some((p) => selectedIds.has(p.id));

	const selectedRemoteCount = products.filter(
		(p) => p.remote && selectedIds.has(p.id),
	).length;

	const selectedEmbeddableCount = products.filter(
		(p) =>
			!p.remote &&
			selectedIds.has(p.id) &&
			!(
				p.embeddings?.updated_at ||
				(p.embeddings?.name_desc && p.embeddings.name_desc.length > 0)
			),
	).length;

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

	const formatEmbeddingStatus = (embeddings) => {
		const hasVectors =
			(embeddings?.name_desc || []).length > 0 ||
			(embeddings?.ingredients || []).length > 0 ||
			(embeddings?.nutrition || []).length > 0;
		return {
			label: hasVectors ? "Embedded" : "Missing",
			className: hasVectors
				? "bg-emerald-100 text-emerald-700 border-emerald-200"
				: "bg-amber-100 text-amber-700 border-amber-200",
		};
	};

	const skeletonRows = Array.from(
		{ length: Math.min(pageSize, 8) },
		(_, i) => i,
	);

	// Build an array of page numbers to show (with ellipsis)
	const pageNumbers = useMemo(() => {
		const pages = [];
		if (totalPages <= 7) {
			for (let i = 1; i <= totalPages; i++) pages.push(i);
		} else {
			pages.push(1);
			if (safePage > 3) pages.push("...");
			for (
				let i = Math.max(2, safePage - 1);
				i <= Math.min(totalPages - 1, safePage + 1);
				i++
			)
				pages.push(i);
			if (safePage < totalPages - 2) pages.push("...");
			pages.push(totalPages);
		}
		return pages;
	}, [totalPages, safePage]);

	return (
		<div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden flex flex-col h-full">
			{/* Selection action bar */}
			{selectedIds.size > 0 && (
				<div className="px-5 py-3 bg-indigo-50 border-b border-indigo-100">
					<div className="flex items-center justify-between">
						<div className="flex items-center space-x-3">
							<span className="text-sm font-bold text-indigo-700">
								{selectedIds.size} selected
							</span>
							{selectedIds.size < products.length && (
								<button
									className="text-xs font-bold text-indigo-600 underline hover:text-indigo-800"
									onClick={() => onSelectAll(true)}
								>
									Select all {products.length}
								</button>
							)}
							<button
								className="text-xs font-bold text-slate-500 hover:text-slate-700"
								onClick={() => onSelectAll(false)}
							>
								Clear selection
							</button>
						</div>
						<div className="flex items-center space-x-2">
							{selectedEmbeddableCount > 0 && (
								<button
									className="flex items-center space-x-2 px-4 py-2 bg-emerald-600 text-white rounded-xl text-xs font-bold hover:bg-emerald-700 transition-colors disabled:opacity-50"
									onClick={onCreateEmbeddings}
									disabled={
										isCreatingEmbeddings ||
										selectedEmbeddableCount === 0
									}
								>
									<i
										className={`fas fa-brain ${
											isCreatingEmbeddings
												? "animate-spin"
												: ""
										}`}
									></i>
									<span>
										{isCreatingEmbeddings
											? "Embedding..."
											: `Create Embeddings (${selectedEmbeddableCount})`}
									</span>
								</button>
							)}
							{selectedRemoteCount > 0 && (
								<button
									className="flex items-center space-x-2 px-4 py-2 bg-indigo-600 text-white rounded-xl text-xs font-bold hover:bg-indigo-700 transition-colors disabled:opacity-50"
									onClick={onSyncAll}
									disabled={isSyncingAll}
								>
									<i
										className={`fas fa-cloud-arrow-down ${
											isSyncingAll ? "animate-spin" : ""
										}`}
									></i>
									<span>
										{isSyncingAll
											? "Syncing..."
											: `Sync All (${selectedRemoteCount})`}
									</span>
								</button>
							)}
							{embeddingProgress?.active && (
								<span className="text-xs font-bold text-emerald-700">
									Embedded {embeddingProgress.done}/
									{embeddingProgress.total}
								</span>
							)}
							{syncProgress?.active && (
								<span className="text-xs font-bold text-indigo-700">
									Synced {syncProgress.done}/
									{syncProgress.total}
								</span>
							)}
						</div>
					</div>
					{activityLog.length > 0 && (
						<div className="mt-3 max-h-28 overflow-auto text-xs text-slate-600 space-y-1">
							{activityLog.slice(0, 6).map((entry) => (
								<div key={entry.id}>
									<span className="text-slate-400">
										[
										{new Date(
											entry.ts,
										).toLocaleTimeString()}
										]
									</span>{" "}
									{entry.message}
								</div>
							))}
						</div>
					)}
				</div>
			)}

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
									onChange={(e) => {
										// Toggle selection for current page only
										if (e.target.checked) {
											const pageIds = pagedProducts.map(
												(p) => p.id,
											);
											const next = new Set(selectedIds);
											pageIds.forEach((id) =>
												next.add(id),
											);
											onSelectAll(true);
										} else {
											onSelectAll(false);
										}
									}}
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
								Nutri Grade
							</th>
							<th
								className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider cursor-pointer hover:bg-slate-100"
								onClick={() => onSort("embedding_score")}
							>
								Similarity {renderSortIcon("embedding_score")}
							</th>
							<th className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider">
								Embeddings
							</th>
							<th className="p-4 text-xs font-bold text-slate-500 uppercase tracking-wider text-right">
								Action
							</th>
						</tr>
					</thead>
					<tbody className="divide-y divide-slate-100 bg-white">
						{isLoading
							? skeletonRows.map((idx) => (
									<tr
										key={`skeleton-${idx}`}
										className="animate-pulse"
									>
										<td className="p-4">
											<div className="h-4 w-4 bg-slate-200 rounded"></div>
										</td>
										<td className="p-4">
											<div className="flex items-center space-x-3">
												<div className="w-10 h-10 bg-slate-200 rounded-lg"></div>
												<div>
													<div className="h-3 w-40 bg-slate-200 rounded"></div>
													<div className="h-2 w-24 bg-slate-200 rounded mt-2"></div>
												</div>
											</div>
										</td>
										<td className="p-4">
											<div className="h-4 w-16 bg-slate-200 rounded-full"></div>
										</td>
										<td className="p-4">
											<div className="h-2 w-20 bg-slate-200 rounded-full"></div>
											<div className="h-2 w-10 bg-slate-200 rounded mt-2"></div>
										</td>
										<td className="p-4">
											<div className="h-4 w-12 bg-slate-200 rounded"></div>
										</td>
										<td className="p-4 hidden md:table-cell">
											<div className="h-4 w-24 bg-slate-200 rounded-full"></div>
											<div className="h-2 w-28 bg-slate-200 rounded mt-2"></div>
										</td>
										<td className="p-4 text-right">
											<div className="h-6 w-10 bg-slate-200 rounded-full ml-auto"></div>
										</td>
									</tr>
								))
							: pagedProducts.map((product) => (
									<tr
										key={product.id}
										className={`hover:bg-indigo-50/30 transition-colors group ${selectedIds.has(product.id) ? "bg-indigo-50/50" : ""}`}
									>
										<td className="p-4">
											<input
												type="checkbox"
												className="rounded border-slate-300 text-indigo-600 focus:ring-indigo-500 w-4 h-4"
												checked={selectedIds.has(
													product.id,
												)}
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
													{product.quality_score ?? 0}
													%
												</span>
											</div>
										</td>
										<td className="p-4">
											<div className="flex items-center space-x-3">
												<NutriScoreBadge
													score={
														product.nutriscore_grade
													}
													size="sm"
												/>
												<span className="text-[10px] font-bold text-slate-400 bg-slate-100 px-1.5 py-0.5 rounded">
													{product.nutriscore_grade}
												</span>
											</div>
										</td>
										<td className="p-4 hidden md:table-cell">
											{(() => {
												const info =
													formatEmbeddingStatus(
														product.embeddings,
													);
												const model =
													product.embeddings?.model ||
													"";
												const updatedAt = product
													.embeddings?.updated_at
													? new Date(
															product.embeddings
																.updated_at,
														).toLocaleDateString()
													: null;
												const similarity =
													typeof product.embedding_score ===
													"number"
														? product.embedding_score
														: typeof product.score ===
															  "number"
															? product.score
															: null;
												return (
													<div className="flex flex-col gap-1">
														<span
															className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wide border w-fit ${info.className}`}
														>
															{info.label}
														</span>
														<div className="text-[10px] text-slate-500">
															{model ||
																"No model"}
															{updatedAt
																? ` | ${updatedAt}`
																: ""}
														</div>
														{similarity !==
															null && (
															<div className="text-[10px] text-slate-500">
																Similarity{" "}
																{similarity.toFixed(
																	3,
																)}
															</div>
														)}
													</div>
												);
											})()}
										</td>
										<td className="p-4 text-right">
											{product.remote ? (
												<button
													className="text-white bg-indigo-600 px-3 py-1 rounded-full text-xs font-bold hover:bg-indigo-700 transition-all"
													onClick={async (e) => {
														e.stopPropagation();
														try {
															const btn =
																e.currentTarget;
															btn.disabled = true;
															const res =
																await fetch(
																	"http://localhost:4000/api/products/import",
																	{
																		method: "POST",
																		headers:
																			{
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
															await res.json();
															if (
																window.reloadProducts
															)
																await window.reloadProducts();
														} catch (err) {
															console.error(err);
															console.log(
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
													<i class="fa-solid fa-eye"></i>
												</button>
											)}
										</td>
									</tr>
								))}
					</tbody>
				</table>
			</div>

			{/* Pagination footer */}
			<div className="flex items-center justify-between px-5 py-3 border-t border-slate-100 bg-slate-50/50">
				{/* Page size selector */}
				<div className="flex items-center space-x-2">
					<span className="text-xs font-bold text-slate-500">
						Show
					</span>
					<select
						className="text-xs font-bold text-slate-700 bg-white border border-slate-200 rounded-lg px-2 py-1.5 focus:outline-none focus:ring-2 focus:ring-indigo-500/20"
						value={pageSize}
						onChange={(e) =>
							onPageSizeChange?.(Number(e.target.value))
						}
					>
						{PAGE_SIZE_OPTIONS.map((s) => (
							<option key={s} value={s}>
								{s}
							</option>
						))}
					</select>
					<span className="text-xs text-slate-400">
						of {total.toLocaleString()} items
					</span>
				</div>

				{/* Page navigation */}
				<div className="flex items-center space-x-1">
					<button
						className="px-3 py-1.5 rounded-lg text-xs font-bold text-slate-500 hover:bg-slate-100 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
						disabled={safePage <= 1}
						onClick={() => onPageChange?.(safePage - 1)}
					>
						<i className="fas fa-chevron-left"></i>
					</button>
					{pageNumbers.map((p, i) =>
						p === "..." ? (
							<span
								key={`ellipsis-${i}`}
								className="px-2 text-xs text-slate-400"
							>
								...
							</span>
						) : (
							<button
								key={p}
								className={`w-8 h-8 rounded-lg text-xs font-bold transition-colors ${
									p === safePage
										? "bg-indigo-600 text-white shadow-sm"
										: "text-slate-500 hover:bg-slate-100"
								}`}
								onClick={() => onPageChange?.(p)}
							>
								{p}
							</button>
						),
					)}
					<button
						className="px-3 py-1.5 rounded-lg text-xs font-bold text-slate-500 hover:bg-slate-100 disabled:opacity-30 disabled:cursor-not-allowed transition-colors"
						disabled={safePage >= totalPages}
						onClick={() => onPageChange?.(safePage + 1)}
					>
						<i className="fas fa-chevron-right"></i>
					</button>
				</div>

				{/* Page info */}
				<span className="text-xs text-slate-400 font-medium">
					Page {safePage} of {totalPages}
				</span>
			</div>
		</div>
	);
};

export default DataTableView;
