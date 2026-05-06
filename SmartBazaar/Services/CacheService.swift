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

class FileSystemCacheService: CacheServiceProtocol {
    private let fileManager = FileManager.default
    private let feedFileName = "cachedFeed.json"
    
    private var cacheURL: URL {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(feedFileName)
    }
    
    func saveFeed(listings: [Listing]) throws {
        let data = try JSONEncoder().encode(listings)
        try data.write(to: cacheURL)
    }
    
    func getCachedFeed() throws -> [Listing]? {
        guard fileManager.fileExists(atPath: cacheURL.path) else { return nil }
        let data = try Data(contentsOf: cacheURL)
        return try JSONDecoder().decode([Listing].self, from: data)
    }
}
