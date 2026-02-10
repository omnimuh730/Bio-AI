const express = require("express");
const router = express.Router();
const Product = require("../models/Product");
const { fetchProductByBarcode } = require("../utils/openfood");

// Remote search (proxy to OpenFoodFacts) — must be before /:id to avoid param clash
router.get("/remote/search", async (req, res) => {
	try {
		const q = (req.query.q || "").trim();
		if (!q) return res.json({ total: 0, products: [] });
		const axios = require("axios");
		const base =
			process.env.OPENFOOD_BASE || "https://world.openfoodfacts.org";
		const url = `${base}/cgi/search.pl`;
		const page = parseInt(req.query.page || "1", 10);
		const pageSize = parseInt(req.query.pageSize || "20", 10);
		const resp = await axios.get(url, {
			params: {
				search_terms: q,
				page: page,
				page_size: pageSize,
				json: 1,
			},
			timeout: 60000,
		});
		const total = resp.data.count || 0;
		const products = (resp.data.products || []).map((p) => ({
			code: p.code,
			product_name: p.product_name || p.brands || "",
			brands: p.brands || "",
			categories: p.categories || [],
			image_url: p.image_small_url || p.image_url || null,
			nutriments: p.nutriments || {},
			tags: p._tags || [],
			remote: true,
			id: `remote:${p.code}`,
		}));
		res.json({ total, page, pageSize, products });
	} catch (err) {
		console.error("remote search error", err?.message || err);
		res.status(500).json({ error: "remote_search_failed" });
	}
});

// List products
router.get("/", async (req, res) => {
	try {
		const q = req.query.q || "";
		const page = parseInt(req.query.page || "1", 10);
		const pageSize = parseInt(req.query.pageSize || "50", 10);
		const filter = {};
		if (q) {
			filter.$or = [
				{ product_name: new RegExp(q, "i") },
				{ brands: new RegExp(q, "i") },
				{ code: new RegExp(q, "i") },
			];
		}
		const total = await Product.countDocuments(filter);
		const products = await Product.find(filter)
			.sort({ last_modified: -1 })
			.skip((page - 1) * pageSize)
			.limit(pageSize)
			.lean();
		// add `id` alias for frontend convenience
		const productsWithId = products.map((p) => ({ ...p, id: p._id }));
		res.json({ total, page, pageSize, products: productsWithId });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "server_error" });
	}
});

// Get by id
router.get("/:id", async (req, res) => {
	try {
		const p = await Product.findById(req.params.id).lean();
		if (!p) return res.status(404).json({ error: "not_found" });
		p.id = p._id;
		res.json(p);
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "server_error" });
	}
});

// Get by code
router.get("/code/:code", async (req, res) => {
	try {
		const p = await Product.findOne({ code: req.params.code }).lean();
		if (!p) return res.status(404).json({ error: "not_found" });
		p.id = p._id;
		res.json(p);
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "server_error" });
	}
});

// Import by barcode - upsert
router.post("/import", async (req, res) => {
	try {
		const barcode = req.body.barcode || req.query.barcode;
		if (!barcode) return res.status(400).json({ error: "missing_barcode" });
		const remote = await fetchProductByBarcode(barcode);
		if (!remote)
			return res.status(404).json({ error: "product_not_found_remote" });
		const doc = {
			code: remote.code,
			product_name: remote.product_name || remote.brands || "",
			brands: remote.brands || "",
			categories: remote.categories_tags || remote.categories || [],
			nutriscore_grade: remote.nutriscore_grade || null,
			nova_group: remote.nova_group || null,
			image_url: remote.image_small_url || remote.image_url || null,
			ingredients_text: remote.ingredients_text || "",
			nutriments: remote.nutriments || {},
			last_modified: remote.last_modified_t || Date.now(),
			tags: remote._tags || [],
		};
		const existing = await Product.findOne({ code: doc.code });
		let saved;
		if (existing) {
			Object.assign(existing, doc);
			saved = await existing.save();
		} else {
			saved = await Product.create(doc);
		}
		// normalize returned object
		saved = saved.toObject ? saved.toObject() : saved;
		saved.id = saved._id;
		res.json({ product: saved });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "server_error" });
	}
});

// Create product
router.post("/", async (req, res) => {
	try {
		const p = await Product.create(req.body);
		const out = p.toObject ? p.toObject() : p;
		out.id = out._id;
		res.status(201).json(out);
	} catch (err) {
		console.error(err);
		res.status(400).json({
			error: "validation_error",
			details: err.message,
		});
	}
});

// Update
router.patch("/:id", async (req, res) => {
	try {
		const p = await Product.findByIdAndUpdate(req.params.id, req.body, {
			new: true,
		}).lean();
		if (!p) return res.status(404).json({ error: "not_found" });
		p.id = p._id;
		res.json(p);
	} catch (err) {
		console.error(err);
		res.status(400).json({ error: "validation_error" });
	}
});

// Delete
router.delete("/:id", async (req, res) => {
	try {
		await Product.findByIdAndDelete(req.params.id);
		res.json({ ok: true });
	} catch (err) {
		console.error(err);
		res.status(500).json({ error: "server_error" });
	}
});

module.exports = router;
