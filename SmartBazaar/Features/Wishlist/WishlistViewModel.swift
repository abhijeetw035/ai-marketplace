import Foundation
import Combine

@MainActor
class WishlistViewModel: ObservableObject {
    @Published var savedListings: [Listing] = []
    @Published var isLoading: Bool = false
    
    private let wishlistService: WishlistServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(wishlistService: WishlistServiceProtocol? = nil, authService: AuthServiceProtocol? = nil) {
        self.wishlistService = wishlistService ?? FirebaseWishlistService()
        self.authService = authService ?? FirebaseAuthService()
    }
    
    func fetchWishlist() {
        guard let currentUser = authService.currentUser else { return }
        isLoading = true
        Task {
            do {
                let items = try await wishlistService.fetchSavedItems(userId: currentUser.id)
                self.savedListings = items
                self.isLoading = false
            } catch {
                print("Failed to fetch wishlist: \(error)")
                self.isLoading = false
            }
        }
    }
}
