//
//  HomeView.swift
//  Mecaro
//
//  Main home screen with car selection and quick actions
//

import SwiftUI
import Combine
import CoreLocation

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService
    
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack(path: $appState.navigationPath) {
            ScrollView {
                VStack(spacing: MecaroTheme.Spacing.lg) {
                    // Header with greeting
                    headerSection
                    
                    // Selected car card
                    carSelectionCard
                    
                    // Quick actions
                    quickActionsSection
                    
                    // Common procedures
                    commonProceduresSection
                    
                    // Nearby services preview
                    nearbyServicesSection
                }
                .padding(.horizontal, MecaroTheme.Spacing.md)
                .padding(.bottom, MecaroTheme.Spacing.xxl)
            }
            .background(MecaroTheme.Colors.background)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "car.fill")
                            .foregroundStyle(MecaroTheme.Colors.primary)
                        Text("Mecaro")
                            .font(MecaroTheme.Typography.headlineMedium())
                            .foregroundStyle(MecaroTheme.Colors.text)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Show notifications
                    } label: {
                        Image(systemName: "bell")
                            .foregroundStyle(MecaroTheme.Colors.text)
                    }
                }
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.xxs) {
            Text(viewModel.greeting)
                .font(MecaroTheme.Typography.displayMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Text("Ce vrei să repari azi?")
                .font(MecaroTheme.Typography.bodyLarge())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Car Selection Card
    
    private var carSelectionCard: some View {
        Button {
            appState.navigationPath.append(NavigationDestination.carSelection)
        } label: {
            HStack(spacing: MecaroTheme.Spacing.md) {
                // Car icon
                ZStack {
                    Circle()
                        .fill(MecaroTheme.Colors.primary.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: appState.selectedCar != nil ? "car.fill" : "plus")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(MecaroTheme.Colors.primary)
                }
                
                // Car info
                VStack(alignment: .leading, spacing: 4) {
                    if let car = appState.selectedCar {
                        Text(car.shortName)
                            .font(MecaroTheme.Typography.headlineSmall())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        if let year = car.year {
                            Text("An fabricație: \(year)")
                                .font(MecaroTheme.Typography.bodySmall())
                                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                        }
                    } else {
                        Text("Selectează mașina ta")
                            .font(MecaroTheme.Typography.headlineSmall())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        Text("Pentru prețuri exacte")
                            .font(MecaroTheme.Typography.bodySmall())
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(MecaroTheme.Colors.textTertiary)
            }
            .padding(MecaroTheme.Spacing.md)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.lg))
            .mecaroShadow(MecaroTheme.Shadows.sm)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            Text("Acțiuni rapide")
                .font(MecaroTheme.Typography.labelLarge())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
            
            HStack(spacing: MecaroTheme.Spacing.sm) {
                QuickActionButton(
                    icon: "magnifyingglass",
                    title: "Caută preț",
                    color: MecaroTheme.Colors.primary
                ) {
                    appState.navigationPath.append(NavigationDestination.procedureSelection)
                }
                
                QuickActionButton(
                    icon: "map.fill",
                    title: "Service-uri",
                    color: MecaroTheme.Colors.info
                ) {
                    appState.selectedTab = .map
                }
                
                QuickActionButton(
                    icon: "doc.badge.gearshape.fill",
                    title: "Pregătire ITP",
                    color: MecaroTheme.Colors.warning
                ) {
                    // Navigate to ITP preparation
                }
                
                QuickActionButton(
                    icon: "star.fill",
                    title: "Favorite",
                    color: MecaroTheme.Colors.accent
                ) {
                    appState.navigationPath.append(NavigationDestination.favorites)
                }
            }
        }
    }
    
    // MARK: - Common Procedures
    
    private var commonProceduresSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            HStack {
                Text("Proceduri populare")
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                
                Spacer()
                
                Button("Vezi toate") {
                    appState.navigationPath.append(NavigationDestination.procedureSelection)
                }
                .font(MecaroTheme.Typography.labelMedium())
                .foregroundStyle(MecaroTheme.Colors.primary)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: MecaroTheme.Spacing.sm) {
                ForEach(viewModel.commonProcedures) { procedure in
                    ProcedureCard(procedure: procedure) {
                        appState.navigationPath.append(NavigationDestination.procedureDetail(procedure))
                    }
                }
            }
        }
    }
    
    // MARK: - Nearby Services
    
    private var nearbyServicesSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            HStack {
                Text("Service-uri din apropiere")
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                
                Spacer()
                
                Button("Hartă") {
                    appState.selectedTab = .map
                }
                .font(MecaroTheme.Typography.labelMedium())
                .foregroundStyle(MecaroTheme.Colors.primary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: MecaroTheme.Spacing.sm) {
                    ForEach(viewModel.nearbyServices) { service in
                        ServicePreviewCard(service: service) {
                            appState.navigationPath.append(NavigationDestination.serviceDetail(service))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Navigation Destinations
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .carSelection:
            CarSelectionView()
        case .procedureSelection:
            ProcedureSelectionView()
        case .procedureDetail(let procedure):
            ProcedureDetailView(procedure: procedure)
        case .serviceDetail(let service):
            ServiceDetailView(service: service)
        case .favorites:
            FavoritesView()
        case .booking(let service, let procedure):
            BookingView(service: service, procedure: procedure)
        }
    }
}

// MARK: - Navigation Destinations

enum NavigationDestination: Hashable {
    case carSelection
    case procedureSelection
    case procedureDetail(Procedure)
    case serviceDetail(CarService)
    case favorites
    case booking(CarService, Procedure)
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MecaroTheme.Spacing.xs) {
                ZStack {
                    RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md)
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(color)
                }
                
                Text(title)
                    .font(MecaroTheme.Typography.labelSmall())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, MecaroTheme.Spacing.sm)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Procedure Card

