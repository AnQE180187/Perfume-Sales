-- ==========================================
-- STORAGE SETUP (Avatars Bucket & Policies)
-- ==========================================

-- 1. Create the bucket
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- 2. Drop existing policies if any (to avoid duplicates on rerun)
drop policy if exists "Avatar Public Access" on storage.objects;
drop policy if exists "Users can upload their own avatar" on storage.objects;
drop policy if exists "Users can update their own avatar" on storage.objects;
drop policy if exists "Users can delete their own avatar" on storage.objects;

-- 3. Set up RLS Policies

-- Allow anyone to view avatars (public bucket)
create policy "Avatar Public Access"
on storage.objects for select
using ( bucket_id = 'avatars' );

-- Allow authenticated users to upload their own avatar to their own folder
-- Path: avatars/USER_ID/filename
create policy "Users can upload their own avatar"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to update their own avatar
create policy "Users can update their own avatar"
on storage.objects for update
to authenticated
using (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own avatar
create policy "Users can delete their own avatar"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'avatars' AND
  (storage.foldername(name))[1] = auth.uid()::text
);
