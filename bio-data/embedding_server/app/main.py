import os
from typing import Any, Dict, List, Optional

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer

app = FastAPI(title="Bio Data Embedding Server")

MODEL_NAME = os.getenv("EMBEDDING_MODEL", "intfloat/e5-large-v2")
MODEL_PREFIX = os.getenv("EMBEDDING_PREFIX", "passage: ")

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

	name_texts = [_build_name_desc(p) for p in payload.products]
	ingredient_texts = [_build_ingredients(p) for p in payload.products]
	nutrition_texts = [_build_nutrition(p) for p in payload.products]

	name_vectors = model.encode(name_texts, normalize_embeddings=True)
	ingredient_vectors = model.encode(ingredient_texts, normalize_embeddings=True)
	nutrition_vectors = model.encode(nutrition_texts, normalize_embeddings=True)

	out: List[EmbeddingOut] = []
	for idx, product in enumerate(payload.products):
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
