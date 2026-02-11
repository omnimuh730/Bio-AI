export function chunkArray(items, size) {
	if (!Array.isArray(items) || items.length === 0) return [];
	const chunkSize = Math.max(1, size);
	const out = [];
	for (let i = 0; i < items.length; i += chunkSize) {
		out.push(items.slice(i, i + chunkSize));
	}
	return out;
}
