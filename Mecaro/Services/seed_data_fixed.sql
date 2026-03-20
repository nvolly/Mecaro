-- ============================================================================
-- Mecaro Seed Data (Fixed)
-- Romanian Market - Car Brands, Models, Procedures, Cities
-- ============================================================================

-- ============================================================================
-- PROCEDURE CATEGORIES
-- ============================================================================

INSERT INTO procedure_categories (name, name_ro, icon, color, sort_order) VALUES
('Maintenance', 'Întreținere', 'wrench.and.screwdriver.fill', '#4CAF50', 1),
('Engine', 'Motor', 'engine.combustion.fill', '#F44336', 2),
('Brakes', 'Frâne', 'circle.circle', '#FF9800', 3),
('Suspension', 'Suspensie', 'arrow.up.and.down', '#9C27B0', 4),
('Electrical', 'Electrică', 'bolt.fill', '#2196F3', 5),
('Body', 'Caroserie', 'car.fill', '#607D8B', 6),
('Tires', 'Anvelope', 'circle.fill', '#795548', 7),
('AC & Climate', 'AC & Climatizare', 'snowflake', '#00BCD4', 8)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- CAR BRANDS (Romanian Market Focus)
-- ============================================================================

INSERT INTO car_brands (name, name_ro, country, is_popular, sort_order) VALUES
('Dacia', 'Dacia', 'Romania', true, 1),
('Volkswagen', 'Volkswagen', 'Germany', true, 2),
('BMW', 'BMW', 'Germany', true, 3),
('Mercedes-Benz', 'Mercedes-Benz', 'Germany', true, 4),
('Audi', 'Audi', 'Germany', true, 5),
('Opel', 'Opel', 'Germany', true, 6),
('Skoda', 'Škoda', 'Czech Republic', true, 7),
('Renault', 'Renault', 'France', true, 8),
('Peugeot', 'Peugeot', 'France', true, 9),
('Citroen', 'Citroën', 'France', true, 10),
('Toyota', 'Toyota', 'Japan', true, 11),
('Honda', 'Honda', 'Japan', true, 12),
('Mazda', 'Mazda', 'Japan', true, 13),
('Nissan', 'Nissan', 'Japan', true, 14),
('Hyundai', 'Hyundai', 'South Korea', true, 15),
('Kia', 'Kia', 'South Korea', true, 16),
('Fiat', 'Fiat', 'Italy', true, 17),
('Ford', 'Ford', 'USA', true, 18)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- CAR MODELS (Most Popular in Romania)
-- ============================================================================

-- Dacia models (most popular in Romania)
INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Logan', 2004, NULL, 'sedan', ARRAY['petrol', 'diesel', 'lpg']::text[], true
FROM car_brands WHERE name = 'Dacia'
ON CONFLICT DO NOTHING;

INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Sandero', 2008, NULL, 'hatchback', ARRAY['petrol', 'diesel', 'lpg']::text[], true
FROM car_brands WHERE name = 'Dacia'
ON CONFLICT DO NOTHING;

INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Duster', 2010, NULL, 'suv', ARRAY['petrol', 'diesel', 'lpg']::text[], true
FROM car_brands WHERE name = 'Dacia'
ON CONFLICT DO NOTHING;

INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Logan MCV', 2006, NULL, 'wagon', ARRAY['petrol', 'diesel']::text[], true
FROM car_brands WHERE name = 'Dacia'
ON CONFLICT DO NOTHING;

INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Spring', 2021, NULL, 'hatchback', ARRAY['electric']::text[], true
FROM car_brands WHERE name = 'Dacia'
ON CONFLICT DO NOTHING;

-- Volkswagen models
INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Golf', 1974, NULL, 'hatchback', ARRAY['petrol', 'diesel']::text[], true
FROM car_brands WHERE name = 'Volkswagen'
ON CONFLICT DO NOTHING;

INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Passat', 1973, NULL, 'sedan', ARRAY['petrol', 'diesel']::text[], true
FROM car_brands WHERE name = 'Volkswagen'
ON CONFLICT DO NOTHING;

INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Polo', 1975, NULL, 'hatchback', ARRAY['petrol', 'diesel']::text[], true
FROM car_brands WHERE name = 'Volkswagen'
ON CONFLICT DO NOTHING;

-- Skoda models
INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Octavia', 1996, NULL, 'sedan', ARRAY['petrol', 'diesel']::text[], true
FROM car_brands WHERE name = 'Skoda'
ON CONFLICT DO NOTHING;

INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular)
SELECT id, 'Fabia', 1999, NULL, 'hatchback', ARRAY['petrol', 'diesel']::text[], true
FROM car_brands WHERE name = 'Skoda'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- REPAIR PROCEDURES
-- ============================================================================

DO $$
DECLARE
    cat_maintenance_id UUID;
    cat_engine_id UUID;
    cat_brakes_id UUID;
BEGIN
    SELECT id INTO cat_maintenance_id FROM procedure_categories WHERE name = 'Maintenance';
    SELECT id INTO cat_engine_id FROM procedure_categories WHERE name = 'Engine';
    SELECT id INTO cat_brakes_id FROM procedure_categories WHERE name = 'Brakes';
    
    -- MAINTENANCE PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_maintenance_id, 'Oil Change', 'Schimb ulei motor', 'Înlocuire ulei motor și filtru ulei', 'drop.fill',
     30, 80, 150, 100, 300, 1, true, false, true, 1),
    
    (cat_maintenance_id, 'Air Filter Replacement', 'Înlocuire filtru aer', 'Înlocuire filtru aer motor', 'wind',
     15, 30, 60, 40, 150, 1, true, false, true, 2),
    
    (cat_maintenance_id, 'Spark Plugs Replacement', 'Înlocuire bujii', 'Înlocuire set bujii', 'bolt.fill',
     45, 60, 120, 80, 250, 2, true, false, true, 3)
    ON CONFLICT DO NOTHING;
    
    -- ENGINE PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_engine_id, 'Timing Belt Replacement', 'Înlocuire curea distribuție', 'Înlocuire kit distribuție complet', 'gearshape.2.fill',
     240, 400, 800, 600, 1800, 4, true, false, true, 1)
    ON CONFLICT DO NOTHING;
    
    -- BRAKE PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_brakes_id, 'Front Brake Pads', 'Plăcuțe frână față', 'Înlocuire plăcuțe frână față', 'circle.circle',
     60, 100, 200, 150, 500, 2, true, false, true, 1),
    
    (cat_brakes_id, 'Rear Brake Pads', 'Plăcuțe frână spate', 'Înlocuire plăcuțe frână spate', 'circle.circle.fill',
     60, 100, 200, 120, 400, 2, true, false, true, 2)
    ON CONFLICT DO NOTHING;
    
END $$;

-- ============================================================================
-- Sample Service Shops (București)
-- ============================================================================

INSERT INTO service_shops (
    name, description_ro, address, city, county,
    location, phone, cui, is_verified, is_active
) VALUES
(
    'Service Auto Pro București',
    'Service autorizat cu experiență de peste 15 ani',
    'Strada Industriilor 45',
    'București',
    'București',
    ST_SetSRID(ST_MakePoint(26.1025, 44.4268), 4326)::geography,
    '0722123456',
    'RO12345678',
    true,
    true
)
ON CONFLICT DO NOTHING;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Seed data loaded successfully!';
    RAISE NOTICE '📊 Check results with: SELECT COUNT(*) FROM car_brands;';
END $$;
