create table public.decks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    name text not null,
    description text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.decks enable row level security;

create policy "Users can view their own decks"
on public.decks
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can create their own decks"
on public.decks
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own decks"
on public.decks
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own decks"
on public.decks
for delete
to authenticated
using (auth.uid() = user_id);

revoke all on table public.decks from anon, authenticated;
grant select, insert, update, delete on table public.decks to authenticated;
grant all on table public.decks to service_role;