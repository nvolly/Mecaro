//
//  MecaroApp.swift
//  Mecaro
//
//  Romanian Car Service Marketplace
//

import SwiftUI
import Combine

@main
struct MecaroApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authService = AuthService.shared
    
    init() {
        // Configure appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authService)
                .preferredColorScheme(appState.colorScheme)
        }
    }
    
    private func configureAppearance() {
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(MecaroTheme.Colors.background)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(MecaroTheme.Colors.text)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(MecaroTheme.Colors.text)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(MecaroTheme.Colors.background)
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var selectedTab: Tab = .home
    @Published var colorScheme: ColorScheme? = nil
    
    // User's selected car (persisted)
    @Published var selectedCar: UserCar?
    
    // Navigation state
    @Published var navigationPath = NavigationPath()
    
    enum Tab: Int {
        case home = 0
        case search = 1
        case map = 2
        case bookings = 3
        case profile = 4
    }
    
    func reset() {
        selectedTab = .home
        navigationPath = NavigationPath()
    }
}

