import streamlit as st
from supabase import create_client


@st.cache_resource
def get_supabase_client():
    return create_client(
        st.secrets["supabase"]["url"],
        st.secrets["supabase"]["key"],
    )