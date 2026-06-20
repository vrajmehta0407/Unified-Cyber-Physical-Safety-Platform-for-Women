-- CyberShield PostgreSQL schema
-- Aligned with ORM models in backend/app/models/__init__.py

-- ─── Core User ───
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  mobile VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Guardians ───
CREATE TABLE IF NOT EXISTS guardians (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  relation VARCHAR(100)
);

-- ─── SOS Incidents ───
CREATE TABLE IF NOT EXISTS incidents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  type VARCHAR(50) DEFAULT 'sos',
  status VARCHAR(50) DEFAULT 'active',
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  is_silent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Location Logs (GPS breadcrumb trail during SOS) ───
CREATE TABLE IF NOT EXISTS location_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Evidence (screenshots, audio, video, etc.) ───
CREATE TABLE IF NOT EXISTS evidence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id UUID REFERENCES incidents(id),
  user_id UUID NOT NULL REFERENCES users(id),
  file_path VARCHAR(500) NOT NULL,
  original_filename VARCHAR(255),
  hash VARCHAR(64) NOT NULL,
  mime_type VARCHAR(100),
  file_size INTEGER,
  court_admissible BOOLEAN DEFAULT FALSE,
  verified BOOLEAN DEFAULT TRUE,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Chain of Custody (audit trail for evidence) ───
CREATE TABLE IF NOT EXISTS chain_of_custody (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  evidence_id UUID NOT NULL REFERENCES evidence(id) ON DELETE CASCADE,
  action VARCHAR(100) NOT NULL,
  actor VARCHAR(255) NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Cyber Crime Reports ───
CREATE TABLE IF NOT EXISTS cyber_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  category VARCHAR(100) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(50) DEFAULT 'submitted',
  priority VARCHAR(50) DEFAULT 'medium',
  assigned_officer VARCHAR(255),
  accused_platform VARCHAR(100),
  accused_username VARCHAR(255),
  resolved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Report Updates (status change audit trail) ───
CREATE TABLE IF NOT EXISTS report_updates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID NOT NULL REFERENCES cyber_reports(id) ON DELETE CASCADE,
  message TEXT NOT NULL,
  updated_by VARCHAR(255) NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── AI Scan Results ───
CREATE TABLE IF NOT EXISTS ai_scan_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  scan_type VARCHAR(50) NOT NULL,
  input TEXT,
  result TEXT,
  risk_score DOUBLE PRECISION,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Notifications ───
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  read BOOLEAN DEFAULT FALSE,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Awareness Content ───
CREATE TABLE IF NOT EXISTS awareness_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  category VARCHAR(100),
  language VARCHAR(10) DEFAULT 'en',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Audit Logs ───
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  action VARCHAR(100) NOT NULL,
  resource VARCHAR(255),
  ip_address VARCHAR(45),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Officer Notes ───
CREATE TABLE IF NOT EXISTS officer_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id UUID REFERENCES incidents(id),
  report_id UUID REFERENCES cyber_reports(id),
  officer_id UUID NOT NULL REFERENCES users(id),
  note TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Community Reports (crowd-sourced incident tips) ───
CREATE TABLE IF NOT EXISTS community_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  lat DOUBLE PRECISION NOT NULL,
  lng DOUBLE PRECISION NOT NULL,
  description TEXT NOT NULL,
  severity VARCHAR(50) DEFAULT 'medium',
  category VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Threat Feed ───
CREATE TABLE IF NOT EXISTS threat_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  description TEXT,
  severity VARCHAR(50) DEFAULT 'medium',
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  category VARCHAR(100),
  source VARCHAR(100) DEFAULT 'system',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- ─── Advisory Broadcasts ───
CREATE TABLE IF NOT EXISTS advisory_broadcasts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  target_audience VARCHAR(100) DEFAULT 'all',
  priority VARCHAR(50) DEFAULT 'medium',
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
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
