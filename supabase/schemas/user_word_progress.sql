create table public.user_word_progress (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references auth.users(id) on delete cascade,
    vocabulary_id uuid not null references public.vocabulary(id) on delete cascade,

    status text not null default 'new',
    correct_count integer not null default 0,
    incorrect_count integer not null default 0,

    last_reviewed_at timestamptz,
    next_review_at timestamptz,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    constraint user_word_progress_unique
        unique (user_id, vocabulary_id),

    constraint user_word_progress_status_check
        check (status in ('new', 'learning', 'memorized')),

    constraint user_word_progress_counts_check
        check (correct_count >= 0 and incorrect_count >= 0)
);

alter table public.user_word_progress enable row level security;

create policy "Users can view their own word progress"
on public.user_word_progress
for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can create their own word progress"
on public.user_word_progress
for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own word progress"
on public.user_word_progress
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own word progress"
on public.user_word_progress
for delete
to authenticated
using (auth.uid() = user_id);

revoke all on table public.user_word_progress from anon, authenticated;
grant select, insert, update, delete on table public.user_word_progress to authenticated;
grant all on table public.user_word_progress to service_role;