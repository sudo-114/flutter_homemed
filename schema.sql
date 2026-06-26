CREATE TYPE user_role AS ENUM ('PATIENT', 'DOCTOR');

CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    role user_role NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL
);

CREATE TABLE public.doctor_profiles (
    doctor_id UUID PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    is_verified BOOLEAN DEFAULT false NOT NULL,
    is_available BOOLEAN DEFAULT false NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL
);
