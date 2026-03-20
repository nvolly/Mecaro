-- ============================================================================
-- Mecaro Seed Data
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
-- Romanian
('Dacia', 'Dacia', 'Romania', true, 1),

-- German (very popular in Romania)
('Volkswagen', 'Volkswagen', 'Germany', true, 2),
('BMW', 'BMW', 'Germany', true, 3),
('Mercedes-Benz', 'Mercedes-Benz', 'Germany', true, 4),
('Audi', 'Audi', 'Germany', true, 5),
('Opel', 'Opel', 'Germany', true, 6),

-- Czech (popular)
('Skoda', 'Škoda', 'Czech Republic', true, 7),

-- French
('Renault', 'Renault', 'France', true, 8),
('Peugeot', 'Peugeot', 'France', true, 9),
('Citroen', 'Citroën', 'France', true, 10),

-- Japanese
('Toyota', 'Toyota', 'Japan', true, 11),
('Honda', 'Honda', 'Japan', true, 12),
('Mazda', 'Mazda', 'Japan', true, 13),
('Nissan', 'Nissan', 'Japan', true, 14),

-- Korean
('Hyundai', 'Hyundai', 'South Korea', true, 15),
('Kia', 'Kia', 'South Korea', true, 16),

-- Italian
('Fiat', 'Fiat', 'Italy', true, 17),

-- American
('Ford', 'Ford', 'USA', true, 18),

-- Other popular
('Suzuki', 'Suzuki', 'Japan', false, 19),
('Mitsubishi', 'Mitsubishi', 'Japan', false, 20),
('Subaru', 'Subaru', 'Japan', false, 21),
('Volvo', 'Volvo', 'Sweden', false, 22),
('Seat', 'Seat', 'Spain', false, 23),
('Alfa Romeo', 'Alfa Romeo', 'Italy', false, 24),
('Jeep', 'Jeep', 'USA', false, 25),
('Mini', 'Mini', 'UK', false, 26),
('Land Rover', 'Land Rover', 'UK', false, 27),
('Porsche', 'Porsche', 'Germany', false, 28)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- CAR MODELS (Most Popular in Romania)
-- ============================================================================

-- Get brand IDs for foreign key references
DO $$
DECLARE
    dacia_id UUID;
    vw_id UUID;
    skoda_id UUID;
    bmw_id UUID;
    ford_id UUID;
    renault_id UUID;
