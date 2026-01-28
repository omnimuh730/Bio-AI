from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent

DATABASE_URL = os.getenv("DATABASE_URL", f"sqlite:///{BASE_DIR / 'bio_ai_server.db'}")
UPLOAD_DIR = os.getenv("UPLOAD_DIR", str(BASE_DIR / "uploads"))
DEBUG = os.getenv("DEBUG", "true").lower() in ("1", "true", "yes")
