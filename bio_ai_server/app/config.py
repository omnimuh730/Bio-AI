from pathlib import Path
import os
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent

# Support environment-specific .env files. Priority:
# 1. .env.{ENV} if it exists (where ENV defaults to "dev")
# 2. fallback to .env
ENV = os.getenv("ENV", "dev")
env_file = BASE_DIR / f".env.{ENV}"
if not env_file.exists():
    env_file = BASE_DIR / ".env"
load_dotenv(env_file)

DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{BASE_DIR / 'bio_ai_server.db'}")
# MongoDB (preferred): configure a MongoDB URI for dev/stage/prod
MONGODB_URI = os.getenv("MONGODB_URI", "mongodb://mongo:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB_NAME", "bio_ai_server_db")

UPLOAD_DIR = os.getenv("UPLOAD_DIR", str(BASE_DIR / "uploads"))
DEBUG = os.getenv("DEBUG", "true").lower() in ("1", "true", "yes")

# FatSecret Platform API configuration (from environment variables)
FATSECRET_CLIENT_ID = os.getenv("FATSECRET_CLIENT_ID")
FATSECRET_CLIENT_SECRET = os.getenv("FATSECRET_CLIENT_SECRET")
FATSECRET_BASE_URL = "https://platform.fatsecret.com/rest/server.api"
FATSECRET_TOKEN_URL = "https://oauth.fatsecret.com/connect/token"
FATSECRET_RECOGNITION_URL = "https://platform.fatsecret.com/rest/image-recognition/v2"
