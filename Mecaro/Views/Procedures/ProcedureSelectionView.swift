//
//  ProcedureSelectionView.swift
//  Mecaro
//
//  Browse and select repair procedures
//

import SwiftUI
import Combine

struct ProcedureSelectionView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = ProcedureSelectionViewModel()
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            if viewModel.isLoading {
                loadingView
            } else if !searchText.isEmpty {
                searchResultsView
            } else {
                categoryView
            }
        }
        .background(MecaroTheme.Colors.background)
        .navigationTitle("Alege procedura")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: MecaroTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
            
            TextField("Caută proceduri...", text: $searchText)
                .font(MecaroTheme.Typography.bodyMedium())
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                }
            }
        }
        .padding(MecaroTheme.Spacing.sm)
        .background(MecaroTheme.Colors.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
        .padding(.horizontal, MecaroTheme.Spacing.md)
        .padding(.vertical, MecaroTheme.Spacing.sm)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            ProgressView()
                .tint(MecaroTheme.Colors.primary)
            Text("Se încarcă...")
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Category View
    
    private var categoryView: some View {
        ScrollView {
            LazyVStack(spacing: MecaroTheme.Spacing.lg) {
                // Selected car info
                if let car = appState.selectedCar {
                    selectedCarBanner(car)
                }
                
                // Category grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: MecaroTheme.Spacing.sm) {
                    ForEach(viewModel.categories) { category in
                        CategoryCard(category: category) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal, MecaroTheme.Spacing.md)
                
                // Procedures for selected category
                if let category = viewModel.selectedCategory {
                    proceduresList(for: category)
                }
            }
            .padding(.bottom, MecaroTheme.Spacing.xxl)
        }
    }
    
    // MARK: - Selected Car Banner
    
    private func selectedCarBanner(_ car: UserCar) -> some View {
        HStack(spacing: MecaroTheme.Spacing.sm) {
            Image(systemName: "car.fill")
                .foregroundStyle(MecaroTheme.Colors.primary)
            
            Text("Prețuri pentru: **\(car.shortName)**")
                .font(MecaroTheme.Typography.bodySmall())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Spacer()
            
            Button("Schimbă") {
                appState.navigationPath.append(NavigationDestination.carSelection)
            }
            .font(MecaroTheme.Typography.labelSmall())
            .foregroundStyle(MecaroTheme.Colors.primary)
        }
        .padding(MecaroTheme.Spacing.sm)
        .background(MecaroTheme.Colors.primary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.sm))
        .padding(.horizontal, MecaroTheme.Spacing.md)
    }
    
    // MARK: - Procedures List
    
    private func proceduresList(for category: ProcedureCategory) -> some View {
        VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
            HStack {
                Text(category.displayName)
                    .font(MecaroTheme.Typography.headlineSmall())
                    .foregroundStyle(MecaroTheme.Colors.text)
                
                Spacer()
                
                Button {
                    withAnimation {
                        viewModel.selectedCategory = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, MecaroTheme.Spacing.md)
            
            ForEach(viewModel.procedures(for: category)) { procedure in
                ProcedureRow(procedure: procedure) {
                    appState.navigationPath.append(NavigationDestination.procedureDetail(procedure))
                }
            }
        }
    }
    
    // MARK: - Search Results
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(filteredProcedures) { procedure in
                    ProcedureRow(procedure: procedure) {
                        appState.navigationPath.append(NavigationDestination.procedureDetail(procedure))
                    }
                }
                
                if filteredProcedures.isEmpty {
                    emptySearchView
                }
            }
        }
    }
    
    private var filteredProcedures: [Procedure] {
        viewModel.allProcedures.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            ($0.displayDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    private var emptySearchView: some View {
        VStack(spacing: MecaroTheme.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
            
            Text("Niciun rezultat")
                .font(MecaroTheme.Typography.headlineSmall())
                .foregroundStyle(MecaroTheme.Colors.text)
            
            Text("Încearcă alte cuvinte cheie")
                .font(MecaroTheme.Typography.bodyMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, MecaroTheme.Spacing.xxxl)
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: ProcedureCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: MecaroTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md)
                        .fill(category.uiColor.opacity(0.1))
                        .frame(height: 80)
                    
                    Image(systemName: category.iconName)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(category.uiColor)
                }
                
                Text(category.displayName)
                    .font(MecaroTheme.Typography.labelMedium())
                    .foregroundStyle(MecaroTheme.Colors.text)
                    .lineLimit(1)
            }
            .padding(MecaroTheme.Spacing.sm)
            .background(MecaroTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: MecaroTheme.CornerRadius.md))
            .mecaroShadow(MecaroTheme.Shadows.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Procedure Row

struct ProcedureRow: View {
    let procedure: Procedure
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: MecaroTheme.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(MecaroTheme.Colors.primary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: procedure.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(MecaroTheme.Colors.primary)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(procedure.displayName)
                        .font(MecaroTheme.Typography.bodyLarge())
                        .foregroundStyle(MecaroTheme.Colors.text)
                    
                    HStack(spacing: MecaroTheme.Spacing.sm) {
                        if let duration = procedure.durationFormatted {
                            Label(duration, systemImage: "clock")
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                        }
                        
                        if procedure.requiresParts {
                            Label("+ piese", systemImage: "gearshape.fill")
                                .font(MecaroTheme.Typography.labelSmall())
                                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    if let price = procedure.totalPriceRangeFormatted {
                        Text(price)
                            .font(MecaroTheme.Typography.labelLarge())
                            .foregroundStyle(procedure.priceLevel.color)
                    }
                    
                    Text("estimat")
                        .font(MecaroTheme.Typography.labelSmall())
                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
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

// MARK: - View Model

@MainActor
class ProcedureSelectionViewModel: ObservableObject {
    @Published var categories: [ProcedureCategory] = []
    @Published var allProcedures: [Procedure] = []
    @Published var selectedCategory: ProcedureCategory?
    @Published var isLoading = false
    
    private var proceduresByCategory: [UUID: [Procedure]] = [:]
    
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load categories
            categories = try await SupabaseService.shared.fetchProcedureCategories()
            
            // Load all procedures
            allProcedures = try await SupabaseService.shared.fetchProcedures()
            
            // Group by category
            proceduresByCategory = Dictionary(grouping: allProcedures, by: { $0.categoryId })
        } catch {
            print("Failed to load procedures: \(error)")
            categories = ProcedureCategory.samples
            allProcedures = Procedure.samples
        }
    }
    
    func procedures(for category: ProcedureCategory) -> [Procedure] {
        proceduresByCategory[category.id] ?? []
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProcedureSelectionView()
            .environmentObject(AppState())
    }
}

