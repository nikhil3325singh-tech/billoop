-- ==============================================================================
-- BILLOOP DATABASE INITIALIZATION SCHEMA (SUPABASE POSTGRESQL)
-- Developed by Focitech Pvt. Ltd. (focitech.in)
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. PROFILES TABLE (Linked with Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  full_name VARCHAR(255),
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. COMPANY PROFILES TABLE
CREATE TABLE IF NOT EXISTS public.company_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL DEFAULT 'Your Electrical Company',
  tagline VARCHAR(255) DEFAULT 'Electrical Contractors & Suppliers',
  address TEXT DEFAULT 'Shop No. 1, Main Road, Your City',
  phone VARCHAR(50) DEFAULT '+91 98765 43210',
  email VARCHAR(255) DEFAULT 'info@yourcompany.in',
  gstin VARCHAR(50) DEFAULT '',
  bank TEXT DEFAULT 'Bank: \nA/c No: \nIFSC: ',
  quote_terms TEXT DEFAULT 'Prices valid for 15 days.\nPayment: 50% advance, balance on completion.\nGST as applicable.',
  invoice_terms TEXT DEFAULT 'Payment due within 15 days.\nGoods once sold will not be taken back.\nSubject to local jurisdiction.',
  signatory_name VARCHAR(255) DEFAULT 'Authorised Signatory',
  logo TEXT DEFAULT '',
  signature TEXT DEFAULT '',
  stamp TEXT DEFAULT '',
  letterhead TEXT DEFAULT '',
  style VARCHAR(50) DEFAULT 'classic',
  color VARCHAR(50) DEFAULT '#1f5a4c',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_company_profiles_user UNIQUE (user_id)
);

-- 4. INVENTORY ITEMS TABLE
CREATE TABLE IF NOT EXISTS public.inventory_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sku VARCHAR(100),
  category VARCHAR(100),
  unit VARCHAR(50) DEFAULT 'pcs',
  cost DOUBLE PRECISION DEFAULT 0,
  price DOUBLE PRECISION DEFAULT 0,
  gst INTEGER DEFAULT 18,
  stock INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. DOCUMENTS TABLE (Quotations and Invoices)
CREATE TABLE IF NOT EXISTS public.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type VARCHAR(20) NOT NULL CHECK (type IN ('quote', 'invoice')),
  number VARCHAR(100) NOT NULL,
  date VARCHAR(20) NOT NULL,
  due_date VARCHAR(20),
  client_name TEXT DEFAULT '',
  client_address TEXT DEFAULT '',
  client_gstin VARCHAR(50) DEFAULT '',
  client_phone VARCHAR(50) DEFAULT '',
  subject TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  terms TEXT DEFAULT '',
  status VARCHAR(50) DEFAULT 'Draft',
  inter_state BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT uq_documents_user_number UNIQUE (user_id, number)
);

-- 6. DOCUMENT LINES TABLE
CREATE TABLE IF NOT EXISTS public.document_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID NOT NULL REFERENCES public.documents(id) ON DELETE CASCADE,
  item_id UUID REFERENCES public.inventory_items(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  unit VARCHAR(50) DEFAULT 'pcs',
  qty DOUBLE PRECISION DEFAULT 1,
  rate DOUBLE PRECISION DEFAULT 0,
  cost DOUBLE PRECISION DEFAULT 0,
  gst INTEGER DEFAULT 18,
  discount DOUBLE PRECISION DEFAULT 0
);

-- 7. PERFORMANCE INDEXES
CREATE INDEX IF NOT EXISTS idx_company_profiles_user_id ON public.company_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_inventory_items_user_id ON public.inventory_items(user_id);
CREATE INDEX IF NOT EXISTS idx_documents_user_id ON public.documents(user_id);
CREATE INDEX IF NOT EXISTS idx_documents_type ON public.documents(user_id, type);
CREATE INDEX IF NOT EXISTS idx_document_lines_document_id ON public.document_lines(document_id);

-- 8. ROW LEVEL SECURITY (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.document_lines ENABLE ROW LEVEL SECURITY;

-- 8.1 PROFILES POLICIES
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- 8.2 COMPANY PROFILES POLICIES
DROP POLICY IF EXISTS "Users can manage own company profile" ON public.company_profiles;
CREATE POLICY "Users can manage own company profile" ON public.company_profiles
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 8.3 INVENTORY ITEMS POLICIES
DROP POLICY IF EXISTS "Users can manage own inventory items" ON public.inventory_items;
CREATE POLICY "Users can manage own inventory items" ON public.inventory_items
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 8.4 DOCUMENTS POLICIES
DROP POLICY IF EXISTS "Users can manage own documents" ON public.documents;
CREATE POLICY "Users can manage own documents" ON public.documents
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 8.5 DOCUMENT LINES POLICIES
DROP POLICY IF EXISTS "Users can manage lines of own documents" ON public.document_lines;
CREATE POLICY "Users can manage lines of own documents" ON public.document_lines
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.documents d
      WHERE d.id = document_lines.document_id AND d.user_id = auth.uid()
    )
  ) WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.documents d
      WHERE d.id = document_lines.document_id AND d.user_id = auth.uid()
    )
  );

-- 9. AUTOMATIC USER ONBOARDING TRIGGER
-- Automatically creates profile and seed company profile + starter inventory on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Insert into public.profiles
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Electrical Contractor')
  )
  ON CONFLICT (id) DO NOTHING;

  -- Insert default company template
  INSERT INTO public.company_profiles (user_id, name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'company_name', 'Your Electrical Company'),
    NEW.email
  )
  ON CONFLICT (user_id) DO NOTHING;

  -- Insert initial starter inventory items
  INSERT INTO public.inventory_items (user_id, name, sku, category, unit, cost, price, gst, stock)
  VALUES
    (NEW.id, 'FR Copper Wire 2.5 sqmm (90m coil)', 'WIR-25', 'Wires & Cables', 'coil', 1650, 1950, 18, 40),
    (NEW.id, 'MCB 32A Single Pole', 'MCB-32SP', 'Switchgear', 'pcs', 180, 245, 18, 120),
    (NEW.id, 'Modular Switch Board 6M', 'MSB-6M', 'Switches', 'pcs', 920, 1180, 18, 35),
    (NEW.id, 'LED Panel Light 12W', 'LED-12', 'Lighting', 'pcs', 260, 380, 12, 200),
    (NEW.id, 'Installation & Labour (per point)', 'LAB-PT', 'Services', 'point', 200, 380, 18, 0);

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 10. UPDATED_AT TIMESTAMP TRIGGER
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_company_profiles_updated_at ON public.company_profiles;
CREATE TRIGGER trg_company_profiles_updated_at BEFORE UPDATE ON public.company_profiles
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_inventory_items_updated_at ON public.inventory_items;
CREATE TRIGGER trg_inventory_items_updated_at BEFORE UPDATE ON public.inventory_items
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS trg_documents_updated_at ON public.documents;
CREATE TRIGGER trg_documents_updated_at BEFORE UPDATE ON public.documents
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
