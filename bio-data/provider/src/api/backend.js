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

export async function searchRemote(q = "", pageSize = 20) {
	const url = new URL("http://localhost:4000/api/products/remote/search");
	url.searchParams.set("q", q);
	url.searchParams.set("pageSize", pageSize);
	const res = await fetch(url);
	if (!res.ok) throw new Error("remote_search_error");
	return res.json();
}
