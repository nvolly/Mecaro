//
//  ServiceDetailView.swift
//  Mecaro
//
//  Detailed view of a car service/garage
//

import SwiftUI
import MapKit
import Combine
import Auth

struct ServiceDetailView: View {
    let service: CarService
    
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ServiceDetailViewModel()
    
    @State private var showAllReviews = false
    @State private var showBooking = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header with photo
                headerSection
                
                // Main content
                VStack(spacing: MecaroTheme.Spacing.lg) {
                    // Name and badges
                    infoSection
                    
                    // Quick actions
                    actionButtonsSection
                    
                    Divider()
                        .padding(.horizontal, MecaroTheme.Spacing.md)
                    
                    // About
                    if let description = service.displayDescription {
                        aboutSection(description)
                    }
                    
                    // Working hours
                    workingHoursSection
                    
                    Divider()
                        .padding(.horizontal, MecaroTheme.Spacing.md)
                    
                    // Prices preview
                    pricesSection
                    
                    Divider()
                        .padding(.horizontal, MecaroTheme.Spacing.md)
                    
                    // Reviews
                    reviewsSection
                    
                    // Location map
                    locationSection
                }
                .padding(.bottom, MecaroTheme.Spacing.xxxl)
            }
        }
        .background(MecaroTheme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: MecaroTheme.Spacing.sm) {
                    Button {
                        viewModel.toggleFavorite(serviceId: service.id)
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(viewModel.isFavorite ? .red : MecaroTheme.Colors.text)
                    }
                    
                    ShareLink(item: URL(string: "https://mecaro.ro/service/\(service.id)")!) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .task {
            await viewModel.loadData(serviceId: service.id)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient background
            LinearGradient(
                colors: [MecaroTheme.Colors.primary, MecaroTheme.Colors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            
            // Service logo/icon
            VStack {
                Spacer()
                HStack {
                    ZStack {
                        Circle()
                            .fill(MecaroTheme.Colors.surface)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(MecaroTheme.Colors.primary)
                    }
                    .offset(y: 40)
                    .padding(.leading, MecaroTheme.Spacing.md)
                    
                    Spacer()
                }
            }
        }
        .frame(height: 200)
    }
    
    // MARK: - Info Section
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            // Name and badges
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(service.name)
                            .font(MecaroTheme.Typography.headlineLarge())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        if service.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(MecaroTheme.Colors.success)
                        }
                        
                        if service.isFeatured {
                            Text("PRO")
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(MecaroTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                    }
                    
                    // Address
                    Text(service.address)
                        .font(MecaroTheme.Typography.bodyMedium())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    
                    Text(service.city)
                        .font(MecaroTheme.Typography.bodySmall())
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                }
                
                Spacer()
                
                // Rating
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(service.ratingFormatted)
                            .font(MecaroTheme.Typography.headlineMedium())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        Image(systemName: "star.fill")
                            .foregroundStyle(MecaroTheme.Colors.star)
                    }
                    
                    Text("\(service.reviewCount) recenzii")
                        .font(MecaroTheme.Typography.labelSmall())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                }
            }
            
            // Stats row
            HStack(spacing: MecaroTheme.Spacing.lg) {
                if let distance = service.distanceFormatted {
                    StatItem(icon: "location.fill", value: distance, label: "distanță")
                }
                
                StatItem(icon: "calendar", value: "\(service.bookingCount)", label: "programări")
                
                if service.isOpen {
                    StatItem(icon: "clock.fill", value: "Deschis", label: "acum", color: MecaroTheme.Colors.success)
                }
            }
        }
        .padding(.horizontal, MecaroTheme.Spacing.md)
        .padding(.top, 50)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsSection: some View {
        HStack(spacing: MecaroTheme.Spacing.sm) {
            // Call button
            if let phone = service.phone {
                Button {
                    if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Sună", systemImage: "phone.fill")
                        .font(MecaroTheme.Typography.labelMedium())
                        .foregroundStyle(MecaroTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MecaroTheme.Spacing.sm)
                        .background(MecaroTheme.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                }
            }
            
            // Directions button
            Button {
                openInMaps()
            } label: {
                Label("Direcții", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(MecaroTheme.Typography.labelMedium())
                    .foregroundStyle(MecaroTheme.Colors.info)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MecaroTheme.Spacing.sm)
                    .background(MecaroTheme.Colors.info.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            }
            
            // Book button
            Button {
                showBooking = true
            } label: {
                Label("Programează", systemImage: "calendar.badge.plus")
                    .font(MecaroTheme.Typography.labelMedium())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MecaroTheme.Spacing.sm)
                    .background(MecaroTheme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            }
        }
        .padding(.horizontal, MecaroTheme.Spacing.md)
    }
    
    // MARK: - About Section
    
    private func aboutSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            Text("Despre")
                .font(MecaroTheme.Typography.labelLarge())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
            
            Text(description)
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Working Hours Section
    
    private var workingHoursSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            Text("Program")
                .font(MecaroTheme.Typography.labelLarge())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
            
            // Simplified hours display
            VStack(spacing: MecaroTheme.Spacing.xs) {
                HoursRow(day: "Luni - Vineri", hours: "08:00 - 18:00")
                HoursRow(day: "Sâmbătă", hours: "09:00 - 14:00")
                HoursRow(day: "Duminică", hours: "Închis", isClosed: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Prices Section
    
    private var pricesSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            HStack {
                Text("Prețuri")
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                
                Spacer()
                
                Button("Vezi toate") {
                    // Navigate to full price list
                }
                .font(MecaroTheme.Typography.labelMedium())
                .foregroundStyle(MecaroTheme.Colors.primary)
            }
            
            // Sample prices
            ForEach(viewModel.prices.prefix(3)) { price in
                PriceRow(price: price)
            }
        }
        .padding(.horizontal, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Reviews Section
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            HStack {
                Text("Recenzii")
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                
                Spacer()
                
                Button("Vezi toate (\(service.reviewCount))") {
                    showAllReviews = true
                }
                .font(MecaroTheme.Typography.labelMedium())
                .foregroundStyle(MecaroTheme.Colors.primary)
            }
            
            // Rating summary
            RatingSummaryView(rating: service.rating, count: service.reviewCount)
            
            // Recent reviews
            ForEach(viewModel.reviews.prefix(2)) { review in
                ReviewCard(review: review)
            }
        }
        .padding(.horizontal, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Location Section
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            Text("Locație")
                .font(MecaroTheme.Typography.labelLarge())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
            
            if let coordinate = service.coordinate {
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )), annotationItems: [service]) { _ in
                    MapMarker(coordinate: coordinate, tint: MecaroTheme.Colors.primary)
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                .onTapGesture {
                    openInMaps()
                }
            }
        }
        .padding(.horizontal, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Helpers
    
    private func openInMaps() {
        guard let coordinate = service.coordinate else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = service.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = MecaroTheme.Colors.textSecondary
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(MecaroTheme.Typography.labelMedium())
                    .foregroundStyle(color)
                Text(label)
                    .font(MecaroTheme.Typography.labelSmall())
                    .foregroundStyle(MecaroTheme.Colors.textTertiary)
            }
        }
    }
}

