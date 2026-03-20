//
//  SearchView.swift
//  Mecaro
//
//  Global search for procedures and services
//

import SwiftUI
import Combine

struct SearchView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = SearchViewModel()
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Content
                if viewModel.searchText.isEmpty {
                    recentSearchesView
                } else {
                    searchResultsView
                }
            }
            .background(MecaroTheme.Colors.background)
            .navigationTitle("Caută")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: MecaroTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(MecaroTheme.Colors.textTertiary)
            
            TextField("Caută proceduri sau service-uri...", text: $viewModel.searchText)
                .font(MecaroTheme.Typography.bodyMedium())
                .focused($isSearchFocused)
                .onSubmit {
                    viewModel.addToRecentSearches()
                }
            
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
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
    
    // MARK: - Recent Searches
    
    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: MecaroTheme.Spacing.lg) {
                // Recent searches
                if !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
                        HStack {
                            Text("Căutări recente")
                                .font(MecaroTheme.Typography.labelLarge())
                                .foregroundStyle(MecaroTheme.Colors.textSecondary)
                            
                            Spacer()
                            
                            Button("Șterge") {
                                viewModel.clearRecentSearches()
                            }
                            .font(MecaroTheme.Typography.labelSmall())
                            .foregroundStyle(MecaroTheme.Colors.textTertiary)
                        }
                        
                        ForEach(viewModel.recentSearches, id: \.self) { search in
                            Button {
                                viewModel.searchText = search
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundStyle(MecaroTheme.Colors.textTertiary)
                                    
                                    Text(search)
                                        .font(MecaroTheme.Typography.bodyMedium())
                                        .foregroundStyle(MecaroTheme.Colors.text)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, MecaroTheme.Spacing.xs)
                            }
                        }
                    }
                    .padding(.horizontal, MecaroTheme.Spacing.md)
                }
                
                // Popular searches
                VStack(alignment: .leading, spacing: MecaroTheme.Spacing.sm) {
                    Text("Căutări populare")
                        .font(MecaroTheme.Typography.labelLarge())
                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    
                    FlowLayout(spacing: MecaroTheme.Spacing.xs) {
                        ForEach(viewModel.popularSearches, id: \.self) { search in
                            Button {
                                viewModel.searchText = search
                            } label: {
                                Text(search)
                                    .font(MecaroTheme.Typography.labelMedium())
                                    .foregroundStyle(MecaroTheme.Colors.primary)
                                    .padding(.horizontal, MecaroTheme.Spacing.sm)
                                    .padding(.vertical, MecaroTheme.Spacing.xs)
                                    .background(MecaroTheme.Colors.primary.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .padding(.horizontal, MecaroTheme.Spacing.md)
            }
            .padding(.top, MecaroTheme.Spacing.md)
        }
    }
    
    // MARK: - Search Results
    
    private var searchResultsView: some View {
        List {
            // Procedures section
            if !viewModel.procedureResults.isEmpty {
                Section {
                    ForEach(viewModel.procedureResults) { procedure in
                        Button {
                            appState.navigationPath.append(NavigationDestination.procedureDetail(procedure))
                        } label: {
                            HStack(spacing: MecaroTheme.Spacing.md) {
                                Image(systemName: procedure.iconName)
                                    .font(.system(size: 18))
                                    .foregroundStyle(MecaroTheme.Colors.primary)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(procedure.displayName)
                                        .font(MecaroTheme.Typography.bodyMedium())
                                        .foregroundStyle(MecaroTheme.Colors.text)
                                    
                                    if let price = procedure.totalPriceRangeFormatted {
                                        Text(price)
                                            .font(MecaroTheme.Typography.labelSmall())
                                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(MecaroTheme.Colors.textTertiary)
                            }
                        }
                    }
                } header: {
                    Text("Proceduri")
                }
            }
            
            // Services section
            if !viewModel.serviceResults.isEmpty {
                Section {
                    ForEach(viewModel.serviceResults) { service in
                        Button {
                            appState.navigationPath.append(NavigationDestination.serviceDetail(service))
                        } label: {
                            HStack(spacing: MecaroTheme.Spacing.md) {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 18))
                                    .foregroundStyle(MecaroTheme.Colors.info)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(service.name)
                                            .font(MecaroTheme.Typography.bodyMedium())
                                            .foregroundStyle(MecaroTheme.Colors.text)
                                        
                                        if service.isVerified {
                                            Image(systemName: "checkmark.seal.fill")
                                                .font(.system(size: 10))
                                                .foregroundStyle(MecaroTheme.Colors.success)
                                        }
                                    }
                                    
                                    Text(service.city)
                                        .font(MecaroTheme.Typography.labelSmall())
                                        .foregroundStyle(MecaroTheme.Colors.textSecondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(MecaroTheme.Colors.star)
                                    Text(service.ratingFormatted)
                                        .font(MecaroTheme.Typography.labelSmall())
                                }
                                .foregroundStyle(MecaroTheme.Colors.text)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(MecaroTheme.Colors.textTertiary)
                            }
                        }
                    }
                } header: {
                    Text("Service-uri")
                }
            }
            
            // No results
            if viewModel.procedureResults.isEmpty && viewModel.serviceResults.isEmpty && !viewModel.isSearching {
                Section {
                    VStack(spacing: MecaroTheme.Spacing.md) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundStyle(MecaroTheme.Colors.textTertiary)
                        
                        Text("Niciun rezultat")
                            .font(MecaroTheme.Typography.headlineSmall())
                            .foregroundStyle(MecaroTheme.Colors.text)
                        
                        Text("Încearcă alte cuvinte cheie")
                            .font(MecaroTheme.Typography.bodySmall())
                            .foregroundStyle(MecaroTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, MecaroTheme.Spacing.xxl)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: width, height: y + rowHeight)
        }
    }
}

// MARK: - Search View Model

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var procedureResults: [Procedure] = []
    @Published var serviceResults: [CarService] = []
    @Published var isSearching = false
    
    @Published var recentSearches: [String] = []
    
    let popularSearches = [
        "Schimb ulei",
        "Plăcuțe frână",
        "Revizie",
        "ITP",
        "Distribuție",
        "AC",
        "Diagnosticare",
        "Schimb anvelope"
    ]
    
    private var searchTask: Task<Void, Never>?
    
    init() {
        loadRecentSearches()
        
        // Debounce search
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                self?.performSearch(text)
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func performSearch(_ query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            procedureResults = []
            serviceResults = []
            return
        }
        
        isSearching = true
        
        searchTask = Task {
            do {
                // Search procedures
                let procedures = try await SupabaseService.shared.fetchProcedures()
                procedureResults = procedures.filter {
                    $0.displayName.localizedCaseInsensitiveContains(query) ||
                    ($0.displayDescription?.localizedCaseInsensitiveContains(query) ?? false)
                }
                
                // Search services
                serviceResults = try await SupabaseService.shared.searchServices(query: query)
                
            } catch {
                print("Search error: \(error)")
            }
            
            isSearching = false
        }
    }
    
    func addToRecentSearches() {
        guard !searchText.isEmpty else { return }
        
        // Remove if exists, add to front
        recentSearches.removeAll { $0 == searchText }
        recentSearches.insert(searchText, at: 0)
        
        // Keep only last 5
        if recentSearches.count > 5 {
            recentSearches = Array(recentSearches.prefix(5))
        }
        
        saveRecentSearches()
    }
    
    func clearRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
}

// MARK: - Preview

#Preview {
    SearchView()
        .environmentObject(AppState())
}

