//
//  PlaceholderViews.swift
//  Mecaro
//
//  Placeholder views to be implemented
//

import SwiftUI
import Combine
import CoreLocation

// MARK: - Procedure Detail View

struct ProcedureDetailView: View {
    let procedure: Procedure
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProcedureDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: MecaroTheme.Spacing.lg) {
                // Header
                VStack(spacing: MecaroTheme.Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(MecaroTheme.Colors.primary.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: procedure.iconName)
                            .font(.system(size: 36))
                            .foregroundStyle(MecaroTheme.Colors.primary)
                    }
                    
                    Text(procedure.displayName)
                        .font(MecaroTheme.Typography.headlineLarge())
                        .foregroundStyle(MecaroTheme.Colors.text)
                        .multilineTextAlignment(.center)
                    
                    if let description = procedure.displayDescription {
                        Text(description)
                            .font(MecaroTheme.Typography.bodyMedium())
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, MecaroTheme.Spacing.lg)
                
                // Price estimate
                VStack(spacing: MecaroTheme.Spacing.sm) {
                    Text("Preț estimat")
                        .font(MecaroTheme.Typography.labelMedium())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    
                    if let price = procedure.totalPriceRangeFormatted {
                        Text(price)
                            .font(MecaroTheme.Typography.price())
                            .foregroundStyle(MecaroTheme.Colors.primary)
                    }
                    
                    if let duration = procedure.durationFormatted {
                        Label("Durată: ~\(duration)", systemImage: "clock")
                            .font(MecaroTheme.Typography.bodySmall())
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    }
                }
                .padding(MecaroTheme.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(MecaroTheme.Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.lg))
                .mecaroShadow(MecaroTheme.Shadows.sm)
                .padding(.horizontal, MecaroTheme.Spacing.md)
                
                // Services with this price
                VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
                    Text("Service-uri disponibile")
                        .font(MecaroTheme.Typography.labelLarge())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                        .padding(.horizontal, MecaroTheme.Spacing.md)
                    
                    ForEach(viewModel.services) { service in
                        ServiceRowWithPrice(service: service, procedure: procedure) {
                            appState.navigationPath.append(NavigationDestination.serviceDetail(service))
                        }
                    }
                }
            }
            .padding(.bottom, MecaroTheme.Spacing.xxxl)
        }
        .background(MecaroTheme.Colors.background)
        .navigationTitle("Detalii procedură")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadServices(for: procedure)
        }
    }
}

struct ServiceRowWithPrice: View {
    let service: CarService
    let procedure: Procedure
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MecaroTheme.Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.sm)
                        .fill(MecaroTheme.Colors.primary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundStyle(MecaroTheme.Colors.primary)
                }
                
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
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(MecaroTheme.Colors.star)
                            Text(service.ratingFormatted)
                        }
                        
                        if let distance = service.distanceFormatted {
                            HStack(spacing: 2) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 10))
                                Text(distance)
                            }
                        }
                    }
                    .font(MecaroTheme.Typography.labelSmall())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    if let price = procedure.totalPriceRangeFormatted {
                        Text(price)
                            .font(MecaroTheme.Typography.labelMedium())
                            .foregroundStyle(MecaroTheme.Colors.primary)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(MecaroTheme.Colors.textTertiary)
            }
            .padding(.horizontal, MecaroTheme.Spacing.md)
            .padding(.vertical, MecaroTheme.Spacing.sm)
            .background(MecaroTheme.Colors.surface)
        }
        .buttonStyle(.plain)
    }
}

@MainActor
class ProcedureDetailViewModel: ObservableObject {
    @Published var services: [CarService] = []
    @Published var isLoading = false
    
    func loadServices(for procedure: Procedure) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let location = await LocationService.shared.getCurrentLocation()
            services = try await SupabaseService.shared.fetchNearbyServices(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } catch {
            services = CarService.samples
        }
    }
}

// MARK: - Favorites View

struct FavoritesView: View {
    @EnvironmentObject var appState: AppState
    @State private var favorites: [CarService] = []
    
    var body: some View {
        Group {
            if favorites.isEmpty {
                VStack(spacing: MecaroTheme.Spacing.lg) {
                    Spacer()
                    
                    Image(systemName: "heart")
                        .font(.system(size: 60))
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                    
                    Text("Niciun favorit")
                        .font(MecaroTheme.Typography.headlineMedium())
                        .foregroundStyle(MecaroTheme.Colors.text)
                    
                    Text("Service-urile salvate vor apărea aici")
                        .font(MecaroTheme.Typography.bodyMedium())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: MecaroTheme.Spacing.sm) {
                        ForEach(favorites) { service in
                            ServiceListRow(service: service) {
                                appState.navigationPath.append(NavigationDestination.serviceDetail(service))
                            }
                        }
                    }
                    .padding(MecaroTheme.Spacing.md)
                }
            }
        }
        .background(MecaroTheme.Colors.background)
        .navigationTitle("Favorite")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Booking View

struct BookingView: View {
    let service: CarService
    let procedure: Procedure
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    @State private var selectedTimeSlot: TimeSlot = .morning
    @State private var notes = ""
    @State private var isSubmitting = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Service info
                Section {
                    HStack {
                        Text(service.name)
                            .font(MecaroTheme.Typography.labelLarge())
                        Spacer()
                        if service.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(MecaroTheme.Colors.success)
                        }
                    }
                    
