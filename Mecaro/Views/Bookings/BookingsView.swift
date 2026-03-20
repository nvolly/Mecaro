//
//  BookingsView.swift
//  Mecaro
//
//  User's bookings/appointments list
//

import SwiftUI
import Combine
import Auth

struct BookingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = BookingsViewModel()
    
    @State private var selectedTab: BookingTab = .upcoming
    
    enum BookingTab: String, CaseIterable {
        case upcoming = "Viitoare"
        case past = "Trecute"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab picker
                Picker("", selection: $selectedTab) {
                    ForEach(BookingTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, MecaroTheme.Spacing.md)
                .padding(.vertical, MecaroTheme.Spacing.sm)
                
                // Content
                if !authService.isAuthenticated {
                    notLoggedInView
                } else if viewModel.isLoading {
                    loadingView
                } else if filteredBookings.isEmpty {
                    emptyView
                } else {
                    bookingsList
                }
            }
            .background(MecaroTheme.Colors.background)
            .navigationTitle("Programări")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if authService.isAuthenticated {
                    await viewModel.loadBookings()
                }
            }
        }
    }
    
    // MARK: - Filtered Bookings
    
    private var filteredBookings: [Booking] {
        switch selectedTab {
        case .upcoming:
            return viewModel.bookings.filter { !$0.isPast }
        case .past:
            return viewModel.bookings.filter { $0.isPast }
        }
    }
    
    // MARK: - Not Logged In View
    
    private var notLoggedInView: some View {
        VStack(spacing: MecaroTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
            
            Text("Autentifică-te")
                .font(MecaroTheme.Typography.headlineMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Text("Pentru a vedea programările tale, trebuie să fii autentificat.")
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MecaroTheme.Spacing.xl)
            
            Button {
                appState.selectedTab = .profile
            } label: {
                Text("Autentifică-te")
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(.white)
                    .padding(.horizontal, MecaroTheme.Spacing.xl)
                    .padding(.vertical, MecaroTheme.Spacing.sm)
                    .background(MecaroTheme.Colors.primary)
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(MecaroTheme.Colors.primary)
            Text("Se încarcă...")
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
            Spacer()
        }
    }
    
    // MARK: - Empty View
    
    private var emptyView: some View {
        VStack(spacing: MecaroTheme.Spacing.lg) {
            Spacer()
            
            Image(systemName: selectedTab == .upcoming ? "calendar" : "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
            
            Text(selectedTab == .upcoming ? "Nicio programare" : "Nicio programare trecută")
                .font(MecaroTheme.Typography.headlineMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Text(selectedTab == .upcoming ?
                 "Caută un service și fă prima ta programare!" :
                 "Programările finalizate vor apărea aici.")
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MecaroTheme.Spacing.xl)
            
            if selectedTab == .upcoming {
                Button {
                    appState.selectedTab = .map
                } label: {
                    Text("Caută service")
                        .font(MecaroTheme.Typography.labelLarge())
                        .foregroundStyle(.white)
                        .padding(.horizontal, MecaroTheme.Spacing.xl)
                        .padding(.vertical, MecaroTheme.Spacing.sm)
                        .background(MecaroTheme.Colors.primary)
                        .clipShape(Capsule())
                }
            }
            
            Spacer()
        }
    }
    
    // MARK: - Bookings List
    
    private var bookingsList: some View {
        ScrollView {
            LazyVStack(spacing: MecaroTheme.Spacing.sm) {
                ForEach(filteredBookings) { booking in
                    BookingCard(booking: booking) {
                        // Navigate to booking detail
                    }
                }
            }
            .padding(MecaroTheme.Spacing.md)
        }
    }
}

// MARK: - Booking Card

struct BookingCard: View {
    let booking: Booking
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MecaroTheme.Spacing.sm) {
                // Header with status
                HStack {
                    // Status badge
                    HStack(spacing: 4) {
                        Image(systemName: booking.bookingStatus.icon)
                            .font(.system(size: 12))
                        Text(booking.bookingStatus.displayName)
                            .font(MecaroTheme.Typography.labelSmall())
                    }
                    .foregroundStyle(Color(hex: booking.bookingStatus.color))
                    .padding(.horizontal, MecaroTheme.Spacing.sm)
                    .padding(.vertical, MecaroTheme.Spacing.xxs)
                    .background(Color(hex: booking.bookingStatus.color).opacity(0.1))
                    .clipShape(Capsule())
                    
                    Spacer()
                    
                    // Date
                    Text(booking.preferredDateShort)
                        .font(MecaroTheme.Typography.labelMedium())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                }
                
                Divider()
                
                // Service info
                HStack(spacing: MecaroTheme.Spacing.md) {
                    // Service icon
                    ZStack {
                        RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.sm)
                            .fill(MecaroTheme.Colors.primary.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundStyle(MecaroTheme.Colors.primary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.service?.name ?? "Service")
                            .font(MecaroTheme.Typography.labelLarge())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        Text(booking.procedure?.displayName ?? "Procedură")
                            .font(MecaroTheme.Typography.bodySmall())
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                        
                        if let slot = booking.timeSlot {
                            Text(slot.shortName)
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(MecaroTheme.Colors.textTertiary)
                        }
                    }
                    
                    Spacer()
                    
                    // Price
                    VStack(alignment: .trailing, spacing: 2) {
                        if let price = booking.finalPriceFormatted ?? booking.quotedPriceFormatted {
                            Text(price)
                                .font(MecaroTheme.Typography.labelLarge())
                                .foregroundStyle(MecaroTheme.Colors.primary)
                        }
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundStyle(MecaroTheme.Colors.textTertiary)
                    }
                }
                
                // Action buttons for pending/confirmed
                if booking.isEditable {
                    Divider()
                    
                    HStack(spacing: MecaroTheme.Spacing.md) {
                        if let phone = booking.service?.phone {
                            Button {
                                if let url = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Label("Sună", systemImage: "phone.fill")
                                    .font(MecaroTheme.Typography.labelSmall())
                                    .foregroundStyle(MecaroTheme.Colors.primary)
                            }
                        }
                        
                        Spacer()
                        
                        Button {
                            // Cancel booking
                        } label: {
                            Text("Anulează")
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(MecaroTheme.Colors.error)
                        }
                    }
                }
                
                // Leave review for completed
                if booking.canReview {
                    Divider()
                    
                    Button {
                        // Leave review
                    } label: {
                        Label("Lasă o recenzie", systemImage: "star.fill")
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(MecaroTheme.Colors.accent)
                    }
                }
            }
            .padding(MecaroTheme.Spacing.md)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            .mecaroShadow(MecaroTheme.Shadows.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Bookings View Model

@MainActor
class BookingsViewModel: ObservableObject {
    @Published var bookings: [Booking] = []
    @Published var isLoading = false
    
    func loadBookings() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            bookings = try await SupabaseService.shared.fetchUserBookings(userId: userId)
        } catch {
            print("Failed to load bookings: \(error)")
            // Use sample data for preview
            bookings = Booking.samples
        }
    }
}

// MARK: - Preview

#Preview {
    BookingsView()
        .environmentObject(AppState())
        .environmentObject(AuthService.shared)
}

