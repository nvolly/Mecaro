-- ============================================================================
-- Mecaro Database Schema
-- Romanian Car Repair Price Transparency Platform
-- Supabase PostgreSQL + PostGIS
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable PostGIS for location queries
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================================================
-- PROFILES (User Profiles)
-- ============================================================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    preferred_car_id UUID,
    city TEXT,
    notification_enabled BOOLEAN DEFAULT true,
    is_service_owner BOOLEAN DEFAULT false,
    language TEXT DEFAULT 'ro',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast profile lookups
CREATE INDEX idx_profiles_city ON profiles(city);
CREATE INDEX idx_profiles_service_owner ON profiles(is_service_owner) WHERE is_service_owner = true;

-- RLS Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Public profiles are viewable by everyone"
    ON profiles FOR SELECT
    USING (true); -- For displaying review authors

-- Auto-update timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- CAR BRANDS
-- ============================================================================

CREATE TABLE car_brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    name_ro TEXT,
    logo_url TEXT,
    country TEXT,
    is_popular BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_car_brands_popular ON car_brands(is_popular, sort_order);

-- Public read access
ALTER TABLE car_brands ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Car brands are viewable by everyone"
    ON car_brands FOR SELECT
    USING (true);

-- ============================================================================
-- CAR MODELS
-- ============================================================================

