//
//  CarSelectionView.swift
//  Mecaro
//
//  Car brand and model selection flow
//

import SwiftUI
import Combine

struct CarSelectionView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = CarSelectionViewModel()
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            // Content
            if viewModel.selectedBrand == nil {
                brandSelectionView
            } else {
                modelSelectionView
            }
        }
        .background(MecaroTheme.Colors.background)
        .navigationTitle(viewModel.selectedBrand == nil ? "Alege marca" : "Alege modelul")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.selectedBrand != nil)
        .toolbar {
            if viewModel.selectedBrand != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            viewModel.selectedBrand = nil
                            searchText = ""
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Marca")
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadBrands()
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: MecaroTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
            
            TextField("Caută...", text: $searchText)
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
    
    // MARK: - Brand Selection
    
    private var brandSelectionView: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Popular brands section
                if !viewModel.popularBrands.isEmpty && searchText.isEmpty {
                    Section {
                        brandGrid(brands: viewModel.popularBrands)
                    } header: {
                        sectionHeader("Mărci populare")
                    }
                }
                
                // All brands section
                Section {
                    ForEach(filteredBrands) { brand in
                        brandRow(brand)
                    }
                } header: {
                    sectionHeader("Toate mărcile")
                }
            }
        }
    }
    
    private func brandGrid(brands: [CarBrand]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: MecaroTheme.Spacing.sm) {
            ForEach(brands) { brand in
                Button {
                    selectBrand(brand)
                } label: {
                    VStack(spacing: MecaroTheme.Spacing.xs) {
                        // Brand logo or flag
                        ZStack {
                            Circle()
                                .fill(MecaroTheme.Colors.backgroundSecondary)
                                .frame(width: 56, height: 56)
                            
                            Text(brand.countryFlag)
                                .font(.system(size: 28))
                        }
                        
                        Text(brand.name)
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(MecaroTheme.Colors.text)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MecaroTheme.Spacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, MecaroTheme.Spacing.md)
        .padding(.bottom, MecaroTheme.Spacing.md)
    }
    
    private func brandRow(_ brand: CarBrand) -> some View {
        Button {
            selectBrand(brand)
        } label: {
            HStack(spacing: MecaroTheme.Spacing.md) {
                Text(brand.countryFlag)
                    .font(.system(size: 24))
                    .frame(width: 40)
                
                Text(brand.name)
                    .font(MecaroTheme.Typography.bodyLarge())
                    .foregroundStyle(MecaroTheme.Colors.text)
                
                Spacer()
                
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
    
    private var filteredBrands: [CarBrand] {
        if searchText.isEmpty {
            return viewModel.allBrands
        }
        return viewModel.allBrands.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Model Selection
    
    private var modelSelectionView: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                // Popular models
                if !viewModel.popularModels.isEmpty && searchText.isEmpty {
                    Section {
                        ForEach(viewModel.popularModels) { model in
                            modelRow(model)
                        }
                    } header: {
                        sectionHeader("Modele populare")
                    }
                }
                
                // All models
                Section {
                    ForEach(filteredModels) { model in
                        modelRow(model)
                    }
                } header: {
                    sectionHeader("Toate modelele")
                }
            }
        }
        .task(id: viewModel.selectedBrand?.id) {
            if let brandId = viewModel.selectedBrand?.id {
                await viewModel.loadModels(brandId: brandId)
            }
        }
    }
    
    private func modelRow(_ model: CarModel) -> some View {
        Button {
            selectModel(model)
        } label: {
            HStack(spacing: MecaroTheme.Spacing.md) {
                Image(systemName: model.bodyTypeIcon)
                    .font(.system(size: 20))
                    .foregroundStyle(MecaroTheme.Colors.primary)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name)
                        .font(MecaroTheme.Typography.bodyLarge())
                        .foregroundStyle(MecaroTheme.Colors.text)
                    
                    if !model.yearRange.isEmpty {
                        Text(model.yearRange)
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Engine type icons
                HStack(spacing: 4) {
                    ForEach(model.engineTypeIcons.prefix(3), id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.system(size: 12))
                            .foregroundStyle(MecaroTheme.Colors.textTertiary)
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
    
    private var filteredModels: [CarModel] {
        if searchText.isEmpty {
            return viewModel.allModels
        }
        return viewModel.allModels.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Section Header
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(MecaroTheme.Typography.labelMedium())
                .foregroundStyle(MecaroTheme.Colors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, MecaroTheme.Spacing.md)
        .padding(.vertical, MecaroTheme.Spacing.sm)
        .background(MecaroTheme.Colors.background)
    }
    
    // MARK: - Actions
    
    private func selectBrand(_ brand: CarBrand) {
        withAnimation(MecaroTheme.Animation.standard) {
            viewModel.selectedBrand = brand
            searchText = ""
        }
    }
    
    private func selectModel(_ model: CarModel) {
        guard let brand = viewModel.selectedBrand else { return }
        
        // Create user car
        var userCar = UserCar(
            id: UUID(),
            userId: UUID(), // Will be set properly when saving
            brandId: brand.id,
            modelId: model.id,
            year: nil,
            licensePlate: nil,
            nickname: nil,
            engineType: model.engineTypes?.first,
            isPrimary: true,
            createdAt: Date()
        )
        userCar.brand = brand
        userCar.model = model
        
        // Save to app state
        appState.selectedCar = userCar
        
        // Dismiss
        dismiss()
    }
}

// MARK: - View Model

@MainActor
class CarSelectionViewModel: ObservableObject {
    @Published var allBrands: [CarBrand] = []
    @Published var popularBrands: [CarBrand] = []
    @Published var selectedBrand: CarBrand?
    
    @Published var allModels: [CarModel] = []
    @Published var popularModels: [CarModel] = []
    
    @Published var isLoading = false
    
    func loadBrands() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let brands = try await SupabaseService.shared.fetchCarBrands()
            allBrands = brands.sorted { $0.sortOrder < $1.sortOrder }
            popularBrands = brands.filter { $0.isPopular }.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            print("Failed to load brands: \(error)")
            // Use sample data
            allBrands = CarBrand.samples
            popularBrands = CarBrand.samples.filter { $0.isPopular }
        }
    }
    
    func loadModels(brandId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let models = try await SupabaseService.shared.fetchCarModels(brandId: brandId)
            allModels = models.sorted { $0.name < $1.name }
            popularModels = models.filter { $0.isPopular }
        } catch {
            print("Failed to load models: \(error)")
            allModels = [CarModel.sample]
            popularModels = []
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CarSelectionView()
            .environmentObject(AppState())
    }
}

