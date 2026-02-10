const axios = require("axios");
const BASE = process.env.OPENFOOD_BASE || "https://world.openfoodfacts.org";

async function fetchProductByBarcode(barcode) {
	const url = `${BASE}/api/v0/product/${barcode}.json`;
	const res = await axios.get(url, { timeout: 8000 });
	if (res.data && res.data.status === 1) {
		return res.data.product;
	}
	return null;
}

module.exports = { fetchProductByBarcode };
