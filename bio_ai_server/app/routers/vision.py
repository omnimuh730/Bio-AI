from fastapi import APIRouter, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import os
import time
import base64
import io
import json
import requests
from PIL import Image
from ..config import (
    UPLOAD_DIR,
    FATSECRET_CLIENT_ID,
    FATSECRET_CLIENT_SECRET,
    FATSECRET_BASE_URL,
    FATSECRET_TOKEN_URL,
    FATSECRET_RECOGNITION_URL,
)

router = APIRouter()

os.makedirs(UPLOAD_DIR, exist_ok=True)

# Token cache for FatSecret OAuth
_token_cache = {"token": None, "expires_at": 0}


def get_fatsecret_token():
    """Get OAuth token for FatSecret API with caching."""
    global _token_cache
    if _token_cache["token"] and time.time() < _token_cache["expires_at"]:
        return _token_cache["token"]

    try:
        payload = {
            "grant_type": "client_credentials",
            "scope": "basic premier barcode"
        }
        response = requests.post(
            FATSECRET_TOKEN_URL,
            auth=(FATSECRET_CLIENT_ID, FATSECRET_CLIENT_SECRET),
            data=payload
        )

        if response.status_code != 200:
            print("FatSecret Token Error:", response.text)
            return None

        data = response.json()
        _token_cache["token"] = data["access_token"]
        _token_cache["expires_at"] = time.time() + data["expires_in"] - 60
        return _token_cache["token"]
    except Exception as e:
        print(f"FatSecret Auth Exception: {e}")
        return None


def fatsecret_request(method: str, params: dict):
    """Make a request to FatSecret API."""
    token = get_fatsecret_token()
    if not token:
        return {"error": "Authentication failed"}

    headers = {"Authorization": f"Bearer {token}"}
    final_params = {"method": method, "format": "json"}
    final_params.update(params)

    # Remove empty params
    final_params = {k: v for k, v in final_params.items() if v is not None and v != ""}

    try:
        res = requests.get(FATSECRET_BASE_URL, headers=headers, params=final_params)
        if res.status_code != 200:
            return {"error": f"API Error {res.status_code}", "details": res.text}
        return res.json()
    except Exception as e:
        return {"error": str(e)}


class BarcodeRequest(BaseModel):
    barcode: str
    region: str = "US"


class SearchRequest(BaseModel):
    query: str
    max_results: int = 20


@router.post("/search")
async def search_food(request: SearchRequest):
    """Search for food items using FatSecret API."""
    return JSONResponse(content=fatsecret_request(
        "foods.search",
        {
            "search_expression": request.query,
            "max_results": request.max_results
        }
    ))


