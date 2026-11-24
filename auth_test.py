import streamlit as st
from auth import sign_up, sign_in, sign_out

st.set_page_config(page_title="Authentication Test")

st.title("Dutch A2 Quiz - Authentication")

if "user" not in st.session_state:
    st.session_state.user = None

if st.session_state.user:
    st.success(f"Logged in as: {st.session_state.user.email}")

    if st.button("Log Out"):
        sign_out()

else:
    tab_login, tab_signup = st.tabs(["Log In", "Sign Up"])

    with tab_login:
        st.subheader("Log In")

        login_email = st.text_input("Email", key="login_email")
        login_password = st.text_input(
            "Password",
            type="password",
            key="login_password"
        )

        if st.button("Log In"):
            try:
                response = sign_in(login_email, login_password)
                st.session_state.user = response.user
                st.success("Login successful!")
                st.rerun()
            except Exception as error:
                st.error(f"Login failed: {error}")

    with tab_signup:
        st.subheader("Create an Account")

        signup_name = st.text_input("Display Name")
        signup_email = st.text_input("Email", key="signup_email")
        signup_password = st.text_input(
            "Password",
            type="password",
            key="signup_password"
        )

        if st.button("Create Account"):
            try:
                response = sign_up(
                    signup_email,
                    signup_password,
                    signup_name
                )

                if response.user and not response.session:
                    st.info("Account created. Please check your email to confirm your account.")
                elif response.user:
                    st.success("Account created successfully!")
                else:
                    st.info("Please check your email for further instructions.")

            except Exception as error:
                st.error(f"Sign up failed: {error}")