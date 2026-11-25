from backend.queries.vocabulary.get_vocabulary_list_query import (
    GetVocabularyListQuery
)
from backend.repositories.vocabulary_repository import VocabularyRepository


class GetVocabularyListHandler:

    def __init__(self, repository: VocabularyRepository):
        self.repository = repository

    def handle(self, query: GetVocabularyListQuery):
        return self.repository.get_vocabulary_list(
            level=query.level,
            search=query.search
        )