                    Text(procedure.displayName)
                        .font(MecaroTheme.Typography.bodyMedium())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                } header: {
                    Text("Detalii programare")
                }
                
                // Date picker
                Section {
                    DatePicker("Data dorită", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                    
                    Picker("Interval orar", selection: $selectedTimeSlot) {
                        ForEach(TimeSlot.allCases, id: \.self) { slot in
                            Text(slot.displayName).tag(slot)
                        }
                    }
                } header: {
                    Text("Când")
                }
                
                // Notes
                Section {
                    TextField("Mesaj pentru service (opțional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Note")
                }
                
                // Price estimate
                Section {
                    HStack {
                        Text("Preț estimat")
                        Spacer()
                        if let price = procedure.totalPriceRangeFormatted {
                            Text(price)
                                .foregroundStyle(MecaroTheme.Colors.primary)
                        }
                    }
                } footer: {
                    Text("Prețul final poate varia în funcție de piesele necesare.")
                }
            }
            .navigationTitle("Programare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anulează") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        submitBooking()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Trimite")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
        }
    }
    
    private func submitBooking() {
        isSubmitting = true
        
        // TODO: Submit booking to backend
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isSubmitting = false
            dismiss()
        }
    }
}

// MARK: - Sign In View

struct SignInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: MecaroTheme.Spacing.lg) {
                // Logo
                VStack(spacing: MecaroTheme.Spacing.sm) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(MecaroTheme.Colors.primary)
                    
                    Text("Mecaro")
                        .font(MecaroTheme.Typography.displayMedium())
                        .foregroundStyle(MecaroTheme.Colors.text)
                }
                .padding(.top, MecaroTheme.Spacing.xxl)
                
                // Form
                VStack(spacing: MecaroTheme.Spacing.md) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(MecaroTheme.Colors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                    
                    SecureField("Parolă", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(MecaroTheme.Colors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(MecaroTheme.Typography.bodySmall())
                            .foregroundStyle(MecaroTheme.Colors.error)
                    }
                    
                    Button {
                        signIn()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Autentifică-te")
                        }
                    }
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MecaroTheme.Spacing.sm)
                    .background(MecaroTheme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                    
                    Button("Am uitat parola") {
                        // Reset password
                    }
                    .font(MecaroTheme.Typography.labelMedium())
                    .foregroundStyle(MecaroTheme.Colors.primary)
                }
                .padding(.horizontal, MecaroTheme.Spacing.lg)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Închide") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func signIn() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signIn(email: email, password: password)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - Sign Up View

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: MecaroTheme.Spacing.lg) {
                Text("Creează cont")
                    .font(MecaroTheme.Typography.displayMedium())
                    .foregroundStyle(MecaroTheme.Colors.text)
                    .padding(.top, MecaroTheme.Spacing.xxl)
                
                VStack(spacing: MecaroTheme.Spacing.md) {
                    TextField("Nume complet", text: $fullName)
                        .textContentType(.name)
                        .padding()
                        .background(MecaroTheme.Colors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(MecaroTheme.Colors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                    
                    SecureField("Parolă", text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(MecaroTheme.Colors.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(MecaroTheme.Typography.bodySmall())
                            .foregroundStyle(MecaroTheme.Colors.error)
                    }
                    
                    Button {
                        signUp()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Creează cont")
                        }
                    }
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MecaroTheme.Spacing.sm)
                    .background(MecaroTheme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                    .disabled(isLoading || email.isEmpty || password.isEmpty)
                }
                .padding(.horizontal, MecaroTheme.Spacing.lg)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Închide") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authService.signUp(email: email, password: password, fullName: fullName)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authService: AuthService
    
    @State private var fullName = ""
    @State private var phone = ""
    @State private var city = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nume complet", text: $fullName)
                    TextField("Telefon", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Oraș", text: $city)
                }
            }
            .navigationTitle("Editează profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Anulează") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvează") {
                        saveProfile()
                    }
                    .disabled(isLoading)
                }
            }
            .onAppear {
                if let profile = authService.userProfile {
                    fullName = profile.fullName ?? ""
                    phone = profile.phone ?? ""
                    city = profile.city ?? ""
                }
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        Task {
            let update = UpdateProfileRequest(
                fullName: fullName,
                phone: phone,
                city: city
            )
            
            try? await authService.updateProfile(update)
            dismiss()
        }
    }
}

