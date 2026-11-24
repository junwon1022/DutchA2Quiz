create table public.study_sessions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,

    started_at timestamptz not null default now(),
    completed_at timestamptz,

    total_words integer not null default 0,
    correct_count integer not null default 0,
    incorrect_count integer not null default 0,

    created_at timestamptz not null default now(),

    constraint study_sessions_counts_check
        check (
            total_words >= 0
            and correct_count >= 0
            and incorrect_count >= 0
            and correct_count + incorrect_count <= total_words
        )
);

create index study_sessions_user_started_idx
on public.study_sessions (user_id, started_at desc);

alter table public.study_sessions enable row level security;

create policy "Users can view their own study sessions"
on public.study_sessions
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can create their own study sessions"
on public.study_sessions
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own study sessions"
on public.study_sessions
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own study sessions"
on public.study_sessions
for delete
to authenticated
using (auth.uid() = user_id);

revoke all on table public.study_sessions from anon, authenticated;
grant select, insert, update, delete on table public.study_sessions to authenticated;
grant all on table public.study_sessions to service_role;