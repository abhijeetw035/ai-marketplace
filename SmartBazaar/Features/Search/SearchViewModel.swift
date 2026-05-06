import Foundation

@MainActor
class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var searchResults: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var extractedIntent: String? = nil
    
    private let aiService: AIServiceProtocol
    private let listingService: ListingServiceProtocol
    
    init(aiService: AIServiceProtocol = MockAIService(), listingService: ListingServiceProtocol = MockListingService()) {
        self.aiService = aiService
        self.listingService = listingService
    }
    
    func performSearch() {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        searchResults = []
        extractedIntent = nil
        
        Task {
            do {
                // Fetch baseline catalogue
                let allListings = try await listingService.fetchFeed(page: 1)
                
                // Parse intent and filter
                let result = try await aiService.parseSearchIntent(query: query, currentListings: allListings)
                
                self.searchResults = result.listings
                
                var intentDesc = "AI understood: "
                if let cat = result.category { intentDesc += "Looking for \(cat). " }
                if let b = result.budget { intentDesc += "Budget under ₹\(b). " }
                if !result.keywords.isEmpty { intentDesc += "Keywords: \(result.keywords.joined(separator: ", "))." }
                
                self.extractedIntent = intentDesc
                self.isLoading = false
            } catch {
                self.isLoading = false
                print("Search error: \(error)")
            }
        }
    }
}
