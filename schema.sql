create type user_role as ENUM('patient', 'doctor');

create type user_gender as ENUM('male', 'female');

create table profiles (
  id UUID primary key references auth.users (id) on delete CASCADE,
  name TEXT,
  phone TEXT unique not null,
  dob TEXT,
  gender user_gender,
  role user_role not null,
  specialty TEXT,
  license TEXT,
  xp_years TEXT,
  created_at TIMESTAMPTZ default now()
);

-- Enable RLS
alter table profiles ENABLE row LEVEL SECURITY;

-- Allow users to select their own profile
create policy "Profiles are viewable by owners." on profiles for
select
  using (id = auth.uid ());

-- Allow users to update their own profile
create policy "Profiles are updatable by owners." on profiles
for update
  using (id = auth.uid ());

-- Allow users to delete their own profile
create policy "Profiles are deletable by owners." on profiles for DELETE using (id = auth.uid ());

-- Allow authenticated users to insert their own profile
create policy "Profiles are insertable by authenticated users." on profiles for INSERT
with
  check (id = auth.uid ());

create type request_status as ENUM('pending', 'accepted', 'completed', 'cancelled');

create table consultation_requests (
  id UUID primary key default gen_random_uuid (),
  patient_id UUID not null references profiles (id) on delete CASCADE,
  symptoms TEXT not null,
  file_urls text[] default '{}',
  status request_status not null default 'pending',
  created_at TIMESTAMPTZ default now()
);

-- Enable RLS
alter table consultation_requests ENABLE row LEVEL SECURITY;

-- Patients can view their own requests
create policy "Patients can view their own requests." on consultation_requests for
select
  using (patient_id = auth.uid ());

-- Patients can insert their own requests
create policy "Patients can insert their own requests." on consultation_requests for INSERT
with
  check (patient_id = auth.uid ());

-- Patients can cancel their own requests
create policy "Patients can update their own requests." on consultation_requests
for update
  using (patient_id = auth.uid ());

-- Index patient_id and created_at columns
create index idx_consultation_requests_patient_created on public.consultation_requests (patient_id, created_at desc);

-- Created consultion_files supabase bucket
insert into
  storage.buckets (id, name, public)
values
  ('consultation-files', 'consultation-files', false)
on conflict (id) do nothing;

-- Patients can only access files inside their own folder (first path segment = their user id)
create policy "patients_read_own_files" on storage.objects for
select
  to authenticated using (
    bucket_id = 'consultation-files'
    and (storage.foldername (name)) [1] = auth.uid ()::text
  );

-- Patients can only upload into their own folder
create policy "patients_upload_own_files" on storage.objects for insert to authenticated
with
  check (
    bucket_id = 'consultation-files'
    and (storage.foldername (name)) [1] = auth.uid ()::text
  );
