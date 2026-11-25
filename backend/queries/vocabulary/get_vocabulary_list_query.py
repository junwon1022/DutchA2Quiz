from pydantic import BaseModel


class GetVocabularyListQuery(BaseModel):
    level: str | None = None
    search: str | None = None