struct HoursRow: View {
    let day: String
    let hours: String
    var isClosed: Bool = false
    
    var body: some View {
        HStack {
            Text(day)
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
            Spacer()
            Text(hours)
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(isClosed ? MecaroTheme.Colors.error : MecaroTheme.Colors.textSecondary)
        }
    }
}

struct PriceRow: View {
    let price: ServicePrice
    
    var body: some View {
        HStack {
            Text(price.procedure?.displayName ?? "Procedură")
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Spacer()
            
            Text(price.priceFormatted)
                .font(MecaroTheme.Typography.labelLarge())
                .foregroundStyle(MecaroTheme.Colors.primary)
        }
        .padding(.vertical, MecaroTheme.Spacing.xs)
    }
}

struct RatingSummaryView: View {
    let rating: Double
    let count: Int
    
    var body: some View {
        HStack(spacing: MecaroTheme.Spacing.lg) {
            // Big rating
            VStack(spacing: 4) {
                Text(String(format: "%.1f", rating))
                    .font(MecaroTheme.Typography.displayLarge())
                    .foregroundStyle(MecaroTheme.Colors.text)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(rating.rounded()) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundStyle(MecaroTheme.Colors.star)
                    }
                }
            }
            
            // Rating bars
            VStack(alignment: .leading, spacing: 4) {
                ForEach((1...5).reversed(), id: \.self) { star in
                    HStack(spacing: 4) {
                        Text("\(star)")
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(MecaroTheme.Colors.textTertiary)
                            .frame(width: 12)
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(MecaroTheme.Colors.border)
                                
                                Capsule()
                                    .fill(MecaroTheme.Colors.star)
                                    .frame(width: geo.size.width * randomPercentage(for: star))
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .padding(MecaroTheme.Spacing.md)
        .background(MecaroTheme.Colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
    }
    
    private func randomPercentage(for star: Int) -> Double {
        // Simplified - in production, use actual distribution
        switch star {
        case 5: return 0.6
        case 4: return 0.25
        case 3: return 0.1
        case 2: return 0.03
        case 1: return 0.02
        default: return 0
        }
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            // Header
            HStack {
                Circle()
                    .fill(MecaroTheme.Colors.primary.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(review.user?.initials ?? "?")
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(MecaroTheme.Colors.primary)
                    )
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(review.user?.displayName ?? "Utilizator")
                        .font(MecaroTheme.Typography.labelMedium())
                        .foregroundStyle(MecaroTheme.Colors.text)
                    
                    Text(review.dateShort)
                        .font(MecaroTheme.Typography.labelSmall())
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                }
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(0..<review.rating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(MecaroTheme.Colors.star)
                    }
                }
            }
            
            // Comment
            if let comment = review.comment {
                Text(comment)
                    .font(MecaroTheme.Typography.bodyMedium())
                    .foregroundStyle(MecaroTheme.Colors.text)
                    .lineLimit(3)
            }
            
            // Verified badge
            if review.isVerified {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 10))
                    Text("Vizită verificată")
                        .font(MecaroTheme.Typography.labelSmall())
                }
                .foregroundStyle(MecaroTheme.Colors.success)
            }
        }
        .padding(MecaroTheme.Spacing.sm)
        .background(MecaroTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
        .mecaroShadow(MecaroTheme.Shadows.sm)
    }
}

