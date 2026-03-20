//
//  ProfileView.swift
//  Mecaro
//
//  User profile and settings
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authService: AuthService
    
    @State private var showSignIn = false
    @State private var showSignUp = false
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: MecaroTheme.Spacing.lg) {
                    if authService.isAuthenticated {
                        // User profile
                        authenticatedView
                    } else {
                        // Sign in prompt
                        signInPrompt
                    }
                    
                    // Settings sections
                    settingsSections
                    
                    // App info
                    appInfoSection
                }
                .padding(.bottom, MecaroTheme.Spacing.xxxl)
            }
            .background(MecaroTheme.Colors.background)
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSignIn) {
                SignInView()
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
            }
        }
    }
    
    // MARK: - Authenticated View
    
    private var authenticatedView: some View {
        VStack(spacing: MecaroTheme.Spacing.md) {
            // Profile header
            HStack(spacing: MecaroTheme.Spacing.md) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(MecaroTheme.Colors.primary.opacity(0.1))
                        .frame(width: 70, height: 70)
                    
                    Text(authService.userProfile?.initials ?? "?")
                        .font(MecaroTheme.Typography.headlineLarge())
                        .foregroundStyle(MecaroTheme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(authService.userProfile?.displayName ?? "Utilizator")
                        .font(MecaroTheme.Typography.headlineSmall())
                        .foregroundStyle(MecaroTheme.Colors.text)
                    
                    if let email = authService.userProfile?.email {
                        Text(email)
                            .font(MecaroTheme.Typography.bodySmall())
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    }
                    
                    Text(authService.userProfile?.memberSinceFormatted ?? "")
                        .font(MecaroTheme.Typography.labelSmall())
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                }
                
                Spacer()
                
                Button {
                    showEditProfile = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(MecaroTheme.Colors.primary)
                }
            }
            .padding(MecaroTheme.Spacing.md)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.lg))
            .mecaroShadow(MecaroTheme.Shadows.sm)
            .padding(.horizontal, MecaroTheme.Spacing.md)
            
            // My car
            if let car = appState.selectedCar {
                Button {
                    appState.navigationPath.append(NavigationDestination.carSelection)
                } label: {
                    HStack(spacing: MecaroTheme.Spacing.md) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(MecaroTheme.Colors.primary)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mașina mea")
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                            Text(car.displayName)
                                .font(MecaroTheme.Typography.labelLarge())
                                .foregroundStyle(MecaroTheme.Colors.text)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(MecaroTheme.Colors.textTertiary)
                    }
                    .padding(MecaroTheme.Spacing.md)
                    .background(MecaroTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, MecaroTheme.Spacing.md)
            }
        }
    }
    
    // MARK: - Sign In Prompt
    
    private var signInPrompt: some View {
        VStack(spacing: MecaroTheme.Spacing.md) {
            Image(systemName: "person.circle")
                .font(.system(size: 60))
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
            
            Text("Bine ai venit!")
                .font(MecaroTheme.Typography.headlineMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Text("Autentifică-te pentru a salva programările și preferințele tale.")
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, MecaroTheme.Spacing.lg)
            
            VStack(spacing: MecaroTheme.Spacing.sm) {
                Button {
                    showSignIn = true
                } label: {
                    Text("Autentifică-te")
                        .font(MecaroTheme.Typography.labelLarge())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MecaroTheme.Spacing.sm)
                        .background(MecaroTheme.Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                }
                
                Button {
                    showSignUp = true
                } label: {
                    Text("Creează cont")
                        .font(MecaroTheme.Typography.labelLarge())
                        .foregroundStyle(MecaroTheme.Colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, MecaroTheme.Spacing.sm)
                        .background(MecaroTheme.Colors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                }
            }
            .padding(.horizontal, MecaroTheme.Spacing.xl)
        }
        .padding(.vertical, MecaroTheme.Spacing.xl)
    }
    
    // MARK: - Settings Sections
    
    private var settingsSections: some View {
        VStack(spacing: MecaroTheme.Spacing.md) {
            // Quick links
            SettingsSection(title: "Quick Links") {
                SettingsRow(icon: "heart.fill", title: "Favorite", color: .red) {
                    // Navigate to favorites
                }
                
                SettingsRow(icon: "clock.fill", title: "Istoric căutări", color: MecaroTheme.Colors.info) {
                    // Navigate to history
                }
            }
            
            // Preferences
            SettingsSection(title: "Preferințe") {
                SettingsRow(icon: "bell.fill", title: "Notificări", color: MecaroTheme.Colors.warning) {
                    // Notifications settings
                }
                
                SettingsRow(icon: "globe", title: "Limbă", color: MecaroTheme.Colors.success) {
                    // Language settings
                }
                
                SettingsRow(icon: "moon.fill", title: "Temă", color: .purple) {
                    // Theme settings
                }
            }
            
            // Support
            SettingsSection(title: "Suport") {
                SettingsRow(icon: "questionmark.circle.fill", title: "Ajutor & FAQ", color: MecaroTheme.Colors.info) {
                    // Help
                }
                
                SettingsRow(icon: "envelope.fill", title: "Contactează-ne", color: MecaroTheme.Colors.primary) {
                    // Contact
                }
                
                SettingsRow(icon: "star.fill", title: "Evaluează aplicația", color: MecaroTheme.Colors.star) {
                    // Rate app
                }
            }
            
            // Legal
            SettingsSection(title: "Legal") {
                SettingsRow(icon: "doc.text.fill", title: "Termeni și condiții", color: MecaroTheme.Colors.textSecondary) {
                    // Terms
                }
                
                SettingsRow(icon: "hand.raised.fill", title: "Politica de confidențialitate", color: MecaroTheme.Colors.textSecondary) {
                    // Privacy
                }
            }
            
            // Sign out
            if authService.isAuthenticated {
                Button {
                    Task {
                        try? await authService.signOut()
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Deconectează-te")
                            .font(MecaroTheme.Typography.labelLarge())
                            .foregroundStyle(MecaroTheme.Colors.error)
                        Spacer()
                    }
                    .padding(.vertical, MecaroTheme.Spacing.md)
                    .background(MecaroTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
                }
                .padding(.horizontal, MecaroTheme.Spacing.md)
            }
        }
    }
    
    // MARK: - App Info
    
    private var appInfoSection: some View {
        VStack(spacing: MecaroTheme.Spacing.xs) {
            Image(systemName: "car.fill")
                .font(.system(size: 24))
                .foregroundStyle(MecaroTheme.Colors.primary)
            
            Text("Mecaro")
                .font(MecaroTheme.Typography.labelMedium())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Text("Versiunea 1.0.0")
                .font(MecaroTheme.Typography.labelSmall())
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
        }
        .padding(.vertical, MecaroTheme.Spacing.lg)
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.xs) {
            Text(title)
                .font(MecaroTheme.Typography.labelMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                .padding(.horizontal, MecaroTheme.Spacing.md)
            
            VStack(spacing: 0) {
                content
            }
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            .padding(.horizontal, MecaroTheme.Spacing.md)
        }
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MecaroTheme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(MecaroTheme.Typography.bodyMedium())
                    .foregroundStyle(MecaroTheme.Colors.text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(MecaroTheme.Colors.textTertiary)
            }
            .padding(.horizontal, MecaroTheme.Spacing.md)
            .padding(.vertical, MecaroTheme.Spacing.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
        .environmentObject(AppState())
        .environmentObject(AuthService.shared)
}

