import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading items...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Failed to load feed.")
                            .foregroundColor(Theme.error)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button("Retry") {
                            viewModel.fetchListings()
                        }
                        .padding()
                    }
                } else {
                    if viewModel.listings.isEmpty {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            Spacer()
                            Image(systemName: "cart")
                                .font(.system(size: 64))
                                .foregroundColor(Theme.secondaryText)
                            Text("No items found")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Check back later or be the first to sell something!")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button(action: {
                                viewModel.fetchListings()
                            }) {
                                Text("Refresh")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, DesignSystem.Spacing.extraLarge)
                                    .padding(.vertical, DesignSystem.Spacing.small)
                                    .background(Theme.accent)
                                    .cornerRadius(DesignSystem.CornerRadius.medium)
                            }
                            .padding(.top, DesignSystem.Spacing.small)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: DesignSystem.Spacing.medium) {
                                ForEach(viewModel.listings) { listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing)) {
                                        FeedItemCard(listing: listing)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear {
                                        if listing.id == viewModel.listings.last?.id {
                                            viewModel.loadMoreListings()
                                        }
                                    }
                                }
                                
                                if viewModel.isLoadingMore {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Marketplace")
            .background(Theme.background)
            .onAppear {
                if viewModel.listings.isEmpty {
                    viewModel.fetchListings()
                }
            }
        }
    }
}

struct FeedItemCard: View {
    let listing: Listing
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    Text("Image Placeholder")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                Text(listing.title)
                    .font(.headline)
                
                Text(String(format: "₹%.2f", listing.price))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.accent)
                
                HStack {
                    if let score = listing.trustScore {
                        Text("Trust Score: \(score)/100")
                            .font(.caption)
                            .foregroundColor(Theme.success)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.success.opacity(0.1))
                            .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                    Spacer()
                    Text("Just now") // Mock timestamp
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.tiny)
        }
        .padding(.bottom, DesignSystem.Spacing.medium)
    }
}

#Preview {
    FeedView()
}
