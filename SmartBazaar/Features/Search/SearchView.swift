import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.accent)
                    TextField("e.g. cheap iPhone for gaming", text: $viewModel.query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            viewModel.performSearch()
                        }
                }
                .padding()
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Analyzing intent...")
                    Spacer()
                } else if !viewModel.searchResults.isEmpty {
                    if let intent = viewModel.extractedIntent {
                        Text(intent)
                            .font(.caption)
                            .foregroundColor(Theme.success)
                            .padding(.horizontal)
                            .padding(.top, 4)
                    }
                    
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
                    Spacer()
                    
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Search with intent")
                            .font(.headline)
                        Text("Try searching for specific needs like 'good study laptop under 30k'.")
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Search")
            .background(Theme.background)
        }
    }
}

#Preview {
    SearchView()
}
