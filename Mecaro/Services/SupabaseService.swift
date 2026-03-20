//
//  SupabaseService.swift
//  Mecaro
//
//  Core Supabase client and database operations
//

import Foundation
import Supabase

@MainActor
class SupabaseService {
    static let shared = SupabaseService()
    
    // MARK: - Properties
    
    private let client: SupabaseClient
    
    // MARK: - Initialization
    
    private init() {
        do {
            try Config.validate()
            self.client = SupabaseClient(
                supabaseURL: URL(string: Config.supabaseURL)!,
                supabaseKey: Config.supabaseAnonKey
            )
            print("✅ Supabase client initialized successfully")
            print("📍 Connected to: \(Config.supabaseURL)")
        } catch {
            fatalError("❌ Supabase configuration error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Auth Methods
    
    func getCurrentSession() async throws -> Session? {
        try await client.auth.session
    }
    
    func signUp(email: String, password: String, data: [String: String]?) async throws -> Session {
        let response = try await client.auth.signUp(
            email: email,
            password: password
        )
        guard let session = response.session else {
            throw SupabaseError.unauthorized
        }
        print("✅ User signed up: \(session.user.id)")
        return session
    }
    
    func signIn(email: String, password: String) async throws -> Session {
        let session = try await client.auth.signIn(
            email: email,
            password: password
        )
        print("✅ User signed in: \(session.user.id)")
        return session
    }
    
    func signInWithPhone(_ phoneNumber: String) async throws {
        try await client.auth.signInWithOTP(phone: phoneNumber)
        print("✅ OTP sent to \(phoneNumber)")
    }
    
    func verifyOTP(phone: String, token: String) async throws -> Session {
        let response = try await client.auth.verifyOTP(
            phone: phone,
            token: token,
            type: .sms
        )
        guard let session = response.session else {
            throw SupabaseError.unauthorized
        }
        print("✅ Phone verified: \(session.user.id)")
        return session
    }
    
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        print("✅ User signed out")
    }
    
    // MARK: - Profile Methods
    
    func fetchProfile(userId: UUID) async throws -> UserProfile {
        try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
    }
    
    func updateProfile(userId: UUID, update: UpdateProfileRequest) async throws -> UserProfile {
        try await client
            .from("profiles")
            .update(update)
            .eq("id", value: userId.uuidString)
            .select()
            .single()
            .execute()
            .value
    }
    
    // MARK: - Car Brands & Models
    
    func fetchCarBrands() async throws -> [CarBrand] {
        try await client
            .from("car_brands")
            .select()
            .order("sort_order")
            .execute()
            .value
    }
    
    func fetchCarModels(brandId: UUID) async throws -> [CarModel] {
        try await client
            .from("car_models")
            .select()
            .eq("brand_id", value: brandId.uuidString)
            .order("is_popular", ascending: false)
            .order("name")
            .execute()
            .value
    }
    
    // MARK: - User Cars
    
    func fetchUserCars(userId: UUID) async throws -> [UserCar] {
        try await client
            .from("user_cars")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("is_primary", ascending: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func addUserCar(_ car: UserCar) async throws -> UserCar {
        try await client
            .from("user_cars")
            .insert(car)
            .select()
            .single()
            .execute()
            .value
    }
    
    func deleteUserCar(carId: UUID) async throws {
        try await client
            .from("user_cars")
            .delete()
            .eq("id", value: carId.uuidString)
            .execute()
    }
    
    // MARK: - Procedures
    
    func fetchProcedureCategories() async throws -> [ProcedureCategory] {
        try await client
            .from("procedure_categories")
            .select()
            .order("sort_order")
            .execute()
            .value
    }
    
    func fetchProcedures(categoryId: UUID? = nil) async throws -> [Procedure] {
        var query = client
            .from("repair_procedures")
            .select()
        
        if let categoryId = categoryId {
            query = query.eq("category_id", value: categoryId.uuidString)
        }
        
        return try await query
            .order("is_common", ascending: false)
            .order("sort_order")
            .execute()
            .value
    }
    
    // MARK: - Price Benchmarks
    
    func fetchPriceBenchmark(
        procedureId: UUID,
        carModelId: UUID? = nil
    ) async throws -> PriceBenchmark? {
        var query = client
            .from("price_benchmarks")
            .select()
            .eq("procedure_id", value: procedureId.uuidString)
        
        if let modelId = carModelId {
            query = query.eq("car_model_id", value: modelId.uuidString)
        }
        // If carModelId is nil, we'll get all results and filter in Swift
        
        let result: [PriceBenchmark] = try await query
            .gte("sample_size", value: Config.minSampleSizeForBenchmark)
            .order("sample_size", ascending: false)
            .execute()
            .value
        
        // Filter for null car_model_id if needed
        if carModelId == nil {
            return result.first(where: { $0.carModelId == nil })
        }
        
        return result.first
    }
    
    // MARK: - Services (Garages)
    
    func fetchNearbyServices(
        latitude: Double,
        longitude: Double,
        radiusKm: Int = 20
    ) async throws -> [CarService] {
        // For now, return sample data until database is set up
        // TODO: Implement PostGIS query after running database_schema.sql
        return CarService.samples
    }
    
    func fetchService(serviceId: UUID) async throws -> CarService {
        try await client
            .from("service_shops")
            .select()
            .eq("id", value: serviceId.uuidString)
            .single()
            .execute()
            .value
    }
    
    func fetchServicePrices(serviceId: UUID, procedureId: UUID? = nil) async throws -> [ServicePrice] {
        var query = client
            .from("service_prices")
            .select()
            .eq("service_id", value: serviceId.uuidString)
        
        if let procedureId = procedureId {
            query = query.eq("procedure_id", value: procedureId.uuidString)
        }
        
        return try await query
            .execute()
            .value
    }
    
    func searchServices(query: String, city: String? = nil) async throws -> [CarService] {
        var dbQuery = client
            .from("service_shops")
            .select()
        
        if let city = city {
            dbQuery = dbQuery.eq("city", value: city)
        }
        
        // Use ilike for case-insensitive search
        dbQuery = dbQuery.ilike("name", pattern: "%\(query)%")
        
        return try await dbQuery
            .order("rating_avg", ascending: false)
            .limit(20)
            .execute()
            .value
    }
    
    // MARK: - Bookings
    
    func fetchUserBookings(userId: UUID) async throws -> [Booking] {
        try await client
            .from("bookings")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("preferred_date", ascending: false)
            .execute()
            .value
    }
    
    func createBooking(_ request: NewBookingRequest, userId: UUID) async throws -> Booking {
        var bookingData = request
        // Add user_id from auth
        
        return try await client
            .from("bookings")
            .insert(bookingData)
            .select()
            .single()
            .execute()
            .value
    }
    
    func updateBookingStatus(bookingId: UUID, status: BookingStatus) async throws -> Booking {
        try await client
            .from("bookings")
            .update(["status": status.rawValue])
            .eq("id", value: bookingId.uuidString)
            .select()
            .single()
            .execute()
            .value
    }
    
    func cancelBooking(bookingId: UUID) async throws {
        try await client
            .from("bookings")
            .update(["status": "cancelled"])
            .eq("id", value: bookingId.uuidString)
            .execute()
    }
    
    // MARK: - Reviews
    
    func fetchShopReviews(shopId: UUID) async throws -> [Review] {
        try await client
            .from("reviews")
            .select()
            .eq("shop_id", value: shopId.uuidString)
            .eq("is_visible", value: true)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func createReview(_ request: NewReviewRequest, userId: UUID) async throws -> Review {
        var reviewData = request
        // Supabase will auto-populate user_id from auth context
        
        return try await client
            .from("reviews")
            .insert(reviewData)
            .select()
            .single()
            .execute()
            .value
    }
    
    func uploadReceiptImage(_ imageData: Data, userId: UUID, reviewId: UUID) async throws -> String {
        let fileName = "\(userId.uuidString)/\(reviewId.uuidString).jpg"
        
        try await client.storage
            .from("receipts")
            .upload(
                path: fileName,
                file: imageData,
                options: FileOptions(
                    cacheControl: "3600",
                    contentType: "image/jpeg"
                )
            )
        
        let url = try client.storage
            .from("receipts")
            .getPublicURL(path: fileName)
        
        return url.absoluteString
    }
    
    // MARK: - Favorites
    
    func fetchFavorites(userId: UUID) async throws -> [CarService] {
        // Join query to get full service data
        try await client
            .from("favorites")
            .select("service_shops(*)")
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    func addFavorite(userId: UUID, serviceId: UUID) async throws {
        try await client
            .from("favorites")
            .insert([
                "user_id": userId.uuidString,
                "service_id": serviceId.uuidString
            ])
            .execute()
    }
    
    func removeFavorite(userId: UUID, serviceId: UUID) async throws {
        try await client
            .from("favorites")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("service_id", value: serviceId.uuidString)
            .execute()
    }
    
    func isFavorite(userId: UUID, serviceId: UUID) async throws -> Bool {
        let result: [Favorite] = try await client
            .from("favorites")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("service_id", value: serviceId.uuidString)
            .execute()
            .value
        
        return !result.isEmpty
    }
}

// MARK: - Helper Models

struct Favorite: Codable {
    let id: UUID
    let userId: UUID
    let serviceId: UUID
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case serviceId = "service_id"
    }
}

// MARK: - Errors

enum SupabaseError: LocalizedError {
    case notImplemented
    case networkError
    case decodingError
    case unauthorized
    case notFound
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Această funcționalitate nu este încă implementată"
        case .networkError:
            return "Eroare de rețea. Verifică conexiunea la internet."
        case .decodingError:
            return "Eroare la procesarea datelor"
        case .unauthorized:
            return "Nu ești autorizat să accesezi această resursă"
        case .notFound:
            return "Resursa nu a fost găsită"
        case .serverError(let message):
            return "Eroare server: \(message)"
        }
    }
}

