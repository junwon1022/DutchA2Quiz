from backend.queries.vocabulary.get_vocabulary_list_query import (
    GetVocabularyListQuery
)


class GetVocabularyListHandler:

    def handle(self, query: GetVocabularyListQuery):
        # TODO: Repository를 통해 실제 데이터 조회
        return []