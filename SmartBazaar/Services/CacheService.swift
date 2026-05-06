import Foundation

protocol CacheServiceProtocol {
    func saveFeed(listings: [Listing]) throws
    func getCachedFeed() throws -> [Listing]?
}

class MockCacheService: CacheServiceProtocol {
    private var cachedListings: [Listing] = []
    
    func saveFeed(listings: [Listing]) throws {
        self.cachedListings = listings
        // In a real app, this would use CoreData or FileSystem
    }
    
    func getCachedFeed() throws -> [Listing]? {
        return cachedListings.isEmpty ? nil : cachedListings
    }
}
