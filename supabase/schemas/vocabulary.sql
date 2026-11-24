
-- =========================================
-- Vocabulary table
-- Shared Dutch vocabulary database
-- =========================================

create table public.vocabulary (
    id uuid primary key default gen_random_uuid(),

    word text not null,
    translation text not null,

    part_of_speech text,
    article text,
    plural text,

    past_tense text,
    past_participle text,

    example_sentence text,
    example_translation text,

    level text not null default 'A2',

    created_at timestamptz not null default now(),

    constraint vocabulary_article_check
        check (article is null or article in ('de', 'het'))
);

-- =========================================
-- Row Level Security
-- =========================================

alter table public.vocabulary enable row level security;

-- Everyone can read shared vocabulary
create policy "Anyone can view vocabulary"
on public.vocabulary
for select
to anon, authenticated
using (true);

-- =========================================
-- Table permissions
-- =========================================

revoke all on table public.vocabulary from anon, authenticated;

grant select
on table public.vocabulary
to anon, authenticated;

grant all
on table public.vocabulary
to service_role;
