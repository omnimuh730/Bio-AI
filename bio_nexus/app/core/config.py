from pydantic import BaseSettings, Field
from typing import Literal

class Settings(BaseSettings):
    app_name: str = "bio_nexus"
    env: Literal["dev", "stage", "prod"] = Field("dev", env="ENV")
    mongo_uri: str = Field(..., env="MONGODB_URI")
    mongo_db: str = Field("bio_nexus_db", env="MONGO_DB_NAME")
    log_level: str = Field("info", env="LOG_LEVEL")
    
    # S3 Storage settings (merged from bio_storage)
    s3_endpoint_url: str | None = Field(None, env="S3_ENDPOINT_URL")
    s3_access_key: str | None = Field(None, env="AWS_ACCESS_KEY_ID")
    s3_secret_key: str | None = Field(None, env="AWS_SECRET_ACCESS_KEY")
    s3_region: str = Field("us-east-1", env="AWS_REGION")
    s3_bucket_hot: str = Field("bio-storage-hot", env="BUCKET_HOT")
    s3_bucket_archive: str = Field("bio-storage-archive", env="BUCKET_ARCHIVE")
    archive_threshold_days: int = Field(30, env="ARCHIVE_THRESHOLD_DAYS")

    class Config:
        env_file = "../../.env"

settings = Settings()