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

struct NegotiationAnalysisResult {
    let isOffer: Bool
    let detectedAmount: Double?
    let dealProbability: Int // 0 to 100
    let suggestionText: String
    let quickReplies: [String]
}

protocol AIServiceProtocol {
    func parseSearchIntent(query: String, currentListings: [Listing]) async throws -> IntentSearchResult
    func suggestPrice(title: String, description: String, category: String, condition: String) async throws -> PriceSuggestionResult
    func analyzeNegotiation(message: String, currentPrice: Double, isSeller: Bool) async throws -> NegotiationAnalysisResult
}

class MockAIService: AIServiceProtocol {
    func parseSearchIntent(query: String, currentListings: [Listing]) async throws -> IntentSearchResult {
        try await Task.sleep(nanoseconds: 1_200_000_000)
        
        let lowerQuery = query.lowercased()
        
        var budget: Double? = nil
        var category: String? = nil
        var keywords: [String] = []
        var useCase: String? = nil
        
        // Extract budget
        let numbers = lowerQuery.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
        if let firstNum = numbers.first, let val = Double(firstNum) {
            budget = val
            if lowerQuery.contains("k") { budget! *= 1000 }
        } else if lowerQuery.contains("cheap") || lowerQuery.contains("budget") {
            budget = 20000.0
        }
        
        // Extract category
        if lowerQuery.contains("iphone") || lowerQuery.contains("laptop") || lowerQuery.contains("phone") {
            category = "Electronics"
        } else if lowerQuery.contains("chair") || lowerQuery.contains("desk") || lowerQuery.contains("table") {
            category = "Furniture"
        } else if lowerQuery.contains("bike") || lowerQuery.contains("car") {
            category = "Vehicles"
        }
        
        // Extract use case
        if lowerQuery.contains("gaming") { useCase = "Gaming" }
        else if lowerQuery.contains("study") || lowerQuery.contains("student") { useCase = "Student/Study" }
        else if lowerQuery.contains("office") || lowerQuery.contains("work") { useCase = "Office Work" }
        
        if let uc = useCase { keywords.append(uc) }
        
        // Filter & Re-rank
        var rankedListings = currentListings.map { listing -> (Listing, Int) in
            var score = 0
            if let cat = category, listing.category == cat { score += 50 }
            if let maxB = budget, listing.price <= maxB { score += 30 }
            if let uc = useCase, listing.description.lowercased().contains(uc.lowercased()) || listing.title.lowercased().contains(uc.lowercased()) { score += 40 }
            
            // Basic keyword match
            for word in lowerQuery.components(separatedBy: " ") {
                if word.count > 3 && (listing.title.lowercased().contains(word) || listing.description.lowercased().contains(word)) {
                    score += 10
                }
            }
            return (listing, score)
        }
        
        rankedListings.removeAll(where: { $0.1 < 20 }) // Fallback logic: must have some relevance
        rankedListings.sort(by: { $0.1 > $1.1 })
        
        let finalResults = rankedListings.map { $0.0 }
        
        return IntentSearchResult(category: category, budget: budget, keywords: keywords, listings: finalResults)
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
    
    func analyzeNegotiation(message: String, currentPrice: Double, isSeller: Bool) async throws -> NegotiationAnalysisResult {
        try await Task.sleep(nanoseconds: 800_000_000)
        
        let lowerMsg = message.lowercased()
        
        // Extract numbers
        let numbers = message.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .filter { !$0.isEmpty }
            .compactMap { Double($0) }
            
        let detectedAmount = numbers.first
        let isOffer = detectedAmount != nil || lowerMsg.contains("offer") || lowerMsg.contains("discount")
        
        if !isOffer {
            return NegotiationAnalysisResult(isOffer: false, detectedAmount: nil, dealProbability: 0, suggestionText: "", quickReplies: [])
        }
        
        var probability = 50
        var suggestion = ""
        var replies: [String] = []
        
        if let offer = detectedAmount {
            let ratio = offer / currentPrice
            if ratio >= 0.9 {
                probability = 90
                suggestion = "Great offer! Consider accepting or rounding to ₹\(Int(currentPrice))."
                replies = ["I'll take it", "Make it ₹\(Int(currentPrice)) and it's yours"]
            } else if ratio >= 0.75 {
                probability = 70
                let counter = Int((currentPrice + offer) / 2)
                suggestion = "Reasonable offer. Counter with ₹\(counter) to meet in the middle."
                replies = ["How about ₹\(counter)?", "I can do ₹\(counter)"]
            } else {
                probability = 20
                suggestion = "Lowball offer. Hold firm or offer a minimal discount."
                replies = ["Too low, sorry.", "Best I can do is ₹\(Int(currentPrice * 0.9))"]
            }
        } else {
            probability = 60
            suggestion = "Buyer is probing for a discount. Ask what they have in mind."
            replies = ["What's your offer?", "Price is slightly negotiable."]
        }
        
        return NegotiationAnalysisResult(
            isOffer: true,
            detectedAmount: detectedAmount,
            dealProbability: probability,
            suggestionText: suggestion,
            quickReplies: replies
        )
    }
}
