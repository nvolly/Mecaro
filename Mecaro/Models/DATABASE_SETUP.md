# Mecaro Database Setup Guide

This guide walks you through setting up the Supabase PostgreSQL database for the Mecaro app.

## Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. A new Supabase project created
3. Access to the SQL Editor in your Supabase dashboard

## Setup Steps

### 1. Create a New Supabase Project

1. Go to [app.supabase.com](https://app.supabase.com)
2. Click "New Project"
3. Choose a project name (e.g., "mecaro-production")
4. Set a strong database password (save this!)
5. Choose a region close to Romania (e.g., Frankfurt, eu-central-1)
6. Wait for the project to be created (~2 minutes)

### 2. Run the Schema Migration

1. In your Supabase dashboard, go to **SQL Editor**
2. Copy the entire contents of `database_schema.sql`
3. Paste into the SQL Editor
4. Click **Run** (or press Cmd/Ctrl + Enter)
5. Wait for completion (~30 seconds)

You should see a success message. This creates:
- ✅ All tables with proper relationships
- ✅ Indexes for performance
- ✅ Row Level Security (RLS) policies
- ✅ Triggers for auto-updates
- ✅ PostGIS functions for location queries

### 3. Seed the Database

1. In the SQL Editor, open a new query
2. Copy the entire contents of `seed_data.sql`
3. Paste and click **Run**
4. Wait for completion (~20 seconds)

This populates:
- ✅ 8 procedure categories (Întreținere, Motor, etc.)
- ✅ ~30 car brands (Dacia, VW, BMW, etc.)
- ✅ ~30+ popular car models
- ✅ ~35 common repair procedures with Romanian prices
- ✅ 3 sample service shops in București

### 4. Enable PostGIS Extension

PostGIS should already be enabled by the schema, but verify:

1. Go to **Database → Extensions**
2. Search for "postgis"
3. If not enabled, click **Enable**

### 5. Configure Storage for Receipt Uploads

1. Go to **Storage** in the sidebar
2. Click **New Bucket**
3. Name it `receipts`
4. Set to **Private** (not public)
5. Click **Create Bucket**

#### Set Storage Policies

In the bucket settings, add these policies:

**Policy 1: Users can upload their own receipts**
```sql
CREATE POLICY "Users can upload their own receipts"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'receipts' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);
```

**Policy 2: Users can view their own receipts**
```sql
CREATE POLICY "Users can view their own receipts"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'receipts' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);
```

### 6. Get Your API Credentials

1. Go to **Settings → API**
2. Copy the following to `Config.swift`:
   - **Project URL** → `Config.supabaseURL`
   - **anon/public key** → `Config.supabaseAnonKey`

⚠️ **IMPORTANT**: Never commit these keys to Git! Use environment variables or Xcode configuration files.

### 7. Enable Phone Authentication (Optional)

For Romanian phone number auth:

1. Go to **Authentication → Providers**
2. Enable **Phone** provider
3. Choose a provider:
   - **Twilio** (recommended for Romania)
   - **MessageBird**
   - Or use Supabase's built-in SMS (limited)
4. Add your provider credentials
5. Add Romania (+40) to allowed countries

### 8. Configure Realtime (Optional)

For live review count updates:

1. Go to **Database → Replication**
2. Enable replication for these tables:
   - `reviews`
   - `service_shops`
   - `price_benchmarks`

## Database Schema Overview

### Core Tables

| Table | Purpose | Key Features |
|-------|---------|--------------|
| `profiles` | User profiles | RLS enabled, auto-created on signup |
| `car_brands` | Car manufacturers | Public read, admin write |
| `car_models` | Car models per brand | Public read, admin write |
| `user_cars` | User's owned vehicles | Private, user-scoped |
| `procedure_categories` | Repair categories | Public read |
| `repair_procedures` | Repair types with pricing | Labor/parts costs separated |
| `service_shops` | Garages/mechanics | PostGIS location, full-text search |
| `reviews` | User reviews with costs | Core trust layer, outlier flagging |
| `price_benchmarks` | Statistical pricing | Auto-calculated from reviews |
| `bookings` | Appointment scheduling | User-scoped RLS |
| `favorites` | Saved shops | User-scoped RLS |

### Key Functions

- **`nearby_services(lat, lng, radius_km)`**: Find shops within radius using PostGIS
- **`recalculate_price_benchmarks(procedure_id, car_model_id)`**: Recompute price statistics
- **Triggers**: Auto-update shop ratings, flag outliers, recalc benchmarks

### Security (RLS Policies)

✅ **Public Read**:
- Car brands/models
- Procedure categories/procedures
- Service shops (active only)
- Reviews (visible only)
- Price benchmarks (sample size ≥ 5)

✅ **User Scoped**:
- Users can only edit their own profile
- Users can only edit/delete their own reviews
- Users can only see their own cars/bookings/favorites

✅ **Service Owner Scoped**:
- Service owners can view bookings for their shops
- Service owners can update their own shop info

## Verification Checklist

Run these queries to verify everything is set up correctly:

```sql
-- Check tables exist (should return ~15 rows)
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check car brands (should return ~30 rows)
SELECT COUNT(*) FROM car_brands;

-- Check procedures (should return ~35 rows)
SELECT COUNT(*) FROM repair_procedures;

-- Check PostGIS is working
SELECT ST_AsText(location) 
FROM service_shops 
LIMIT 1;

-- Test nearby_services function (București center)
SELECT name, distance_km 
FROM nearby_services(44.4268, 26.1025, 20);
```

All queries should return data without errors.

## Next Steps

1. **Add your own seed data** for more cities:
   - Cluj-Napoca: `ST_MakePoint(23.6203, 46.7712)`
   - Timișoara: `ST_MakePoint(21.2272, 45.7489)`
   - Iași: `ST_MakePoint(27.5754, 47.1585)`

2. **Set up Edge Functions** (optional):
   - Create `recalculate-benchmarks` function
   - Trigger on review insert/update webhook

3. **Configure backups**:
   - Supabase auto-backs up daily
   - For production, enable point-in-time recovery

4. **Monitor usage**:
   - Go to **Reports** to see API usage
   - Set up alerts for high usage

## Troubleshooting

### PostGIS Error: "type geography does not exist"

Run this in SQL Editor:
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

### RLS Error: "new row violates row-level security policy"

Check you're authenticated:
```sql
SELECT auth.uid(); -- Should return your user ID, not NULL
```

### "function nearby_services does not exist"

Re-run the `database_schema.sql` file completely.

### No data showing in app

Check RLS policies are correct:
```sql
SELECT * FROM pg_policies WHERE tablename = 'service_shops';
```

## Database Maintenance

### Weekly Tasks
- Review flagged reviews (outliers)
- Verify new service shop CUIs
- Check for spam reviews

### Monthly Tasks
- Analyze slow queries
- Update procedure pricing estimates
- Archive old bookings (>6 months)

### Monitoring Queries

**Most expensive procedures:**
```sql
SELECT 
    name_ro,
    AVG(median_price) as avg_median,
    COUNT(*) as benchmark_count
FROM price_benchmarks pb
JOIN repair_procedures rp ON rp.id = pb.procedure_id
WHERE sample_size >= 5
GROUP BY rp.id, name_ro
ORDER BY avg_median DESC
LIMIT 10;
```

**Most reviewed shops:**
```sql
SELECT name, city, review_count, rating_avg
FROM service_shops
WHERE is_active = true
ORDER BY review_count DESC
LIMIT 10;
```

**Recent outlier reviews:**
```sql
SELECT 
    r.id,
    ss.name as shop_name,
    rp.name_ro as procedure,
    r.labor_cost_paid + COALESCE(r.parts_cost_paid, 0) as total_paid,
    r.created_at
FROM reviews r
JOIN service_shops ss ON ss.id = r.shop_id
JOIN repair_procedures rp ON rp.id = r.procedure_id
WHERE r.is_flagged = true
ORDER BY r.created_at DESC
LIMIT 20;
```

## Support

For Supabase support:
- [Supabase Docs](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)

For Mecaro database questions:
- Open an issue in the GitHub repo
- Contact the dev team