CREATE TABLE car_models (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    brand_id UUID NOT NULL REFERENCES car_brands(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    year_start INTEGER,
    year_end INTEGER,
    body_type TEXT,
    engine_types TEXT[], -- ['petrol', 'diesel', 'electric', 'hybrid', 'lpg']
    is_popular BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT car_models_brand_name_unique UNIQUE (brand_id, name)
);

CREATE INDEX idx_car_models_brand ON car_models(brand_id);
CREATE INDEX idx_car_models_popular ON car_models(is_popular) WHERE is_popular = true;
CREATE INDEX idx_car_models_year ON car_models(year_start, year_end);

-- Public read access
ALTER TABLE car_models ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Car models are viewable by everyone"
    ON car_models FOR SELECT
    USING (true);

-- ============================================================================
-- USER CARS
-- ============================================================================

CREATE TABLE user_cars (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    brand_id UUID NOT NULL REFERENCES car_brands(id),
    model_id UUID NOT NULL REFERENCES car_models(id),
    year INTEGER,
    license_plate TEXT,
    nickname TEXT,
    engine_type TEXT,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_user_cars_user ON user_cars(user_id);
CREATE INDEX idx_user_cars_model ON user_cars(model_id);

-- RLS Policies
ALTER TABLE user_cars ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own cars"
    ON user_cars FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own cars"
    ON user_cars FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own cars"
    ON user_cars FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own cars"
    ON user_cars FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================================
-- PROCEDURE CATEGORIES
-- ============================================================================

CREATE TABLE procedure_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    name_ro TEXT NOT NULL,
    icon TEXT,
    color TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_procedure_categories_sort ON procedure_categories(sort_order);

-- Public read access
ALTER TABLE procedure_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Procedure categories are viewable by everyone"
    ON procedure_categories FOR SELECT
    USING (true);

-- ============================================================================
-- REPAIR PROCEDURES
-- ============================================================================

CREATE TABLE repair_procedures (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES procedure_categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_ro TEXT NOT NULL,
    description TEXT,
    description_ro TEXT,
    icon TEXT,
    
    -- Duration
    estimated_duration_minutes INTEGER,
    
    -- Pricing (labor separate from parts)
    labor_cost_min INTEGER,
    labor_cost_max INTEGER,
    parts_cost_min INTEGER,
    parts_cost_max INTEGER,
    
    -- Metadata
    difficulty_level INTEGER CHECK (difficulty_level >= 1 AND difficulty_level <= 5),
    requires_parts BOOLEAN DEFAULT true,
    is_parts_included BOOLEAN DEFAULT false,
    is_common BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_repair_procedures_category ON repair_procedures(category_id);
CREATE INDEX idx_repair_procedures_common ON repair_procedures(is_common) WHERE is_common = true;
CREATE INDEX idx_repair_procedures_sort ON repair_procedures(category_id, sort_order);

-- Public read access
ALTER TABLE repair_procedures ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Repair procedures are viewable by everyone"
    ON repair_procedures FOR SELECT
    USING (true);

-- ============================================================================
-- SERVICE SHOPS (Garages)
-- ============================================================================

CREATE TABLE service_shops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    
    -- Basic info
    name TEXT NOT NULL,
    description TEXT,
    description_ro TEXT,
    
    -- Location
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    county TEXT,
    postal_code TEXT,
    location GEOGRAPHY(POINT, 4326), -- PostGIS point for lat/lng
    
    -- Contact
    phone TEXT,
    phone_secondary TEXT,
    email TEXT,
    website TEXT,
    
    -- Business details
    cui TEXT, -- Romanian fiscal code (CIF/CUI)
    business_name TEXT,
    
    -- Working hours (JSONB for flexibility)
    working_hours JSONB,
    
    -- Media
    photos TEXT[],
    logo_url TEXT,
    
    -- Stats (updated via triggers)
    rating_avg NUMERIC(3, 2) DEFAULT 0,
    review_count INTEGER DEFAULT 0,
    booking_count INTEGER DEFAULT 0,
    
    -- Status
    is_verified BOOLEAN DEFAULT false, -- CUI verified
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    
    -- Subscription
    subscription_tier TEXT DEFAULT 'free',
    subscription_expires_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial index for nearby searches
CREATE INDEX idx_service_shops_location ON service_shops USING GIST(location);

-- Regular indexes
CREATE INDEX idx_service_shops_city ON service_shops(city);
CREATE INDEX idx_service_shops_verified ON service_shops(is_verified) WHERE is_verified = true;
CREATE INDEX idx_service_shops_featured ON service_shops(is_featured) WHERE is_featured = true;
CREATE INDEX idx_service_shops_active ON service_shops(is_active) WHERE is_active = true;

-- Full-text search index
CREATE INDEX idx_service_shops_search ON service_shops USING GIN(
    to_tsvector('romanian', COALESCE(name, '') || ' ' || COALESCE(description_ro, ''))
);

-- RLS Policies
ALTER TABLE service_shops ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service shops are viewable by everyone"
    ON service_shops FOR SELECT
    USING (is_active = true);

CREATE POLICY "Owners can update their own shops"
    ON service_shops FOR UPDATE
    USING (auth.uid() = owner_id);

-- Auto-update timestamp
CREATE TRIGGER service_shops_updated_at
    BEFORE UPDATE ON service_shops
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- SERVICE PRICES
-- ============================================================================

CREATE TABLE service_prices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    service_id UUID NOT NULL REFERENCES service_shops(id) ON DELETE CASCADE,
    procedure_id UUID NOT NULL REFERENCES repair_procedures(id) ON DELETE CASCADE,
    car_model_id UUID REFERENCES car_models(id) ON DELETE CASCADE,
    
    price_min INTEGER NOT NULL,
    price_max INTEGER,
    currency TEXT DEFAULT 'RON',
    
    includes_parts BOOLEAN DEFAULT false,
    includes_labor BOOLEAN DEFAULT true,
    estimated_hours NUMERIC(4, 2),
    
    notes TEXT,
    notes_ro TEXT,
    
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT service_prices_unique UNIQUE (service_id, procedure_id, car_model_id)
);

CREATE INDEX idx_service_prices_service ON service_prices(service_id);
CREATE INDEX idx_service_prices_procedure ON service_prices(procedure_id);
CREATE INDEX idx_service_prices_model ON service_prices(car_model_id);

-- Public read access
ALTER TABLE service_prices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service prices are viewable by everyone"
    ON service_prices FOR SELECT
    USING (is_active = true);

-- ============================================================================
-- REVIEWS (Core Trust Layer)
-- ============================================================================

CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    shop_id UUID NOT NULL REFERENCES service_shops(id) ON DELETE CASCADE,
    procedure_id UUID NOT NULL REFERENCES repair_procedures(id) ON DELETE CASCADE,
    car_model_id UUID REFERENCES car_models(id) ON DELETE SET NULL,
    
    -- Pricing (core data for benchmarks)
    labor_cost_paid INTEGER NOT NULL,
    parts_cost_paid INTEGER,
    currency TEXT DEFAULT 'RON',
    
    -- Rating
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    
    -- Content
    comment TEXT,
    
    -- Verification (trust layer)
    receipt_uploaded BOOLEAN DEFAULT false,
    receipt_url TEXT, -- Supabase Storage URL
    verified_at TIMESTAMPTZ, -- When admin verified
    
    -- Photos
    photos TEXT[],
    
    -- Status
    is_visible BOOLEAN DEFAULT true,
    is_flagged BOOLEAN DEFAULT false, -- Outlier detection flag
    
    -- Service response
    service_response TEXT,
    service_response_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reviews_shop ON reviews(shop_id);
CREATE INDEX idx_reviews_procedure ON reviews(procedure_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_car_model ON reviews(car_model_id);
CREATE INDEX idx_reviews_verified ON reviews(verified_at) WHERE verified_at IS NOT NULL;
CREATE INDEX idx_reviews_flagged ON reviews(is_flagged) WHERE is_flagged = true;
CREATE INDEX idx_reviews_created ON reviews(created_at DESC);

-- RLS Policies
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Reviews are viewable by everyone"
    ON reviews FOR SELECT
    USING (is_visible = true);

CREATE POLICY "Users can insert their own reviews"
    ON reviews FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own reviews"
    ON reviews FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews"
    ON reviews FOR DELETE
    USING (auth.uid() = user_id);

-- Auto-update timestamp
CREATE TRIGGER reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- ============================================================================
-- PRICE BENCHMARKS (Materialized View)
-- ============================================================================

CREATE TABLE price_benchmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    procedure_id UUID NOT NULL REFERENCES repair_procedures(id) ON DELETE CASCADE,
    car_model_id UUID REFERENCES car_models(id) ON DELETE CASCADE,
    
    -- Statistical pricing (from community reviews)
    p25_price INTEGER, -- 25th percentile
    median_price INTEGER NOT NULL, -- 50th percentile
    p75_price INTEGER, -- 75th percentile
    
    -- Labor vs Parts breakdown
    median_labor_cost INTEGER,
    median_parts_cost INTEGER,
    
    -- Metadata
    sample_size INTEGER NOT NULL DEFAULT 0,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT price_benchmarks_unique UNIQUE (procedure_id, car_model_id)
);

CREATE INDEX idx_price_benchmarks_procedure ON price_benchmarks(procedure_id);
CREATE INDEX idx_price_benchmarks_model ON price_benchmarks(car_model_id);
CREATE INDEX idx_price_benchmarks_sample ON price_benchmarks(sample_size);

-- Public read access
ALTER TABLE price_benchmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Price benchmarks are viewable by everyone"
    ON price_benchmarks FOR SELECT
    USING (sample_size >= 5); -- Only show if reliable

-- ============================================================================
-- BOOKINGS
-- ============================================================================

CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES service_shops(id) ON DELETE CASCADE,
    procedure_id UUID NOT NULL REFERENCES repair_procedures(id) ON DELETE CASCADE,
    user_car_id UUID REFERENCES user_cars(id) ON DELETE SET NULL,
    
    -- When
    preferred_date DATE NOT NULL,
    preferred_time_slot TEXT, -- 'morning', 'afternoon', 'flexible'
    confirmed_date DATE,
    confirmed_time TEXT,
    
    -- Status
    status TEXT DEFAULT 'pending', -- pending, confirmed, in_progress, completed, cancelled
    
    -- Pricing
    quoted_price_min INTEGER,
    quoted_price_max INTEGER,
    final_price INTEGER,
    currency TEXT DEFAULT 'RON',
    
    -- Notes
    user_notes TEXT,
    service_notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_service ON bookings(service_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_date ON bookings(preferred_date);

-- RLS Policies
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own bookings"
    ON bookings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own bookings"
    ON bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bookings"
    ON bookings FOR UPDATE
    USING (auth.uid() = user_id);

-- Service owners can view bookings for their shops
CREATE POLICY "Service owners can view their bookings"
    ON bookings FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM service_shops
            WHERE service_shops.id = bookings.service_id
            AND service_shops.owner_id = auth.uid()
        )
    );

-- ============================================================================
-- FAVORITES
-- ============================================================================

CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES service_shops(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT favorites_unique UNIQUE (user_id, service_id)
);

CREATE INDEX idx_favorites_user ON favorites(user_id);
CREATE INDEX idx_favorites_service ON favorites(service_id);

-- RLS Policies
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own favorites"
    ON favorites FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function: Nearby Services (PostGIS proximity search)
CREATE OR REPLACE FUNCTION nearby_services(
    user_lat FLOAT,
    user_lng FLOAT,
    radius_km INTEGER DEFAULT 20
)
RETURNS TABLE (
    id UUID,
    owner_id UUID,
    name TEXT,
    description TEXT,
    description_ro TEXT,
    address TEXT,
    city TEXT,
    county TEXT,
    postal_code TEXT,
    latitude FLOAT,
    longitude FLOAT,
    phone TEXT,
    phone_secondary TEXT,
    email TEXT,
    website TEXT,
    cui TEXT,
    business_name TEXT,
    working_hours JSONB,
    photos TEXT[],
    logo_url TEXT,
    rating_avg NUMERIC,
    review_count INTEGER,
    booking_count INTEGER,
    is_verified BOOLEAN,
    is_active BOOLEAN,
    is_featured BOOLEAN,
    subscription_tier TEXT,
    subscription_expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    distance_km FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.*,
        ST_Distance(
            s.location,
            ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
        ) / 1000.0 AS distance_km
    FROM service_shops s
    WHERE s.is_active = true
    AND ST_DWithin(
        s.location,
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
        radius_km * 1000
    )
    ORDER BY distance_km ASC;
END;
$$ LANGUAGE plpgsql;

-- Function: Recalculate Price Benchmarks
CREATE OR REPLACE FUNCTION recalculate_price_benchmarks(
    p_procedure_id UUID,
    p_car_model_id UUID DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    v_p25 INTEGER;
    v_median INTEGER;
    v_p75 INTEGER;
    v_median_labor INTEGER;
    v_median_parts INTEGER;
    v_sample_size INTEGER;
BEGIN
    -- Calculate statistics from reviews
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY labor_cost_paid + COALESCE(parts_cost_paid, 0))::INTEGER,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY labor_cost_paid + COALESCE(parts_cost_paid, 0))::INTEGER,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY labor_cost_paid + COALESCE(parts_cost_paid, 0))::INTEGER,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY labor_cost_paid)::INTEGER,
        PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY COALESCE(parts_cost_paid, 0))::INTEGER,
        COUNT(*)
    INTO v_p25, v_median, v_p75, v_median_labor, v_median_parts, v_sample_size
    FROM reviews
    WHERE procedure_id = p_procedure_id
    AND (p_car_model_id IS NULL OR car_model_id = p_car_model_id)
    AND is_visible = true
    AND verified_at IS NOT NULL; -- Only use verified reviews
    
    -- Only insert/update if we have data
    IF v_sample_size > 0 THEN
        INSERT INTO price_benchmarks (
            procedure_id,
            car_model_id,
            p25_price,
            median_price,
            p75_price,
            median_labor_cost,
            median_parts_cost,
            sample_size,
            last_updated
        ) VALUES (
            p_procedure_id,
            p_car_model_id,
            v_p25,
            v_median,
            v_p75,
            v_median_labor,
            v_median_parts,
            v_sample_size,
            NOW()
        )
        ON CONFLICT (procedure_id, car_model_id)
        DO UPDATE SET
            p25_price = EXCLUDED.p25_price,
            median_price = EXCLUDED.median_price,
            p75_price = EXCLUDED.p75_price,
            median_labor_cost = EXCLUDED.median_labor_cost,
            median_parts_cost = EXCLUDED.median_parts_cost,
            sample_size = EXCLUDED.sample_size,
            last_updated = NOW();
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger: Auto-flag outlier reviews
CREATE OR REPLACE FUNCTION flag_outlier_reviews()
RETURNS TRIGGER AS $$
DECLARE
    v_median_price INTEGER;
    v_total_paid INTEGER;
