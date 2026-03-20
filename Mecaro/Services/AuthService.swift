//
//  AuthService.swift
//  Mecaro
//
//  Authentication service using Supabase Auth
//

import Foundation
import Combine
import Supabase

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    // MARK: - Published Properties
    
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var error: AuthError?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let supabase = SupabaseService.shared
    
    // MARK: - Initialization
    
    private init() {
        Task {
            await checkAuthState()
        }
    }
    
    // MARK: - Auth State
    
    func checkAuthState() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Check for existing session
            if let session = try await supabase.getCurrentSession() {
                currentUser = session.user
                isAuthenticated = true
                await fetchUserProfile()
            } else {
                isAuthenticated = false
                currentUser = nil
                userProfile = nil
            }
        } catch {
            print("Auth check error: \(error)")
            isAuthenticated = false
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, fullName: String? = nil) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.signUp(
                email: email,
                password: password,
                data: fullName != nil ? ["full_name": fullName!] : nil
            )
            
            currentUser = session.user
            isAuthenticated = true
            await fetchUserProfile()
            
        } catch let supabaseError {
            self.error = .signUpFailed(supabaseError.localizedDescription)
            throw self.error!
        }
    }
    
    // MARK: - Sign In with Email
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await supabase.signIn(email: email, password: password)
            
            currentUser = session.user
            isAuthenticated = true
            await fetchUserProfile()
            
        } catch let supabaseError {
            self.error = .signInFailed(supabaseError.localizedDescription)
            throw self.error!
        }
    }
    
    // MARK: - Sign In with Apple
    
    func signInWithApple(idToken: String, nonce: String) async throws {
        // TODO: Implement Sign in with Apple
        throw AuthError.signInFailed("Sign in with Apple not yet implemented")
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.resetPassword(email: email)
        } catch let supabaseError {
            self.error = .passwordResetFailed(supabaseError.localizedDescription)
            throw self.error!
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await supabase.signOut()
            
            currentUser = nil
            userProfile = nil
            isAuthenticated = false
            
        } catch let supabaseError {
            self.error = .signOutFailed(supabaseError.localizedDescription)
            throw self.error!
        }
    }
    
    // MARK: - Profile Management
    
    func fetchUserProfile() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            userProfile = try await supabase.fetchProfile(userId: userId)
        } catch {
            print("Failed to fetch profile: \(error)")
        }
    }
    
    func updateProfile(_ update: UpdateProfileRequest) async throws {
        guard let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }
        
        do {
            userProfile = try await supabase.updateProfile(userId: userId, update: update)
        } catch let supabaseError {
            self.error = .profileUpdateFailed(supabaseError.localizedDescription)
            throw self.error!
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async throws {
        guard currentUser != nil else {
            throw AuthError.notAuthenticated
        }
        
        // TODO: Implement account deletion
        // This requires calling a Supabase Edge Function or server-side endpoint
        // that has admin privileges to delete the user
        
        try await signOut()
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case signUpFailed(String)
    case signInFailed(String)
    case signOutFailed(String)
    case passwordResetFailed(String)
    case profileUpdateFailed(String)
    case notAuthenticated
    case invalidCredentials
    case emailNotVerified
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .signUpFailed(let message):
            return "Înregistrarea a eșuat: \(message)"
        case .signInFailed(let message):
            return "Autentificarea a eșuat: \(message)"
        case .signOutFailed(let message):
            return "Deconectarea a eșuat: \(message)"
        case .passwordResetFailed(let message):
            return "Resetarea parolei a eșuat: \(message)"
        case .profileUpdateFailed(let message):
            return "Actualizarea profilului a eșuat: \(message)"
        case .notAuthenticated:
            return "Nu ești autentificat"
        case .invalidCredentials:
            return "Email sau parolă incorectă"
        case .emailNotVerified:
            return "Te rugăm să îți verifici emailul"
        case .unknown:
            return "A apărut o eroare necunoscută"
        }
    }
}

// MARK: - Session Result (placeholder for backwards compatibility)

struct SessionResult {
    let user: User
    let accessToken: String
    let refreshToken: String
}