BEGIN
    SELECT id INTO dacia_id FROM car_brands WHERE name = 'Dacia';
    SELECT id INTO vw_id FROM car_brands WHERE name = 'Volkswagen';
    SELECT id INTO skoda_id FROM car_brands WHERE name = 'Skoda';
    SELECT id INTO bmw_id FROM car_brands WHERE name = 'BMW';
    SELECT id INTO ford_id FROM car_brands WHERE name = 'Ford';
    SELECT id INTO renault_id FROM car_brands WHERE name = 'Renault';
    
    -- Dacia models (most popular in Romania)
    INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular) VALUES
    (dacia_id, 'Logan', 2004, NULL, 'sedan', ARRAY['petrol', 'diesel', 'lpg'], true),
    (dacia_id, 'Sandero', 2008, NULL, 'hatchback', ARRAY['petrol', 'diesel', 'lpg'], true),
    (dacia_id, 'Duster', 2010, NULL, 'suv', ARRAY['petrol', 'diesel', 'lpg'], true),
    (dacia_id, 'Logan MCV', 2006, NULL, 'wagon', ARRAY['petrol', 'diesel'], true),
    (dacia_id, 'Spring', 2021, NULL, 'hatchback', ARRAY['electric'], true),
    (dacia_id, 'Jogger', 2021, NULL, 'mpv', ARRAY['petrol', 'hybrid'], true);
    
    -- Volkswagen models
    INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular) VALUES
    (vw_id, 'Golf', 1974, NULL, 'hatchback', ARRAY['petrol', 'diesel'], true),
    (vw_id, 'Passat', 1973, NULL, 'sedan', ARRAY['petrol', 'diesel'], true),
    (vw_id, 'Polo', 1975, NULL, 'hatchback', ARRAY['petrol', 'diesel'], true),
    (vw_id, 'Tiguan', 2007, NULL, 'suv', ARRAY['petrol', 'diesel'], true),
    (vw_id, 'Jetta', 1979, NULL, 'sedan', ARRAY['petrol', 'diesel'], true);
    
    -- Skoda models
    INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular) VALUES
    (skoda_id, 'Octavia', 1996, NULL, 'sedan', ARRAY['petrol', 'diesel'], true),
    (skoda_id, 'Fabia', 1999, NULL, 'hatchback', ARRAY['petrol', 'diesel'], true),
    (skoda_id, 'Superb', 2001, NULL, 'sedan', ARRAY['petrol', 'diesel'], true),
    (skoda_id, 'Karoq', 2017, NULL, 'suv', ARRAY['petrol', 'diesel'], true);
    
    -- BMW models
    INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular) VALUES
    (bmw_id, 'Seria 3', 1975, NULL, 'sedan', ARRAY['petrol', 'diesel'], true),
    (bmw_id, 'Seria 5', 1972, NULL, 'sedan', ARRAY['petrol', 'diesel'], true),
    (bmw_id, 'X5', 1999, NULL, 'suv', ARRAY['petrol', 'diesel'], true);
    
    -- Ford models
    INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular) VALUES
    (ford_id, 'Focus', 1998, NULL, 'hatchback', ARRAY['petrol', 'diesel'], true),
    (ford_id, 'Fiesta', 1976, NULL, 'hatchback', ARRAY['petrol', 'diesel'], true),
    (ford_id, 'Mondeo', 1992, NULL, 'sedan', ARRAY['petrol', 'diesel'], true);
    
    -- Renault models
    INSERT INTO car_models (brand_id, name, year_start, year_end, body_type, engine_types, is_popular) VALUES
    (renault_id, 'Clio', 1990, NULL, 'hatchback', ARRAY['petrol', 'diesel'], true),
    (renault_id, 'Megane', 1995, NULL, 'hatchback', ARRAY['petrol', 'diesel'], true),
    (renault_id, 'Captur', 2013, NULL, 'suv', ARRAY['petrol', 'diesel'], true);
END $$;

-- ============================================================================
-- REPAIR PROCEDURES
-- ============================================================================

DO $$
DECLARE
    cat_maintenance_id UUID;
    cat_engine_id UUID;
    cat_brakes_id UUID;
    cat_suspension_id UUID;
    cat_electrical_id UUID;
    cat_body_id UUID;
    cat_tires_id UUID;
    cat_ac_id UUID;
