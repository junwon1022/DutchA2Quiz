create table public.deck_words (
    id uuid primary key default gen_random_uuid(),
    deck_id uuid not null references public.decks(id) on delete cascade,
    vocabulary_id uuid not null references public.vocabulary(id) on delete cascade,
    created_at timestamptz not null default now(),

    constraint deck_words_unique
        unique (deck_id, vocabulary_id)
);

alter table public.deck_words enable row level security;

create policy "Users can view words in their own decks"
on public.deck_words
for select
to authenticated
using (
    exists (
        select 1
        from public.decks
        where decks.id = deck_words.deck_id
        and decks.user_id = (select auth.uid())
    )
);

create policy "Users can add words to their own decks"
on public.deck_words
for insert
to authenticated
with check (
    exists (
        select 1
        from public.decks
        where decks.id = deck_words.deck_id
        and decks.user_id = (select auth.uid())
    )
);

create policy "Users can remove words from their own decks"
on public.deck_words
for delete
to authenticated
using (
    exists (
        select 1
        from public.decks
        where decks.id = deck_words.deck_id
        and decks.user_id = (select auth.uid())
    )
);

revoke all on table public.deck_words from anon, authenticated;
grant select, insert, delete on table public.deck_words to authenticated;
grant all on table public.deck_words to service_role;