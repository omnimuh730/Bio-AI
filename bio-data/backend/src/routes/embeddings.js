const express = require("express");
const axios = require("axios");
const Product = require("../models/Product");

const router = express.Router();

const EMBEDDING_SERVER_URL =
	process.env.EMBEDDING_SERVER_URL || "http://localhost:7001";

const dot = (a, b) => {
	let sum = 0;
	for (let i = 0; i < a.length; i += 1) sum += a[i] * b[i];
	return sum;
};

const norm = (a) => Math.sqrt(dot(a, a));

const cosineSimilarity = (a, b) => {
	if (!a || !b || a.length !== b.length || a.length === 0) return 0;
	const denom = norm(a) * norm(b);
	return denom === 0 ? 0 : dot(a, b) / denom;
};

router.post("/generate", async (req, res) => {
	try {
		const ids = Array.isArray(req.body.ids) ? req.body.ids : [];
		const force = req.body?.force === true || req.query?.force === "true";
		if (ids.length === 0) {
			return res.status(400).json({ error: "missing_ids" });
		}

		// Fetch products
		const products = await Product.find({ _id: { $in: ids } }).lean();
		if (products.length === 0) {
			return res.json({ count: 0, updated: 0, skipped: 0 });
		}

		// If not forced, skip products that already have embeddings
		let productsToProcess = products;
		let skipped = 0;
		if (!force) {
			const filtered = products.filter((p) => {
				const hasEmbedding = !!(
					p.embeddings &&
					(p.embeddings.updated_at ||
						(p.embeddings.name_desc &&
							p.embeddings.name_desc.length > 0))
				);
				if (hasEmbedding) skipped++;
				return !hasEmbedding;
			});
			productsToProcess = filtered;
		}

		if (productsToProcess.length === 0) {
			return res.json({ count: 0, updated: 0, skipped });
		}

		const payload = productsToProcess.map((p) => ({
			id: p._id.toString(),
			product_name: p.product_name || "",
			categories: p.categories || [],
			ingredients_text: p.ingredients_text || "",
			nutriments: p.nutriments || {},
			nova_group: p.nova_group || null,
		}));

		const resp = await axios.post(
			`${EMBEDDING_SERVER_URL}/embeddings/generate`,
			{ products: payload },
			{ timeout: 120000 },
		);

		const model = resp.data?.model || "";
		const embeddings = Array.isArray(resp.data?.embeddings)
			? resp.data.embeddings
			: [];
		if (embeddings.length === 0) {
			return res.status(502).json({ error: "embedding_failed" });
		}

		const now = new Date();
		for (const entry of embeddings) {
			console.log(`embedding_complete id=${entry.id}`);
		}
		const ops = embeddings.map((entry) => ({
			updateOne: {
				filter: { _id: entry.id },
				update: {
					$set: {
						embeddings: {
							model,
							name_desc: entry.embeddings?.name_desc || [],
							ingredients: entry.embeddings?.ingredients || [],
							nutrition: entry.embeddings?.nutrition || [],
							updated_at: now,
						},
					},
				},
			},
		}));

		const result = await Product.bulkWrite(ops, { ordered: false });
		const updated = result.modifiedCount || 0;

		// Return the updated product docs (embeddings only) so callers can refresh state
		const updatedIds = embeddings.map((e) => e.id);
		const updatedProducts = await Product.find({ _id: { $in: updatedIds } }, { embeddings: 1 }).lean();
		const updatedProductsFormatted = updatedProducts.map((p) => ({ ...p, id: p._id }));

		return res.json({ count: embeddings.length, updated, model, skipped, updatedProducts: updatedProductsFormatted });
	} catch (err) {
		console.error("embedding generate error", err?.message || err);
		return res.status(500).json({ error: "embedding_generate_failed" });
	}
});

router.get("/search", async (req, res) => {
	try {
		const q = (req.query.q || "").trim();
		if (!q) return res.status(400).json({ error: "missing_query" });
		const field = req.query.field || "name_desc";
		const limit = Math.min(parseInt(req.query.limit || "20", 10), 100);
		const maxCandidates = Math.min(
			parseInt(req.query.maxCandidates || "500", 10),
			5000,
		);

		const embedResp = await axios.post(
			`${EMBEDDING_SERVER_URL}/embeddings/encode`,
			{ text: q },
			{ timeout: 60000 },
		);
		const queryVector = embedResp.data?.vector || [];
		const encodeMs = embedResp.data?.encode_ms ?? null;
		if (queryVector.length === 0) {
			return res.status(502).json({ error: "embedding_failed" });
		}

		const fieldPath = `embeddings.${field}`;
		const candidates = await Product.find(
			{ [fieldPath]: { $exists: true, $ne: [] } },
			null,
			{ limit: maxCandidates },
		).lean();

		const scored = candidates
			.map((p) => {
				const vector = p.embeddings?.[field] || [];
				const score = cosineSimilarity(queryVector, vector);
				return {
					...p,
					id: p._id,
					score,
					embedding_score: score,
				};
			})
			.sort((a, b) => b.score - a.score);

		const products = scored.slice(0, limit);
		return res.json({ total: scored.length, products, encodeMs });
	} catch (err) {
		console.error("embedding search error", err?.message || err);
		return res.status(500).json({ error: "embedding_search_failed" });
	}
});

module.exports = router;
