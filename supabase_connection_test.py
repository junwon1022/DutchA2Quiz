import streamlit as st
from supabase_client import get_supabase_client

st.title("Supabase Connection Test")

try:
    supabase = get_supabase_client()

    result = (
        supabase
        .table("vocabulary")
        .select("id")
        .limit(1)
        .execute()
    )

    st.success("Supabase connection successful!")
    st.write("Vocabulary table is accessible.")
    st.write(f"Retrieved rows: {len(result.data)}")

except Exception as error:
    st.error("Supabase connection failed.")
    st.exception(error)