BEGIN
    SELECT id INTO cat_maintenance_id FROM procedure_categories WHERE name = 'Maintenance';
    SELECT id INTO cat_engine_id FROM procedure_categories WHERE name = 'Engine';
    SELECT id INTO cat_brakes_id FROM procedure_categories WHERE name = 'Brakes';
    SELECT id INTO cat_suspension_id FROM procedure_categories WHERE name = 'Suspension';
    SELECT id INTO cat_electrical_id FROM procedure_categories WHERE name = 'Electrical';
    SELECT id INTO cat_body_id FROM procedure_categories WHERE name = 'Body';
    SELECT id INTO cat_tires_id FROM procedure_categories WHERE name = 'Tires';
    SELECT id INTO cat_ac_id FROM procedure_categories WHERE name = 'AC & Climate';
    
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
    
    (cat_maintenance_id, 'Cabin Filter Replacement', 'Înlocuire filtru habitaclu', 'Înlocuire filtru polen/habitaclu', 'wind.snow',
     15, 30, 60, 40, 120, 1, true, false, true, 3),
    
    (cat_maintenance_id, 'Spark Plugs Replacement', 'Înlocuire bujii', 'Înlocuire set bujii', 'bolt.fill',
     45, 60, 120, 80, 250, 2, true, false, true, 4),
    
    (cat_maintenance_id, 'Fuel Filter Replacement', 'Înlocuire filtru combustibil', 'Înlocuire filtru benzină/motorină', 'fuelpump.fill',
     30, 50, 100, 60, 180, 2, true, false, true, 5);
    
    -- ENGINE PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_engine_id, 'Timing Belt Replacement', 'Înlocuire curea distribuție', 'Înlocuire kit distribuție complet (curea, role, pompa apă)', 'gearshape.2.fill',
     240, 400, 800, 600, 1800, 4, true, false, true, 1),
    
    (cat_engine_id, 'Accessory Belt Replacement', 'Înlocuire curea accesorii', 'Înlocuire curea alternator/servocurea', 'arrow.triangle.2.circlepath',
     45, 60, 120, 80, 200, 2, true, false, true, 2),
    
    (cat_engine_id, 'Coolant Change', 'Schimb lichid răcire', 'Înlocuire lichid răcire motor (antigel)', 'thermometer',
     60, 80, 150, 60, 150, 2, true, false, true, 3),
    
    (cat_engine_id, 'Head Gasket Replacement', 'Înlocuire garnitura chiulasa', 'Înlocuire garnitură chiuloasă motor', 'square.stack.3d.up.fill',
     480, 800, 1500, 300, 800, 5, true, false, false, 4),
    
    (cat_engine_id, 'Turbo Replacement', 'Înlocuire turbină', 'Înlocuire turbosuflantă', 'tornado',
     300, 500, 1000, 2000, 5000, 4, true, false, false, 5);
    
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
     60, 100, 200, 120, 400, 2, true, false, true, 2),
    
    (cat_brakes_id, 'Front Brake Discs', 'Discuri frână față', 'Înlocuire discuri frână față', 'circle.hexagongrid',
     90, 150, 300, 200, 600, 2, true, false, true, 3),
    
    (cat_brakes_id, 'Rear Brake Discs', 'Discuri frână spate', 'Înlocuire discuri frână spate', 'circle.hexagongrid.fill',
     90, 150, 300, 180, 500, 2, true, false, true, 4),
    
    (cat_brakes_id, 'Brake Fluid Change', 'Schimb lichid frână', 'Înlocuire lichid de frână', 'drop.triangle',
     45, 60, 120, 40, 100, 2, true, false, true, 5);
    
    -- SUSPENSION PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_suspension_id, 'Front Shock Absorbers', 'Amortizoare față', 'Înlocuire amortizoare față', 'arrow.up.and.down.circle',
     120, 200, 400, 400, 1200, 3, true, false, true, 1),
    
    (cat_suspension_id, 'Rear Shock Absorbers', 'Amortizoare spate', 'Înlocuire amortizoare spate', 'arrow.up.and.down.circle.fill',
     120, 200, 400, 300, 1000, 3, true, false, true, 2),
    
    (cat_suspension_id, 'Ball Joint Replacement', 'Înlocuire rotulă', 'Înlocuire rotulă suspensie', 'circle.circle',
     90, 120, 250, 80, 300, 3, true, false, true, 3),
    
    (cat_suspension_id, 'Control Arm Replacement', 'Înlocuire brat suspensie', 'Înlocuire brat inferior/superior', 'line.diagonal',
     120, 150, 300, 200, 600, 3, true, false, true, 4);
    
    -- ELECTRICAL PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_electrical_id, 'Battery Replacement', 'Înlocuire baterie', 'Înlocuire baterie auto (acumulator)', 'battery.100',
     30, 40, 80, 250, 700, 1, true, false, true, 1),
    
    (cat_electrical_id, 'Alternator Replacement', 'Înlocuire alternator', 'Înlocuire alternator', 'bolt.circle',
     120, 200, 400, 400, 1200, 3, true, false, false, 2),
    
    (cat_electrical_id, 'Starter Motor Replacement', 'Înlocuire electromotor', 'Înlocuire electromotor (demaror)', 'power',
     120, 180, 350, 350, 1000, 3, true, false, false, 3),
    
    (cat_electrical_id, 'Headlight Bulb Replacement', 'Înlocuire bec faruri', 'Înlocuire bec faruri', 'lightbulb',
     15, 30, 60, 20, 150, 1, true, false, true, 4);
    
    -- TIRE PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_tires_id, 'Tire Replacement (4 tires)', 'Schimb anvelope (4 buc)', 'Montaj 4 anvelope noi + echilibrare', 'circle.fill',
     60, 80, 150, 800, 3000, 1, true, false, true, 1),
    
    (cat_tires_id, 'Wheel Balancing', 'Echilibrare roți', 'Echilibrare 4 roți', 'circle.dashed',
     30, 40, 80, 0, 0, 1, false, true, true, 2),
    
    (cat_tires_id, 'Wheel Alignment', 'Geometrie roți', 'Reglaj geometrie tren față/spate', 'arrow.left.and.right',
     45, 80, 150, 0, 0, 2, false, true, true, 3),
    
    (cat_tires_id, 'Tire Puncture Repair', 'Reparație pană', 'Reparație pană anvelopă', 'bandage',
     30, 30, 60, 20, 50, 1, true, false, true, 4);
    
    -- AC & CLIMATE PROCEDURES
    INSERT INTO repair_procedures (
        category_id, name, name_ro, description_ro, icon,
        estimated_duration_minutes,
        labor_cost_min, labor_cost_max,
        parts_cost_min, parts_cost_max,
        difficulty_level, requires_parts, is_parts_included, is_common, sort_order
    ) VALUES
    (cat_ac_id, 'AC Recharge', 'Încărcare AC', 'Completare/reîncărcare freon climatizare', 'snowflake',
     45, 100, 200, 80, 200, 2, true, false, true, 1),
    
    (cat_ac_id, 'AC Compressor Replacement', 'Înlocuire compresor AC', 'Înlocuire compresor climatizare', 'fan',
     180, 300, 600, 800, 2500, 4, true, false, false, 2);
    
