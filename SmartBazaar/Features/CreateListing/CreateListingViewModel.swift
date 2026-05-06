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
    @Published var suggestedPriceRange: String? = nil
    @Published var errorMessage: String? = nil
    
    private let listingService: ListingServiceProtocol
    // private let aiService: AIServiceProtocol // To be added in Phase 3
    
    init(listingService: ListingServiceProtocol = MockListingService()) {
        self.listingService = listingService
    }
    
    func suggestPrice() {
        // Mocking AI Price Suggestion (Phase 3 placeholder)
        guard !title.isEmpty, !description.isEmpty else { return }
        
        // Simulating network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.suggestedPriceRange = "₹4,200 - ₹4,800"
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
