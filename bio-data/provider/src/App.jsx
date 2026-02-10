import React, { useState, useMemo } from "react";
import {
	MOCK_PRODUCTS,
	MOCK_AUDIT_LOGS,
	SAVED_SEGMENTS,
	PROD_CATEGORIES,
} from "./constants";
import NutriScoreBadge from "./components/NutriScoreBadge";
import ProductDetail from "./components/ProductDetail";
import Dashboard from "./components/Dashboard";
import QualityDashboard from "./components/QualityDashboard";
import DataTableView from "./components/DataTableView";
import DataManagement from "./components/DataManagement";
import {
	importByBarcode,
	listProducts,
	searchRemote,
	generateEmbeddings,
} from "./api/backend";
import CategoryTree from "./components/CategoryTree";
import CategoryMapping from "./components/CategoryMapping";
import AuditLogViewer from "./components/AuditLogViewer";

const App = () => {
	const [state, setState] = useState({
		products: MOCK_PRODUCTS,
		auditLogs: MOCK_AUDIT_LOGS,
		segments: SAVED_SEGMENTS,
		selectedProduct: null,
		selectedProductIds: new Set(),
		searchQuery: "",
		filterNutriScore: "ALL",
		categoryFilter: "ALL",
		activeTab: "inventory",
		managementSubTab: "merging",
		viewMode: "table",
		sortField: "last_modified",
		sortOrder: "desc",
		includeRemote: true,
	});

	// Load local products from backend on mount
	React.useEffect(() => {
		async function load() {
			try {
				const data = await listProducts("", 1, 20);
				setState((s) => ({ ...s, products: data.products }));
				setTotalProducts(data.total ?? data.products.length);
			} catch (err) {
				console.warn("Failed to load backend products", err);
			}
		}
		load();
	}, []);

	// Expose helper to reload local products (used by row sync button)
	window.reloadProducts = async () => {
		try {
			const q = state.searchQuery.trim();
			const backendQ = q === "$all" ? "" : q;
			const data = await listProducts(backendQ, currentPage, pageSize);
			setState((s) => ({ ...s, products: data.products }));
			setTotalProducts(data.total ?? data.products.length);
		} catch (err) {
			console.warn("reloadProducts failed", err);
		}
	};

	// Search: query both local backend and remote OpenFoodFacts and merge results
	React.useEffect(() => {
		const q = state.searchQuery.trim();
		let cancelled = false;
		const t = setTimeout(async () => {
			try {
				await performSearch(q);
			} catch (err) {
				if (!cancelled) console.warn("Search failed", err);
			}
		}, 300);
		return () => {
			cancelled = true;
			clearTimeout(t);
		};
	}, [state.searchQuery, state.includeRemote]);

	const [aiQuery, setAiQuery] = useState("");
	const [aiResponse, setAiResponse] = useState(null);
	const [isAiLoading, setIsAiLoading] = useState(false);

	// Import & search UI state
	const [importBarcode, setImportBarcode] = useState("");
	const [isImporting, setIsImporting] = useState(false);
	const [isSearching, setIsSearching] = useState(false);
	const [isSyncingAll, setIsSyncingAll] = useState(false);
	const [isCreatingEmbeddings, setIsCreatingEmbeddings] = useState(false);

	// Pagination state
	const [pageSize, setPageSize] = useState(20);
	const [currentPage, setCurrentPage] = useState(1);
	const [totalProducts, setTotalProducts] = useState(0);

	// Fetch a page of products from backend (local + remote for searches)
	async function fetchPage(
		q,
		page,
		size,
		includeRemote = state.includeRemote,
	) {
		const query = (q || "").trim();
		const backendQ = query === "$all" ? "" : query;

		// For text searches (not $all / empty), fetch local and remote conditionally
		if (backendQ) {
			// Always fetch local first
			const localRes = await listProducts(backendQ, page, size);
			let local = localRes.products || [];
			let localTotal = localRes.total ?? local.length;
			let remote = [];
			let remoteTotal = 0;
			if (includeRemote) {
				try {
					const remoteRes = await searchRemote(backendQ, page, size);
					remote = (remoteRes.products || []).filter(
						(r) => !local.some((l) => l.code === r.code),
					);
					remoteTotal = remoteRes.total ?? 0;
				} catch (err) {
					console.warn("Remote search failed", err);
				}
			}
			const combined = [...local, ...remote];
			setState((s) => ({ ...s, products: combined }));
			setTotalProducts(localTotal + remoteTotal);
		} else {
			// $all or empty — local only
			const data = await listProducts("", page, size);
			setState((s) => ({ ...s, products: data.products }));
			setTotalProducts(data.total ?? data.products.length);
		}
	}

	// Re-fetch when page or pageSize changes (server-side pagination)
	const skipNextPageEffect = React.useRef(false);
	React.useEffect(() => {
		if (skipNextPageEffect.current) {
			skipNextPageEffect.current = false;
			return;
		}
		const q = state.searchQuery.trim();
		fetchPage(q, currentPage, pageSize, state.includeRemote).catch((err) =>
			console.warn("Page fetch failed", err),
		);
	}, [currentPage, pageSize, state.includeRemote]);

	// performSearch: query local backend and remote, update product list
	async function performSearch(q) {
		const query = (q || "").trim();
		// "$all" shows everything from local DB (paginated)
		if (query === "$all" || !query) {
			setIsSearching(true);
			try {
				skipNextPageEffect.current = true;
				setCurrentPage(1);
				await fetchPage(query, 1, pageSize, state.includeRemote);
			} catch (err) {
				console.warn("Failed to load products", err);
			} finally {
				setIsSearching(false);
			}
			return;
		}
		setIsSearching(true);
		try {
			skipNextPageEffect.current = true;
			setCurrentPage(1);
			await fetchPage(query, 1, pageSize, state.includeRemote);
		} catch (err) {
			console.warn("Search failed", err);
		} finally {
			setIsSearching(false);
		}
	}

	// Sync all selected remote products
	async function handleSyncAll() {
		const selectedRemote = state.products.filter(
			(p) => p.remote && state.selectedProductIds.has(p.id),
		);
		if (selectedRemote.length === 0) {
			alert("No remote products selected to sync.");
			return;
		}
		setIsSyncingAll(true);
		let synced = 0;
		let failed = 0;
		for (const p of selectedRemote) {
			try {
				const res = await fetch(
					"http://localhost:4000/api/products/import",
					{
						method: "POST",
						headers: { "Content-Type": "application/json" },
						body: JSON.stringify({ barcode: p.code }),
					},
				);
				if (!res.ok) throw new Error("import_failed");
				synced++;
			} catch {
				failed++;
			}
		}
		setIsSyncingAll(false);
		alert(
			`Synced ${synced} product(s)${failed ? `, ${failed} failed` : ""}`,
		);
		setState((s) => ({ ...s, selectedProductIds: new Set() }));
		if (window.reloadProducts) await window.reloadProducts();
	}

	async function handleCreateEmbeddings() {
		const selectedLocal = state.products.filter(
			(p) => !p.remote && state.selectedProductIds.has(p.id),
		);
		if (selectedLocal.length === 0) {
			alert("No local products selected to embed.");
			return;
		}
		setIsCreatingEmbeddings(true);
		try {
			const res = await generateEmbeddings(
				selectedLocal.map((p) => p.id),
			);
			const count = res.updated ?? res.count ?? selectedLocal.length;
			alert(`Created embeddings for ${count} products.`);
		} catch (err) {
			console.warn("Embedding generation failed", err);
			alert("Embedding generation failed.");
		} finally {
			setIsCreatingEmbeddings(false);
		}
	}

	const filteredProducts = useMemo(() => {
		// Server already handles text search — only apply local nutri/category filters
		let result = state.products.filter((p) => {
			const matchesNutri =
				state.filterNutriScore === "ALL" ||
				p.nutriscore_grade === state.filterNutriScore;
			const matchesCat =
				state.categoryFilter === "ALL" ||
				(Array.isArray(p.categories)
					? p.categories.some((c) => c.includes(state.categoryFilter))
					: typeof p.categories === "string" &&
						p.categories.includes(state.categoryFilter));
			return matchesNutri && matchesCat;
		});

		result.sort((a, b) => {
			let valA, valB;
			if (
				state.sortField === "energy_100g" ||
				state.sortField === "proteins_100g"
			) {
				valA = a.nutriments[state.sortField];
				valB = b.nutriments[state.sortField];
			} else {
				valA = a[state.sortField];
				valB = b[state.sortField];
			}
			if (valA < valB) return state.sortOrder === "asc" ? -1 : 1;
			if (valA > valB) return state.sortOrder === "asc" ? 1 : -1;
			return 0;
		});
		return result;
	}, [
		state.products,
		state.filterNutriScore,
		state.categoryFilter,
		state.sortField,
		state.sortOrder,
	]);

	const handleExport = () => {
		const data = JSON.stringify(filteredProducts, null, 2);
		const blob = new Blob([data], { type: "application/json" });
		const url = URL.createObjectURL(blob);
		const a = document.createElement("a");
		a.href = url;
		a.download = `foodflow_export_${new Date().toISOString().split("T")[0]}.json`;
		a.click();
	};

	const handleMapCategory = (pId, category) => {
		setState((s) => ({
			...s,
			products: s.products.map((p) =>
				p.id === pId ? { ...p, mappedCategory: category } : p,
			),
		}));
	};

	return (
		<div className="min-h-screen bg-slate-50 flex flex-col md:flex-row font-sans selection:bg-indigo-100">
			<aside className="w-full md:w-64 bg-slate-900 text-slate-300 flex flex-col sticky top-0 h-auto md:h-screen z-20 shadow-2xl">
				<div className="p-6 flex items-center space-x-3 bg-slate-900/50">
					<div className="bg-gradient-to-tr from-indigo-500 to-purple-600 w-10 h-10 rounded-2xl flex items-center justify-center shadow-xl shadow-indigo-500/20">
						<i className="fas fa-layer-group text-white text-lg"></i>
					</div>
					<div>
						<h1 className="text-lg font-black text-white leading-none">
							FoodFlow
						</h1>
						<span className="text-[9px] text-slate-500 font-black uppercase tracking-[0.2em]">
							Data Studio
						</span>
					</div>
				</div>

				<nav className="flex-1 px-4 py-6 space-y-1 overflow-y-auto">
					{[
						{
							id: "inventory",
							label: "Inventory",
							icon: "fa-table-columns",
						},
						{
							id: "quality",
							label: "Quality Monitor",
							icon: "fa-microscope",
						},
						{
							id: "analytics",
							label: "Advanced Stats",
							icon: "fa-chart-line",
						},
						{
							id: "management",
							label: "Stewardship",
							icon: "fa-toolbox",
						},
						{
							id: "ai-advisor",
							label: "AI Optimizer",
							icon: "fa-brain-circuit",
						},
					].map((tab) => (
						<button
							key={tab.id}
							onClick={() =>
								setState((s) => ({ ...s, activeTab: tab.id }))
							}
							className={`w-full flex items-center space-x-3 px-4 py-3 rounded-2xl transition-all border border-transparent ${state.activeTab === tab.id ? "bg-indigo-600 text-white shadow-lg shadow-indigo-500/30" : "hover:bg-slate-800 hover:text-white"}`}
						>
							<i
								className={`fas ${tab.icon} w-5 text-center`}
							></i>
							<span className="font-bold text-sm tracking-tight">
								{tab.label}
							</span>
						</button>
					))}

					<div className="mt-10 mb-4 px-4">
						<h4 className="text-[10px] font-black text-slate-500 uppercase tracking-widest flex items-center">
							<i className="fas fa-bookmark mr-2"></i> Saved
							Segments
						</h4>
					</div>
					{state.segments.map((seg) => (
						<button
							key={seg.id}
							className="w-full flex items-center space-x-3 px-4 py-2 rounded-xl text-slate-400 hover:bg-slate-800 hover:text-indigo-400 transition-all group"
						>
							<i
								className={`fas ${seg.icon} w-5 text-center text-xs group-hover:scale-125 transition-transform`}
							></i>
							<span className="text-xs font-bold">
								{seg.name}
							</span>
						</button>
					))}
				</nav>

				<div className="p-4 bg-slate-950/30">
					<button
						onClick={handleExport}
						className="w-full py-3 px-4 bg-indigo-500/10 border border-indigo-500/20 text-indigo-400 rounded-2xl font-black text-xs uppercase tracking-widest hover:bg-indigo-500 hover:text-white transition-all shadow-sm"
					>
						<i className="fas fa-cloud-arrow-down mr-2"></i> Push to
						Production
					</button>
				</div>
			</aside>

			<main className="flex-1 flex flex-col max-h-screen overflow-hidden">
				<header className="bg-white border-b border-slate-100 px-8 py-4 flex-shrink-0 z-10 flex justify-between items-center shadow-sm">
					<div className="flex items-center space-x-4">
						<h2 className="text-xl font-black text-slate-800 uppercase tracking-tighter">
							{state.activeTab}
						</h2>
						<div className="h-6 w-px bg-slate-200"></div>
						<div className="flex items-center space-x-2 bg-emerald-50 px-3 py-1 rounded-full">
							<span className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-ping"></span>
							<span className="text-[10px] font-black text-emerald-600 uppercase">
								Live Sync Active
							</span>
						</div>
					</div>

					<div className="flex items-center space-x-6">
						<div className="hidden xl:flex items-center space-x-2 text-xs font-bold text-slate-400">
							<i className="fas fa-clock"></i>
							<span>Last Import: 14m ago</span>
						</div>
						{/* Quick Import */}
						<div className="flex items-center space-x-2">
							<input
								type="text"
								placeholder="Import barcode (e.g. 3017620422003)"
								className="p-2 pl-3 pr-12 rounded-xl border border-slate-200 text-xs bg-white"
								value={importBarcode}
								onChange={(e) =>
									setImportBarcode(e.target.value)
								}
								aria-label="Import barcode"
							/>
							<button
								onClick={async () => {
									if (!importBarcode)
										return alert(
											"Enter a barcode to import",
										);
									try {
										setIsImporting(true);
										const res =
											await importByBarcode(
												importBarcode,
											);
										const newP = res.product;
										setState((s) => ({
											...s,
											products: [newP, ...s.products],
										}));
										setImportBarcode("");
									} catch (err) {
										console.error(err);
										alert(
											"Import failed: " +
												(err.message ||
													JSON.stringify(err)),
										);
									} finally {
										setIsImporting(false);
									}
								}}
								className="h-10 px-4 rounded-xl bg-indigo-600 text-white font-bold text-xs hover:bg-indigo-700 transition-colors"
							>
								{isImporting ? "Importing..." : "Import"}
							</button>
						</div>{" "}
						<button className="h-10 w-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-400 hover:bg-slate-100 hover:text-indigo-600 transition-all border border-slate-100">
							<i className="fas fa-gear"></i>
						</button>
						<div className="flex items-center space-x-3 pl-4 border-l border-slate-100">
							<div className="text-right">
								<p className="text-xs font-black text-slate-800">
									Admin User
								</p>
								<p className="text-[10px] text-slate-400 font-bold">
									Data Steward
								</p>
							</div>
							<div className="h-10 w-10 bg-indigo-600 rounded-2xl flex items-center justify-center text-white font-black border-2 border-indigo-200 shadow-lg shadow-indigo-100">
								AU
							</div>
						</div>
					</div>
				</header>

				<div className="flex-1 flex overflow-hidden">
					{state.activeTab === "inventory" && (
						<CategoryTree
							selectedCategory={state.categoryFilter}
							onSelectCategory={(c) =>
								setState((s) => ({ ...s, categoryFilter: c }))
							}
						/>
					)}

					<div className="flex-1 overflow-y-auto p-8 bg-slate-50/50">
						{state.activeTab === "inventory" && (
							<div className="space-y-6 h-full flex flex-col">
								{state.searchQuery &&
									state.searchQuery.trim() !== "$all" &&
									filteredProducts.length === 0 && (
										<div className="bg-white rounded-xl p-6 border border-slate-100 text-center mb-4">
											<p className="text-slate-500 mb-3">
												No products matched "
												{state.searchQuery}".
											</p>
											<div className="flex items-center justify-center gap-2">
												<button
													className="px-4 py-2 bg-indigo-600 text-white rounded-xl"
													onClick={() =>
														performSearch(
															state.searchQuery,
														)
													}
												>
													Search remote
												</button>
												{isSearching && (
													<span className="text-slate-400">
														Searching...
													</span>
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
											value={state.searchQuery}
											onKeyDown={async (e) => {
												if (e.key === "Enter") {
													e.preventDefault();
													await performSearch(
														state.searchQuery,
													);
												}
											}}
											onChange={(e) =>
												setState((s) => ({
													...s,
													searchQuery: e.target.value,
												}))
											}
										/>
									</div>
									<div className="flex items-center space-x-2">
										<label className="flex items-center text-sm text-slate-500 bg-slate-100 px-3 py-1 rounded-xl">
											<input
												type="checkbox"
												className="mr-2"
												checked={state.includeRemote}
												onChange={(e) =>
													setState((s) => ({
														...s,
														includeRemote:
															e.target.checked,
													}))
												}
											/>
											Include OpenFoodFacts
										</label>
										<button className="px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold text-slate-500 hover:bg-slate-100 transition-colors">
											<i className="fas fa-filter mr-2"></i>{" "}
											Advanced Query
										</button>
										<div className="h-6 w-px bg-slate-200 mx-2"></div>
										<div className="flex bg-slate-100 p-1.5 rounded-xl">
											<button
												onClick={() =>
													setState((s) => ({
														...s,
														viewMode: "grid",
													}))
												}
												className={`px-4 py-2 rounded-lg text-xs font-black transition-all ${state.viewMode === "grid" ? "bg-white shadow-sm text-indigo-600" : "text-slate-400"}`}
											>
												GRID
											</button>
											<button
												onClick={() =>
													setState((s) => ({
														...s,
														viewMode: "table",
													}))
												}
												className={`px-4 py-2 rounded-lg text-xs font-black transition-all ${state.viewMode === "table" ? "bg-white shadow-sm text-indigo-600" : "text-slate-400"}`}
											>
												TABLE
											</button>
										</div>
									</div>
								</div>

								<DataTableView
									products={filteredProducts}
									selectedIds={state.selectedProductIds}
									onSelect={(id, sel) => {
										const next = new Set(
											state.selectedProductIds,
										);
										sel ? next.add(id) : next.delete(id);
										setState((s) => ({
											...s,
											selectedProductIds: next,
										}));
									}}
									onSelectAll={(sel) =>
										setState((s) => ({
											...s,
											selectedProductIds: sel
												? new Set(
														filteredProducts.map(
															(p) => p.id,
														),
													)
												: new Set(),
										}))
									}
									onViewProduct={(p) =>
										setState((s) => ({
											...s,
											selectedProduct: p,
										}))
									}
									sortField={state.sortField}
									sortOrder={state.sortOrder}
									onSort={(f) =>
										setState((s) => ({
											...s,
											sortField: f,
											sortOrder:
												s.sortField === f &&
												s.sortOrder === "asc"
													? "desc"
													: "asc",
										}))
									}
									pageSize={pageSize}
									onPageSizeChange={(size) => {
										setPageSize(size);
										setCurrentPage(1);
									}}
									currentPage={currentPage}
									onPageChange={setCurrentPage}
									totalProducts={totalProducts}
									onSyncAll={handleSyncAll}
									isSyncingAll={isSyncingAll}
									onCreateEmbeddings={handleCreateEmbeddings}
									isCreatingEmbeddings={isCreatingEmbeddings}
								/>
							</div>
						)}

						{state.activeTab === "quality" && (
							<QualityDashboard
								products={state.products}
								onReviewProduct={(p) =>
									setState((s) => ({
										...s,
										selectedProduct: p,
									}))
								}
							/>
						)}

						{state.activeTab === "analytics" && (
							<Dashboard products={state.products} />
						)}

						{state.activeTab === "management" && (
							<div className="max-w-6xl mx-auto space-y-8 pb-12">
								<div className="flex bg-white p-2 rounded-2xl border border-slate-100 shadow-sm w-fit mx-auto mb-8">
									{[
										{
											id: "merging",
											label: "Duplicates",
											icon: "fa-object-group",
										},
										{
											id: "mapping",
											label: "Classification",
											icon: "fa-sitemap",
										},
										{
											id: "audit",
											label: "Audit Logs",
											icon: "fa-history",
										},
									].map((sub) => (
										<button
											key={sub.id}
											onClick={() =>
												setState((s) => ({
													...s,
													managementSubTab: sub.id,
												}))
											}
											className={`px-6 py-2 rounded-xl text-xs font-bold transition-all flex items-center space-x-2 ${state.managementSubTab === sub.id ? "bg-slate-900 text-white shadow-lg" : "text-slate-400 hover:bg-slate-50"}`}
										>
											<i
												className={`fas ${sub.icon}`}
											></i>
											<span>{sub.label}</span>
										</button>
									))}
								</div>

								{state.managementSubTab === "merging" && (
									<DataManagement
										products={state.products}
										onMerge={() => {}}
										onNormalize={() => {}}
									/>
								)}
								{state.managementSubTab === "mapping" && (
									<CategoryMapping
										products={state.products}
										onMap={handleMapCategory}
									/>
								)}
								{state.managementSubTab === "audit" && (
									<AuditLogViewer
										logs={state.auditLogs}
										products={state.products}
									/>
								)}
							</div>
						)}

						{state.activeTab === "ai-advisor" && (
							<div className="max-w-4xl mx-auto space-y-8 pb-12">
								<div className="bg-white p-12 rounded-[3rem] shadow-2xl border border-slate-100 relative overflow-hidden">
									<div className="absolute top-0 right-0 w-64 h-64 bg-indigo-50 rounded-full -mr-32 -mt-32 blur-3xl opacity-50"></div>
									<div className="flex items-center space-x-6 mb-10">
										<div className="w-16 h-16 bg-gradient-to-br from-indigo-600 to-purple-700 rounded-3xl flex items-center justify-center text-white shadow-2xl shadow-indigo-200">
											<i className="fas fa-robot text-2xl"></i>
										</div>
										<div>
											<h3 className="text-3xl font-black text-slate-800 tracking-tighter">
												AI Knowledge Engine
											</h3>
											<p className="text-slate-400 font-bold uppercase text-[10px] tracking-[0.3em]">
												Data Science & Dietetics
											</p>
										</div>
									</div>

									<form
										onSubmit={async (e) => {
											e.preventDefault();
											setIsAiLoading(true);
											const res = null;
											setAiResponse(res);
											setIsAiLoading(false);
										}}
										className="relative group"
									>
										<input
											type="text"
											value={aiQuery}
											onChange={(e) =>
												setAiQuery(e.target.value)
											}
											placeholder="Ask about data normalization, dietetic trends, or category re-mapping..."
											className="w-full pl-8 pr-44 py-6 bg-slate-50 border border-slate-200 rounded-[2rem] focus:outline-none focus:ring-8 focus:ring-indigo-500/5 transition-all text-lg font-bold placeholder:text-slate-300"
										/>
										<button
											type="submit"
											disabled={
												isAiLoading || !aiQuery.trim()
											}
											className="absolute right-4 top-4 bottom-4 bg-slate-900 text-white px-10 rounded-[1.5rem] font-black uppercase text-xs tracking-widest hover:bg-indigo-600 disabled:bg-slate-200 transition-all shadow-xl"
										>
											{isAiLoading ? (
												<i className="fas fa-spinner animate-spin"></i>
											) : (
												"Execute"
											)}
										</button>
									</form>

									{aiResponse && (
										<div className="mt-12 animate-in fade-in slide-in-from-top-4">
											<div className="bg-indigo-50/50 rounded-[2.5rem] p-12 border border-indigo-100/30">
												<div className="prose prose-indigo max-w-none text-slate-700 leading-relaxed text-lg font-medium">
													{aiResponse}
												</div>
											</div>
										</div>
									)}
								</div>
							</div>
						)}
					</div>
				</div>
			</main>

			{state.selectedProduct && (
				<ProductDetail
					product={state.selectedProduct}
					onClose={() =>
						setState((s) => ({ ...s, selectedProduct: null }))
					}
				/>
			)}
		</div>
	);
};

export default App;
