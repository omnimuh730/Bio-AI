import os
import httpx
from typing import Optional

FATSECRET_BASE = os.environ.get("FATSECRET_BASE", "https://platform.fatsecret.com")
FATSECRET_CLIENT_ID = os.environ.get("FATSECRET_CLIENT_ID")
FATSECRET_CLIENT_SECRET = os.environ.get("FATSECRET_CLIENT_SECRET")

class FatSecretError(RuntimeError):
    pass


async def lookup_barcode(barcode: str) -> dict:
    """Lookup product metadata by barcode via FatSecret Platform API.
    Returns a normalized dict or raises FatSecretError on failure.
    This function expects that proper credentials are present in env.
    """
    if not FATSECRET_CLIENT_ID or not FATSECRET_CLIENT_SECRET:
        raise FatSecretError("FatSecret credentials not configured")

    async with httpx.AsyncClient(timeout=10.0) as client:
        # NOTE: The real FatSecret API may use OAuth2; this is a simplified example.
        url = f"{FATSECRET_BASE}/food/get_by_barcode"
        params = {"barcode": barcode}
        headers = {"Accept": "application/json"}
        r = await client.get(url, params=params, headers=headers, auth=(FATSECRET_CLIENT_ID, FATSECRET_CLIENT_SECRET))
        if r.status_code != 200:
            raise FatSecretError(f"FatSecret lookup failed: {r.status_code}")
        data = r.json()

    # normalize data (example mapping)
    item = {
        "external_source_id": f"fatsecret:{barcode}",
        "name": data.get("name") or data.get("food_name") or "Unknown",
        "brand": data.get("brand") or None,
        "serving_size": data.get("serving_size") or None,
        "macros_per_100g": data.get("macros") or {},
        "source": "fatsecret",
        "for_ml_training": True,
        "provenance": {"retrieved_at": __import__("datetime").datetime.utcnow().isoformat(), "confidence": data.get("confidence", 0.9)},
    }
    return item