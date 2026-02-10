require("dotenv").config();
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const mongoose = require("mongoose");

const productsRouter = require("./routes/products");
const embeddingsRouter = require("./routes/embeddings");

const PORT = process.env.PORT || 4000;
const MONGODB_URI =
	process.env.MONGODB_URI ||
	"mongodb+srv://eatsy:Test.1234!@eatsy-cluster.kplwbvn.mongodb.net/eatsy";
const CORS_ORIGINS = (
	process.env.CORS_ORIGINS || "http://localhost:5173,http://localhost:8011"
).split(",");

async function main() {
	await mongoose.connect(MONGODB_URI, { dbName: "eatsy" });
	const app = express();
	app.use(cors({ origin: CORS_ORIGINS }));
	app.use(morgan("dev"));
	app.use(express.json());

	app.use("/api/products", productsRouter);
	app.use("/api/embeddings", embeddingsRouter);

	app.get("/health", (req, res) => res.json({ ok: true }));

	app.listen(PORT, () => {
		console.log(`backend listening on http://localhost:${PORT}`);
	});
}

main().catch((err) => {
	console.error("Failed to start", err);
	process.exit(1);
});
