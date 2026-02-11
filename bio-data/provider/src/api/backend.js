export async function listProducts(q = "", page = 1, pageSize = 50) {
	const url = new URL("http://localhost:4000/api/products");
	url.searchParams.set("q", q);
	url.searchParams.set("page", page);
	url.searchParams.set("pageSize", pageSize);
	const res = await fetch(url);
	if (!res.ok) throw new Error("network_error");
	return res.json();
}

export async function importByBarcode(barcode) {
	const res = await fetch("http://localhost:4000/api/products/import", {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ barcode }),
	});
	if (!res.ok) {
		const error = await res.json().catch(() => ({}));
		throw new Error(error.error || "import_error");
	}
	return res.json();
}

export async function getByCode(code) {
	const res = await fetch(`http://localhost:4000/api/products/code/${code}`);
	if (!res.ok) throw new Error("not_found");
	return res.json();
}

export async function getById(id) {
	const res = await fetch(`http://localhost:4000/api/products/${id}`);
	if (!res.ok) throw new Error("not_found");
	return res.json();
}

export async function searchRemote(q = "", page = 1, pageSize = 20) {
	const url = new URL("http://localhost:4000/api/products/remote/search");
	url.searchParams.set("q", q);
	url.searchParams.set("page", page);
	url.searchParams.set("pageSize", pageSize);
	const res = await fetch(url);
	if (!res.ok) throw new Error("remote_search_error");
	return res.json();
}

export async function generateEmbeddings(ids = [], options = {}) {
	const body = { ids };
	if (options.force) body.force = true;
	const res = await fetch("http://localhost:4000/api/embeddings/generate", {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify(body),
	});
	if (!res.ok) {
		const error = await res.json().catch(() => ({}));
		throw new Error(error.error || "embedding_error");
	}
	return res.json();
}

export async function searchEmbeddings(query, options = {}) {
	const url = new URL("http://localhost:4000/api/embeddings/search");
	url.searchParams.set("q", query);
	if (options.limit) url.searchParams.set("limit", options.limit);
	if (options.field) url.searchParams.set("field", options.field);
	if (options.maxCandidates)
		url.searchParams.set("maxCandidates", options.maxCandidates);
	const res = await fetch(url);
	if (!res.ok) {
		const error = await res.json().catch(() => ({}));
		throw new Error(error.error || "embedding_search_error");
	}
	return res.json();
}
