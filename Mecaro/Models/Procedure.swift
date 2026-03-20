//
//  Procedure.swift
//  Mecaro
//
//  Repair procedure data models
//

import Foundation
import SwiftUI

// MARK: - Procedure Category

struct ProcedureCategory: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let nameRo: String
    let icon: String?
    let color: String?
    let sortOrder: Int
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, color
        case nameRo = "name_ro"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
    }
    
    // Display name (Romanian preferred)
    var displayName: String {
        nameRo
    }
    
    // SF Symbol icon name
    var iconName: String {
        icon ?? "wrench.fill"
    }
    
    // SwiftUI Color from hex
    var uiColor: Color {
        guard let colorHex = color else {
            return MecaroTheme.Colors.primary
        }
        return Color(hex: colorHex)
    }
}

// MARK: - Procedure

struct Procedure: Codable, Identifiable, Hashable {
    let id: UUID
    let categoryId: UUID
    let name: String
    let nameRo: String
    let description: String?
    let descriptionRo: String?
    let icon: String?
    
    // Duration
    let estimatedDurationMinutes: Int?
    
    // Pricing - separated by labor and parts
    let laborCostMin: Int?
    let laborCostMax: Int?
    let partsCostMin: Int?
    let partsCostMax: Int?
    
    // Metadata
    let difficultyLevel: Int? // 1-5 scale
    let requiresParts: Bool
    let isPartsIncluded: Bool // Whether parts are included in base price
    let isCommon: Bool
    let sortOrder: Int
    let createdAt: Date?
    
    // Related objects
    var category: ProcedureCategory?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, icon
        case categoryId = "category_id"
        case nameRo = "name_ro"
        case descriptionRo = "description_ro"
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case laborCostMin = "labor_cost_min"
        case laborCostMax = "labor_cost_max"
        case partsCostMin = "parts_cost_min"
        case partsCostMax = "parts_cost_max"
        case difficultyLevel = "difficulty_level"
        case requiresParts = "requires_parts"
        case isPartsIncluded = "is_parts_included"
        case isCommon = "is_common"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
    }
    
    // MARK: - Computed Properties
    
    // Display name (Romanian preferred)
    var displayName: String {
        nameRo
    }
    
    // Display description
    var displayDescription: String? {
        descriptionRo ?? description
    }
    
    // SF Symbol icon name
    var iconName: String {
        icon ?? "wrench.fill"
    }
    
    // Duration formatted
    var durationFormatted: String? {
        guard let minutes = estimatedDurationMinutes else { return nil }
        if minutes < 60 {
            return "\(minutes) min"
        }
        let hours = Double(minutes) / 60.0
        if hours == 1 {
            return "1 oră"
        }
        return String(format: "%.1f ore", hours)
    }
    
    // Labor cost range formatted
    var laborCostFormatted: String? {
        guard let min = laborCostMin else { return nil }
        if let max = laborCostMax, max != min {
            return "\(min) - \(max) RON"
        }
        return "\(min) RON"
    }
    
    // Parts cost range formatted
    var partsCostFormatted: String? {
        guard let min = partsCostMin else { return nil }
        if let max = partsCostMax, max != min {
            return "\(min) - \(max) RON"
        }
        return "\(min) RON"
    }
    
    // Total estimated price range (labor + parts)
    var totalPriceRangeFormatted: String? {
        let laborMin = laborCostMin ?? 0
        let laborMax = laborCostMax ?? laborMin
        let partsMin = partsCostMin ?? 0
        let partsMax = partsCostMax ?? partsMin
        
        let totalMin = laborMin + partsMin
        let totalMax = laborMax + partsMax
        
        if totalMin == 0 && totalMax == 0 { return nil }
        
        if totalMax != totalMin {
            return "\(totalMin) - \(totalMax) RON"
        }
        return "\(totalMin) RON"
    }
    
    // Average total price (for sorting/comparison)
    var averageTotalPrice: Int? {
        let laborAvg = averageLaborCost ?? 0
        let partsAvg = averagePartsCost ?? 0
        let total = laborAvg + partsAvg
        return total > 0 ? total : nil
    }
    
    private var averageLaborCost: Int? {
        guard let min = laborCostMin else { return nil }
        if let max = laborCostMax {
            return (min + max) / 2
        }
        return min
    }
    
    private var averagePartsCost: Int? {
        guard let min = partsCostMin else { return nil }
        if let max = partsCostMax {
            return (min + max) / 2
        }
        return min
    }
    
    // Price level indicator (based on total average)
    var priceLevel: PriceLevel {
        guard let avg = averageTotalPrice else { return .medium }
        if avg < 200 {
            return .low
        } else if avg < 800 {
            return .medium
        } else {
            return .high
        }
    }
    
    // Difficulty stars
    var difficultyStars: Int {
        difficultyLevel ?? 3
    }
    
    // Difficulty label
    var difficultyLabel: String? {
        guard let level = difficultyLevel else { return nil }
        switch level {
        case 1: return "Foarte simplu"
        case 2: return "Simplu"
        case 3: return "Mediu"
        case 4: return "Complex"
        case 5: return "Foarte complex"
        default: return nil
        }
    }
    
    enum PriceLevel {
        case low, medium, high
        
        var color: Color {
            switch self {
            case .low: return MecaroTheme.Colors.priceLow
            case .medium: return MecaroTheme.Colors.priceMedium
            case .high: return MecaroTheme.Colors.priceHigh
            }
        }
        
        var label: String {
            switch self {
            case .low: return "Preț accesibil"
            case .medium: return "Preț moderat"
            case .high: return "Preț ridicat"
            }
        }
    }
}


