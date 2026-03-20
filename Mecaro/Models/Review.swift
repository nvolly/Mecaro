//
//  Review.swift
//  Mecaro
//
//  Review and rating data models
//

import Foundation

// MARK: - Review

struct Review: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let shopId: UUID // Renamed from serviceId to match spec
    let procedureId: UUID // Which repair procedure
    let carModelId: UUID? // Which car model (optional for privacy)
    
    // Pricing (core data for benchmarks)
    let laborCostPaid: Int
    let partsCostPaid: Int?
    let currency: String
    
    // Rating
    let rating: Int // 1-5
    
    // Content
    let comment: String?
    
    // Verification
    let receiptUploaded: Bool
    let receiptUrl: String? // Supabase Storage URL
    let verifiedAt: Date? // When admin verified it
    
    // Photos (additional)
    let photos: [String]?
    
    // Status
    let isVisible: Bool
    let isFlagged: Bool // Flagged for manual review (outlier detection)
    
    // Service response
    let serviceResponse: String?
    let serviceResponseAt: Date?
    
    // Metadata
    let createdAt: Date?
    let updatedAt: Date?
    
    // Related
    var user: UserProfile?
    var shop: CarService?
    var procedure: Procedure?
    var carModel: CarModel?
    
    enum CodingKeys: String, CodingKey {
        case id, rating, comment, photos, currency
        case userId = "user_id"
        case shopId = "shop_id"
        case procedureId = "procedure_id"
        case carModelId = "car_model_id"
        case laborCostPaid = "labor_cost_paid"
        case partsCostPaid = "parts_cost_paid"
        case receiptUploaded = "receipt_uploaded"
        case receiptUrl = "receipt_url"
        case verifiedAt = "verified_at"
        case isVisible = "is_visible"
        case isFlagged = "is_flagged"
        case serviceResponse = "service_response"
        case serviceResponseAt = "service_response_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Computed Properties
    
    // Total cost paid
    var totalCostPaid: Int {
        laborCostPaid + (partsCostPaid ?? 0)
    }
    
    // Total formatted
    var totalCostFormatted: String {
        "\(totalCostPaid) \(currency)"
    }
    
    // Labor cost formatted
    var laborCostFormatted: String {
        "\(laborCostPaid) \(currency)"
    }
    
    // Parts cost formatted
    var partsCostFormatted: String? {
        guard let parts = partsCostPaid else { return nil }
        return "\(parts) \(currency)"
    }
    
    // Is verified (has receipt and admin verified)
    var isVerified: Bool {
        receiptUploaded && verifiedAt != nil
    }
    
    // Verification badge text
    var verificationBadge: String? {
        if isVerified {
            return "Verificat cu bon fiscal"
        } else if receiptUploaded {
            return "Bon fiscal încărcat"
        }
        return nil
    }
    
    // Rating label
    var ratingLabel: String {
        switch rating {
        case 5: return "Excelent"
        case 4: return "Foarte bun"
        case 3: return "Bun"
        case 2: return "Satisfăcător"
        case 1: return "Nesatisfăcător"
        default: return ""
        }
    }
    
    // Date formatted
    var dateFormatted: String {
        guard let date = createdAt else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    // Short date
    var dateShort: String {
        guard let date = createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    // Has response
    var hasServiceResponse: Bool {
        serviceResponse != nil && !serviceResponse!.isEmpty
    }
    
    // Should display warning (flagged as outlier)
    var showOutlierWarning: Bool {
        isFlagged
    }
}

// MARK: - New Review Request

struct NewReviewRequest: Codable {
    let shopId: UUID
    let procedureId: UUID
    let carModelId: UUID?
    let rating: Int
    let laborCostPaid: Int
    let partsCostPaid: Int?
    let comment: String?
    let currency: String
    
    enum CodingKeys: String, CodingKey {
        case rating, comment, currency
        case shopId = "shop_id"
        case procedureId = "procedure_id"
        case carModelId = "car_model_id"
        case laborCostPaid = "labor_cost_paid"
        case partsCostPaid = "parts_cost_paid"
    }
}

// MARK: - Rating Summary

struct RatingSummary {
    let averageRating: Double
    let totalReviews: Int
    let distribution: [Int: Int] // rating -> count
    
    // Percentage for each rating
    func percentage(for rating: Int) -> Double {
        guard totalReviews > 0 else { return 0 }
        let count = distribution[rating] ?? 0
        return Double(count) / Double(totalReviews) * 100
    }
    
    static let sample = RatingSummary(
        averageRating: 4.5,
        totalReviews: 89,
        distribution: [
            5: 52,
            4: 25,
            3: 8,
            2: 3,
            1: 1
        ]
    )
}

// MARK: - Sample Data

extension Review {
    static let sample = Review(
        id: UUID(),
        userId: UUID(),
        shopId: UUID(),
        procedureId: UUID(),
        carModelId: UUID(),
        laborCostPaid: 120,
        partsCostPaid: 180,
        currency: "RON",
        rating: 5,
        comment: "Am schimbat uleiul și filtrele. Totul a fost rapid, curat și la preț bun. Recomand cu încredere!",
        receiptUploaded: true,
        receiptUrl: nil,
        verifiedAt: Date().addingTimeInterval(-2 * 24 * 60 * 60),
        photos: nil,
        isVisible: true,
        isFlagged: false,
        serviceResponse: "Mulțumim pentru recenzie! Vă așteptăm cu drag și data viitoare.",
        serviceResponseAt: Date().addingTimeInterval(-1 * 24 * 60 * 60),
        createdAt: Date().addingTimeInterval(-3 * 24 * 60 * 60),
        updatedAt: Date().addingTimeInterval(-3 * 24 * 60 * 60)
    )
    
    static let samples: [Review] = [
        sample,
        Review(
            id: UUID(),
            userId: UUID(),
            shopId: UUID(),
            procedureId: UUID(),
            carModelId: UUID(),
            laborCostPaid: 150,
            partsCostPaid: 350,
            currency: "RON",
            rating: 4,
            comment: "Bun service, prețuri ok. Singura problemă a fost că am așteptat un pic mai mult decât estimat.",
            receiptUploaded: false,
            receiptUrl: nil,
            verifiedAt: nil,
            photos: nil,
            isVisible: true,
            isFlagged: false,
            serviceResponse: nil,
            serviceResponseAt: nil,
            createdAt: Date().addingTimeInterval(-10 * 24 * 60 * 60),
            updatedAt: nil
        ),
        Review(
            id: UUID(),
            userId: UUID(),
            shopId: UUID(),
            procedureId: UUID(),
            carModelId: nil, // Anonymous car model
            laborCostPaid: 600,
            partsCostPaid: 1200,
            currency: "RON",
            rating: 5,
            comment: "Mașina avea o problemă pe care nu o găsea nimeni. Aici au reparat-o în 4 ore. Super profesioniști! Kit distribuție complet schimbat.",
            receiptUploaded: true,
            receiptUrl: "https://storage.example.com/receipts/xyz.jpg",
            verifiedAt: Date().addingTimeInterval(-18 * 24 * 60 * 60),
            photos: nil,
            isVisible: true,
            isFlagged: false,
            serviceResponse: nil,
            serviceResponseAt: nil,
            createdAt: Date().addingTimeInterval(-20 * 24 * 60 * 60),
            updatedAt: nil
        ),
    ]
}

