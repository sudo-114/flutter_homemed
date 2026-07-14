CREATE TYPE user_role AS ENUM ('patient', 'doctor');
CREATE TYPE user_gender AS ENUM ('male', 'female');

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    phone TEXT UNIQUE NOT NULL,
    dob TEXT,
    gender user_gender,
    role user_role NOT NULL,
    specialty TEXT,
    license  TEXT,
    xp_years TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to select their own profile
CREATE POLICY "Profiles are viewable by owners."
    ON profiles
    FOR SELECT
    USING (id = auth.uid());

-- Allow users to update their own profile
CREATE POLICY "Profiles are updatable by owners."
    ON profiles
    FOR UPDATE
    USING (id = auth.uid());

-- Allow users to delete their own profile
CREATE POLICY "Profiles are deletable by owners."
    ON profiles
    FOR DELETE
    USING (id = auth.uid());

-- Allow authenticated users to insert their own profile
CREATE POLICY "Profiles are insertable by authenticated users."
    ON profiles
    FOR INSERT
    WITH CHECK (id = auth.uid());

CREATE TYPE request_status AS ENUM ('pending', 'accepted', 'completed', 'cancelled');

CREATE TABLE consultation_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    symptoms TEXT NOT NULL,
    file_urls TEXT[] DEFAULT '{}',
    status request_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE consultation_requests ENABLE ROW LEVEL SECURITY;

-- Patients can view their own requests
CREATE POLICY "Patients can view their own requests."
    ON consultation_requests
    FOR SELECT
    USING (patient_id = auth.uid());

-- Patients can insert their own requests
CREATE POLICY "Patients can insert their own requests."
    ON consultation_requests
    FOR INSERT
    WITH CHECK (patient_id = auth.uid());

-- Patients can cancel their own requests
CREATE POLICY "Patients can update their own requests."
    ON consultation_requests
    FOR UPDATE
    USING (patient_id = auth.uid());
