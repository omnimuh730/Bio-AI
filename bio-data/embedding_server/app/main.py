import os
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer

app = FastAPI(title="Bio Data Embedding Server")

MODEL_NAME = os.getenv("EMBEDDING_MODEL", "intfloat/e5-large-v2")
MODEL_PREFIX = os.getenv("EMBEDDING_PREFIX", "passage: ")
BATCH_SIZE = int(os.getenv("EMBEDDING_BATCH_SIZE", "32"))

model: Optional[SentenceTransformer] = None


class ProductIn(BaseModel):
	id: str
	product_name: Optional[str] = ""
	categories: Optional[List[str]] = None
	ingredients_text: Optional[str] = ""
	nutriments: Optional[Dict[str, Any]] = None
	nova_group: Optional[int] = None


class GenerateRequest(BaseModel):
	products: List[ProductIn]


class EmbeddingOut(BaseModel):
	id: str
	embeddings: Dict[str, List[float]]


class GenerateResponse(BaseModel):
	model: str
	count: int
	embeddings: List[EmbeddingOut]


@app.on_event("startup")
def load_model() -> None:
	global model
	model = SentenceTransformer(MODEL_NAME)


def _to_float(value: Any) -> Optional[float]:
	if value is None:
		return None
	if isinstance(value, (int, float)):
		return float(value)
	try:
		return float(str(value))
	except (ValueError, TypeError):
		return None


def _get_nutriment(nutriments: Dict[str, Any], key: str, default: float = 0.0) -> float:
	value = _to_float(nutriments.get(key))
	return value if value is not None else default


def _build_name_desc(product: ProductIn) -> str:
	name = product.product_name or ""
	categories = product.categories or []
	category_text = " ".join([c for c in categories if c])
	parts = [p for p in [name, category_text] if p]
	text = ". ".join(parts) + "."
	return f"{MODEL_PREFIX}{text}".strip()


def _build_ingredients(product: ProductIn) -> str:
	ingredients = product.ingredients_text or ""
	text = f"Ingredients: {ingredients}." if ingredients else "Ingredients: ."
	return f"{MODEL_PREFIX}{text}".strip()


def _build_nutrition(product: ProductIn) -> str:
	nutriments = product.nutriments or {}
	energy_kcal = _get_nutriment(nutriments, "energy-kcal_100g")
	if energy_kcal == 0.0:
		energy_kcal = _get_nutriment(nutriments, "energy_100g")
	fat = _get_nutriment(nutriments, "fat_100g")
	carbs = _get_nutriment(nutriments, "carbohydrates_100g")
	protein = _get_nutriment(nutriments, "proteins_100g")
	sugars = _get_nutriment(nutriments, "sugars_100g")
	fiber = _get_nutriment(nutriments, "fiber_100g")
	salt = _get_nutriment(nutriments, "salt_100g")
	calcium = _get_nutriment(nutriments, "calcium_100g")
	nova_group = product.nova_group if product.nova_group is not None else 0
	text = (
		"Per 100 g: "
		f"{energy_kcal} kcal, "
		f"{fat} g fat, "
		f"{carbs} g carbohydrates, "
		f"{protein} g proteins, "
		f"{sugars} g sugars, "
		f"{fiber} g fiber, "
		f"{salt} g salt, "
		f"{calcium} g calcium. "
		f"NOVA group {nova_group}."
	)
	return f"{MODEL_PREFIX}{text}".strip()


@app.get("/health")
def health() -> Dict[str, str]:
	return {"ok": "true"}


@app.post("/embeddings/generate", response_model=GenerateResponse)
async def generate_embeddings(payload: GenerateRequest) -> GenerateResponse:
	if model is None:
		raise HTTPException(status_code=503, detail="model_not_loaded")
	if not payload.products:
		raise HTTPException(status_code=400, detail="missing_products")

	# Process inputs in chunks and encode combined texts (one call per chunk) to maximize throughput
	CHUNK_SIZE = int(os.getenv("EMBEDDING_CHUNK_SIZE", "256"))
	import asyncio
	from functools import partial
	loop = asyncio.get_running_loop()
	encode_fn = lambda texts: model.encode(texts, normalize_embeddings=True, batch_size=BATCH_SIZE)

	out: List[EmbeddingOut] = []
	# chunk payload.products to limit memory usage for very large requests
	for i in range(0, len(payload.products), CHUNK_SIZE):
		chunk = payload.products[i : i + CHUNK_SIZE]
		m = len(chunk)
		name_texts = [_build_name_desc(p) for p in chunk]
		ingredient_texts = [_build_ingredients(p) for p in chunk]
		nutrition_texts = [_build_nutrition(p) for p in chunk]

		# Combine lists and encode once per chunk
		combined_texts = name_texts + ingredient_texts + nutrition_texts
		vectors = await loop.run_in_executor(None, partial(encode_fn, combined_texts))

		# Split into the three groups
		name_vectors = vectors[0:m]
		ingredient_vectors = vectors[m : 2 * m]
		nutrition_vectors = vectors[2 * m : 3 * m]

		for idx, product in enumerate(chunk):
			out.append(
				EmbeddingOut(
					id=product.id,
					embeddings={
						"name_desc": [float(v) for v in name_vectors[idx]],
						"ingredients": [float(v) for v in ingredient_vectors[idx]],
						"nutrition": [float(v) for v in nutrition_vectors[idx]],
					},
				)
			)

	return GenerateResponse(model=MODEL_NAME, count=len(out), embeddings=out)
