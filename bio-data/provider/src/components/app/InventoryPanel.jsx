import React from "react";
import DataTableView from "../DataTableView";

const InventoryPanel = ({
	searchQuery,
	onSearchQueryChange,
	onSearchSubmit,
	includeRemote,
	onIncludeRemoteChange,
	viewMode,
	onViewModeChange,
	filteredProducts,
	selectedProductIds,
	onSelect,
	onSelectAll,
	onViewProduct,
	sortField,
	sortOrder,
	onSort,
	pageSize,
	onPageSizeChange,
	currentPage,
	onPageChange,
	totalProducts,
	onSyncAll,
	isSyncingAll,
	onCreateEmbeddings,
	isCreatingEmbeddings,
	isLoading,
	syncProgress,
	embeddingProgress,
	activityLog,
	embeddingQuery,
	onEmbeddingQueryChange,
	onEmbeddingSearch,
	isEmbeddingSearching,
	embeddingSearchMeta,
	isSearching,
}) => {
	const showEmptyState =
		searchQuery && searchQuery.trim() !== "$all" && filteredProducts.length === 0;

	return (
		<div className="space-y-6 h-full flex flex-col">
			{showEmptyState && (
				<div className="bg-white rounded-xl p-6 border border-slate-100 text-center mb-4">
					<p className="text-slate-500 mb-3">
						No products matched "{searchQuery}".
					</p>
					<div className="flex items-center justify-center gap-2">
						<button
							className="px-4 py-2 bg-indigo-600 text-white rounded-xl"
							onClick={() => onSearchSubmit(searchQuery)}
						>
							Search remote
						</button>
						{isSearching && (
							<span className="text-slate-400">Searching...</span>
						)}
					</div>
				</div>
			)}
			<div className="flex flex-wrap items-center gap-4 bg-white p-5 rounded-3xl border border-slate-100 shadow-sm">
				<div className="relative flex-1 min-w-[300px]">
					<i className="fas fa-search absolute left-5 top-1/2 -translate-y-1/2 text-slate-300"></i>
					<input
						type="text"
						placeholder="Smart Search (Name, Brand, Code...)"
						className="w-full pl-12 pr-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl focus:outline-none focus:ring-4 focus:ring-indigo-500/10 transition-all text-sm font-bold placeholder:text-slate-300"
						value={searchQuery}
						onKeyDown={async (e) => {
							if (e.key === "Enter") {
								e.preventDefault();
								await onSearchSubmit(searchQuery);
							}
						}}
						onChange={(e) => onSearchQueryChange(e.target.value)}
					/>
				</div>
				<div className="flex flex-col gap-1 min-w-[260px]">
					<div className="flex items-center gap-2">
						<input
							type="text"
							placeholder="Rank by embedding (e.g. burger)"
							className="flex-1 px-4 py-3 bg-slate-50 border border-slate-200 rounded-2xl focus:outline-none focus:ring-4 focus:ring-emerald-500/10 transition-all text-sm font-bold placeholder:text-slate-300"
							value={embeddingQuery}
							onKeyDown={async (e) => {
								if (e.key === "Enter") {
									e.preventDefault();
									await onEmbeddingSearch(embeddingQuery);
								}
							}}
							onChange={(e) =>
								onEmbeddingQueryChange(e.target.value)
							}
						/>
						<button
							className="px-4 py-2 bg-emerald-600 text-white rounded-xl text-xs font-bold hover:bg-emerald-700 transition-colors disabled:opacity-50"
							onClick={() => onEmbeddingSearch(embeddingQuery)}
							disabled={
								isEmbeddingSearching ||
								!embeddingQuery.trim()
							}
						>
							{isEmbeddingSearching ? "Ranking..." : "Rank"}
						</button>
					</div>
					{embeddingSearchMeta?.query && (
						<div className="text-[11px] text-slate-500">
							<span>
								Embedding time:{" "}
								{embeddingSearchMeta.encodeMs ?? "n/a"} ms
							</span>
							{embeddingSearchMeta.topScore !== null && (
								<span>
									{" "}
									| Top similarity:{" "}
									{embeddingSearchMeta.topScore.toFixed(3)}
								</span>
							)}
						</div>
					)}
				</div>
				<div className="flex items-center space-x-2">
					<label className="flex items-center text-sm text-slate-500 bg-slate-100 px-3 py-1 rounded-xl">
						<input
							type="checkbox"
							className="mr-2"
							checked={includeRemote}
							onChange={(e) => onIncludeRemoteChange(e.target.checked)}
						/>
						Include OpenFoodFacts
					</label>
					<button className="px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-500 hover:bg-slate-100 transition-colors">
						<i className="fas fa-filter mr-2"></i> Advanced Query
					</button>
					<div className="h-6 w-px bg-slate-200 mx-2"></div>
					<div className="flex bg-slate-100 p-1.5 rounded-xl">
						<button
							onClick={() => onViewModeChange("grid")}
							className={`px-4 py-2 rounded-lg text-xs font-black transition-all ${
								viewMode === "grid"
									? "bg-white shadow-sm text-indigo-600"
									: "text-slate-400"
							}`}
						>
							GRID
						</button>
						<button
							onClick={() => onViewModeChange("table")}
							className={`px-4 py-2 rounded-lg text-xs font-black transition-all ${
								viewMode === "table"
									? "bg-white shadow-sm text-indigo-600"
									: "text-slate-400"
							}`}
						>
							TABLE
						</button>
					</div>
				</div>
			</div>

			<DataTableView
				products={filteredProducts}
				selectedIds={selectedProductIds}
				onSelect={onSelect}
				onSelectAll={onSelectAll}
				onViewProduct={onViewProduct}
				sortField={sortField}
				sortOrder={sortOrder}
				onSort={onSort}
				pageSize={pageSize}
				onPageSizeChange={onPageSizeChange}
				currentPage={currentPage}
				onPageChange={onPageChange}
				totalProducts={totalProducts}
				onSyncAll={onSyncAll}
				isSyncingAll={isSyncingAll}
				onCreateEmbeddings={onCreateEmbeddings}
				isCreatingEmbeddings={isCreatingEmbeddings}
				isLoading={isLoading}
				syncProgress={syncProgress}
				embeddingProgress={embeddingProgress}
				activityLog={activityLog}
			/>
		</div>
	);
};

export default InventoryPanel;
