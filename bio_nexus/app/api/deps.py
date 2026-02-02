from app.db.mongodb import get_db

# Small helpers for dependency injection

def get_db_dep():
    return get_db()

# Backwards compatibility: other modules import ..deps.get_db
from app.db.mongodb import get_db