@router.post("/barcode")
async def lookup_barcode(request: BarcodeRequest):
    """
    Look up food by barcode using FatSecret API.
    
    FatSecret requires GTIN-13 format (13-digit barcode).
    Supports: UPC-A (12), EAN-13 (13), EAN-8 (8), UPC-E (6/8).
    All barcodes are converted to GTIN-13 for API compatibility.
    """
    print("=" * 80)
    print("🔍 BARCODE LOOKUP REQUEST RECEIVED")
    print("=" * 80)
    
    code = request.barcode.strip()
    print(f"📊 Step 1: Received barcode")
    print(f"   - Original barcode: {request.barcode!r}")
    print(f"   - Trimmed barcode: {code!r}")
    print(f"   - Length: {len(code)} characters")
    print(f"   - Region: {request.region}")
    print(f"   - Is numeric: {code.isdigit()}")

    # Convert various barcode formats to GTIN-13
    original_code = code
    conversion_applied = False
    
    if not code.isdigit():
        print(f"\n⚠️  Step 2: Barcode validation")
        print(f"   - Error: Barcode must contain only digits")
        print(f"   - Received: {code!r}")
        print("=" * 80)
        print()
        return JSONResponse(content={
            "error": "Invalid barcode format",
            "message": "Barcode must contain only numeric digits"
        })
    
    print(f"\n📐 Step 2: Barcode format conversion to GTIN-13")
    
    if len(code) == 13:
        # EAN-13 / GTIN-13 (already correct format)
        print(f"   - Format detected: EAN-13 / GTIN-13")
        print(f"   - Already in correct format: {code!r}")
        print(f"   - No conversion needed")
    elif len(code) == 12:
        # UPC-A → GTIN-13 (add leading zero)
        code = "0" + code
        conversion_applied = True
        print(f"   - Format detected: UPC-A (12 digits)")
        print(f"   - Conversion rule: Add '0' at front → GTIN-13")
        print(f"   - Original: {original_code!r}")
        print(f"   - Converted: {code!r}")
    elif len(code) == 8:
        # EAN-8 → GTIN-13 (pad with 5 leading zeros)
        code = "00000" + code
        conversion_applied = True
        print(f"   - Format detected: EAN-8 (8 digits)")
        print(f"   - Conversion rule: Add '00000' at front → GTIN-13")
        print(f"   - Original: {original_code!r}")
        print(f"   - Converted: {code!r}")
    elif len(code) == 6:
        # UPC-E → UPC-A → GTIN-13
        # Note: Full UPC-E expansion is complex; this is a simplified version
        print(f"   - Format detected: UPC-E (6 digits)")
        print(f"   - Warning: UPC-E conversion requires manufacturer code expansion")
        print(f"   - Attempting simple padding (may not work for all codes)")
        code = "0" + code + "00000"  # Simplified; real UPC-E needs proper expansion
        conversion_applied = True
        print(f"   - Original: {original_code!r}")
        print(f"   - Converted: {code!r} (experimental)")
    else:
        print(f"   - Format: Unknown ({len(code)} digits)")
        print(f"   - Supported formats: UPC-A(12), EAN-13(13), EAN-8(8), UPC-E(6)")
        print(f"   - Will attempt lookup with original barcode")

    print(f"\n🌐 Step 3: Calling FatSecret API")
    print(f"   - API Endpoint: {FATSECRET_BASE_URL}")
    print(f"   - Method: food.find_id_for_barcode.v2")
    print(f"   - Barcode (GTIN-13): {code}")
    print(f"   - Region: {request.region}")
    print(f"   - Conversion applied: {conversion_applied}")
    
    result = fatsecret_request(
        "food.find_id_for_barcode.v2",
        {
            "barcode": code,
            "region": request.region
        }
    )

    print(f"\n✅ Step 4: FatSecret API Response")
    print(f"\n📄 FULL RAW RESPONSE DATA:")
    print("=" * 80)
    try:
        # Pretty print the full JSON response
        print(json.dumps(result, indent=2, ensure_ascii=False))
    except Exception as e:
        # Fallback to regular print if JSON formatting fails
        print(f"   (JSON formatting failed: {e})")
        print(f"   Raw data: {result}")
    print("=" * 80)
    
    # Check for various error formats
    is_error = False
    if isinstance(result, dict):
        # Check for direct error key
        if "error" in result:
            is_error = True
            error_info = result["error"]
            print(f"\n   - Status: ❌ ERROR")
            
            if isinstance(error_info, dict):
                print(f"   - Error Code: {error_info.get('code', 'N/A')}")
                print(f"   - Error Message: {error_info.get('message', 'N/A')}")
            else:
                print(f"   - Error: {error_info}")
            
            if "details" in result:
                print(f"   - Details: {result.get('details')}")
            
            # Provide helpful context for common errors
            if isinstance(error_info, dict) and error_info.get('code') == 211:
                print(f"\n   💡 Troubleshooting:")
                print(f"      - Error 211: No food item found for this barcode")
                print(f"      - This barcode may not exist in the FatSecret database")
                print(f"      - Verify the barcode is correct and matches the region")
                print(f"      - FatSecret database is country-specific (region: {request.region})")
        # Check if response itself is successful
        elif "food_id" in result or "food" in result:
            print(f"\n   - Status: ✅ SUCCESS")
            if "food_id" in result:
                food_id = result.get("food_id", {})
                if isinstance(food_id, dict):
                    print(f"   - Food ID: {food_id.get('value', 'N/A')}")
                else:
                    print(f"   - Food ID: {food_id}")
            
            if "food" in result:
                food = result.get("food", {})
                print(f"   - Food Name: {food.get('food_name', 'N/A')}")
                print(f"   - Brand: {food.get('brand_name', 'N/A')}")
                
                # Show serving info if available
                servings = food.get("servings", {})
                if servings and "serving" in servings:
                    serving = servings["serving"]
                    if isinstance(serving, list) and len(serving) > 0:
                        serving = serving[0]
                    if isinstance(serving, dict):
                        print(f"   - Serving: {serving.get('serving_description', 'N/A')}")
                        print(f"   - Calories: {serving.get('calories', 'N/A')} kcal")
        else:
            print(f"\n   - Status: UNKNOWN")
            print(f"   - Response keys: {list(result.keys())}")
    else:
        print(f"\n   - Status: UNEXPECTED RESPONSE TYPE")
        print(f"   - Response type: {type(result)}")
    
    print("=" * 80)
    print()

    return JSONResponse(content=result)