BEGIN
    -- Calculate total paid
    v_total_paid := NEW.labor_cost_paid + COALESCE(NEW.parts_cost_paid, 0);
    
    -- Get current median for this procedure
    SELECT median_price INTO v_median_price
    FROM price_benchmarks
    WHERE procedure_id = NEW.procedure_id
    AND (car_model_id = NEW.car_model_id OR car_model_id IS NULL)
    ORDER BY sample_size DESC
    LIMIT 1;
    
    -- Flag if > 2.5x median
    IF v_median_price IS NOT NULL AND v_total_paid > (v_median_price * 250 / 100) THEN
        NEW.is_flagged := true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reviews_flag_outliers
    BEFORE INSERT ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION flag_outlier_reviews();

-- Trigger: Update shop rating on review insert/update
CREATE OR REPLACE FUNCTION update_shop_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE service_shops
    SET
        rating_avg = (
            SELECT AVG(rating)::NUMERIC(3, 2)
            FROM reviews
            WHERE shop_id = COALESCE(NEW.shop_id, OLD.shop_id)
            AND is_visible = true
        ),
        review_count = (
            SELECT COUNT(*)
            FROM reviews
            WHERE shop_id = COALESCE(NEW.shop_id, OLD.shop_id)
            AND is_visible = true
        )
    WHERE id = COALESCE(NEW.shop_id, OLD.shop_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reviews_update_shop_rating
    AFTER INSERT OR UPDATE OR DELETE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_shop_rating();

-- Trigger: Recalculate benchmarks on verified review
CREATE OR REPLACE FUNCTION trigger_recalculate_benchmarks()
RETURNS TRIGGER AS $$
BEGIN
    -- Only recalculate if review is verified
    IF NEW.verified_at IS NOT NULL AND NEW.is_visible = true THEN
        PERFORM recalculate_price_benchmarks(NEW.procedure_id, NEW.car_model_id);
        PERFORM recalculate_price_benchmarks(NEW.procedure_id, NULL); -- Also update global benchmark
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reviews_recalculate_benchmarks
    AFTER INSERT OR UPDATE ON reviews
    FOR EACH ROW
    WHEN (NEW.verified_at IS NOT NULL)
    EXECUTE FUNCTION trigger_recalculate_benchmarks();

-- ============================================================================
-- SEED DATA (Romanian Market Focus)
-- ============================================================================

-- Note: Run seed data separately after schema creation
-- See seed_data.sql for Romanian brands, procedures, and cities

