import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseListingService: ListingServiceProtocol {
    private let db = Firestore.firestore()
    
    func fetchFeed(page: Int) async throws -> [Listing] {
        let snapshot = try await db.collection("listings")
            .whereField("status", isEqualTo: "active")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            .getDocuments()
            
        return snapshot.documents.compactMap { doc -> Listing? in
            try? doc.data(as: Listing.self)
        }
    }
    
    func fetchListing(id: String) async throws -> Listing {
        let doc = try await db.collection("listings").document(id).getDocument()
        guard let listing = try? doc.data(as: Listing.self) else {
            throw NSError(domain: "ListingError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Listing not found"])
        }
        return listing
    }
    
    func createListing(listing: Listing) async throws -> Listing {
        let docRef = db.collection("listings").document(listing.id)
        try docRef.setData(from: listing)
        return listing
    }
}
