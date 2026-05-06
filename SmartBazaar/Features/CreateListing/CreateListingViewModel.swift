import Foundation
import Combine

@MainActor
class CreateListingViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var price: String = ""
    @Published var category: String = "Electronics"
    @Published var condition: String = "Good"
    
    @Published var isPublishing: Bool = false
    @Published var isFetchingSuggestion: Bool = false
    @Published var suggestedPriceRange: String? = nil
    @Published var recommendedPrice: Double? = nil
    @Published var aiExplanation: String? = nil
    @Published var errorMessage: String? = nil
    
    private let listingService: ListingServiceProtocol
    private let aiService: AIServiceProtocol
    
    init(listingService: ListingServiceProtocol? = nil, aiService: AIServiceProtocol? = nil) {
        self.listingService = listingService ?? FirebaseListingService()
        self.aiService = aiService ?? MockAIService()
    }
    
    private var suggestPriceTask: Task<Void, Never>?
    
    func suggestPrice() {
        guard !title.isEmpty, !description.isEmpty else { return }
        
        suggestPriceTask?.cancel()
        
        suggestPriceTask = Task {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second debounce
                guard !Task.isCancelled else { return }
                
                self.isFetchingSuggestion = true
                let suggestion = try await aiService.suggestPrice(title: title, description: description, category: category, condition: condition)
                
                guard !Task.isCancelled else { return }
                
                self.suggestedPriceRange = suggestion.suggestedRange
                self.recommendedPrice = suggestion.recommendedPrice
                self.aiExplanation = suggestion.explanation
                self.price = String(format: "%.0f", suggestion.recommendedPrice)
                self.isFetchingSuggestion = false
            } catch {
                if !Task.isCancelled {
                    print("Failed to get suggestion: \(error)")
                    self.isFetchingSuggestion = false
                }
            }
        }
    }
    
    func publishListing() async {
        guard let priceValue = Double(price), !title.isEmpty, !description.isEmpty else {
            self.errorMessage = "Please fill all required fields correctly."
            return
        }
        
        isPublishing = true
        errorMessage = nil
        
        let newListing = Listing(
            id: UUID().uuidString,
            sellerId: "currentUser123", // To get from AuthService
            title: title,
            description: description,
            images: [],
            category: category,
            condition: condition,
            price: priceValue,
            suggestedPriceRange: suggestedPriceRange,
            trustScore: 100, // Will be calculated
            location: "Local",
            createdAt: Date(),
            status: "active"
        )
        
        do {
            _ = try await listingService.createListing(listing: newListing)
            isPublishing = false
            // Handle success (e.g., dismiss view)
        } catch {
            errorMessage = error.localizedDescription
            isPublishing = false
        }
    }
}
