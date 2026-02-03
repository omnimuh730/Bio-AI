# Database shim for MongoDB migration
from typing import Generator
from app.db.mongodb import get_db as get_mongo_db


def init_db():
    # No-op for MongoDB
    return None


def get_session():
    """Compatibility dependency used by some routers. Returns the Motor database instance."""
    db = get_mongo_db()
    try:
        yield db
    finally:
        pass


def get_db():
    """Preferred dependency returning the Motor database instance."""
    return get_mongo_db()
