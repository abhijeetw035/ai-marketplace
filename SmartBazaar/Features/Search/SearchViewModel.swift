import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var searchResults: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var hasSearched: Bool = false
    
    // Parsed intent state shown in UI
    @Published var extractedCategory: String? = nil
    @Published var extractedBudget: Double? = nil
    @Published var extractedUseCase: String? = nil
    @Published var extractedIntent: String? = nil
    
    private let aiService: AIServiceProtocol
    private let listingService: ListingServiceProtocol
    private var searchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(aiService: AIServiceProtocol? = nil, listingService: ListingServiceProtocol? = nil) {
        self.aiService = aiService ?? MockAIService()
        self.listingService = listingService ?? FirebaseListingService()
    }
    
    func performSearch() {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        searchTask?.cancel()
        isLoading = true
        hasSearched = false
        searchResults = []
        extractedIntent = nil
        extractedCategory = nil
        extractedBudget = nil
        extractedUseCase = nil
        
        searchTask = Task {
            do {
                // Fetch catalogue baseline
                let allListings = try await listingService.fetchFeed(page: 1)
                guard !Task.isCancelled else { return }
                
                // Semantic parse + re-rank via AI engine
                let result = try await aiService.parseSearchIntent(query: query, currentListings: allListings)
                guard !Task.isCancelled else { return }
                
                self.searchResults = result.listings
                self.extractedCategory = result.category
                self.extractedBudget = result.budget
                self.extractedUseCase = result.keywords.first
                
                // Build human-readable intent summary
                var parts: [String] = []
                if let cat = result.category { parts.append(cat) }
                if let uc = result.keywords.first { parts.append("for \(uc)") }
                if let b = result.budget { parts.append("under ₹\(Int(b))") }
                
                self.extractedIntent = parts.isEmpty
                    ? "Showing all relevant items"
                    : "Looking for \(parts.joined(separator: " "))"
                
                self.isLoading = false
                self.hasSearched = true
            } catch {
                if !Task.isCancelled {
                    self.isLoading = false
                    self.hasSearched = true
                }
            }
        }
    }
    
    func clearSearch() {
        searchTask?.cancel()
        query = ""
        searchResults = []
        extractedIntent = nil
        extractedCategory = nil
        extractedBudget = nil
        extractedUseCase = nil
        isLoading = false
        hasSearched = false
    }
}
