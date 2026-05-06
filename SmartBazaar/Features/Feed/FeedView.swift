import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    private let analytics = AnalyticsService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                OfflineBanner(pendingCount: viewModel.pendingSyncCount)
                
                Group {
                    if viewModel.isLoading {
                        FeedSkeletonList()
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            Spacer()
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 48))
                                .foregroundColor(Theme.warning)
                            Text("Failed to load feed.")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(Theme.primary)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Retry") { viewModel.fetchListings() }
                                .buttonStyle(PrimaryButtonStyle())
                                .padding(.horizontal, 48)
                            Spacer()
                        }
                    } else if viewModel.listings.isEmpty {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            Spacer()
                            Image(systemName: "cart")
                                .font(.system(size: 64))
                                .foregroundColor(Theme.secondaryText)
                            Text("No items found")
                                .font(DesignSystem.Typography.title)
                            Text("Check back later or be the first to sell something!")
                                .font(.subheadline)
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            Button("Refresh") { viewModel.fetchListings() }
                                .buttonStyle(PrimaryButtonStyle())
                                .padding(.horizontal, 48)
                                .padding(.top, DesignSystem.Spacing.tiny)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: DesignSystem.Spacing.medium) {
                                ForEach(Array(viewModel.listings.enumerated()), id: \.element.id) { index, listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing)) {
                                        FeedItemCard(listing: listing)
                                    }
                                    .buttonStyle(ScalePressButtonStyle())
                                    .appearAnimation(delay: Double(min(index, 6)) * 0.06)
                                    .onAppear {
                                        if listing.id == viewModel.listings.last?.id {
                                            viewModel.loadMoreListings()
                                            analytics.log(.feedPaginationLoaded(page: viewModel.listings.count / 20 + 1))
                                        }
                                    }
                                    .simultaneousGesture(
                                        TapGesture().onEnded {
                                            analytics.log(.listingCardTapped(listingId: listing.id, title: listing.title))
                                        }
                                    )
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
                .background(Theme.background)
            } // end VStack
            .navigationTitle("Marketplace")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.fetchListings() }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Theme.accent)
                    }
                }
            }
            .onAppear {
                if viewModel.listings.isEmpty { viewModel.fetchListings() }
                analytics.log(.feedViewed)
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
