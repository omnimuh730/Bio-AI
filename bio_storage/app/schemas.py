from pydantic import BaseModel
from typing import Optional

class FileMeta(BaseModel):
    id: str
    filename: str
    content_type: Optional[str]
    key: str
    bucket: str
    archived: bool = False
