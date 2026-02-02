"""Initialize MongoDB collections and indexes for local development"""
import os
from pymongo import MongoClient

MONGO_URI = os.environ.get("MONGODB_URI", "mongodb://localhost:27017")
DB_NAME = os.environ.get("MONGO_DB_NAME", "bio_nexus_db")

client = MongoClient(MONGO_URI)
db = client[DB_NAME]

print("Collections before:", db.list_collection_names())

if "health_metrics" not in db.list_collection_names():
    db.create_collection("health_metrics", timeseries={"timeField": "timestamp", "metaField": "metadata", "granularity": "minutes"})
    print("Created time-series collection: health_metrics")

foods = db["global_foods"]
foods.create_index([("name", "text")])
foods.create_index([("external_source_id", 1)], unique=True)

print("Init complete. Collections:", db.list_collection_names())