import React, { useState } from "react";
import { importByBarcode } from "./api/backend";
import CategoryTree from "./components/CategoryTree";
import Dashboard from "./components/Dashboard";
import ProductDetail from "./components/ProductDetail";
import QualityDashboard from "./components/QualityDashboard";
import AiAssistantBar from "./components/app/AiAssistantBar";
import AppHeader from "./components/app/AppHeader";
import InventoryPanel from "./components/app/InventoryPanel";
import ManagementPanel from "./components/app/ManagementPanel";
import ManagementTabs from "./components/app/ManagementTabs";
import Sidebar from "./components/app/Sidebar";
import { useInventoryData } from "./hooks/useInventoryData";

const App = () => {
	const {
		state,
		setState,
		filteredProducts,
		isSearching,
		isSyncingAll,
		isCreatingEmbeddings,
		isPageLoading,
		syncProgress,
		embeddingProgress,
		pageSize,
		setPageSize,
		currentPage,
		setCurrentPage,
		totalProducts,
		performSearch,
		handleSyncAll,
		handleCreateEmbeddings,
		handleMapCategory,
		handleExport,
	} = useInventoryData();

	const [aiQuery, setAiQuery] = useState("");
	const [aiResponse, setAiResponse] = useState(null);
	const [isAiLoading, setIsAiLoading] = useState(false);

	const [importBarcode, setImportBarcode] = useState("");
	const [isImporting, setIsImporting] = useState(false);

	const handleImport = async () => {
		if (!importBarcode) return alert("Enter a barcode to import");
		try {
			setIsImporting(true);
			const res = await importByBarcode(importBarcode);
			const newP = res.product;
			setState((s) => ({
				...s,
				products: [newP, ...s.products],
			}));
			setImportBarcode("");
		} catch (err) {
			console.error(err);
			alert(
				"Import failed: " + (err.message || JSON.stringify(err)),
			);
		} finally {
			setIsImporting(false);
		}
	};

	return (
		<div className="min-h-screen bg-slate-50 flex flex-col md:flex-row font-sans selection:bg-indigo-100">
			<Sidebar
				activeTab={state.activeTab}
				onTabChange={(tab) =>
					setState((s) => ({ ...s, activeTab: tab }))
				}
				onExport={handleExport}
			/>

			<main className="flex-1 flex flex-col max-h-screen overflow-hidden">
				<AppHeader
					activeTab={state.activeTab}
					importBarcode={importBarcode}
					onImportBarcodeChange={setImportBarcode}
					onImport={handleImport}
					isImporting={isImporting}
				/>

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
							<InventoryPanel
								searchQuery={state.searchQuery}
								onSearchQueryChange={(value) =>
									setState((s) => ({
										...s,
										searchQuery: value,
									}))
								}
								onSearchSubmit={performSearch}
								includeRemote={state.includeRemote}
								onIncludeRemoteChange={(value) =>
									setState((s) => ({
										...s,
										includeRemote: value,
									}))
								}
								viewMode={state.viewMode}
								onViewModeChange={(mode) =>
									setState((s) => ({ ...s, viewMode: mode }))
								}
								filteredProducts={filteredProducts}
								selectedProductIds={state.selectedProductIds}
								onSelect={(id, sel) => {
									const next = new Set(state.selectedProductIds);
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
											? new Set(filteredProducts.map((p) => p.id))
											: new Set(),
									}))
								}
								onViewProduct={(p) =>
									setState((s) => ({ ...s, selectedProduct: p }))
								}
								sortField={state.sortField}
								sortOrder={state.sortOrder}
								onSort={(f) =>
									setState((s) => ({
										...s,
										sortField: f,
										sortOrder:
											s.sortField === f && s.sortOrder === "asc"
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
								isLoading={isSearching || isPageLoading}
								syncProgress={syncProgress}
								embeddingProgress={embeddingProgress}
								isSearching={isSearching}
							/>
						)}

						{state.activeTab === "quality" && (
							<QualityDashboard
								products={state.products}
								onReviewProduct={(p) =>
									setState((s) => ({ ...s, selectedProduct: p }))
								}
							/>
						)}

						{state.activeTab === "analytics" && (
							<Dashboard products={state.products} />
						)}

						<ManagementTabs
							managementSubTab={state.managementSubTab}
							onChange={(value) =>
								setState((s) => ({
									...s,
									managementSubTab: value,
								}))
							}
						/>
					</div>

					<ManagementPanel
						managementSubTab={state.managementSubTab}
						products={state.products}
						auditLogs={state.auditLogs}
						onMap={handleMapCategory}
					/>
				</div>

				<AiAssistantBar
					aiQuery={aiQuery}
					onAiQueryChange={setAiQuery}
					onSubmit={async (e) => {
						e.preventDefault();
						setIsAiLoading(true);
						const res = null;
						setAiResponse(res);
						setIsAiLoading(false);
					}}
					isAiLoading={isAiLoading}
					aiResponse={aiResponse}
				/>
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
