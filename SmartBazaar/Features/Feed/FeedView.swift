import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                OfflineBanner(pendingCount: viewModel.pendingSyncCount)
                
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
                .background(Theme.background)
            } // end VStack
            .navigationTitle("Marketplace")
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
    
    // Computed once per card render
    private var trust: TrustScoreResult {
        TrustScoreEngine.evaluate(listing: listing)
    }
    private var isSuspect: Bool { trust.grade == .suspect || trust.grade == .low }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            // Image area
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.gray.opacity(isSuspect ? 0.15 : 0.2))
                    .frame(height: 200)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .overlay(
                        Group {
                            if listing.images.isEmpty {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(Color.gray.opacity(0.4))
                            }
                        }
                    )
                
                // Suspicious overlay ribbon
                if isSuspect {
                    HStack(spacing: 4) {
                        Image(systemName: trust.grade.icon)
                            .font(.caption2)
                        Text(trust.grade.rawValue.uppercased())
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: trust.grade.colorHex))
                    .cornerRadius(DesignSystem.CornerRadius.small)
                    .padding(8)
                }
            }
            
            // Info rows
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                Text(listing.title)
                    .font(.headline)
                    .foregroundColor(Theme.primary)
                
                Text(String(format: "₹%.0f", listing.price))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.accent)
                
                HStack {
                    TrustBadge(result: trust)
                    
                    Spacer()
                    
                    if let loc = listing.location {
                        HStack(spacing: 2) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption2)
                            Text(loc)
                                .font(.caption)
                        }
                        .foregroundColor(Theme.secondaryText)
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.tiny)
        }
        .padding(.bottom, DesignSystem.Spacing.medium)
        .opacity(trust.grade == .suspect ? 0.75 : 1.0)
    }
}

#Preview {
    FeedView()
}
