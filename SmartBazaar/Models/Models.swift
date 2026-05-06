import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var avatar: String?
    var rating: Double
    var createdAt: Date
    var verificationStatus: Bool
}

struct Listing: Identifiable, Codable {
    let id: String
    let sellerId: String
    var title: String
    var description: String
    var images: [String]
    var category: String
    var condition: String
    var price: Double
    var suggestedPriceRange: String?
    var trustScore: Int?
    var location: String?
    var createdAt: Date
    var status: String // "active", "sold", "draft"
}

struct Message: Identifiable, Codable {
    let id: String
    let chatId: String
    let senderId: String
    let text: String
    let mediaUrl: String?
    let timestamp: Date
    var readStatus: Bool
    var offerAmount: Double?
}

struct Chat: Identifiable, Codable {
    let id: String
    let buyerId: String
    let sellerId: String
    let listingId: String
    var lastMessage: String
    var updatedAt: Date
}

struct SavedItem: Identifiable, Codable {
    var id: String { "\(userId)_\(listingId)" }
    let userId: String
    let listingId: String
    let savedAt: Date
}

struct AIInsight: Identifiable, Codable {
    var id: String { listingId }
    let listingId: String
    let priceSuggestion: Double?
    let trustScore: Int
    let explanation: String
    let negotiationHint: String?
}
