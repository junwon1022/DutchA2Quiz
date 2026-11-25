from supabase import Client

class VocabularyRepository:

    def __init__(self, supabase: Client):
        self.supabase = supabase

    def get_vocabulary_list(
        self,
        level: str | None = None,
        search: str | None = None
    ) -> list[dict]:

        query = self.supabase.table("vocabulary").select("*")

        if level:
            query = query.eq("level", level)

        if search:
            query = query.ilike("word", f"%{search}%")

        response = query.order("word").execute()

        return response.data