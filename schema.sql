-- OPTIONAL STARTER ONLY. This schema is not connected to index.html yet.
-- Create an admin user in Supabase Auth before using the admin-only policies.

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  division text not null,
  summary text not null,
  details text,
  image_path text,
  project_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.projects enable row level security;

-- Anyone may read published project data. Add a published boolean column and
-- filter this policy if you want drafts to remain private.
drop policy if exists "Public can read projects" on public.projects;
create policy "Public can read projects"
  on public.projects for select
  using (true);

-- Only signed-in users may write. For production, restrict this further to a
-- dedicated admin role/user instead of every authenticated account.
drop policy if exists "Authenticated users manage projects" on public.projects;
create policy "Authenticated users manage projects"
  on public.projects for all to authenticated
  using (true) with check (true);

insert into storage.buckets (id, name, public)
values ('project-images', 'project-images', true)
on conflict (id) do nothing;

drop policy if exists "Public can view project images" on storage.objects;
create policy "Public can view project images"
  on storage.objects for select
  using (bucket_id = 'project-images');

drop policy if exists "Authenticated users upload project images" on storage.objects;
create policy "Authenticated users upload project images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'project-images');

drop policy if exists "Authenticated users update project images" on storage.objects;
create policy "Authenticated users update project images"
  on storage.objects for update to authenticated
  using (bucket_id = 'project-images') with check (bucket_id = 'project-images');

drop policy if exists "Authenticated users delete project images" on storage.objects;
create policy "Authenticated users delete project images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'project-images');
