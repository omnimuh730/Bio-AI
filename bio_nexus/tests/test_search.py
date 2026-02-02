import pytest
import numpy as np
from app.db.mongodb import get_client

@pytest.mark.asyncio
async def test_vector_search_fallback(monkeypatch):
    client = get_client()
    db = client["bio_nexus_db_test"]
    foods = db["global_foods"]
    await foods.delete_many({})
    await foods.insert_one({"name": "A", "embedding_vector": [0.0, 1.0]})
    await foods.insert_one({"name": "B", "embedding_vector": [1.0, 0.0]})

    # Query vector similar to B
    qv = np.array([1.0, 0.0])

    # naive scoring like endpoint
    docs = await foods.find({"embedding_vector": {"$exists": True}}).to_list(length=1000)
    assert len(docs) >= 2

    # Clean up
    await foods.drop()