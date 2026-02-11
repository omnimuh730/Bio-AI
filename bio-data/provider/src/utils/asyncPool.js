export async function mapWithConcurrency(items, limit, worker) {
	if (!Array.isArray(items) || items.length === 0) return [];
	const concurrency = Math.max(1, Math.min(limit, items.length));
	let nextIndex = 0;
	const results = new Array(items.length);

	const runners = Array.from({ length: concurrency }, async () => {
		while (true) {
			const current = nextIndex++;
			if (current >= items.length) return;
			try {
				const value = await worker(items[current], current);
				results[current] = { status: "fulfilled", value };
			} catch (error) {
				results[current] = { status: "rejected", reason: error };
			}
		}
	});

	await Promise.all(runners);
	return results;
}
