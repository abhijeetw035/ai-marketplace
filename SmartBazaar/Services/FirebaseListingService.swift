import FirebaseFirestore
import FirebaseStorage

class FirebaseListingService: ListingServiceProtocol {
    private let db = Firestore.firestore()
    
    private var lastDocument: DocumentSnapshot?
    
    func fetchFeed(page: Int) async throws -> [Listing] {
        var query = db.collection("listings")
            .whereField("status", isEqualTo: "active")
            .order(by: "createdAt", descending: true)
            .limit(to: 20)
            
        if page > 1, let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        } else if page == 1 {
            lastDocument = nil
        }
            
        let snapshot = try await query.getDocuments()
        if let last = snapshot.documents.last {
            self.lastDocument = last
        }
            
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
    
    func updateListing(listing: Listing) async throws -> Listing {
        let docRef = db.collection("listings").document(listing.id)
        try docRef.setData(from: listing)
        return listing
    }
    
    func uploadImages(images: [Data]) async throws -> [String] {
        var urls: [String] = []
        let storageRef = Storage.storage().reference()
        
        for data in images {
            let imageRef = storageRef.child("listings/\(UUID().uuidString).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            _ = try await imageRef.putDataAsync(data, metadata: metadata)
            let downloadURL = try await imageRef.downloadURL()
            urls.append(downloadURL.absoluteString)
        }
        return urls
    }
    
    func fetchListings(bySellerId sellerId: String) async throws -> [Listing] {
        let snapshot = try await db.collection("listings")
            .whereField("sellerId", isEqualTo: sellerId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            
        return snapshot.documents.compactMap { doc -> Listing? in
            try? doc.data(as: Listing.self)
        }
    }
}