// MARK: - Price Benchmark

struct PriceBenchmark: Codable, Identifiable, Hashable {
    let id: UUID
    let procedureId: UUID
    let carModelId: UUID?
    
    // Statistical pricing (from community reviews)
    let p25Price: Int? // 25th percentile
    let medianPrice: Int // 50th percentile (median)
    let p75Price: Int? // 75th percentile
    
    // Labor vs Parts breakdown
    let medianLaborCost: Int?
    let medianPartsCost: Int?
    
    // Metadata
    let sampleSize: Int
    let lastUpdated: Date?
    
    // Related
    var procedure: Procedure?
    var carModel: CarModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case procedureId = "procedure_id"
        case carModelId = "car_model_id"
        case p25Price = "p25_price"
        case medianPrice = "median_price"
        case p75Price = "p75_price"
        case medianLaborCost = "median_labor_cost"
        case medianPartsCost = "median_parts_cost"
        case sampleSize = "sample_size"
        case lastUpdated = "last_updated"
    }
    
    // Has sufficient data
    var isReliable: Bool {
        sampleSize >= 5
    }
    
    // Price range formatted
    var priceRangeFormatted: String {
        if let p25 = p25Price, let p75 = p75Price {
            return "\(p25) - \(p75) RON"
        }
        return "\(medianPrice) RON"
    }
    
    // Median formatted
    var medianFormatted: String {
        "\(medianPrice) RON"
    }
    
    // Confidence label
    var confidenceLabel: String {
        if sampleSize >= 20 {
            return "Date foarte fiabile"
        } else if sampleSize >= 10 {
            return "Date fiabile"
        } else if sampleSize >= 5 {
            return "Date moderate"
        } else {
            return "Date limitate"
        }
    }
    
    // Sample size display
    var sampleSizeFormatted: String {
        if sampleSize == 1 {
            return "1 recenzie"
        }
        return "\(sampleSize) recenzii"
    }
    
    // Check if a price is an outlier (>2.5x median)
    func isOutlier(totalPrice: Int) -> Bool {
        totalPrice > medianPrice * 250 / 100 // 2.5x
    }
    
    // Check if price is within expected range
    func isWithinRange(totalPrice: Int) -> Bool {
        guard let p25 = p25Price, let p75 = p75Price else {
            // Without full range, use ±50% of median
            return totalPrice >= medianPrice / 2 && totalPrice <= medianPrice * 3 / 2
        }
        return totalPrice >= p25 && totalPrice <= p75
    }
}

// MARK: - Sample Data

extension PriceBenchmark {
    static let sample = PriceBenchmark(
        id: UUID(),
        procedureId: UUID(),
        carModelId: UUID(),
        p25Price: 180,
        medianPrice: 250,
        p75Price: 350,
        medianLaborCost: 120,
        medianPartsCost: 130,
        sampleSize: 23,
        lastUpdated: Date()
    )
    
    static let lowConfidence = PriceBenchmark(
        id: UUID(),
        procedureId: UUID(),
        carModelId: nil,
        p25Price: 800,
        medianPrice: 1200,
        p75Price: 1800,
        medianLaborCost: 600,
        medianPartsCost: 600,
        sampleSize: 6,
        lastUpdated: Date()
    )
}

