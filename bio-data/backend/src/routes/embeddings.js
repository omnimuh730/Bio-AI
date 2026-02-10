const express = require("express");
const axios = require("axios");
const Product = require("../models/Product");

const router = express.Router();

const EMBEDDING_SERVER_URL =
	process.env.EMBEDDING_SERVER_URL || "http://localhost:7001";

router.post("/generate", async (req, res) => {
	try {
		const ids = Array.isArray(req.body.ids) ? req.body.ids : [];
		if (ids.length === 0) {
			return res.status(400).json({ error: "missing_ids" });
		}

		const products = await Product.find({ _id: { $in: ids } }).lean();
		if (products.length === 0) {
			return res.json({ count: 0, updated: 0 });
		}

		const payload = products.map((p) => ({
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
		return res.json({ count: embeddings.length, updated, model });
	} catch (err) {
		console.error("embedding generate error", err?.message || err);
		return res.status(500).json({ error: "embedding_generate_failed" });
	}
});

module.exports = router;
