-- CyberShield PostgreSQL schema (initial)

CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name TEXT NOT NULL,
  mobile VARCHAR(20) UNIQUE NOT NULL,
  email TEXT,
  password_hash TEXT NOT NULL,
  aadhaar_verified BOOLEAN DEFAULT FALSE,
  biometric_enabled BOOLEAN DEFAULT FALSE,
  safe_word TEXT,
  safety_score INTEGER DEFAULT 0,
  language VARCHAR(10) DEFAULT 'en',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  last_active TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS guardians (
  guardian_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone VARCHAR(20) NOT NULL,
  relationship TEXT,
  priority_order INTEGER DEFAULT 0,
  permission_level TEXT DEFAULT 'notify',
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS incidents (
  incident_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(user_id),
  type TEXT,
  status TEXT,
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  address TEXT,
  audio_file_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  resolved_at TIMESTAMP WITH TIME ZONE,
  assigned_officer_id UUID,
  case_id TEXT
);

CREATE TABLE IF NOT EXISTS evidence (
  evidence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id UUID REFERENCES incidents(incident_id),
  report_id UUID,
  file_url TEXT,
  file_type TEXT,
  file_size BIGINT,
  sha256_hash VARCHAR(128),
  upload_timestamp TIMESTAMP WITH TIME ZONE DEFAULT now(),
  is_tampered BOOLEAN DEFAULT FALSE,
  court_admissible BOOLEAN DEFAULT FALSE,
  chain_of_custody_json JSONB
);

CREATE TABLE IF NOT EXISTS cyber_reports (
  report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(user_id),
  category TEXT,
  description TEXT,
  accused_details_json JSONB,
  witness_details_json JSONB,
  status TEXT,
  priority TEXT,
  assigned_officer_id UUID,
  complaint_number TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS officer_notes (
  note_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES cyber_reports(report_id),
  officer_id UUID,
  note TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS community_reports (
  report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  description TEXT,
  category TEXT,
  confirmation_count INTEGER DEFAULT 0,
  expires_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS threat_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT,
  category TEXT,
  description TEXT,
  affected_area TEXT,
  severity INTEGER,
  source TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE IF NOT EXISTS advisory_broadcasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT,
  body TEXT,
  target_area TEXT,
  sent_by UUID,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  delivery_count INTEGER DEFAULT 0
);
