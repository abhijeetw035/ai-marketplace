import Foundation
import Combine

@MainActor
class ListingDetailViewModel: ObservableObject {
    @Published var listing: Listing?
    @Published var isLoading = false
    @Published var error: String? = nil
    
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol? = nil, listing: Listing? = nil) {
        self.listingService = listingService ?? MockListingService()
        self.listing = listing
    }
    
    func fetchListing(id: String) {
        isLoading = true
        Task {
            do {
                self.listing = try await listingService.fetchListing(id: id)
                self.isLoading = false
            } catch {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
