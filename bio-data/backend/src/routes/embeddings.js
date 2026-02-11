const express = require("express");
const axios = require("axios");
const Product = require("../models/Product");

const router = express.Router();

const EMBEDDING_SERVER_URL =
	process.env.EMBEDDING_SERVER_URL || "http://localhost:7001";

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

module.exports = router;
