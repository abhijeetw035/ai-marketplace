import Foundation

@MainActor
class WishlistViewModel: ObservableObject {
    @Published var savedListings: [Listing] = []
    @Published var isLoading: Bool = false
    
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol = MockListingService()) {
        self.listingService = listingService
    }
    
    func fetchWishlist() {
        isLoading = true
        Task {
            do {
                // In a real app, fetch only wishlist items
                let feed = try await listingService.fetchFeed(page: 1)
                self.savedListings = Array(feed.prefix(1)) // Mock: grab the first item
                self.isLoading = false
            } catch {
                print("Failed to fetch wishlist")
                self.isLoading = false
            }
        }
    }
}
