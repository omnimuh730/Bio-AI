from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent

DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{BASE_DIR / 'bio_ai_server.db'}")
UPLOAD_DIR = os.getenv("UPLOAD_DIR", str(BASE_DIR / "uploads"))
DEBUG = os.getenv("DEBUG", "true").lower() in ("1", "true", "yes")

# FatSecret Platform API configuration (from environment variables)
FATSECRET_CLIENT_ID = os.getenv("FATSECRET_CLIENT_ID")
FATSECRET_CLIENT_SECRET = os.getenv("FATSECRET_CLIENT_SECRET")
FATSECRET_BASE_URL = "https://platform.fatsecret.com/rest/server.api"
FATSECRET_TOKEN_URL = "https://oauth.fatsecret.com/connect/token"
FATSECRET_RECOGNITION_URL = "https://platform.fatsecret.com/rest/image-recognition/v2"
