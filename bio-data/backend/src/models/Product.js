const mongoose = require("mongoose");

const NutrimentsSchema = new mongoose.Schema({}, { strict: false });

const ProductSchema = new mongoose.Schema(
	{
		code: { type: String, index: true, unique: true, required: true },
		product_name: String,
		brands: String,
		categories: [String],
		mappedCategory: String,
		nutriscore_grade: String,
		nova_group: Number,
		image_url: String,
		ingredients_text: String,
		nutriments: { type: Object },
		last_modified: { type: Number },
		status: { type: String, default: "active" },
		tags: [String],
		quality_score: Number,
		embeddings: {
			model: String,
			name_desc: [Number],
			ingredients: [Number],
			nutrition: [Number],
			updated_at: Date,
		},
	},
	{ timestamps: true },
);

module.exports = mongoose.model("Product", ProductSchema);
