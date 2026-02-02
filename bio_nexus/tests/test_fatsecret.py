import respx
import pytest
from app.services.fatsecret import lookup_barcode, FatSecretError

@respx.mock
@pytest.mark.asyncio
async def test_lookup_barcode_success(respx_mock):
    url = "https://platform.fatsecret.com/food/get_by_barcode"
    respx_mock.get(url).respond(200, json={"name": "Test Food", "brand": "TF", "macros": {"kcal": 100}})

    item = await lookup_barcode("0123456789")
    assert item["name"] == "Test Food"
    assert item["source"] == "fatsecret"


@respx.mock
@pytest.mark.asyncio
async def test_lookup_barcode_no_creds(monkeypatch):
    # Temporarily ensure credentials not set
    monkeypatch.delenv("FATSECRET_CLIENT_ID", raising=False)
    monkeypatch.delenv("FATSECRET_CLIENT_SECRET", raising=False)
    with pytest.raises(FatSecretError):
        await lookup_barcode("000")