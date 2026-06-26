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
