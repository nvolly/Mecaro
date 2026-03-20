//
//  Service.swift
//  Mecaro
//
//  Car service/garage data models
//

import Foundation
import CoreLocation

// MARK: - Car Service

struct CarService: Codable, Identifiable, Hashable {
    let id: UUID
    let ownerId: UUID
    
    // Basic Info
    let name: String
    let description: String?
    let descriptionRo: String?
    
    // Location
    let address: String
    let city: String
    let county: String?
    let postalCode: String?
    let latitude: Double?
    let longitude: Double?
    
    // Contact
    let phone: String?
    let phoneSecondary: String?
    let email: String?
    let website: String?
    
    // Business Details
    let taxId: String?
    let businessName: String?
    
    // Working Hours (JSON object)
    let workingHours: WorkingHours?
    
    // Media
    let photos: [String]?
    let logoUrl: String?
    
    // Stats
    let rating: Double
    let reviewCount: Int
    let bookingCount: Int
    
    // Status
    let isVerified: Bool
    let isActive: Bool
    let isFeatured: Bool
    
    // Subscription
    let subscriptionTier: String
    let subscriptionExpiresAt: Date?
    
    // Metadata
    let createdAt: Date?
    let updatedAt: Date?
    
    // Computed (from nearby_services function)
    var distanceKm: Double?
    
    // Related data
    var prices: [ServicePrice]?
    var specializations: [ServiceSpecialization]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, address, city, county, latitude, longitude
        case phone, email, website, photos, rating
        case ownerId = "owner_id"
        case descriptionRo = "description_ro"
        case postalCode = "postal_code"
        case phoneSecondary = "phone_secondary"
        case taxId = "tax_id"
        case businessName = "business_name"
        case workingHours = "working_hours"
        case logoUrl = "logo_url"
        case reviewCount = "review_count"
        case bookingCount = "booking_count"
        case isVerified = "is_verified"
        case isActive = "is_active"
        case isFeatured = "is_featured"
        case subscriptionTier = "subscription_tier"
        case subscriptionExpiresAt = "subscription_expires_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case distanceKm = "distance_km"
    }
    
    // Display description
    var displayDescription: String? {
        descriptionRo ?? description
    }
    
    // CLLocation coordinate
    var coordinate: CLLocationCoordinate2D? {
        guard let lat = latitude, let lng = longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    // Distance formatted
    var distanceFormatted: String? {
        guard let distance = distanceKm else { return nil }
        if distance < 1 {
            return String(format: "%.0f m", distance * 1000)
        }
        return String(format: "%.1f km", distance)
    }
    
    // Rating formatted
    var ratingFormatted: String {
        String(format: "%.1f", rating)
    }
    
    // Rating stars (0-5)
    var ratingStars: Int {
        Int(rating.rounded())
    }
    
    // Is currently open
    var isOpen: Bool {
        // TODO: Implement based on workingHours and current time
        true
    }
    
    // Today's hours
    var todayHours: String? {
        // TODO: Implement based on workingHours
        "08:00 - 18:00"
    }
    
    // Phone number formatted
    var phoneFormatted: String? {
        phone?.replacingOccurrences(of: " ", with: "")
    }
    
    // Subscription tier display
    var subscriptionTierDisplay: String {
        switch subscriptionTier.lowercased() {
        case "free": return "Gratuit"
        case "basic": return "Basic"
        case "pro": return "Pro"
        case "premium": return "Premium"
        default: return subscriptionTier
        }
    }
}

// MARK: - Working Hours

struct WorkingHours: Codable, Hashable {
    let monday: DayHours?
    let tuesday: DayHours?
    let wednesday: DayHours?
    let thursday: DayHours?
    let friday: DayHours?
    let saturday: DayHours?
    let sunday: DayHours?
    
    struct DayHours: Codable, Hashable {
        let open: String
        let close: String
    }
}

// MARK: - Service Price

struct ServicePrice: Codable, Identifiable, Hashable {
    let id: UUID
    let serviceId: UUID
    let procedureId: UUID
    let carModelId: UUID?
    
    let priceMin: Int
    let priceMax: Int?
    let currency: String
    
    let includesParts: Bool
    let includesLabor: Bool
    let estimatedHours: Double?
    let notes: String?
    let notesRo: String?
    
    let isActive: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    // Related
    var procedure: Procedure?
    var carModel: CarModel?
    
