import SwiftUI

struct WishlistView: View {
    @StateObject private var viewModel = WishlistViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.savedListings.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                            .padding(.bottom, DesignSystem.Spacing.small)
                        Text("No saved items yet")
                            .font(.headline)
                        Text("Items you favorite will appear here.")
                            .font(.subheadline)
                            .foregroundColor(Theme.secondaryText)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.medium) {
                            ForEach(viewModel.savedListings) { listing in
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
