//
//  MecaroTheme.swift
//  Mecaro
//
//  Design system and theme configuration
//

import SwiftUI

enum MecaroTheme {
    
    // MARK: - Colors
    
    enum Colors {
        // Primary brand colors - Deep teal with warm accents
        static let primary = Color(hex: "0D9488")       // Teal 600
        static let primaryLight = Color(hex: "14B8A6")  // Teal 500
        static let primaryDark = Color(hex: "0F766E")   // Teal 700
        
        // Accent colors - Warm amber for CTAs
        static let accent = Color(hex: "F59E0B")        // Amber 500
        static let accentLight = Color(hex: "FBBF24")   // Amber 400
        
        // Semantic colors
        static let success = Color(hex: "10B981")       // Emerald 500
        static let warning = Color(hex: "F59E0B")       // Amber 500
        static let error = Color(hex: "EF4444")         // Red 500
        static let info = Color(hex: "3B82F6")          // Blue 500
        
        // Background colors
        static let background = Color(hex: "FAFAFA")    // Neutral 50
        static let backgroundSecondary = Color(hex: "F5F5F5") // Neutral 100
        static let surface = Color.white
        static let surfaceElevated = Color.white
        
        // Text colors
        static let text = Color(hex: "171717")          // Neutral 900
        static let textSecondary = Color(hex: "525252") // Neutral 600
        static let textTertiary = Color(hex: "A3A3A3")  // Neutral 400
        static let textOnPrimary = Color.white
        
        // Border colors
        static let border = Color(hex: "E5E5E5")        // Neutral 200
        static let borderFocused = primary
        
        // Rating stars
        static let star = Color(hex: "FBBF24")          // Amber 400
        static let starEmpty = Color(hex: "D4D4D4")     // Neutral 300
        
        // Map & Location
        static let mapPin = primary
        static let mapPinSelected = accent
        static let userLocation = Color(hex: "3B82F6")  // Blue 500
        
        // Price ranges
        static let priceLow = Color(hex: "10B981")      // Green
        static let priceMedium = Color(hex: "F59E0B")   // Amber
        static let priceHigh = Color(hex: "EF4444")     // Red
    }
    
    // MARK: - Typography
    
    enum Typography {
        // Display
        static func displayLarge() -> Font {
            .custom("Avenir-Heavy", size: 34)
        }
        
        static func displayMedium() -> Font {
            .custom("Avenir-Heavy", size: 28)
        }
        
        // Headlines
        static func headlineLarge() -> Font {
            .custom("Avenir-Heavy", size: 24)
        }
        
        static func headlineMedium() -> Font {
            .custom("Avenir-Medium", size: 20)
        }
        
        static func headlineSmall() -> Font {
            .custom("Avenir-Medium", size: 18)
        }
        
        // Body
        static func bodyLarge() -> Font {
            .custom("Avenir-Medium", size: 17)
        }
        
        static func bodyMedium() -> Font {
            .custom("Avenir-Book", size: 15)
        }
        
        static func bodySmall() -> Font {
            .custom("Avenir-Book", size: 13)
        }
        
        // Labels
        static func labelLarge() -> Font {
            .custom("Avenir-Heavy", size: 15)
        }
        
        static func labelMedium() -> Font {
            .custom("Avenir-Medium", size: 13)
        }
        
        static func labelSmall() -> Font {
            .custom("Avenir-Medium", size: 11)
        }
        
        // Price
        static func price() -> Font {
            .custom("Avenir-Heavy", size: 22)
        }
        
        static func priceSmall() -> Font {
            .custom("Avenir-Heavy", size: 17)
        }
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let full: CGFloat = 9999
    }
    
    // MARK: - Shadows
    
    enum Shadows {
        static let sm = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        static let md = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let lg = Shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
    }
    
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Extension for Shadows

extension View {
    func mecaroShadow(_ shadow: MecaroTheme.Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

