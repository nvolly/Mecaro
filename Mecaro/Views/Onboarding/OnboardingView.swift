//
//  OnboardingView.swift
//  Mecaro
//
//  First-time user onboarding flow
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "car.fill",
            title: "Alege mașina ta",
            description: "Selectează marca și modelul pentru a vedea prețuri specifice mașinii tale.",
            color: MecaroTheme.Colors.primary
        ),
        OnboardingPage(
            icon: "wrench.and.screwdriver.fill",
            title: "Compară prețurile",
            description: "Vezi estimări de preț pentru orice reparație și compară ofertele service-urilor.",
            color: MecaroTheme.Colors.accent
        ),
        OnboardingPage(
            icon: "map.fill",
            title: "Găsește service-uri",
            description: "Descoperă cele mai bune service-uri din apropierea ta pe hartă.",
            color: MecaroTheme.Colors.success
        ),
        OnboardingPage(
            icon: "star.fill",
            title: "Alege cu încredere",
            description: "Citește recenzii de la alți șoferi și programează-te direct din aplicație.",
            color: MecaroTheme.Colors.info
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    MecaroTheme.Colors.background,
                    pages[currentPage].color.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(MecaroTheme.Animation.smooth, value: currentPage)
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Sari peste") {
                        completeOnboarding()
                    }
                    .font(MecaroTheme.Typography.labelLarge())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    .padding()
                }
                
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? pages[currentPage].color : MecaroTheme.Colors.border)
                            .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                            .animation(MecaroTheme.Animation.quick, value: currentPage)
                    }
                }
                .padding(.bottom, MecaroTheme.Spacing.lg)
                
                // Action button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation(MecaroTheme.Animation.spring) {
                            currentPage += 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    HStack {
                        Text(currentPage < pages.count - 1 ? "Continuă" : "Începe")
                            .font(MecaroTheme.Typography.labelLarge())
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MecaroTheme.Spacing.md)
                    .background(pages[currentPage].color)
                    .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.lg))
                }
                .padding(.horizontal, MecaroTheme.Spacing.lg)
                .padding(.bottom, MecaroTheme.Spacing.xxl)
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        withAnimation(MecaroTheme.Animation.smooth) {
            showOnboarding = false
        }
    }
}

// MARK: - Onboarding Page Model

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    @State private var iconScale: CGFloat = 0.5
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: MecaroTheme.Spacing.xl) {
            Spacer()
            
            // Icon with animated background
            ZStack {
                // Decorative circles
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 150, height: 150)
                
                // Icon
                Image(systemName: page.icon)
                    .font(.system(size: 70, weight: .medium))
                    .foregroundStyle(page.color)
                    .scaleEffect(iconScale)
            }
            .padding(.bottom, MecaroTheme.Spacing.lg)
            
            // Text content
            VStack(spacing: MecaroTheme.Spacing.sm) {
                Text(page.title)
                    .font(MecaroTheme.Typography.displayMedium())
                    .foregroundStyle(MecaroTheme.Colors.text)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(MecaroTheme.Typography.bodyLarge())
                    .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, MecaroTheme.Spacing.lg)
            }
            .opacity(textOpacity)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                textOpacity = 1.0
            }
        }
        .onDisappear {
            iconScale = 0.5
            textOpacity = 0
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}

