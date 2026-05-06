import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.accent)
                    TextField("e.g. cheap iPhone for gaming", text: $viewModel.query)
                        .onSubmit { viewModel.performSearch() }
                    if !viewModel.query.isEmpty {
                        Button(action: { viewModel.clearSearch() }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                }
                .padding(12)
                .background(Theme.secondaryBackground)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .padding()
                
                // Intent Pills
                if let intent = viewModel.extractedIntent {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            IntentPill(label: intent, icon: "brain", color: Theme.success)
                            
                            if let cat = viewModel.extractedCategory {
                                IntentPill(label: cat, icon: "tag", color: Theme.accent)
                            }
                            if let uc = viewModel.extractedUseCase {
                                IntentPill(label: uc, icon: "person", color: .purple)
                            }
                            if let budget = viewModel.extractedBudget {
                                IntentPill(label: "Under ₹\(Int(budget))", icon: "indianrupeesign", color: Theme.warning)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }
                
                Divider()
                
                // Body
                Group {
                    if viewModel.isLoading {
                        Spacer()
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            ProgressView()
                            Text("Analyzing intent...")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                        }
                        Spacer()
                        
                    } else if viewModel.hasSearched && viewModel.searchResults.isEmpty {
                        // No-result fallback
                        Spacer()
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            Image(systemName: "questionmark.folder")
                                .font(.system(size: 52))
                                .foregroundColor(Theme.warning)
                            Text("No perfect matches found")
                                .font(.headline)
                            if let intent = viewModel.extractedIntent {
                                Text(intent)
                                    .font(.caption)
                                    .foregroundColor(Theme.success)
                                    .padding(.horizontal)
                            }
                            Text("Try broadening your keywords or adjusting the budget.")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        Spacer()
                        
                    } else if !viewModel.searchResults.isEmpty {
                        // Results
                        Text("\(viewModel.searchResults.count) result\(viewModel.searchResults.count == 1 ? "" : "s") found")
                            .font(.caption)
                            .foregroundColor(Theme.secondaryText)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        ScrollView {
                            VStack(spacing: DesignSystem.Spacing.medium) {
                                ForEach(viewModel.searchResults) { listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing)) {
                                        FeedItemCard(listing: listing)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                        
                    } else {
                        // Empty / pre-search state
                        Spacer()
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 52))
                                .foregroundColor(Color.gray.opacity(0.4))
                            Text("Search with intent")
                                .font(.headline)
                            Text("Describe what you need. Our AI understands use cases, budgets, and categories.")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            // Suggestion chips
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Try:")
                                    .font(.caption)
                                    .foregroundColor(Theme.secondaryText)
                                ForEach(searchSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        viewModel.query = suggestion
                                        viewModel.performSearch()
                                    }) {
                                        Text("→ \(suggestion)")
                                            .font(.subheadline)
                                            .foregroundColor(Theme.accent)
                                    }
                                }
                            }
                            .padding(.top, 8)
                        }
                        Spacer()
                    }
                }
            }
            .background(Theme.background)
            .navigationTitle("Search")
        }
    }
    
    private let searchSuggestions = [
        "cheap laptop for student under 25k",
        "gaming phone good condition",
        "office chair urgent sale"
    ]
}

struct IntentPill: View {
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .cornerRadius(DesignSystem.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SearchView()
}
