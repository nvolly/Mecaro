//
//  MapTabView.swift
//  Mecaro
//
//  Map view showing nearby car services
//

import SwiftUI
import MapKit
import Combine

struct MapTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = MapViewModel()
    @StateObject private var locationService = LocationService.shared
    
    @State private var selectedService: CarService?
    @State private var showServiceSheet = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map
                mapView
                
                // Bottom controls
                VStack(spacing: MecaroTheme.Spacing.sm) {
                    // Location button
                    HStack {
                        Spacer()
                        
                        Button {
                            viewModel.centerOnUserLocation()
                        } label: {
                            Image(systemName: locationService.hasPermission ? "location.fill" : "location")
                                .font(.system(size: 20))
                                .foregroundStyle(MecaroTheme.Colors.primary)
                                .padding(MecaroTheme.Spacing.sm)
                                .background(MecaroTheme.Colors.surface)
                                .clipShape(Circle())
                                .mecaroShadow(MecaroTheme.Shadows.md)
                        }
                        .padding(.trailing, MecaroTheme.Spacing.md)
                    }
                    
                    // Service list toggle
                    serviceListToggle
                }
                
                // Service list sheet
                if viewModel.showList {
                    serviceListSheet
                }
            }
            .navigationTitle("Service-uri")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.sortBy = .distance
                        } label: {
                            Label("Distanță", systemImage: viewModel.sortBy == .distance ? "checkmark" : "")
                        }
                        
                        Button {
                            viewModel.sortBy = .rating
                        } label: {
                            Label("Rating", systemImage: viewModel.sortBy == .rating ? "checkmark" : "")
                        }
                        
                        Button {
                            viewModel.sortBy = .reviews
                        } label: {
                            Label("Recenzii", systemImage: viewModel.sortBy == .reviews ? "checkmark" : "")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .task {
                await viewModel.loadServices()
            }
            .sheet(item: $selectedService) { service in
                ServiceDetailSheet(service: service)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // MARK: - Map View
    
    private var mapView: some View {
        Map(
            coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: viewModel.services
        ) { service in
            MapAnnotation(coordinate: service.coordinate ?? CLLocationCoordinate2D()) {
                ServiceMapPin(
                    service: service,
                    isSelected: selectedService?.id == service.id
                ) {
                    selectedService = service
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Service List Toggle
    
    private var serviceListToggle: some View {
        Button {
            withAnimation(MecaroTheme.Animation.spring) {
                viewModel.showList.toggle()
            }
        } label: {
            HStack {
                Image(systemName: viewModel.showList ? "map.fill" : "list.bullet")
                Text(viewModel.showList ? "Hartă" : "Lista (\(viewModel.services.count))")
                    .font(MecaroTheme.Typography.labelMedium())
            }
            .foregroundStyle(MecaroTheme.Colors.text)
            .padding(.horizontal, MecaroTheme.Spacing.md)
            .padding(.vertical, MecaroTheme.Spacing.sm)
            .background(MecaroTheme.Colors.surface)
            .clipShape(Capsule())
            .mecaroShadow(MecaroTheme.Shadows.md)
        }
        .padding(.bottom, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Service List Sheet
    
    private var serviceListSheet: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(MecaroTheme.Colors.border)
                .frame(width: 40, height: 4)
                .padding(.top, MecaroTheme.Spacing.sm)
            
            // Header
            HStack {
                Text("\(viewModel.services.count) service-uri în zonă")
                    .font(MecaroTheme.Typography.headlineSmall())
                    .foregroundStyle(MecaroTheme.Colors.text)
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.showList = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, MecaroTheme.Spacing.md)
            .padding(.vertical, MecaroTheme.Spacing.sm)
            
            Divider()
            
            // List
            ScrollView {
                LazyVStack(spacing: MecaroTheme.Spacing.sm) {
                    ForEach(viewModel.sortedServices) { service in
                        ServiceListRow(service: service) {
                            selectedService = service
                            viewModel.showList = false
                            viewModel.centerOnService(service)
                        }
                    }
                }
                .padding(MecaroTheme.Spacing.md)
            }
        }
        .frame(height: 400)
        .background(MecaroTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.xl, style: .continuous))
        .mecaroShadow(MecaroTheme.Shadows.lg)
        .padding(.horizontal, MecaroTheme.Spacing.sm)
        .transition(.move(edge: .bottom))
    }
}

// MARK: - Service Map Pin

struct ServiceMapPin: View {
    let service: CarService
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isSelected ? MecaroTheme.Colors.primary : MecaroTheme.Colors.surface)
                        .frame(width: 44, height: 44)
                        .mecaroShadow(MecaroTheme.Shadows.md)
                    
                    if service.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(isSelected ? .white : MecaroTheme.Colors.success)
                    } else {
                        Image(systemName: "wrench.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(isSelected ? .white : MecaroTheme.Colors.primary)
                    }
                }
                
                // Triangle pointer
                Triangle()
                    .fill(isSelected ? MecaroTheme.Colors.primary : MecaroTheme.Colors.surface)
                    .frame(width: 12, height: 8)
                    .offset(y: -4)
            }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(MecaroTheme.Animation.quick, value: isSelected)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Service List Row

struct ServiceListRow: View {
    let service: CarService
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MecaroTheme.Spacing.md) {
                // Service icon
                ZStack {
                    RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.sm)
                        .fill(MecaroTheme.Colors.primary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundStyle(MecaroTheme.Colors.primary)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(service.name)
                            .font(MecaroTheme.Typography.labelLarge())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        if service.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(MecaroTheme.Colors.success)
                        }
                    }
                    
                    HStack(spacing: MecaroTheme.Spacing.sm) {
                        // Rating
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(MecaroTheme.Colors.star)
                            Text(service.ratingFormatted)
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(MecaroTheme.Colors.text)
                            Text("(\(service.reviewCount))")
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(MecaroTheme.Colors.textTertiary)
                        }
                        
                        // Distance
                        if let distance = service.distanceFormatted {
                            HStack(spacing: 2) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                Text(distance)
                                    .font(MecaroTheme.Typography.labelSmall())
                            }
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(MecaroTheme.Colors.textTertiary)
            }
            .padding(MecaroTheme.Spacing.sm)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            .mecaroShadow(MecaroTheme.Shadows.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Service Detail Sheet

struct ServiceDetailSheet: View {
    let service: CarService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ServiceDetailView(service: service)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(MecaroTheme.Colors.textTertiary)
                        }
                    }
                }
        }
    }
}

