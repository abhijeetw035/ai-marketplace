import Foundation

protocol ListingServiceProtocol {
    func fetchFeed(page: Int) async throws -> [Listing]
    func fetchListing(id: String) async throws -> Listing
    func createListing(listing: Listing) async throws -> Listing
    func updateListing(listing: Listing) async throws -> Listing
    func uploadImages(images: [Data]) async throws -> [String]
    func fetchListings(bySellerId: String) async throws -> [Listing]
}

class MockListingService: ListingServiceProtocol {
    func fetchFeed(page: Int) async throws -> [Listing] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return [
            Listing(id: "1", sellerId: "s1", title: "iPhone 13 Pro", description: "Excellent condition, used for 1 year.", images: [], category: "Electronics", condition: "Like New", price: 45000.0, trustScore: 95, location: "Mumbai", createdAt: Date(), status: "active"),
            Listing(id: "2", sellerId: "s2", title: "Ergonomic Office Chair", description: "Slight wear and tear, very comfortable.", images: [], category: "Furniture", condition: "Good", price: 3500.0, trustScore: 82, location: "Bangalore", createdAt: Date().addingTimeInterval(-86400), status: "active")
        ]
    }
    
    func fetchListing(id: String) async throws -> Listing {
        try await Task.sleep(nanoseconds: 500_000_000)
        return Listing(id: id, sellerId: "s1", title: "iPhone 13 Pro", description: "Excellent condition, used for 1 year.", images: [], category: "Electronics", condition: "Like New", price: 45000.0, trustScore: 95, location: "Mumbai", createdAt: Date(), status: "active")
    }
    
    func createListing(listing: Listing) async throws -> Listing {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return listing
    }
    
    func updateListing(listing: Listing) async throws -> Listing {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return listing
    }
    
    func uploadImages(images: [Data]) async throws -> [String] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return images.map { _ in "https://via.placeholder.com/400" }
    }
    
    func fetchListings(bySellerId: String) async throws -> [Listing] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return []
    }
}
