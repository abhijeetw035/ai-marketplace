import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var userName: String = "Loading..."
    @Published var listingsCount: Int = 0
    @Published var wishlistCount: Int = 0
    @Published var rating: String = "New"
    @Published var isLoading: Bool = false
    
    private let authService: AuthServiceProtocol
    private let listingService: ListingServiceProtocol
    private let wishlistService: WishlistServiceProtocol
    
    init(authService: AuthServiceProtocol? = nil, 
         listingService: ListingServiceProtocol? = nil, 
         wishlistService: WishlistServiceProtocol? = nil) {
        self.authService = authService ?? FirebaseAuthService()
        self.listingService = listingService ?? FirebaseListingService()
        self.wishlistService = wishlistService ?? FirebaseWishlistService()
    }
    
    func loadProfileData() {
        guard let userId = authService.currentUser?.id else { return }
        self.userName = authService.currentUser?.name ?? "User Name"
        
        isLoading = true
        Task {
            do {
                let userListings = try await listingService.fetchListings(bySellerId: userId)
                let wishlistItems = try await wishlistService.fetchSavedItems(userId: userId)
                
                self.listingsCount = userListings.count
                self.wishlistCount = wishlistItems.count
                // Logic for rating could be added here if available on User model
                self.rating = "4.8" // Placeholder until user rating model is fully implemented
            } catch {
                print("Failed to load profile stats: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
    
    func logout() {
        authService.signOut()
    }
}
