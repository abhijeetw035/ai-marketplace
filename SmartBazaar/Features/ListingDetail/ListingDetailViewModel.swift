import Foundation
import Combine

@MainActor
class ListingDetailViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var isLoading = false
    @Published var error: String? = nil
    
    @Published var isSaved: Bool = false
    @Published var sellerName: String = "John Doe"
    @Published var sellerRating: String = "4.8"
    
    private let listingService: ListingServiceProtocol
    private let wishlistService: WishlistServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(listingService: ListingServiceProtocol? = nil, 
         wishlistService: WishlistServiceProtocol? = nil,
         authService: AuthServiceProtocol? = nil,
         listing: Listing? = nil) {
        self.listingService = listingService ?? FirebaseListingService()
        self.wishlistService = wishlistService ?? FirebaseWishlistService()
        self.authService = authService ?? FirebaseAuthService()
        self.listing = listing
        
        if let listing = listing {
            checkIfSaved(listingId: listing.id)
            fetchSellerProfile(sellerId: listing.sellerId)
        }
    }
    
    func fetchListing(id: String) {
        isLoading = true
        Task {
            do {
                let fetchedListing = try await listingService.fetchListing(id: id)
                self.listing = fetchedListing
                self.isLoading = false
                
                checkIfSaved(listingId: fetchedListing.id)
                fetchSellerProfile(sellerId: fetchedListing.sellerId)
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func checkIfSaved(listingId: String) {
        guard let userId = authService.currentUser?.id else { return }
        Task {
            do {
                let savedItems = try await wishlistService.fetchSavedItems(userId: userId)
                self.isSaved = savedItems.contains(where: { $0.id == listingId })
            } catch {
                print("Error checking wishlist: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleWishlist() {
        guard let userId = authService.currentUser?.id, let currentListing = listing else { return }
        
        isSaved.toggle() // Optimistic UI update
        Task {
            do {
                if isSaved {
                    try await wishlistService.saveItem(userId: userId, listing: currentListing)
                } else {
                    try await wishlistService.unsaveItem(userId: userId, listingId: currentListing.id)
                }
            } catch {
                self.isSaved.toggle() // Revert on failure
                self.error = "Failed to update wishlist"
            }
        }
    }
    
    private func fetchSellerProfile(sellerId: String) {
        // Placeholder for fetching real seller profile from a users collection
        if sellerId == authService.currentUser?.id {
            self.sellerName = "You"
        } else {
            self.sellerName = "Seller \(sellerId.prefix(4))" // Mock dynamic name
            self.sellerRating = "4.\(Int.random(in: 2...9))" // Mock dynamic rating
        }
    }
}