END $$;

-- ============================================================================
-- Sample Service Shops (București examples)
-- ============================================================================

INSERT INTO service_shops (
    name, description_ro, address, city, county,
    location, phone, email, cui,
    rating_avg, review_count, is_verified, is_active, is_featured,
    subscription_tier
) VALUES
(
    'Service Auto Pro',
    'Service autorizat cu experiență de peste 15 ani. Specialiști în mărci germane. Echipament modern de diagnosticare.',
    'Strada Industriilor 45',
    'București',
    'București',
    ST_SetSRID(ST_MakePoint(26.1025, 44.4268), 4326)::geography,
    '0722123456',
    'contact@serviceautopro.ro',
    'RO12345678',
    4.5,
    23,
    true,
    true,
    true,
    'pro'
),
(
    'Auto Expert',
    'Reparații auto de calitate la prețuri corecte. Service familiar cu experiență de 10 ani.',
    'Bulevardul Timișoara 58',
    'București',
    'București',
    ST_SetSRID(ST_MakePoint(26.0925, 44.4168), 4326)::geography,
    '0733456789',
    'office@autoexpert.ro',
    NULL,
    4.2,
    45,
    false,
    true,
    false,
    'basic'
),
(
    'Garaj Mihai',
    'Service familiar, prețuri mici, muncă de calitate. Specializat pe Dacia și Renault.',
    'Strada Meșterilor 12',
    'București',
    'București',
    ST_SetSRID(ST_MakePoint(26.1125, 44.4368), 4326)::geography,
    '0744987654',
    NULL,
    NULL,
    4.8,
    89,
    false,
    true,
    false,
    'free'
);

-- ============================================================================
-- NOTES
-- ============================================================================

-- After running this seed data:
-- 1. You'll have 8 procedure categories
-- 2. ~30 car brands (Romanian market focus)
-- 3. ~30+ popular car models
-- 4. ~35 common repair procedures with realistic Romanian prices
-- 5. 3 sample service shops in București
-- 6. All prices are in RON (Romanian Lei)

-- To add more cities, replicate the service_shops pattern for:
-- - Cluj-Napoca: ST_MakePoint(23.6203, 46.7712)
-- - Timișoara: ST_MakePoint(21.2272, 45.7489)
-- - Iași: ST_MakePoint(27.5754, 47.1585)
-- - Constanța: ST_MakePoint(28.6348, 44.1598)
-- - Craiova: ST_MakePoint(23.8010, 44.3302)
-- - Brașov: ST_MakePoint(25.6012, 45.6427)