// MARK: - View Model

@MainActor
class ServiceDetailViewModel: ObservableObject {
    @Published var prices: [ServicePrice] = []
    @Published var reviews: [Review] = []
    @Published var isFavorite = false
    @Published var isLoading = false
    
    func loadData(serviceId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load prices
            prices = try await SupabaseService.shared.fetchServicePrices(serviceId: serviceId)
            
            // Load reviews
            reviews = try await SupabaseService.shared.fetchShopReviews(shopId: serviceId)
            
            // Check if favorite
            if let userId = AuthService.shared.currentUser?.id {
                isFavorite = try await SupabaseService.shared.isFavorite(userId: userId, serviceId: serviceId)
            }
        } catch {
            print("Failed to load service data: \(error)")
            // Use sample data
            prices = [ServicePrice.sample]
            reviews = Review.samples
        }
    }
    
    func toggleFavorite(serviceId: UUID) {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        Task {
            do {
                if isFavorite {
                    try await SupabaseService.shared.removeFavorite(userId: userId, serviceId: serviceId)
                } else {
                    try await SupabaseService.shared.addFavorite(userId: userId, serviceId: serviceId)
                }
                isFavorite.toggle()
            } catch {
                print("Failed to toggle favorite: \(error)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ServiceDetailView(service: CarService.sample)
            .environmentObject(AppState())
    }
}

