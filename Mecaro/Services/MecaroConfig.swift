//
//  Config.swift
//  Mecaro
//
//  Configuration with Supabase credentials
//

import Foundation

enum Config {
    
    // MARK: - Supabase Configuration
    
    /// Your Supabase project URL
    static let supabaseURL: String = "https://vsgxzbrvabrxrzeynkyo.supabase.co"
    
    /// Your Supabase anonymous (public) key
    static let supabaseAnonKey: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzZ3h6YnJ2YWJyeHJ6ZXlua3lvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczNDQ2ODMsImV4cCI6MjA4MjkyMDY4M30.nZlW96hFd0Mwb89m4c4wzKqFBvfmiAQadMc3a_HtJRk"
    
    // MARK: - App Configuration
    
    static let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }()
    
    static let buildNumber: String = {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }()
    
    static let bundleIdentifier: String = {
        Bundle.main.bundleIdentifier ?? "com.mecaro.app"
    }()
    
    // MARK: - Feature Flags
    
    static let isDebugMode: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    static let useSampleDataWhenOffline: Bool = isDebugMode
    static let enableAnalytics: Bool = !isDebugMode
    
    // MARK: - API Configuration
    
    static let requestTimeout: TimeInterval = 30
    static let maxUploadSize: Int = 10 * 1024 * 1024
    static let allowedImageFormats: [String] = ["jpg", "jpeg", "png", "heic"]
    
    // MARK: - Map Configuration
    
    static let defaultSearchRadius: Int = 20
    static let maxSearchRadius: Int = 100
    
    // MARK: - Review Configuration
    
    static let minSampleSizeForBenchmark: Int = 5
    static let outlierThresholdMultiplier: Double = 2.5
    static let maxReviewCommentLength: Int = 500
    
    // MARK: - Localization
    
    static let defaultLanguage: String = "ro"
    static let supportedLanguages: [String] = ["ro", "en"]
    static let currencyCode: String = "RON"
    static let romanianLocale: Locale = Locale(identifier: "ro_RO")
    
    // MARK: - Romanian Market Specifics
    
    static let anafAPIURL: String = "https://webservicesp.anaf.ro/PlatitorTvaRest/api/v6/ws/tva"
    static let romanianPhonePrefix: String = "+40"
    
    static let majorCities: [String] = [
        "București", "Cluj-Napoca", "Timișoara", "Iași", "Constanța",
        "Craiova", "Brașov", "Galați", "Ploiești", "Oradea"
    ]
    
    // MARK: - Validation
    
    static func validate() throws {
        guard !supabaseURL.isEmpty else {
            throw ConfigError.invalidConfiguration("Supabase URL not configured")
        }
        
        guard !supabaseAnonKey.isEmpty else {
            throw ConfigError.invalidConfiguration("Supabase anon key not configured")
        }
        
        guard URL(string: supabaseURL) != nil else {
            throw ConfigError.invalidConfiguration("Invalid Supabase URL format")
        }
    }
}

// MARK: - Errors

enum ConfigError: LocalizedError {
    case invalidConfiguration(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return "Eroare configurare: \(message)"
        }
    }
}
