import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationView {
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
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach(viewModel.listings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    FeedItemCard(listing: listing)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Marketplace")
            .background(Theme.secondaryBackground)
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
