# React + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) uses [Babel](https://babeljs.io/) (or [oxc](https://oxc.rs) when used in [rolldown-vite](https://vite.dev/guide/rolldown)) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## React Compiler

The React Compiler is currently not compatible with SWC. See [this issue](https://github.com/vitejs/vite-plugin-react/issues/428) for tracking the progress.

## Expanding the ESLint configuration

If you are developing a production application, we recommend using TypeScript with type-aware lint rules enabled. Check out the [TS template](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) for information on how to integrate TypeScript and [`typescript-eslint`](https://typescript-eslint.io) in your project.

---

## Local backend for OpenFoodFacts sync 🔧

This project can be used with the small backend located in `../backend` which:

- imports products from OpenFoodFacts by barcode and stores them in a local MongoDB
- serves product list and CRUD endpoints to the frontend

Quick start:

1. cd `bio-data/backend`
2. copy `.env.example` → `.env` and confirm `MONGODB_URI` (default `mongodb://localhost:27017/eatsy`)
3. `npm install` (or `yarn`)
4. `npm run dev` to start the backend on port `4000`

The provider frontend calls `http://localhost:4000/api/products` and provides a small import box in the header to import by barcode.