@router.post("/recognize")
async def recognize_image(file: UploadFile = File(...)):
    """
    Recognize food in an uploaded image using FatSecret Image Recognition API.
    """
    token = get_fatsecret_token()
    if not token:
        raise HTTPException(status_code=401, detail="Authentication failed")

    try:
        # Read and process image
        img = Image.open(file.file)
        if img.mode in ("RGBA", "P"):
            img = img.convert("RGB")
        img.thumbnail((512, 512))

        # Convert to base64
        buffer = io.BytesIO()
        img.save(buffer, format="JPEG", quality=85)
        buffer.seek(0)
        image_data = buffer.read()
        base64_encoded = base64.b64encode(image_data).decode('utf-8')

        # Call FatSecret recognition API
        payload = {
            "image_b64": base64_encoded,
            "include_food_data": True,
            "region": "US",
            "language": "en"
        }

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

        res = requests.post(FATSECRET_RECOGNITION_URL, headers=headers, json=payload)

        if res.status_code != 200:
            raise HTTPException(
                status_code=res.status_code,
                detail=f"FatSecret API error: {res.text}"
            )

        return JSONResponse(content=res.json())

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/upload")
async def upload_vision(file: UploadFile = File(...)):
    """
    Upload an image and recognize food using FatSecret.
    Saves file locally and returns recognition results.
    """
    try:
        # Save uploaded file
        out_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(out_path, "wb") as f:
            content = await file.read()
            f.write(content)

        # Reset file pointer and recognize
        await file.seek(0)
        token = get_fatsecret_token()
        if not token:
            return JSONResponse(
                content={"status": "saved", "file": out_path, "recognition": None}
            )

        # Process image for recognition
        img = Image.open(io.BytesIO(content))
        if img.mode in ("RGBA", "P"):
            img = img.convert("RGB")
        img.thumbnail((512, 512))

        buffer = io.BytesIO()
        img.save(buffer, format="JPEG", quality=85)
        buffer.seek(0)
        image_data = buffer.read()
        base64_encoded = base64.b64encode(image_data).decode('utf-8')

        payload = {
            "image_b64": base64_encoded,
            "include_food_data": True,
            "region": "US",
            "language": "en"
        }

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

        res = requests.post(FATSECRET_RECOGNITION_URL, headers=headers, json=payload)

        recognition_result = res.json() if res.status_code == 200 else None

        return JSONResponse(content={
            "status": "processed",
            "file": out_path,
            "recognition": recognition_result
        })

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/autocomplete")
async def autocomplete(q: str):
    """Autocomplete food names using FatSecret API."""
    return JSONResponse(content=fatsecret_request(
        "foods.autocomplete.v2",
        {"expression": q}
    ))


@router.get("/health")
def vision_health():
    """Check FatSecret API connectivity and configuration."""
    token = get_fatsecret_token()
    return {
        "ok": token is not None,
        "fatsecret_configured": bool(FATSECRET_CLIENT_ID and FATSECRET_CLIENT_SECRET),
        "token_valid": token is not None,
    }

