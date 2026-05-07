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
                        FeedSkeletonList()
                    } else if viewModel.hasSearched && viewModel.searchResults.isEmpty {
                        // No-result fallback
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            Spacer()
                            Image(systemName: "questionmark.folder")
                                .font(.system(size: 64))
                                .foregroundColor(Theme.warning.opacity(0.4))
                            
                            Text("No perfect matches found")
                                .font(DesignSystem.Typography.title)
                                .foregroundColor(Theme.primary)
                            
                            if let intent = viewModel.extractedIntent {
                                Text(intent)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(Theme.success)
                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                                    .padding(.vertical, 6)
                                    .background(Theme.success.opacity(0.1))
                                    .cornerRadius(DesignSystem.CornerRadius.pill)
                            }
                            
                            Text("Describe your need differently or broaden your keywords.")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                        .appearAnimation()
                        
                    } else if !viewModel.searchResults.isEmpty {
                        // Results
                        ScrollView {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                                Text("\(viewModel.searchResults.count) result\(viewModel.searchResults.count == 1 ? "" : "s") found")
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(Theme.secondaryText)
                                    .padding(.horizontal)
                                
                                ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing)) {
                                        FeedItemCard(listing: listing)
                                    }
                                    .buttonStyle(ScalePressButtonStyle())
                                    .appearAnimation(delay: Double(index) * 0.05)
                                }
                            }
                            .padding()
                        }
                        
                    } else {
                        // Empty / pre-search state
                        VStack(spacing: DesignSystem.Spacing.large) {
                            Spacer()
                            
                            VStack(spacing: DesignSystem.Spacing.medium) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(Theme.accent.opacity(0.1))
                                
                                Text("Search with intent")
                                    .font(DesignSystem.Typography.title)
                                    .foregroundColor(Theme.primary)
                                
                                Text("Describe what you need. Our AI understands use cases, budgets, and categories.")
                                    .font(DesignSystem.Typography.body)
                                    .foregroundColor(Theme.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .appearAnimation()
                            
                            // Suggestion chips
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                                Text("Popular Intents")
                                    .font(DesignSystem.Typography.headline)
                                    .foregroundColor(Theme.primary)
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(Array(searchSuggestions.enumerated()), id: \.offset) { index, suggestion in
                                        Button(action: {
                                            viewModel.query = suggestion
                                            viewModel.performSearch()
                                        }) {
                                            HStack {
                                                Image(systemName: "sparkles")
                                                    .font(.caption)
                                                Text(suggestion)
                                                    .font(DesignSystem.Typography.body)
                                                Spacer()
                                                Image(systemName: "arrow.up.left")
                                                    .font(.caption)
                                            }
                                            .padding()
                                            .background(Theme.background)
                                            .cornerRadius(DesignSystem.CornerRadius.medium)
                                            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
                                        }
                                        .buttonStyle(ScalePressButtonStyle())
                                        .appearAnimation(delay: 0.1 + Double(index) * 0.05)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            Spacer()
                        }
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
