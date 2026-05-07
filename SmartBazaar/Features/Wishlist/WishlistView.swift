import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    FeedSkeletonList()
                } else if viewModel.savedListings.isEmpty {
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .font(.system(size: 64))
                            .foregroundColor(Theme.secondaryText.opacity(0.3))
                        
                        Text("No saved items yet")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(Theme.primary)
                        
                        Text("Items you favorite will appear here so you can find them later.")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DesignSystem.Spacing.extraLarge)
                        
                        Spacer()
                    }
                    .appearAnimation()
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach(Array(viewModel.savedListings.enumerated()), id: \.element.id) { index, listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    FeedItemCard(listing: listing)
                                }
                                .buttonStyle(ScalePressButtonStyle())
                                .appearAnimation(delay: Double(index) * 0.05)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Wishlist")
            .background(Theme.secondaryBackground)
            .onAppear {
                viewModel.fetchWishlist()
            }
        }
    }
}

#Preview {
    WishlistView()
}