// MARK: - Map View Model

@MainActor
class MapViewModel: ObservableObject {
    @Published var services: [CarService] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 44.4268, longitude: 26.1025), // Bucharest
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Published var showList = false
    @Published var sortBy: SortOption = .distance
    @Published var isLoading = false
    
    enum SortOption {
        case distance, rating, reviews
    }
    
    var sortedServices: [CarService] {
        switch sortBy {
        case .distance:
            return services.sorted { ($0.distanceKm ?? 999) < ($1.distanceKm ?? 999) }
        case .rating:
            return services.sorted { $0.rating > $1.rating }
        case .reviews:
            return services.sorted { $0.reviewCount > $1.reviewCount }
        }
    }
    
    func loadServices() async {
        isLoading = true
        defer { isLoading = false }
        
        let location = await LocationService.shared.getCurrentLocation()
        
        // Update region to user location
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        
        do {
            services = try await SupabaseService.shared.fetchNearbyServices(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                radiusKm: 20
            )
        } catch {
            print("Failed to load services: \(error)")
            services = CarService.samples
        }
    }
    
    func centerOnUserLocation() {
        Task {
            let location = await LocationService.shared.getCurrentLocation()
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
    }
    
    func centerOnService(_ service: CarService) {
        guard let coordinate = service.coordinate else { return }
        withAnimation {
            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    MapTabView()
        .environmentObject(AppState())
}

