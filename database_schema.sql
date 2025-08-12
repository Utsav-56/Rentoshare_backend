-- This is a database model file for our project
-- This is for PostgreSQL

-- Create custom ENUM types first
CREATE TYPE user_role AS ENUM ('vendor', 'consumer');
CREATE TYPE listing_type AS ENUM ('product', 'service', 'donation');
CREATE TYPE request_status AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE transaction_status AS ENUM ('pending', 'active', 'completed', 'cancelled', 'disputed');
CREATE TYPE dispute_status AS ENUM ('open', 'resolved', 'rejected');
CREATE TYPE document_type AS ENUM ('license', 'passport', 'national_id', 'voter_id', 'pan_card', 'aadhaar', 'other');
CREATE TYPE kyc_status AS ENUM ('pending', 'approved', 'rejected', 'under_review');

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20),
  password_hash VARCHAR(128) NOT NULL,
  role user_role NOT NULL,
  bio TEXT,
  profile_picture TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE kyc (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  gov_id_number VARCHAR(50) NOT NULL,
  document_type document_type NOT NULL,
  document_front_picture TEXT NOT NULL,
  document_back_picture TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  kyc_status kyc_status DEFAULT 'pending',
  temp_address TEXT,
  permanent_address TEXT NOT NULL,
  date_of_birth DATE,
  nationality VARCHAR(50),
  occupation VARCHAR(100),
  annual_income NUMERIC(12,2),
  emergency_contact_name VARCHAR(100),
  emergency_contact_phone VARCHAR(20),
  emergency_contact_relation VARCHAR(50),
  submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  verified_at TIMESTAMP NULL,
  verified_by INTEGER NULL,
  rejection_reason TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
--   FOREIGN KEY (verified_by) REFERENCES users(id),
  UNIQUE (user_id),
  UNIQUE (gov_id_number, document_type)
);

CREATE TABLE listings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  title VARCHAR(200) NOT NULL,
  description TEXT NOT NULL,
  listing_type listing_type NOT NULL,
  price_per_day NUMERIC(10,2),
  location TEXT,
  images JSONB,
  is_active BOOLEAN DEFAULT TRUE,
  available_from TIMESTAMP NULL,
  available_to TIMESTAMP NULL,
  extra_details JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE donation_requests (
  id SERIAL PRIMARY KEY,
  listing_id INTEGER,
  user_id INTEGER,
  message TEXT,
  status request_status DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  listing_id INTEGER,
  vendor_id INTEGER,
  consumer_id INTEGER,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP NOT NULL,
  total_price NUMERIC(10,2) NOT NULL,
  status transaction_status DEFAULT 'pending',
  is_refunded BOOLEAN DEFAULT FALSE,
  payment_hold_expires TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (listing_id) REFERENCES listings(id),
  FOREIGN KEY (vendor_id) REFERENCES users(id),
  FOREIGN KEY (consumer_id) REFERENCES users(id)
);

CREATE TABLE reviews (
  id SERIAL PRIMARY KEY,
  reviewer_id INTEGER,
  reviewed_id INTEGER,
  rating NUMERIC(2,1) NOT NULL,
  comment TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (reviewer_id, reviewed_id),
  FOREIGN KEY (reviewer_id) REFERENCES users(id),
  FOREIGN KEY (reviewed_id) REFERENCES users(id),
  CHECK (rating >= 0 AND rating <= 5)
);

CREATE TABLE disputes (
  id SERIAL PRIMARY KEY,
  transaction_id INTEGER,
  raised_by INTEGER,
  reason TEXT NOT NULL,
  status dispute_status DEFAULT 'open',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (transaction_id) REFERENCES transactions(id),
  FOREIGN KEY (raised_by) REFERENCES users(id)
);