// MARK: - Sample Data

extension ProcedureCategory {
    static let sample = ProcedureCategory(
        id: UUID(),
        name: "Maintenance",
        nameRo: "Întreținere",
        icon: "wrench.and.screwdriver.fill",
        color: "#4CAF50",
        sortOrder: 1,
        createdAt: Date()
    )
    
    static let samples: [ProcedureCategory] = [
        ProcedureCategory(id: UUID(), name: "Maintenance", nameRo: "Întreținere", icon: "wrench.and.screwdriver.fill", color: "#4CAF50", sortOrder: 1, createdAt: Date()),
        ProcedureCategory(id: UUID(), name: "Engine", nameRo: "Motor", icon: "engine.combustion.fill", color: "#F44336", sortOrder: 2, createdAt: Date()),
        ProcedureCategory(id: UUID(), name: "Brakes", nameRo: "Frâne", icon: "circle.circle", color: "#FF9800", sortOrder: 3, createdAt: Date()),
        ProcedureCategory(id: UUID(), name: "Tires", nameRo: "Anvelope", icon: "circle.fill", color: "#607D8B", sortOrder: 4, createdAt: Date()),
    ]
}

extension Procedure {
    static let sample = Procedure(
        id: UUID(),
        categoryId: UUID(),
        name: "Oil Change",
        nameRo: "Schimb ulei motor",
        description: "Oil and filter replacement",
        descriptionRo: "Înlocuire ulei motor și filtru ulei",
        icon: "drop.fill",
        estimatedDurationMinutes: 30,
        laborCostMin: 80,
        laborCostMax: 150,
        partsCostMin: 100,
        partsCostMax: 300,
        difficultyLevel: 1,
        requiresParts: true,
        isPartsIncluded: false,
        isCommon: true,
        sortOrder: 1,
        createdAt: Date()
    )
    
    static let samples: [Procedure] = [
        Procedure(
            id: UUID(),
            categoryId: UUID(),
            name: "Oil Change",
            nameRo: "Schimb ulei motor",
            description: nil,
            descriptionRo: "Înlocuire ulei motor și filtru ulei",
            icon: "drop.fill",
            estimatedDurationMinutes: 30,
            laborCostMin: 80,
            laborCostMax: 150,
            partsCostMin: 100,
            partsCostMax: 300,
            difficultyLevel: 1,
            requiresParts: true,
            isPartsIncluded: false,
            isCommon: true,
            sortOrder: 1,
            createdAt: Date()
        ),
        Procedure(
            id: UUID(),
            categoryId: UUID(),
            name: "Brake Pads Replacement",
            nameRo: "Înlocuire plăcuțe frână",
            description: nil,
            descriptionRo: "Înlocuire plăcuțe frână față sau spate",
            icon: "circle.circle",
            estimatedDurationMinutes: 60,
            laborCostMin: 100,
            laborCostMax: 200,
            partsCostMin: 150,
            partsCostMax: 500,
            difficultyLevel: 2,
            requiresParts: true,
            isPartsIncluded: false,
            isCommon: true,
            sortOrder: 2,
            createdAt: Date()
        ),
        Procedure(
            id: UUID(),
            categoryId: UUID(),
            name: "Timing Belt Replacement",
            nameRo: "Înlocuire curea distribuție",
            description: nil,
            descriptionRo: "Înlocuire kit distribuție complet (curea, role, pompa apa)",
            icon: "gearshape.2.fill",
            estimatedDurationMinutes: 240,
            laborCostMin: 400,
            laborCostMax: 800,
            partsCostMin: 600,
            partsCostMax: 1800,
            difficultyLevel: 4,
            requiresParts: true,
            isPartsIncluded: false,
            isCommon: true,
            sortOrder: 3,
            createdAt: Date()
        ),
        Procedure(
            id: UUID(),
            categoryId: UUID(),
            name: "Air Filter Replacement",
            nameRo: "Înlocuire filtru aer",
            description: nil,
            descriptionRo: "Înlocuire filtru aer motor",
            icon: "wind",
            estimatedDurationMinutes: 15,
            laborCostMin: 30,
            laborCostMax: 60,
            partsCostMin: 40,
            partsCostMax: 150,
            difficultyLevel: 1,
            requiresParts: true,
            isPartsIncluded: false,
            isCommon: true,
            sortOrder: 4,
            createdAt: Date()
        ),
    ]
}

