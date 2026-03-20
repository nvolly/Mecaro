//
//  Car.swift
//  Mecaro
//
//  Car brand and model data models
//

import Foundation

// MARK: - Car Brand

struct CarBrand: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let nameRo: String?
    let logoUrl: String?
    let country: String?
    let isPopular: Bool
    let sortOrder: Int
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, country
        case nameRo = "name_ro"
        case logoUrl = "logo_url"
        case isPopular = "is_popular"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
    }
    
    // Display name (use Romanian if available)
    var displayName: String {
        nameRo ?? name
    }
    
    // Flag emoji based on country
    var countryFlag: String {
        switch country?.lowercased() {
        case "romania": return "🇷🇴"
        case "germany": return "🇩🇪"
        case "france": return "🇫🇷"
        case "japan": return "🇯🇵"
        case "south korea": return "🇰🇷"
        case "italy": return "🇮🇹"
        case "czech republic": return "🇨🇿"
        case "sweden": return "🇸🇪"
        case "usa": return "🇺🇸"
        case "uk": return "🇬🇧"
        case "spain": return "🇪🇸"
        default: return "🚗"
        }
    }
}

// MARK: - Car Model

struct CarModel: Codable, Identifiable, Hashable {
    let id: UUID
    let brandId: UUID
    let name: String
    let yearStart: Int?
    let yearEnd: Int?
    let bodyType: String?
    let engineTypes: [String]?
    let isPopular: Bool
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case brandId = "brand_id"
        case yearStart = "year_start"
        case yearEnd = "year_end"
        case bodyType = "body_type"
        case engineTypes = "engine_types"
        case isPopular = "is_popular"
        case createdAt = "created_at"
    }
    
    // Year range display
    var yearRange: String {
        guard let start = yearStart else { return "" }
        if let end = yearEnd {
            return "\(start) - \(end)"
        } else {
            return "\(start) - prezent"
        }
    }
    
    // Body type icon
    var bodyTypeIcon: String {
        switch bodyType?.lowercased() {
        case "sedan": return "car.side"
        case "hatchback": return "car.fill"
        case "suv": return "suv.side.fill"
        case "mpv": return "car.top.door.front.left.and.front.right.open"
        case "coupe": return "car.side"
        case "wagon": return "car.side"
        default: return "car.fill"
        }
    }
    
    // Engine type icons
    var engineTypeIcons: [String] {
        engineTypes?.compactMap { engineType in
            switch engineType.lowercased() {
            case "petrol": return "fuelpump.fill"
            case "diesel": return "fuelpump.fill"
            case "electric": return "bolt.fill"
            case "hybrid": return "leaf.fill"
            case "lpg": return "flame.fill"
            default: return nil
            }
        } ?? []
    }
}

// MARK: - User's Car

struct UserCar: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: UUID
    let brandId: UUID
    let modelId: UUID
    let year: Int?
    let licensePlate: String?
    let nickname: String?
    let engineType: String?
    let isPrimary: Bool
    let createdAt: Date?
    
    // Related objects (fetched separately or via join)
    var brand: CarBrand?
    var model: CarModel?
    
    enum CodingKeys: String, CodingKey {
        case id, year, nickname
        case userId = "user_id"
        case brandId = "brand_id"
        case modelId = "model_id"
        case licensePlate = "license_plate"
        case engineType = "engine_type"
        case isPrimary = "is_primary"
        case createdAt = "created_at"
    }
    
    // Display name for the car
    var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return nickname
        }
        if let brand = brand, let model = model {
            if let year = year {
                return "\(brand.name) \(model.name) (\(year))"
            }
            return "\(brand.name) \(model.name)"
        }
        return "Mașina mea"
    }
    
    // Short display
    var shortName: String {
        if let brand = brand, let model = model {
            return "\(brand.name) \(model.name)"
        }
        return nickname ?? "Mașina mea"
    }
}

// MARK: - Sample Data (for previews)

extension CarBrand {
    static let sample = CarBrand(
        id: UUID(),
        name: "Dacia",
        nameRo: nil,
        logoUrl: nil,
        country: "Romania",
        isPopular: true,
        sortOrder: 1,
        createdAt: Date()
    )
    
    static let samples: [CarBrand] = [
        CarBrand(id: UUID(), name: "Dacia", nameRo: nil, logoUrl: nil, country: "Romania", isPopular: true, sortOrder: 1, createdAt: Date()),
        CarBrand(id: UUID(), name: "Volkswagen", nameRo: nil, logoUrl: nil, country: "Germany", isPopular: true, sortOrder: 2, createdAt: Date()),
        CarBrand(id: UUID(), name: "BMW", nameRo: nil, logoUrl: nil, country: "Germany", isPopular: true, sortOrder: 3, createdAt: Date()),
        CarBrand(id: UUID(), name: "Toyota", nameRo: nil, logoUrl: nil, country: "Japan", isPopular: true, sortOrder: 4, createdAt: Date()),
    ]
}

extension CarModel {
    static let sample = CarModel(
        id: UUID(),
        brandId: UUID(),
        name: "Logan",
        yearStart: 2020,
        yearEnd: nil,
        bodyType: "sedan",
        engineTypes: ["petrol", "diesel", "lpg"],
        isPopular: true,
        createdAt: Date()
    )
}

extension UserCar {
    static let sample: UserCar = {
        var car = UserCar(
            id: UUID(),
            userId: UUID(),
            brandId: UUID(),
            modelId: UUID(),
            year: 2020,
            licensePlate: "B 123 ABC",
            nickname: "Daily Driver",
            engineType: "petrol",
            isPrimary: true,
            createdAt: Date()
        )
        car.brand = CarBrand.sample
        car.model = CarModel.sample
        return car
    }()
}

