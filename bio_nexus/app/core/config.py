from pydantic import BaseSettings, Field
from typing import Literal

class Settings(BaseSettings):
    app_name: str = "bio_nexus"
    env: Literal["dev", "stage", "prod"] = Field("dev", env="ENV")
    mongo_uri: str = Field(..., env="MONGODB_URI")
    mongo_db: str = Field("bio_nexus_db", env="MONGO_DB_NAME")
    log_level: str = Field("info", env="LOG_LEVEL")

    class Config:
        env_file = "../../.env"

settings = Settings()