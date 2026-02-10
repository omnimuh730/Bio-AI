import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { MOCK_PRODUCTS, MOCK_AUDIT_LOGS } from "../constants";
import {
	generateEmbeddings,
	importByBarcode,
	listProducts,
	searchRemote,
} from "../api/backend";
import { chunkArray } from "../utils/array";
import { mapWithConcurrency } from "../utils/asyncPool";

const DEFAULT_PAGE_SIZE = 20;
const SYNC_CONCURRENCY = 6;
const EMBEDDING_BATCH_SIZE = 64;
const EMBEDDING_CONCURRENCY = 4;

const hasEmbeddings = (product) =>
	!!(
		product.embeddings?.updated_at ||
		(product.embeddings?.name_desc &&
			product.embeddings.name_desc.length > 0)
	);

const mergeImportedProduct = (products, imported) => {
	const idx = products.findIndex((item) => item.code === imported.code);
	const next = [...products];
	if (idx >= 0) {
		next[idx] = { ...next[idx], ...imported, remote: false };
	} else {
		next.unshift({ ...imported, remote: false });
	}
	return next;
};

export const useInventoryData = () => {
	const [state, setState] = useState({
		products: MOCK_PRODUCTS,
		auditLogs: MOCK_AUDIT_LOGS,
		selectedProduct: null,
		selectedProductIds: new Set(),
		searchQuery: "",
		filterNutriScore: "ALL",
		categoryFilter: "ALL",
		activeTab: "inventory",
		viewMode: "table",
		sortField: "last_modified",
		sortOrder: "desc",
		includeRemote: true,
		managementSubTab: null,
	});

	const [isSearching, setIsSearching] = useState(false);
	const [isSyncingAll, setIsSyncingAll] = useState(false);
	const [isCreatingEmbeddings, setIsCreatingEmbeddings] = useState(false);
	const [isPageLoading, setIsPageLoading] = useState(false);

	const [syncProgress, setSyncProgress] = useState({
		active: false,
		total: 0,
		done: 0,
		failed: 0,
	});
	const [embeddingProgress, setEmbeddingProgress] = useState({
		active: false,
		total: 0,
		done: 0,
		failed: 0,
	});

	const [pageSize, setPageSize] = useState(DEFAULT_PAGE_SIZE);
	const [currentPage, setCurrentPage] = useState(1);
	const [totalProducts, setTotalProducts] = useState(0);

	const skipNextPageEffect = useRef(false);
	const searchQueryRef = useRef(state.searchQuery);

	useEffect(() => {
		async function load() {
			try {
				setIsPageLoading(true);
				const data = await listProducts("", 1, DEFAULT_PAGE_SIZE);
				setState((s) => ({ ...s, products: data.products }));
				setTotalProducts(data.total ?? data.products.length);
			} catch (err) {
				console.warn("Failed to load backend products", err);
			} finally {
				setIsPageLoading(false);
			}
		}
		load();
	}, []);

	useEffect(() => {
		window.reloadProducts = async () => {
			try {
				setIsPageLoading(true);
				const q = state.searchQuery.trim();
				const backendQ = q === "$all" ? "" : q;
				const data = await listProducts(
					backendQ,
					currentPage,
					pageSize,
				);
				setState((s) => ({ ...s, products: data.products }));
				setTotalProducts(data.total ?? data.products.length);
			} catch (err) {
				console.warn("reloadProducts failed", err);
			} finally {
				setIsPageLoading(false);
			}
		};

		return () => {
			delete window.reloadProducts;
		};
	}, [state.searchQuery, currentPage, pageSize]);

	useEffect(() => {
		searchQueryRef.current = state.searchQuery;
	}, [state.searchQuery]);

	const fetchPage = useCallback(async (q, page, size, includeRemote) => {
		setIsPageLoading(true);
		try {
			const query = (q || "").trim();
			const backendQ = query === "$all" ? "" : query;

			if (backendQ) {
				const localRes = await listProducts(backendQ, page, size);
				const local = localRes.products || [];
				const localTotal = localRes.total ?? local.length;
				let remote = [];
				let remoteTotal = 0;
				if (includeRemote) {
					try {
						const remoteRes = await searchRemote(
							backendQ,
							page,
							size,
						);
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
				const data = await listProducts("", page, size);
				setState((s) => ({ ...s, products: data.products }));
				setTotalProducts(data.total ?? data.products.length);
			}
		} finally {
			setIsPageLoading(false);
		}
	}, []);

	useEffect(() => {
		if (skipNextPageEffect.current) {
			skipNextPageEffect.current = false;
			return;
		}
		const q = searchQueryRef.current.trim();
		fetchPage(q, currentPage, pageSize, state.includeRemote).catch((err) =>
			console.warn("Page fetch failed", err),
		);
	}, [currentPage, pageSize, state.includeRemote, fetchPage]);

	const performSearch = useCallback(
		async (q) => {
			const query = (q || "").trim();
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
		},
		[fetchPage, pageSize, state.includeRemote],
	);

	useEffect(() => {
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
	}, [state.searchQuery, state.includeRemote, performSearch]);

	async function handleSyncAll() {
		const selectedRemote = state.products.filter(
			(p) => p.remote && state.selectedProductIds.has(p.id),
		);
		if (selectedRemote.length === 0) {
			console.log("No remote products selected to sync.");
			return;
		}
		setIsSyncingAll(true);
		setSyncProgress({
			active: true,
			total: selectedRemote.length,
			done: 0,
			failed: 0,
		});
		let synced = 0;
		let failed = 0;

		await mapWithConcurrency(
			selectedRemote,
			SYNC_CONCURRENCY,
			async (product) => {
				try {
					const res = await importByBarcode(product.code);
					if (res?.product) {
						setState((s) => ({
							...s,
							products: mergeImportedProduct(
								s.products,
								res.product,
							),
						}));
					}
					synced += 1;
					setSyncProgress((prev) => ({
						...prev,
						done: prev.done + 1,
					}));
					return res;
				} catch (err) {
					failed += 1;
					setSyncProgress((prev) => ({
						...prev,
						failed: prev.failed + 1,
					}));
					throw err;
				}
			},
		);
		setIsSyncingAll(false);
		setSyncProgress((prev) => ({ ...prev, active: false }));
		console.log(
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
			console.log("No local products selected to embed.");
			return;
		}

		// Only include products that don't already have embeddings
		const embeddable = selectedLocal.filter((p) => !hasEmbeddings(p));
		const skipped = selectedLocal.length - embeddable.length;
		if (embeddable.length === 0) {
			console.log(
				`No selected products need embeddings.${skipped > 0 ? ` ${skipped} already embedded.` : ``}`,
			);
			return;
		}

		setIsCreatingEmbeddings(true);
		setEmbeddingProgress({
			active: true,
			total: embeddable.length,
			done: 0,
			failed: 0,
		});
		try {
			let done = 0;
			let failed = 0;

			const ids = embeddable.map((p) => p.id);
			const batches = chunkArray(ids, EMBEDDING_BATCH_SIZE);

			const applyEmbeddingUpdates = (resp) => {
				const updated = resp?.updatedProducts || [];
				if (updated.length > 0) {
					setState((s) => {
						const next = [...s.products];
						for (const u of updated) {
							const idx = next.findIndex(
								(item) => String(item.id) === String(u.id),
							);
							if (idx !== -1) {
								next[idx] = {
									...next[idx],
									embeddings: u.embeddings,
								};
							}
						}
						return { ...s, products: next };
					});
					return;
				}

				if (!resp?.embeddings) return;
				setState((s) => {
					const next = [...s.products];
					for (const e of resp.embeddings) {
						const idx = next.findIndex(
							(item) => String(item.id) === String(e.id),
						);
						if (idx !== -1) {
							next[idx] = {
								...next[idx],
								embeddings: e.embeddings,
							};
						}
					}
					return { ...s, products: next };
				});
			};

			async function processBatch(batchIds) {
				try {
					const resp = await generateEmbeddings(batchIds, {
						force: false,
					});
					const count = resp?.count || batchIds.length;
					done += count;
					setEmbeddingProgress((prev) => ({
						...prev,
						done: prev.done + count,
					}));
					applyEmbeddingUpdates(resp);
				} catch (err) {
					failed += batchIds.length;
					setEmbeddingProgress((prev) => ({
						...prev,
						failed: prev.failed + batchIds.length,
					}));
					console.warn("Embedding batch failed", err);
				}
			}

			await mapWithConcurrency(
				batches,
				EMBEDDING_CONCURRENCY,
				processBatch,
			);

			if (skipped > 0) {
				console.log(
					`${skipped} product(s) were already embedded and were skipped.`,
				);
			}
			console.log(
				`Created embeddings for ${done} product(s)${
					failed ? `, ${failed} failed` : ""
				}`,
			);
		} catch (err) {
			console.warn("Embedding generation failed", err);
			console.log("Embedding generation failed.");
		} finally {
			setIsCreatingEmbeddings(false);
			setEmbeddingProgress((prev) => ({ ...prev, active: false }));
		}
	}

	const filteredProducts = useMemo(() => {
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
			let valA;
			let valB;
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
		a.download = `foodflow_export_${
			new Date().toISOString().split("T")[0]
		}.json`;
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

	return {
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
	};
};
