//
//  ContentView.swift
//  Mecaro
//
//  Main navigation container
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService
    
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if authService.isLoading {
                // Loading screen while checking auth state
                LaunchScreen()
            } else if showOnboarding {
                // First-time user onboarding
                OnboardingView(showOnboarding: $showOnboarding)
            } else {
                // Main app
                MainTabView()
            }
        }
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private func checkOnboardingStatus() {
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        showOnboarding = !hasSeenOnboarding
    }
}

// MARK: - Launch Screen

struct LaunchScreen: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            MecaroTheme.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "car.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(MecaroTheme.Colors.primary)
                    .scaleEffect(scale)
                
                Text("Mecaro")
                    .font(.custom("Avenir-Heavy", size: 42))
                    .foregroundStyle(MecaroTheme.Colors.text)
                
                Text("Găsește cel mai bun preț")
                    .font(.custom("Avenir-Medium", size: 18))
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
            }
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Acasă", systemImage: "house.fill")
                }
                .tag(AppState.Tab.home)
            
            SearchView()
                .tabItem {
                    Label("Caută", systemImage: "magnifyingglass")
                }
                .tag(AppState.Tab.search)
            
            MapTabView()
                .tabItem {
                    Label("Hartă", systemImage: "map.fill")
                }
                .tag(AppState.Tab.map)
            
            BookingsView()
                .tabItem {
                    Label("Programări", systemImage: "calendar")
                }
                .tag(AppState.Tab.bookings)
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
                .tag(AppState.Tab.profile)
        }
        .tint(MecaroTheme.Colors.primary)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(AuthService.shared)
}

