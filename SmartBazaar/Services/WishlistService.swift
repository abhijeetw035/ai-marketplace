import Foundation
import FirebaseFirestore

protocol WishlistServiceProtocol {
    func fetchSavedItems(userId: String) async throws -> [Listing]
    func saveItem(userId: String, listing: Listing) async throws
    func unsaveItem(userId: String, listingId: String) async throws
}

class FirebaseWishlistService: WishlistServiceProtocol {
    private let db = Firestore.firestore()
    
    func fetchSavedItems(userId: String) async throws -> [Listing] {
        let snapshot = try await db.collection("users").document(userId).collection("wishlist")
            .order(by: "savedAt", descending: true)
            .getDocuments()
            
        var listings: [Listing] = []
        for doc in snapshot.documents {
            let listingId = doc.documentID
            // Normally we'd use a cloud function or batch fetch to get all listing docs at once
            // For now, fetch individually or assume listing details are saved in the wishlist doc
            if let savedItem = try? doc.data(as: SavedItem.self) {
                let listingDoc = try await db.collection("listings").document(savedItem.listingId).getDocument()
                if let listing = try? listingDoc.data(as: Listing.self) {
                    listings.append(listing)
                }
            }
        }
        return listings
    }
    
    func saveItem(userId: String, listing: Listing) async throws {
        let savedItem = SavedItem(userId: userId, listingId: listing.id, savedAt: Date())
        try db.collection("users").document(userId).collection("wishlist").document(listing.id).setData(from: savedItem)
    }
    
    func unsaveItem(userId: String, listingId: String) async throws {
        try await db.collection("users").document(userId).collection("wishlist").document(listingId).delete()
    }
}
