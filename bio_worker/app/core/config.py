from pydantic import BaseSettings, Field
from typing import Literal

class Settings(BaseSettings):
    env: Literal["dev", "stage", "prod"] = Field("dev", env="ENV")
    redis_url: str = Field("redis://redis:6379/0", env="REDIS_URL")
    mongo_uri: str = Field("mongodb://mongo:27017", env="MONGODB_URI")
    mongo_db: str = Field("bio_nexus_db", env="MONGO_DB_NAME")
    worker_group: str = Field("bio_worker_group", env="WORKER_GROUP")
    # S3 / Archive settings
    s3_endpoint_url: str = Field("http://minio:9000", env="S3_ENDPOINT_URL")
    s3_access_key: str = Field(None, env="AWS_ACCESS_KEY_ID")
    s3_secret_key: str = Field(None, env="AWS_SECRET_ACCESS_KEY")
    s3_region: str = Field("us-east-1", env="AWS_REGION")
    s3_bucket_hot: str = Field("bio-ai-hot", env="BUCKET_HOT")
    s3_bucket_archive: str = Field("bio-ai-archive", env="BUCKET_ARCHIVE")
    archive_threshold_days: int = Field(30, env="ARCHIVE_THRESHOLD_DAYS")
    retention_days: int = Field(90, env="RETENTION_DAYS")
    # Metrics
    metrics_port: int = Field(8001, env="METRICS_PORT")

    class Config:
        env_file = "../../.env"

settings = Settings()