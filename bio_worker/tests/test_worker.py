import pytest
import asyncio
from unittest.mock import AsyncMock
from app.worker import process_health_point

@pytest.mark.asyncio
async def test_process_health_point_calls_insert_one(mocker):
    fake_coll = AsyncMock()
    db = AsyncMock()
    db.get_collection.return_value = fake_coll

    point = {"user_id": "u1", "timestamp": "2026-02-02T00:00:00Z", "sensor_type": "HR", "measurements": {"hr": 70}}

    await process_health_point(point, db)

    fake_coll.insert_one.assert_awaited_once()
    args = fake_coll.insert_one.await_args.args[0]
    assert args["metadata"]["user_id"] == "u1"
    assert args["measurements"]["hr"] == 70