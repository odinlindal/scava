import SwiftUI

struct Theme {
    // Primary Colors
    static let primary = Color(red: 0.29, green: 0.18, blue: 0.49) // Deep Indigo
    static let primaryLight = Color(red: 0.35, green: 0.25, blue: 0.55)
    static let primaryDark = Color(red: 0.23, green: 0.13, blue: 0.43)
    
    // Secondary Colors
    static let secondary = Color(red: 0.95, green: 0.75, blue: 0.15) // Gold
    static let secondaryLight = Color(red: 1.0, green: 0.85, blue: 0.25)
    static let secondaryDark = Color(red: 0.9, green: 0.65, blue: 0.05)
    
    // Background Colors
    static let background = Color(red: 0.98, green: 0.98, blue: 0.98) // Off-white
    static let surface = Color.white
    
    // Text Colors
    static let textPrimary = Color.black
    static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
    static let textOnPrimary = Color.white
    static let textOnSecondary = Color.black
    
    // Status Colors
    static let success = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let error = Color(red: 0.9, green: 0.2, blue: 0.2)
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.0)
} 