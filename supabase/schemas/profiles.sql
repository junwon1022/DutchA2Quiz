
-- =========================================
-- Profiles table
-- =========================================

create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    username text unique,
    display_name text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- =========================================
-- Row Level Security
-- =========================================

alter table public.profiles enable row level security;

create policy "Users can view their own profile"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

create policy "Users can update their own profile"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- =========================================
-- Table permissions
-- =========================================

revoke all on table public.profiles from anon, authenticated;

grant select, update
on table public.profiles
to authenticated;

grant all
on table public.profiles
to service_role;

-- =========================================
-- Automatically create a profile
-- when a new user signs up
-- =========================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.profiles (id, display_name)
    values (
        new.id,
        coalesce(
            new.raw_user_meta_data ->> 'display_name',
            new.raw_user_meta_data ->> 'full_name'
        )
    );

    return new;
end;
$$;

revoke all on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();
