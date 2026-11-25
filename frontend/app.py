
import streamlit as st
import sqlite3

# -------------------------
# Page configuration
# -------------------------

st.set_page_config(
    page_title="Dutch A2 Quiz",
    page_icon="🇳🇱",
    layout="centered"
)

DB_NAME = "vocabulary.db"


# -------------------------
# Database functions
# -------------------------

def get_connection():
    return sqlite3.connect(DB_NAME)


def initialize_database():
    with get_connection() as conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS vocabulary (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                dutch TEXT NOT NULL UNIQUE,
                english TEXT NOT NULL,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        """)

        sample_words = [
            ("de afspraak", "appointment"),
            ("gezellig", "cozy / pleasant"),
            ("vergeten", "to forget"),
            ("de omgeving", "surroundings"),
            ("waarschijnlijk", "probably"),
        ]

        conn.executemany("""
            INSERT OR IGNORE INTO vocabulary (dutch, english)
            VALUES (?, ?)
        """, sample_words)


def get_words():
    with get_connection() as conn:
        return conn.execute("""
            SELECT id, dutch, english
            FROM vocabulary
            ORDER BY id
        """).fetchall()


def add_word(dutch, english):
    with get_connection() as conn:
        conn.execute("""
            INSERT INTO vocabulary (dutch, english)
            VALUES (?, ?)
        """, (dutch.strip(), english.strip()))


# Initialize database
initialize_database()


# -------------------------
# Session state
# -------------------------

if "current_index" not in st.session_state:
    st.session_state.current_index = 0

if "show_answer" not in st.session_state:
    st.session_state.show_answer = False


# -------------------------
# Application
# -------------------------

st.title("🇳🇱 Dutch A2 Quiz")
st.subheader("Flashcards")

words = get_words()

st.write(f"Total vocabulary: **{len(words)} words**")

if not words:
    st.info("No vocabulary available yet.")
else:
    index = min(
        st.session_state.current_index,
        len(words) - 1
    )

    st.session_state.current_index = index

    word = words[index]

    st.progress((index + 1) / len(words))
    st.caption(f"Card {index + 1} of {len(words)}")

    with st.container(border=True):
        st.markdown(
            f"<h1 style='text-align:center; padding:35px 10px;'>"
            f"{word[1]}</h1>",
            unsafe_allow_html=True
        )

        if st.session_state.show_answer:
            st.divider()
            st.markdown(
                f"<h2 style='text-align:center; color:#16A34A;'>"
                f"{word[2]}</h2>",
                unsafe_allow_html=True
            )
        else:
            st.caption("Think of the English meaning.")

    if st.button("Show / Hide Answer", use_container_width=True):
        st.session_state.show_answer = not st.session_state.show_answer

    col1, col2 = st.columns(2)

    with col1:
        if st.button("← Previous", use_container_width=True):
            st.session_state.current_index = max(0, index - 1)
            st.session_state.show_answer = False
            st.rerun()

    with col2:
        if st.button("Next →", use_container_width=True):
            st.session_state.current_index = min(
                len(words) - 1,
                index + 1
            )
            st.session_state.show_answer = False
            st.rerun()


# -------------------------
# Add new vocabulary
# -------------------------

st.divider()

st.subheader("Add New Vocabulary")

with st.form("add_word_form"):
    dutch_input = st.text_input("Dutch Word")
    english_input = st.text_input("English Meaning")

    submitted = st.form_submit_button("Save Word")

    if submitted:
        if not dutch_input.strip() or not english_input.strip():
            st.warning("Please enter both fields.")

        else:
            try:
                add_word(dutch_input, english_input)

                st.success("Word saved successfully!")
                st.session_state.show_answer = False
                st.session_state.current_index = 0
                st.rerun()

            except sqlite3.IntegrityError:
                st.error("This Dutch word already exists.")
