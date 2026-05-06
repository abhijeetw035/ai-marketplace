import Foundation
import SwiftUI
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String? = nil
    
    private var currentPage: Int = 1
    private var hasMorePages: Bool = true
    
    private let listingService: ListingServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    init(
        listingService: ListingServiceProtocol? = nil,
        cacheService: CacheServiceProtocol? = nil
    ) {
        self.listingService = listingService ?? FirebaseListingService()
        self.cacheService = cacheService ?? FileSystemCacheService()
        
        loadCachedFeed()
    }
    
    private func loadCachedFeed() {
        if let cached = try? cacheService.getCachedFeed() {
            self.listings = cached
        }
    }
    
    func fetchListings() {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMorePages = true
        
        Task {
            do {
                let fetchedListings = try await listingService.fetchFeed(page: currentPage)
                self.listings = fetchedListings
                try? cacheService.saveFeed(listings: fetchedListings)
                self.hasMorePages = fetchedListings.count == 20
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadMoreListings() {
        guard !isLoadingMore, hasMorePages else { return }
        isLoadingMore = true
        currentPage += 1
        
        Task {
            do {
                let moreListings = try await listingService.fetchFeed(page: currentPage)
                self.listings.append(contentsOf: moreListings)
                self.hasMorePages = moreListings.count == 20
                self.isLoadingMore = false
            } catch {
                self.isLoadingMore = false
            }
        }
    }
}
