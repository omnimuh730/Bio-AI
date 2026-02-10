require("dotenv").config();
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const mongoose = require("mongoose");

const productsRouter = require("./routes/products");

const PORT = process.env.PORT || 4000;
const MONGODB_URI =
	process.env.MONGODB_URI || "mongodb://localhost:27017/bio_data";
const CORS_ORIGINS = (
	process.env.CORS_ORIGINS || "http://localhost:5173,http://localhost:8011"
).split(",");

async function main() {
	await mongoose.connect(MONGODB_URI, { dbName: "bio_data" });
	const app = express();
	app.use(cors({ origin: CORS_ORIGINS }));
	app.use(morgan("dev"));
	app.use(express.json());

	app.use("/api/products", productsRouter);

	app.get("/health", (req, res) => res.json({ ok: true }));

	app.listen(PORT, () => {
		console.log(`backend listening on http://localhost:${PORT}`);
	});
}

main().catch((err) => {
	console.error("Failed to start", err);
	process.exit(1);
});
