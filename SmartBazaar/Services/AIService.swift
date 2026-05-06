import Foundation

struct IntentSearchResult {
    let category: String?
    let budget: Double?
    let keywords: [String]
    let listings: [Listing]
}

struct PriceSuggestionResult {
    let suggestedRange: String
    let recommendedPrice: Double
    let sellFastPrice: Double
    let confidence: String
    let explanation: String
}

protocol AIServiceProtocol {
    func parseSearchIntent(query: String, currentListings: [Listing]) async throws -> IntentSearchResult
    func suggestPrice(title: String, description: String, category: String, condition: String) async throws -> PriceSuggestionResult
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
    
    func suggestPrice(title: String, description: String, category: String, condition: String) async throws -> PriceSuggestionResult {
        try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate network
        
        // Rule-based base price
        var basePrice = 5000.0
        if category == "Electronics" { basePrice = 15000.0 }
        else if category == "Furniture" { basePrice = 8000.0 }
        else if category == "Vehicles" { basePrice = 50000.0 }
        
        // Condition multiplier
        let conditionMultiplier: Double
        switch condition {
        case "Like New": conditionMultiplier = 0.9
        case "Good": conditionMultiplier = 0.7
        case "Fair": conditionMultiplier = 0.5
        default: conditionMultiplier = 0.7
        }
        
        var calculatedPrice = basePrice * conditionMultiplier
        
        // AI Refinement Layer (mocked via heuristics)
        var explanation = "Based on market average for \(category) in \(condition) condition."
        let lowerDesc = description.lowercased()
        
        if lowerDesc.contains("urgent") || lowerDesc.contains("quick sale") {
            calculatedPrice *= 0.85
            explanation += " Lowered slightly due to urgent sale intent."
        }
        
        if lowerDesc.contains("barely used") || lowerDesc.contains("original box") {
            calculatedPrice *= 1.15
            explanation += " Increased value detected from 'barely used' or 'original box' signals."
        }
        
        // Rounding to nearest 99 for realism
        let recommendedPrice = floor(calculatedPrice / 100) * 100 + 99
        let sellFastPrice = floor(recommendedPrice * 0.85 / 100) * 100 + 99
        
        let rangeStart = floor(recommendedPrice * 0.9 / 100) * 100
        let rangeEnd = ceil(recommendedPrice * 1.1 / 100) * 100
        
        return PriceSuggestionResult(
            suggestedRange: "₹\(Int(rangeStart)) - ₹\(Int(rangeEnd))",
            recommendedPrice: recommendedPrice,
            sellFastPrice: sellFastPrice,
            confidence: "High",
            explanation: explanation
        )
    }
}
