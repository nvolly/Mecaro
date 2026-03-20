//
//  Booking.swift
//  Mecaro
//
//  Booking and appointment data models
//

import Foundation

// MARK: - Booking Status

enum BookingStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case confirmed = "confirmed"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending: return "În așteptare"
        case .confirmed: return "Confirmat"
        case .inProgress: return "În lucru"
        case .completed: return "Finalizat"
        case .cancelled: return "Anulat"
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock.fill"
        case .confirmed: return "checkmark.circle.fill"
        case .inProgress: return "wrench.and.screwdriver.fill"
        case .completed: return "checkmark.seal.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .pending: return "#F59E0B"     // Amber
        case .confirmed: return "#3B82F6"   // Blue
        case .inProgress: return "#8B5CF6"  // Purple
        case .completed: return "#10B981"   // Green
        case .cancelled: return "#EF4444"   // Red
        }
    }
}

// MARK: - Time Slot

enum TimeSlot: String, Codable, CaseIterable {
    case morning = "morning"
    case afternoon = "afternoon"
    case flexible = "flexible"
    
    var displayName: String {
        switch self {
        case .morning: return "Dimineață (08:00 - 12:00)"
        case .afternoon: return "După-amiază (12:00 - 18:00)"
        case .flexible: return "Flexibil"
        }
    }
    
    var shortName: String {
        switch self {
        case .morning: return "Dimineață"
        case .afternoon: return "După-amiază"
        case .flexible: return "Flexibil"
        }
    }
}

// MARK: - Booking

struct Booking: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let serviceId: UUID
    let procedureId: UUID
    let userCarId: UUID?
    
    // When
    let preferredDate: Date
    let preferredTimeSlot: String?
    let confirmedDate: Date?
    let confirmedTime: String?
    
    // Status
    let status: String
    
    // Pricing
    let quotedPriceMin: Int?
    let quotedPriceMax: Int?
    let finalPrice: Int?
    let currency: String
    
    // Notes
    let userNotes: String?
    let serviceNotes: String?
    
    // Metadata
    let createdAt: Date?
    let updatedAt: Date?
    
    // Related objects
    var service: CarService?
    var procedure: Procedure?
    var userCar: UserCar?
    
    enum CodingKeys: String, CodingKey {
        case id, status, currency
        case userId = "user_id"
        case serviceId = "service_id"
        case procedureId = "procedure_id"
        case userCarId = "user_car_id"
        case preferredDate = "preferred_date"
        case preferredTimeSlot = "preferred_time_slot"
        case confirmedDate = "confirmed_date"
        case confirmedTime = "confirmed_time"
        case quotedPriceMin = "quoted_price_min"
        case quotedPriceMax = "quoted_price_max"
        case finalPrice = "final_price"
        case userNotes = "user_notes"
        case serviceNotes = "service_notes"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Status enum
    var bookingStatus: BookingStatus {
        BookingStatus(rawValue: status) ?? .pending
    }
    
    // Time slot enum
    var timeSlot: TimeSlot? {
        guard let slot = preferredTimeSlot else { return nil }
        return TimeSlot(rawValue: slot)
    }
    
    // Formatted date
    var preferredDateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: preferredDate).capitalized
    }
    
    // Short date
    var preferredDateShort: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: preferredDate)
    }
    
    // Quoted price formatted
    var quotedPriceFormatted: String? {
        guard let min = quotedPriceMin else { return nil }
        if let max = quotedPriceMax, max != min {
            return "\(min) - \(max) \(currency)"
        }
        return "\(min) \(currency)"
    }
    
    // Final price formatted
    var finalPriceFormatted: String? {
        guard let price = finalPrice else { return nil }
        return "\(price) \(currency)"
    }
    
    // Is editable (can cancel)
    var isEditable: Bool {
        bookingStatus == .pending || bookingStatus == .confirmed
    }
    
    // Is past
    var isPast: Bool {
        preferredDate < Date()
    }
    
    // Can leave review
    var canReview: Bool {
        bookingStatus == .completed
    }
}

// MARK: - New Booking Request

struct NewBookingRequest: Codable {
    let serviceId: UUID
    let procedureId: UUID
    let userCarId: UUID?
    let preferredDate: Date
    let preferredTimeSlot: String
    let userNotes: String?
    
    enum CodingKeys: String, CodingKey {
        case serviceId = "service_id"
        case procedureId = "procedure_id"
        case userCarId = "user_car_id"
        case preferredDate = "preferred_date"
        case preferredTimeSlot = "preferred_time_slot"
        case userNotes = "user_notes"
    }
}

// MARK: - Sample Data

extension Booking {
    static let sample: Booking = {
        var booking = Booking(
            id: UUID(),
            userId: UUID(),
            serviceId: UUID(),
            procedureId: UUID(),
            userCarId: UUID(),
            preferredDate: Date().addingTimeInterval(3 * 24 * 60 * 60),
            preferredTimeSlot: "morning",
            confirmedDate: nil,
            confirmedTime: nil,
            status: "pending",
            quotedPriceMin: 200,
            quotedPriceMax: 350,
            finalPrice: nil,
            currency: "RON",
            userNotes: "Prefer să fiu sunat înainte",
            serviceNotes: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        booking.service = CarService.sample
        booking.procedure = Procedure.sample
        booking.userCar = UserCar.sample
        return booking
    }()
    
    static let samples: [Booking] = [
        sample,
        {
            var booking = Booking(
                id: UUID(),
                userId: UUID(),
                serviceId: UUID(),
                procedureId: UUID(),
                userCarId: UUID(),
                preferredDate: Date().addingTimeInterval(-7 * 24 * 60 * 60),
                preferredTimeSlot: "afternoon",
                confirmedDate: Date().addingTimeInterval(-7 * 24 * 60 * 60),
                confirmedTime: "14:00",
                status: "completed",
                quotedPriceMin: 180,
                quotedPriceMax: nil,
                finalPrice: 180,
                currency: "RON",
                userNotes: nil,
                serviceNotes: "Totul ok, mașina a fost gata în 30 min",
                createdAt: Date().addingTimeInterval(-10 * 24 * 60 * 60),
                updatedAt: Date().addingTimeInterval(-7 * 24 * 60 * 60)
            )
            booking.service = CarService.samples[1]
            booking.procedure = Procedure.samples[0]
            return booking
        }(),
    ]
}

