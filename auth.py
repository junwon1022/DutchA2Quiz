import streamlit as st
from supabase_client import get_supabase_client


def sign_up(email, password, display_name):
    supabase = get_supabase_client()

    return supabase.auth.sign_up({
        "email": email,
        "password": password,
        "options": {
            "data": {
                "display_name": display_name
            }
        }
    })


def sign_in(email, password):
    supabase = get_supabase_client()

    return supabase.auth.sign_in_with_password({
        "email": email,
        "password": password
    })


def sign_out():
    supabase = get_supabase_client()
    supabase.auth.sign_out()
    st.session_state.pop("user", None)
    st.rerun()