    enum CodingKeys: String, CodingKey {
        case id, currency, notes
        case serviceId = "service_id"
        case procedureId = "procedure_id"
        case carModelId = "car_model_id"
        case priceMin = "price_min"
        case priceMax = "price_max"
        case includesParts = "includes_parts"
        case includesLabor = "includes_labor"
        case estimatedHours = "estimated_hours"
        case notesRo = "notes_ro"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Price formatted
    var priceFormatted: String {
        if let max = priceMax, max != priceMin {
            return "\(priceMin) - \(max) \(currency)"
        }
        return "\(priceMin) \(currency)"
    }
    
    // Short price
    var shortPrice: String {
        if let max = priceMax, max != priceMin {
            return "\(priceMin)-\(max)"
        }
        return "\(priceMin)"
    }
}

// MARK: - Service Specialization

struct ServiceSpecialization: Codable, Identifiable, Hashable {
    let id: UUID
    let serviceId: UUID
    let brandId: UUID?
    let isCertified: Bool
    let createdAt: Date?
    
    var brand: CarBrand?
    
    enum CodingKeys: String, CodingKey {
        case id
        case serviceId = "service_id"
        case brandId = "brand_id"
        case isCertified = "is_certified"
        case createdAt = "created_at"
    }
}

// MARK: - Sample Data

extension CarService {
    static let sample = CarService(
        id: UUID(),
        ownerId: UUID(),
        name: "Service Auto Pro",
        description: nil,
        descriptionRo: "Service autorizat cu experiență de peste 15 ani. Specialiști în mărci germane.",
        address: "Strada Industriilor 45",
        city: "București",
        county: "București",
        postalCode: "012345",
        latitude: 44.4268,
        longitude: 26.1025,
        phone: "0722 123 456",
        phoneSecondary: nil,
        email: "contact@serviceautopro.ro",
        website: "https://serviceautopro.ro",
        taxId: "RO12345678",
        businessName: "Service Auto Pro SRL",
        workingHours: WorkingHours(
            monday: .init(open: "08:00", close: "18:00"),
            tuesday: .init(open: "08:00", close: "18:00"),
            wednesday: .init(open: "08:00", close: "18:00"),
            thursday: .init(open: "08:00", close: "18:00"),
            friday: .init(open: "08:00", close: "18:00"),
            saturday: .init(open: "09:00", close: "14:00"),
            sunday: nil
        ),
        photos: [],
        logoUrl: nil,
        rating: 4.5,
        reviewCount: 23,
        bookingCount: 156,
        isVerified: true,
        isActive: true,
        isFeatured: true,
        subscriptionTier: "pro",
        subscriptionExpiresAt: Date().addingTimeInterval(30 * 24 * 60 * 60),
        createdAt: Date(),
        updatedAt: Date(),
        distanceKm: 2.3
    )
    
    static let samples: [CarService] = [
        sample,
        CarService(
            id: UUID(), ownerId: UUID(), name: "Auto Expert", description: nil,
            descriptionRo: "Reparații auto de calitate la prețuri corecte",
            address: "Bulevardul Timișoara 58", city: "București", county: "București",
            postalCode: nil, latitude: 44.4168, longitude: 26.0925,
            phone: "0733 456 789", phoneSecondary: nil, email: "office@autoexpert.ro",
            website: nil, taxId: nil, businessName: nil, workingHours: nil,
            photos: [], logoUrl: nil, rating: 4.2, reviewCount: 45, bookingCount: 230,
            isVerified: true, isActive: true, isFeatured: false, subscriptionTier: "basic",
            subscriptionExpiresAt: nil, createdAt: Date(), updatedAt: Date(), distanceKm: 4.1
        ),
        CarService(
            id: UUID(), ownerId: UUID(), name: "Garaj Mihai", description: nil,
            descriptionRo: "Service familiar, prețuri mici, muncă de calitate",
            address: "Strada Meșterilor 12", city: "București", county: "București",
            postalCode: nil, latitude: 44.4368, longitude: 26.1125,
            phone: "0744 987 654", phoneSecondary: nil, email: nil,
            website: nil, taxId: nil, businessName: nil, workingHours: nil,
            photos: [], logoUrl: nil, rating: 4.8, reviewCount: 89, bookingCount: 312,
            isVerified: false, isActive: true, isFeatured: false, subscriptionTier: "free",
            subscriptionExpiresAt: nil, createdAt: Date(), updatedAt: Date(), distanceKm: 1.2
        ),
    ]
}

extension ServicePrice {
    static let sample = ServicePrice(
        id: UUID(),
        serviceId: UUID(),
        procedureId: UUID(),
        carModelId: nil,
        priceMin: 200,
        priceMax: 350,
        currency: "RON",
        includesParts: true,
        includesLabor: true,
        estimatedHours: 0.5,
        notes: nil,
        notesRo: "Preț pentru ulei standard",
        isActive: true,
        createdAt: Date(),
        updatedAt: Date()
    )
}