struct ProcedureCard: View {
    let procedure: Procedure
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: MecaroTheme.Spacing.xs) {
                HStack {
                    Image(systemName: procedure.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(MecaroTheme.Colors.primary)
                    
                    Spacer()
                    
                    if let price = procedure.totalPriceRangeFormatted {
                        Text(price)
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(procedure.priceLevel.color)
                    }
                }
                
                Text(procedure.displayName)
                    .font(MecaroTheme.Typography.labelMedium())
                    .foregroundStyle(MecaroTheme.Colors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let duration = procedure.durationFormatted {
                    Text("~\(duration)")
                        .font(MecaroTheme.Typography.labelSmall())
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                }
            }
            .padding(MecaroTheme.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            .mecaroShadow(MecaroTheme.Shadows.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Service Preview Card

struct ServicePreviewCard: View {
    let service: CarService
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: MecaroTheme.Spacing.xs) {
                // Rating and verified badge
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(MecaroTheme.Colors.star)
                        
                        Text(service.ratingFormatted)
                            .font(MecaroTheme.Typography.labelMedium())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        Text("(\(service.reviewCount))")
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(MecaroTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    if service.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(MecaroTheme.Colors.success)
                    }
                }
                
                Text(service.name)
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(MecaroTheme.Colors.text)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                    
                    if let distance = service.distanceFormatted {
                        Text(distance)
                    } else {
                        Text(service.city)
                    }
                }
                .font(MecaroTheme.Typography.labelSmall())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
            }
            .padding(MecaroTheme.Spacing.sm)
            .frame(width: 180)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            .mecaroShadow(MecaroTheme.Shadows.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Home View Model

@MainActor
class HomeViewModel: ObservableObject {
    @Published var commonProcedures: [Procedure] = []
    @Published var nearbyServices: [CarService] = []
    @Published var isLoading = false
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Bună dimineața! ☀️"
        case 12..<18: return "Bună ziua! 👋"
        case 18..<22: return "Bună seara! 🌙"
        default: return "Bună! 👋"
        }
    }
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load common procedures
        do {
            let procedures = try await SupabaseService.shared.fetchProcedures()
            commonProcedures = Array(procedures.filter { $0.isCommon }.prefix(4))
        } catch {
            print("Failed to load procedures: \(error)")
            commonProcedures = Array(Procedure.samples.prefix(4))
        }
        
        // Load nearby services
        do {
            let location = await LocationService.shared.getCurrentLocation()
            nearbyServices = try await SupabaseService.shared.fetchNearbyServices(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } catch {
            print("Failed to load services: \(error)")
            nearbyServices = CarService.samples
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AppState())
        .environmentObject(AuthService.shared)
}

