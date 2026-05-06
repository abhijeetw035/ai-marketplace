import Foundation
import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol = MockListingService()) {
        self.listingService = listingService
    }
    
    func fetchListings() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetchedListings = try await listingService.fetchFeed(page: 1)
                self.listings = fetchedListings
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
