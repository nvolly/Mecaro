//
//  User.swift
//  Mecaro
//
//  User profile data model
//

import Foundation

// MARK: - User Profile

struct UserProfile: Codable, Identifiable {
    let id: UUID
    var email: String?
    var fullName: String?
    var phone: String?
    var avatarUrl: String?
    var preferredCarId: UUID?
    var city: String?
    var notificationEnabled: Bool
    var isServiceOwner: Bool
    var language: String
    let createdAt: Date?
    var updatedAt: Date?
    
    // Related
    var preferredCar: UserCar?
    var cars: [UserCar]?
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone, city, language
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case preferredCarId = "preferred_car_id"
        case notificationEnabled = "notification_enabled"
        case isServiceOwner = "is_service_owner"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Display name
    var displayName: String {
        if let name = fullName, !name.isEmpty {
            return name
        }
        if let email = email {
            return email.components(separatedBy: "@").first ?? email
        }
        return "Utilizator"
    }
    
    // Initials for avatar
    var initials: String {
        guard let name = fullName else { return "?" }
        let components = name.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
    
    // Has complete profile
    var isProfileComplete: Bool {
        fullName != nil && !fullName!.isEmpty &&
        phone != nil && !phone!.isEmpty
    }
    
    // Member since formatted
    var memberSinceFormatted: String {
        guard let date = createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.dateFormat = "MMMM yyyy"
        return "Membru din " + formatter.string(from: date).capitalized
    }
}

// MARK: - Update Profile Request

struct UpdateProfileRequest: Codable {
    var fullName: String?
    var phone: String?
    var city: String?
    var notificationEnabled: Bool?
    var language: String?
    var preferredCarId: UUID?
    
    enum CodingKeys: String, CodingKey {
        case phone, city, language
        case fullName = "full_name"
        case notificationEnabled = "notification_enabled"
        case preferredCarId = "preferred_car_id"
    }
}

// MARK: - Auth User (from Supabase Auth)

struct AuthUser: Codable {
    let id: UUID
    let email: String?
    let phone: String?
    let createdAt: Date?
    let updatedAt: Date?
    let emailConfirmedAt: Date?
    let phoneConfirmedAt: Date?
    let lastSignInAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case emailConfirmedAt = "email_confirmed_at"
        case phoneConfirmedAt = "phone_confirmed_at"
        case lastSignInAt = "last_sign_in_at"
    }
    
    var isEmailVerified: Bool {
        emailConfirmedAt != nil
    }
    
    var isPhoneVerified: Bool {
        phoneConfirmedAt != nil
    }
}

// MARK: - Sample Data

extension UserProfile {
    static let sample = UserProfile(
        id: UUID(),
        email: "ion.popescu@email.com",
        fullName: "Ion Popescu",
        phone: "0722123456",
        avatarUrl: nil,
        preferredCarId: nil,
        city: "București",
        notificationEnabled: true,
        isServiceOwner: false,
        language: "ro",
        createdAt: Date().addingTimeInterval(-90 * 24 * 60 * 60),
        updatedAt: Date()
    )
    
    static let empty = UserProfile(
        id: UUID(),
        email: nil,
        fullName: nil,
        phone: nil,
        avatarUrl: nil,
        preferredCarId: nil,
        city: nil,
        notificationEnabled: true,
        isServiceOwner: false,
        language: "ro",
        createdAt: Date(),
        updatedAt: nil
    )
}

