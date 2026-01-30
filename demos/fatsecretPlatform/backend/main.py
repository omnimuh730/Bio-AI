from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import base64
import time
import io
from PIL import Image # Requires: pip install Pillow
import os
from dotenv import load_dotenv  # Requires: pip install python-dotenv


app = Flask(__name__)
# Allow CORS for localhost:3000
CORS(app, resources={r"/api/*": {"origins": "*"}})

# --- CONFIGURATION ---
# Load credentials from backend/.env (use .env.example as template)
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

CLIENT_ID = os.getenv('CLIENT_ID')
CLIENT_SECRET = os.getenv('CLIENT_SECRET')

if not CLIENT_ID or not CLIENT_SECRET:
    raise RuntimeError("CLIENT_ID and CLIENT_SECRET must be set in backend/.env or environment variables.")

BASE_URL = "https://platform.fatsecret.com/rest/server.api"
TOKEN_URL = "https://oauth.fatsecret.com/connect/token"
RECOGNITION_V2_URL = "https://platform.fatsecret.com/rest/image-recognition/v2"

_token_cache = {"token": None, "expires_at": 0}

def get_token():
    global _token_cache
    if _token_cache["token"] and time.time() < _token_cache["expires_at"]:
        return _token_cache["token"]
    
    try:
        # Added 'localization' to scope for region-specific barcode/recipe searches
        payload = {
            "grant_type": "client_credentials", 
            "scope": "basic premier barcode" 
        }
        response = requests.post(TOKEN_URL, auth=(CLIENT_ID, CLIENT_SECRET), data=payload)
        
        if response.status_code != 200:
            print("Token Error:", response.text)
            return None
            
        data = response.json()
        _token_cache["token"] = data["access_token"]
        _token_cache["expires_at"] = time.time() + data["expires_in"] - 60
        return _token_cache["token"]
    except Exception as e:
        print(f"Auth Exception: {e}")
        return None

def fs_request(method, params):
    token = get_token()
    if not token:
        return {"error": "Authentication failed"}
    
    headers = {"Authorization": f"Bearer {token}"}
    final_params = {"method": method, "format": "json"}
    final_params.update(params)
    
    # Remove empty params
    final_params = {k: v for k, v in final_params.items() if v is not None and v != ""}

    try:
        res = requests.get(BASE_URL, headers=headers, params=final_params)
        if res.status_code != 200:
            return {"error": f"API Error {res.status_code}", "details": res.text}
        return res.json()
    except Exception as e:
        return {"error": str(e)}

# --- ROUTES ---

@app.route('/api/search', methods=['GET'])
def search_food():
    term = request.args.get('q')
    return jsonify(fs_request("foods.search", {
        "search_expression": term, 
        "max_results": 20
    }))

@app.route('/api/autocomplete', methods=['GET'])
def autocomplete():
    term = request.args.get('q')
    return jsonify(fs_request("foods.autocomplete.v2", {"expression": term}))

@app.route('/api/barcode', methods=['GET'])
def barcode():
    code = request.args.get('code', '')
    region = request.args.get('region', 'US')

    # FIX: FatSecret requires GTIN-13.
    # If code is UPC-A (12 digits), pad with leading zero.
    if len(code) == 12 and code.isdigit():
        code = "0" + code

    # FIX: Correct method name is food.find_id_for_barcode.v2
    return jsonify(fs_request("food.find_id_for_barcode.v2", {
        "barcode": code,
        "region": region
    }))

@app.route('/api/recipes', methods=['GET'])
def search_recipes():
    params = {
        "search_expression": request.args.get('q'),
        "recipe_types": request.args.get('type'), 
        "must_have_images": request.args.get('images'),
        "region": request.args.get('region'),
        
        "calories.from": request.args.get('cal_min'),
        "calories.to": request.args.get('cal_max'),
        "carb_percentage.from": request.args.get('carb_min'),
        "carb_percentage.to": request.args.get('carb_max'),
        "protein_percentage.from": request.args.get('prot_min'),
        "protein_percentage.to": request.args.get('prot_max'),
        "fat_percentage.from": request.args.get('fat_min'),
        "fat_percentage.to": request.args.get('fat_max'),
    }
    return jsonify(fs_request("recipes.search.v3", params))

@app.route('/api/nlp', methods=['GET'])
def nlp_search():
    # Using foods.search V4 as a proxy for NLP-like capability
    term = request.args.get('q')
    return jsonify(fs_request("foods.search", {
        "search_expression": term,
        "max_results": 10
    }))

@app.route('/api/recognize', methods=['POST'])
def recognize_image():
    if 'image' not in request.files: 
        return jsonify({"error": "No image uploaded"}), 400
    
    file = request.files['image']
    token = get_token()
    if not token:
        return jsonify({"error": "Authentication failed"}), 401

    try:
        img = Image.open(file)
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

        res = requests.post(RECOGNITION_V2_URL, headers=headers, json=payload)
        return jsonify(res.json()), res.status_code

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)