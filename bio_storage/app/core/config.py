from pydantic import BaseSettings, Field
from typing import Literal

class Settings(BaseSettings):
    env: Literal["dev", "stage", "prod"] = Field("dev", env="ENV")
    # Mongo
    mongo_uri: str = Field("mongodb://mongo:27017", env="MONGODB_URI")
    mongo_db: str = Field("bio_storage_db", env="MONGO_DB_NAME")
    # S3
    s3_endpoint_url: str | None = Field(None, env="S3_ENDPOINT_URL")
    s3_access_key: str | None = Field(None, env="AWS_ACCESS_KEY_ID")
    s3_secret_key: str | None = Field(None, env="AWS_SECRET_ACCESS_KEY")
    s3_region: str = Field("us-east-1", env="AWS_REGION")
    s3_bucket_hot: str = Field("bio-storage-hot", env="BUCKET_HOT")
    s3_bucket_archive: str = Field("bio-storage-archive", env="BUCKET_ARCHIVE")

    class Config:
        env_file = "../../.env"

settings = Settings()