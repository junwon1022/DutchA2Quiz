from fastapi import APIRouter, Depends

from supabase import create_client, Client
import streamlit as st

from backend.queries.vocabulary.get_vocabulary_list_query import (
    GetVocabularyListQuery
)
from backend.queries.vocabulary.get_vocabulary_list_query_handler import (
    GetVocabularyListHandler
)
from backend.repositories.vocabulary_repository import (
    VocabularyRepository
)
from backend.schemas.common import ApiResponse


router = APIRouter(
    prefix="/api/vocabulary",
    tags=["Vocabulary"]
)


def get_supabase_client() -> Client:
    return create_client(
        st.secrets["supabase"]["url"],
        st.secrets["supabase"]["key"]
    )


def get_vocabulary_handler(
    supabase: Client = Depends(get_supabase_client)
) -> GetVocabularyListHandler:

    repository = VocabularyRepository(supabase)

    return GetVocabularyListHandler(repository)


@router.get("/", response_model=ApiResponse[list[dict]])
def get_vocabulary_list(
    level: str | None = None,
    search: str | None = None,
    handler: GetVocabularyListHandler = Depends(get_vocabulary_handler)
):
    query = GetVocabularyListQuery(
        level=level,
        search=search
    )

    result = handler.handle(query)

    return ApiResponse(
        success=True,
        message="Vocabulary retrieved successfully.",
        data=result
    )