# Bio Data Backend

Simple Node/Express backend for storing OpenFoodFacts products in a local MongoDB and serving them to the provider frontend.

Quick start

1. Copy `.env.example` to `.env` and adjust `MONGODB_URI` (default `mongodb://localhost:27017/eatsy`).
2. Install deps: `npm install` (or `yarn`)
3. Run dev: `npm run dev` (requires `nodemon`)

Endpoints

- GET `/api/products` - list (supports `q`, `page`, `pageSize`)
- GET `/api/products/:id` - get by Mongo id
- GET `/api/products/code/:code` - get by barcode
- POST `/api/products/import` - body `{ "barcode": "..." }` import from OpenFoodFacts and upsert
- POST `/api/products` - create product
- PATCH `/api/products/:id` - update
- DELETE `/api/products/:id` - delete

Notes

This project is intentionally small and starter-focused. Add auth, validation and rate-limits for production use.
