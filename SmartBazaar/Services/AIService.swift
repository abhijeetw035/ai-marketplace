import Foundation

struct IntentSearchResult {
    let category: String?
    let budget: Double?
    let keywords: [String]
    let listings: [Listing]
}

protocol AIServiceProtocol {
    func parseSearchIntent(query: String, currentListings: [Listing]) async throws -> IntentSearchResult
}

class MockAIService: AIServiceProtocol {
    func parseSearchIntent(query: String, currentListings: [Listing]) async throws -> IntentSearchResult {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        
        let lowerQuery = query.lowercased()
        
        var budget: Double? = nil
        var category: String? = nil
        var keywords: [String] = []
        
        // Very basic mock heuristic for "intent" extraction
        if lowerQuery.contains("cheap") || lowerQuery.contains("under 30k") {
            budget = 30000.0
        }
        
        if lowerQuery.contains("iphone") || lowerQuery.contains("laptop") {
            category = "Electronics"
            keywords.append(lowerQuery.contains("iphone") ? "iPhone" : "Laptop")
        }
        
        if lowerQuery.contains("gaming") {
            keywords.append("gaming")
        }
        
        // Filter mock listings
        let filtered = currentListings.filter { listing in
            if let cat = category, listing.category != cat { return false }
            if let maxB = budget, listing.price > maxB { return false }
            return true
        }
        
        return IntentSearchResult(category: category, budget: budget, keywords: keywords, listings: filtered)
    }
}
