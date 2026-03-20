//
//  CurrencyFormatter.swift
//  Mecaro
//
//  Romanian currency formatting utilities
//

import Foundation

enum CurrencyFormatter {
    
    // MARK: - Romanian Lei Formatting
    
    /// Format price in Romanian Lei with proper locale
    /// Example: 1200 -> "1.200 lei"
    static func formatRON(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return "\(formatted) lei"
        }
        
        return "\(amount) lei"
    }
    
    /// Format price range in Romanian Lei
    /// Example: (1200, 1800) -> "1.200 - 1.800 lei"
    static func formatRONRange(_ min: Int, _ max: Int?) -> String {
        if let max = max, max != min {
            let minFormatted = formatRONValue(min)
            let maxFormatted = formatRONValue(max)
            return "\(minFormatted) - \(maxFormatted) lei"
        }
        return formatRON(min)
    }
    
    /// Format just the numeric value (no "lei" suffix)
    /// Example: 1200 -> "1.200"
    static func formatRONValue(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    /// Format with decimal precision (for averages)
    /// Example: 1234.56 -> "1.234,56 lei"
    static func formatRONDecimal(_ amount: Double, decimals: Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ro_RO")
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        
        if let formatted = formatter.string(from: NSNumber(value: amount)) {
            return "\(formatted) lei"
        }
        
        return String(format: "%.2f lei", amount)
    }
    
    // MARK: - Short Format (for UI constraints)
    
    /// Format price in short format (no thousands separator)
    /// Example: 1200 -> "1200 lei"
    static func formatRONShort(_ amount: Int) -> String {
        "\(amount) lei"
    }
    
    /// Format price in compact format (K for thousands)
    /// Example: 12000 -> "12K lei"
    static func formatRONCompact(_ amount: Int) -> String {
        if amount >= 1000 {
            let thousands = Double(amount) / 1000.0
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(thousands))K lei"
            }
            return String(format: "%.1fK lei", thousands)
        }
        return formatRON(amount)
    }
    
    // MARK: - Input Parsing
    
    /// Parse Romanian formatted currency string to Int
    /// Example: "1.200 lei" -> 1200
    static func parseRON(_ text: String) -> Int? {
        // Remove "lei", "RON", spaces, and dots
        let cleaned = text
            .replacingOccurrences(of: "lei", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "RON", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return Int(cleaned)
    }
    
    // MARK: - Validation
    
    /// Check if price is within reasonable range for car repairs
    static func isValidRepairPrice(_ amount: Int) -> Bool {
        // Reasonable range: 20 lei - 50,000 lei
        amount >= 20 && amount <= 50_000
    }
    
    /// Validate price range (min must be <= max)
    static func isValidPriceRange(min: Int, max: Int?) -> Bool {
        guard let max = max else { return true }
        return min <= max
    }
}

// MARK: - Int Extension

extension Int {
    /// Format this integer as Romanian Lei
    var asRON: String {
        CurrencyFormatter.formatRON(self)
    }
    
    /// Format this integer as compact Romanian Lei
    var asRONCompact: String {
        CurrencyFormatter.formatRONCompact(self)
    }
}

// MARK: - Double Extension

extension Double {
    /// Format this double as Romanian Lei with decimals
    func asRON(decimals: Int = 2) -> String {
        CurrencyFormatter.formatRONDecimal(self, decimals: decimals)
    }
}

// MARK: - String Extension

extension String {
    /// Parse this string as Romanian currency to Int
    var parseAsRON: Int? {
        CurrencyFormatter.parseRON(self)
    }
}

