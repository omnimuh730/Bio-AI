import React, { useState } from "react";
import { importByBarcode } from "./api/backend";
import CategoryTree from "./components/CategoryTree";
import AnalyticsDashboard from "./components/AnalyticsDashboard";
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
		if (!importBarcode) return console.log("Enter a barcode to import");
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
			console.log(
				"Import failed: " + (err.message || JSON.stringify(err)),
			);
		} finally {
			setIsImporting(false);
		}
	};

	const handleTabChange = (tab) =>
		setState((s) => ({ ...s, activeTab: tab }));

	const handleCategorySelect = (category) =>
		setState((s) => ({ ...s, categoryFilter: category }));

	const handleSearchQueryChange = (value) =>
		setState((s) => ({ ...s, searchQuery: value }));

	const handleIncludeRemoteChange = (value) =>
		setState((s) => ({ ...s, includeRemote: value }));

	const handleViewModeChange = (mode) =>
		setState((s) => ({ ...s, viewMode: mode }));

	const handleSelect = (id, selected) => {
		const next = new Set(state.selectedProductIds);
		selected ? next.add(id) : next.delete(id);
		setState((s) => ({ ...s, selectedProductIds: next }));
	};

	const handleSelectAll = (selected) =>
		setState((s) => ({
			...s,
			selectedProductIds: selected
				? new Set(filteredProducts.map((p) => p.id))
				: new Set(),
		}));

	const handleViewProduct = (product) =>
		setState((s) => ({ ...s, selectedProduct: product }));

	const handleSort = (field) =>
		setState((s) => ({
			...s,
			sortField: field,
			sortOrder:
				s.sortField === field && s.sortOrder === "asc" ? "desc" : "asc",
		}));

	const handleManagementTabChange = (value) =>
		setState((s) => ({ ...s, managementSubTab: value }));

	return (
		<div className="min-h-screen bg-slate-50 flex flex-col md:flex-row font-sans selection:bg-indigo-100">
			<Sidebar
				activeTab={state.activeTab}
				onTabChange={handleTabChange}
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
							onSelectCategory={handleCategorySelect}
						/>
					)}

					<div className="flex-1 overflow-y-auto p-8 bg-slate-50/50">
						{state.activeTab === "inventory" && (
							<InventoryPanel
								searchQuery={state.searchQuery}
								onSearchQueryChange={handleSearchQueryChange}
								onSearchSubmit={performSearch}
								includeRemote={state.includeRemote}
								onIncludeRemoteChange={handleIncludeRemoteChange}
								viewMode={state.viewMode}
								onViewModeChange={handleViewModeChange}
								filteredProducts={filteredProducts}
								selectedProductIds={state.selectedProductIds}
								onSelect={handleSelect}
								onSelectAll={handleSelectAll}
								onViewProduct={handleViewProduct}
								sortField={state.sortField}
								sortOrder={state.sortOrder}
								onSort={handleSort}
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
								onReviewProduct={handleViewProduct}
							/>
						)}

						{state.activeTab === "analytics" && (
							<AnalyticsDashboard products={state.products} />
						)}

						<ManagementTabs
							managementSubTab={state.managementSubTab}
							onChange={handleManagementTabChange}
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
