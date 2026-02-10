import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { MOCK_PRODUCTS, MOCK_AUDIT_LOGS } from "../constants";
import {
	generateEmbeddings,
	getById,
	listProducts,
	searchRemote,
} from "../api/backend";

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

	const [pageSize, setPageSize] = useState(20);
	const [currentPage, setCurrentPage] = useState(1);
	const [totalProducts, setTotalProducts] = useState(0);

	const skipNextPageEffect = useRef(false);
	const searchQueryRef = useRef(state.searchQuery);

	useEffect(() => {
		async function load() {
			try {
				setIsPageLoading(true);
				const data = await listProducts("", 1, 20);
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
				const data = await listProducts(backendQ, currentPage, pageSize);
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

	const performSearch = useCallback(async (q) => {
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
	}, [fetchPage, pageSize, state.includeRemote]);

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
			alert("No remote products selected to sync.");
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
				const json = await res.json();
				if (json?.product) {
					setState((s) => {
						const idx = s.products.findIndex(
							(item) => item.code === json.product.code,
						);
						const next = [...s.products];
						if (idx >= 0) {
							next[idx] = {
								...next[idx],
								...json.product,
								remote: false,
							};
						} else {
							next.unshift(json.product);
						}
						return { ...s, products: next };
					});
				}
				synced++;
				setSyncProgress((prev) => ({
					...prev,
					done: prev.done + 1,
				}));
			} catch {
				failed++;
				setSyncProgress((prev) => ({
					...prev,
					failed: prev.failed + 1,
				}));
			}
		}
		setIsSyncingAll(false);
		setSyncProgress((prev) => ({ ...prev, active: false }));
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
		setEmbeddingProgress({
			active: true,
			total: selectedLocal.length,
			done: 0,
			failed: 0,
		});
		try {
			let done = 0;
			let failed = 0;
			for (const p of selectedLocal) {
				try {
					await generateEmbeddings([p.id]);
					const refreshed = await getById(p.id);
					setState((s) => {
						const idx = s.products.findIndex(
							(item) => item.id === p.id,
						);
						if (idx === -1) return s;
						const next = [...s.products];
						next[idx] = { ...next[idx], ...refreshed };
						return { ...s, products: next };
					});
					done++;
					setEmbeddingProgress((prev) => ({
						...prev,
						done: prev.done + 1,
					}));
				} catch {
					failed++;
					setEmbeddingProgress((prev) => ({
						...prev,
						failed: prev.failed + 1,
					}));
				}
			}
			alert(
				`Created embeddings for ${done} product(s)${
					failed ? `, ${failed} failed` : ""
				}`,
			);
		} catch (err) {
			console.warn("Embedding generation failed", err);
			alert("Embedding generation failed.");
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
		a.download = `foodflow_export_${new Date()
			.toISOString()
			.split("T")[0]}.json`;
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
