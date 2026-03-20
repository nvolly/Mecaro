# 🚀 Mecaro Quick Start Checklist

Use this checklist to get your Mecaro app from current state to production-ready.

---

## ✅ Phase 1: Database Setup (30 minutes)

- [ ] Create Supabase account at [supabase.com](https://supabase.com)
- [ ] Create new project (name: "mecaro-production", region: eu-central-1)
- [ ] Copy project URL and anon key
- [ ] Open SQL Editor in Supabase dashboard
- [ ] Run `database_schema.sql` (paste entire file, click Run)
- [ ] Run `seed_data.sql` (paste entire file, click Run)
- [ ] Verify tables created: `SELECT COUNT(*) FROM car_brands;` (should return ~30)
- [ ] Test PostGIS: `SELECT name FROM nearby_services(44.4268, 26.1025, 20);`

**Expected Result**: ✅ 15 tables created, ~30 brands, ~35 procedures, 3 sample shops

---

## ✅ Phase 2: iOS Project Configuration (15 minutes)

- [ ] Update `Config.swift`:
  ```swift
  static let supabaseURL = "https://YOUR-PROJECT.supabase.co"
  static let supabaseAnonKey = "YOUR-ANON-KEY"
  ```
- [ ] Add Supabase Swift SDK to Xcode:
  - File → Add Package Dependencies
  - URL: `https://github.com/supabase/supabase-swift`
  - Version: "2.0.0" or latest
- [ ] Update `SupabaseService.swift`:
  ```swift
  import Supabase
  
  private init() {
      self.client = SupabaseClient(
          supabaseURL: URL(string: Config.supabaseURL)!,
          supabaseKey: Config.supabaseAnonKey
      )
  }
  ```
- [ ] Build project (⌘+B) - should compile without errors

**Expected Result**: ✅ App compiles, Config validates, Supabase client initializes

---

## ✅ Phase 3: First Working Query (30 minutes)

- [ ] Implement `fetchCarBrands()` in `SupabaseService.swift`:
  ```swift
  func fetchCarBrands() async throws -> [CarBrand] {
      try await client
          .from("car_brands")
          .select()
          .order("sort_order")
          .execute()
          .value
  }
  ```

- [ ] Implement `fetchProcedureCategories()`:
  ```swift
  func fetchProcedureCategories() async throws -> [ProcedureCategory] {
      try await client
          .from("procedure_categories")
          .select()
          .order("sort_order")
          .execute()
          .value
  }
  ```

- [ ] Test in a view:
  ```swift
  @State private var brands: [CarBrand] = []
  
  .task {
      do {
          brands = try await SupabaseService.shared.fetchCarBrands()
      } catch {
          print("Error: \(error)")
      }
  }
  ```

- [ ] Run app, check console for successful data fetch

**Expected Result**: ✅ App displays real data from Supabase

---

## ✅ Phase 4: Review Model Alignment (1 hour)

- [ ] Find all places using old `Review` fields:
  - Search project for: `review.serviceId` → replace with `review.shopId`
  - Search for: `review.title` → remove (field deleted)
  - Search for: `review.ratingQuality` → remove (field deleted)

- [ ] Update any `ReviewRow` or `ReviewCard` views:
  ```swift
  // Show verification badge
  if review.isVerified {
      Label("Verificat", systemImage: "checkmark.seal.fill")
          .foregroundColor(.green)
  }
  
  // Show total cost
  Text("Total: \(review.totalCostFormatted)")
  
  // Show breakdown if available
  Text("Manoperă: \(review.laborCostFormatted)")
  if let parts = review.partsCostFormatted {
      Text("Piese: \(parts)")
  }
  ```

- [ ] Build and test: reviews should display correctly

**Expected Result**: ✅ Review UI shows new price structure

---

## ✅ Phase 5: Procedure Model Alignment (1 hour)

- [ ] Find all places using old `Procedure` fields:
  - Search for: `procedure.avgPriceMin` → replace with `procedure.laborCostMin`
  - Search for: `procedure.priceRangeFormatted` → use `procedure.totalPriceRangeFormatted`
  - Search for: `procedure.avgDurationHours` → use `procedure.estimatedDurationMinutes`

- [ ] Update `ProcedureDetailView` or similar:
  ```swift
  VStack(alignment: .leading) {
      Text("Manoperă: \(procedure.laborCostFormatted ?? "N/A")")
      Text("Piese: \(procedure.partsCostFormatted ?? "N/A")")
      Divider()
      Text("Total estimat: \(procedure.totalPriceRangeFormatted ?? "N/A")")
          .font(.headline)
  }
  ```

- [ ] Build and test: procedures should show labor + parts breakdown

**Expected Result**: ✅ Procedure details show separated costs

---

## ✅ Phase 6: Price Benchmark Display (2 hours)

- [ ] Create `PriceBenchmarkCard` view component:
  ```swift
  struct PriceBenchmarkCard: View {
      let benchmark: PriceBenchmark
      
      var body: some View {
          VStack(alignment: .leading, spacing: 8) {
              Text("Preț median comunitate")
                  .font(.caption)
                  .foregroundColor(.secondary)
              
              Text(benchmark.medianFormatted)
                  .font(.title2)
                  .fontWeight(.bold)
              
              Text(benchmark.priceRangeFormatted)
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              
              HStack {
                  Image(systemName: "chart.bar.fill")
                  Text(benchmark.sampleSizeFormatted)
                  Spacer()
                  Text(benchmark.confidenceLabel)
                      .font(.caption)
              }
              .foregroundColor(.blue)
          }
          .padding()
          .background(Color.blue.opacity(0.1))
          .cornerRadius(12)
      }
  }
  ```

- [ ] Implement `fetchPriceBenchmark()` in `SupabaseService.swift`:
  ```swift
  func fetchPriceBenchmark(
      procedureId: UUID,
      carModelId: UUID?
  ) async throws -> PriceBenchmark? {
      let query = client
          .from("price_benchmarks")
          .select()
          .eq("procedure_id", value: procedureId.uuidString)
      
      if let modelId = carModelId {
          query.eq("car_model_id", value: modelId.uuidString)
      } else {
          query.is("car_model_id", value: "null")
      }
      
      let result: [PriceBenchmark] = try await query
          .gte("sample_size", value: 5) // Only reliable data
          .order("sample_size", ascending: false)
          .limit(1)
          .execute()
          .value
      
      return result.first
  }
  ```

- [ ] Add to procedure detail view:
  ```swift
  @State private var benchmark: PriceBenchmark?
  
  .task {
      benchmark = try? await SupabaseService.shared
          .fetchPriceBenchmark(
              procedureId: procedure.id,
              carModelId: selectedCar?.modelId
          )
  }
  
  if let benchmark = benchmark {
      PriceBenchmarkCard(benchmark: benchmark)
  } else {
      Text("Date insuficiente pentru preț median (minim 5 recenzii)")
          .font(.caption)
          .foregroundColor(.secondary)
  }
  ```

**Expected Result**: ✅ Price benchmarks display when enough reviews exist

---

## ✅ Phase 7: Review Submission Form (3 hours)

- [ ] Create `SubmitReviewView.swift`:
  ```swift
  struct SubmitReviewView: View {
      let shop: CarService
      let procedure: Procedure
      
      @State private var rating: Int = 5
      @State private var laborCost: String = ""
      @State private var partsCost: String = ""
      @State private var comment: String = ""
      @State private var selectedCarModel: CarModel?
      @State private var receiptImage: UIImage?
      
      var body: some View {
          Form {
              Section("Evaluare") {
                  RatingPicker(rating: $rating)
              }
              
              Section("Costuri") {
                  TextField("Manoperă (RON)", text: $laborCost)
                      .keyboardType(.numberPad)
                  TextField("Piese (RON) - opțional", text: $partsCost)
                      .keyboardType(.numberPad)
              }
              
              Section("Detalii") {
                  Picker("Mașină", selection: $selectedCarModel) {
                      Text("Anonimat").tag(nil as CarModel?)
                      ForEach(userCars) { car in
                          Text(car.shortName).tag(car.model as CarModel?)
                      }
                  }
                  
                  TextEditor(text: $comment)
                      .frame(height: 100)
              }
              
              Section("Bon fiscal (opțional)") {
                  if let image = receiptImage {
                      Image(uiImage: image)
                          .resizable()
                          .scaledToFit()
                  }
                  Button("Încarcă bon") {
                      showImagePicker = true
                  }
              }
              
              Button("Trimite recenzie") {
                  submitReview()
              }
              .disabled(!isValid)
          }
      }
  }
  ```

- [ ] Implement `createReview()` in `SupabaseService.swift`
- [ ] Implement receipt upload to Supabase Storage
- [ ] Test submission flow end-to-end

**Expected Result**: ✅ Users can submit reviews with labor/parts costs

---

## ✅ Phase 8: Phone Authentication (2 hours)

- [ ] Enable Phone provider in Supabase Auth settings
- [ ] Configure Twilio or MessageBird credentials
- [ ] Implement phone auth UI:
  ```swift
  func signInWithPhone(_ phoneNumber: String) async throws {
      try await SupabaseService.shared.client.auth.signInWithOTP(
          phone: phoneNumber
      )
  }
  
  func verifyOTP(_ phone: String, code: String) async throws {
      try await SupabaseService.shared.client.auth.verifyOTP(
          phone: phone,
          token: code,
          type: .sms
      )
  }
  ```

- [ ] Test: Send OTP → Verify → User logged in

**Expected Result**: ✅ Romanian users can sign in with phone number

---

## ✅ Phase 9: Map Integration (2 hours)

- [ ] Implement `fetchNearbyServices()`:
  ```swift
  func fetchNearbyServices(
      latitude: Double,
      longitude: Double,
      radiusKm: Int = 20
  ) async throws -> [CarService] {
      try await client
          .rpc("nearby_services", params: [
              "user_lat": latitude,
              "user_lng": longitude,
              "radius_km": radiusKm
          ])
          .execute()
          .value
  }
  ```

- [ ] Update `MapTabView` to show real shops:
  ```swift
  @State private var nearbyShops: [CarService] = []
  
  .task {
      nearbyShops = try await SupabaseService.shared
          .fetchNearbyServices(
              latitude: userLocation.latitude,
              longitude: userLocation.longitude
          )
  }
  ```

- [ ] Add map annotations for each shop
- [ ] Tap annotation → show shop detail sheet

**Expected Result**: ✅ Map shows real service shops near user

---

## ✅ Phase 10: Testing & Polish (1 week)

### Core Functionality Tests

- [ ] User can browse car brands → models
- [ ] User can browse procedure categories → procedures
- [ ] Procedure detail shows community median price (if data exists)
- [ ] User can submit review with labor + parts costs
- [ ] Receipt upload works
- [ ] Verified reviews show badge
- [ ] Outlier reviews get flagged
- [ ] Shop ratings update automatically
- [ ] Price benchmarks recalculate on new reviews
- [ ] Map shows nearby shops correctly
- [ ] Search works (procedures and shops)

### Romanian UX Tests

- [ ] All text is in Romanian (or English fallback)
- [ ] Currency formatted as "1.200 lei" (not "1,200")
- [ ] Phone auth accepts +40 numbers
- [ ] Cities display correctly (București, Cluj-Napoca, etc.)
- [ ] Date/time formatted with Romanian locale

### Edge Cases

- [ ] Handle offline gracefully
- [ ] Show "date insuficiente" when sample size < 5
- [ ] Handle missing car brand logos
- [ ] Handle shops with no reviews yet
- [ ] Handle procedures with no benchmarks

---

## 🎉 Launch Checklist

- [ ] All core features working
- [ ] No console errors
- [ ] Supabase RLS policies verified
- [ ] Receipt storage working
- [ ] Phone auth working for +40 numbers
- [ ] Beta testers recruited (5-10 Romanian users)
- [ ] Privacy policy written (Romanian + English)
- [ ] Terms of service written
- [ ] App Store screenshots prepared (Romanian)
- [ ] App Store description written (Romanian + English)
- [ ] TestFlight build uploaded
- [ ] Beta feedback collected
- [ ] Critical bugs fixed
- [ ] App Store submission

---

## 📊 Success Metrics (First 3 Months)

- [ ] **50+ shops added** across major Romanian cities
- [ ] **500+ reviews submitted** (ideally 50%+ with receipts)
- [ ] **20+ procedures** with reliable benchmarks (sample size ≥ 5)
- [ ] **1000+ active users**
- [ ] **Average 4.5+ stars** on App Store
- [ ] **70%+ review verification rate** (receipts uploaded)

---

## 🆘 Getting Help

**Supabase Issues:**
- [Supabase Docs](https://supabase.com/docs)
- [Supabase Discord](https://discord.supabase.com)

**Swift/iOS Issues:**
- [Swift Forums](https://forums.swift.org)
- [Apple Developer Forums](https://developer.apple.com/forums)

**Romanian Market Questions:**
- Validate pricing with local mechanics
- Test with Romanian beta users early
- Join Romanian dev communities for feedback

---

**Current Status**: 📊 ~25% Complete (Models refactored, DB schema ready)

**Time to MVP**: 3-4 weeks of focused development

**You are here** ✋ → Ready to integrate Supabase SDK and start building UI flows!

