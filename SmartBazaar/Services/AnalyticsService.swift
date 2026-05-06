import Foundation

// MARK: - Event Definitions

enum AnalyticsEvent {
    // Feed
    case feedViewed
    case feedRefreshed
    case listingCardTapped(listingId: String, title: String)
    case feedPaginationLoaded(page: Int)
    
    // Listing Detail
    case listingDetailViewed(listingId: String)
    case wishlistAdded(listingId: String)
    case chatOpened(listingId: String)
    
    // Create Listing
    case createListingStarted
    case aiPriceSuggestionRequested(category: String, condition: String)
    case listingPublished(listingId: String, price: Double, category: String)
    
    // Search
    case searchPerformed(query: String, resultCount: Int)
    case searchNoResults(query: String)
    
    // Chat
    case messageSent(chatId: String)
    case offerMade(chatId: String, amount: Double)
    case negotiationHintShown(chatId: String, probability: Int)
    case quickReplySent(chatId: String)
    
    // Offline
    case offlineBannerShown
    case syncCompleted(pendingCount: Int)
    
    var name: String {
        switch self {
        case .feedViewed:                  return "feed_viewed"
        case .feedRefreshed:               return "feed_refreshed"
        case .listingCardTapped:           return "listing_card_tapped"
        case .feedPaginationLoaded:        return "feed_pagination_loaded"
        case .listingDetailViewed:         return "listing_detail_viewed"
        case .wishlistAdded:               return "wishlist_added"
        case .chatOpened:                  return "chat_opened"
        case .createListingStarted:        return "create_listing_started"
        case .aiPriceSuggestionRequested:  return "ai_price_suggestion_requested"
        case .listingPublished:            return "listing_published"
        case .searchPerformed:             return "search_performed"
        case .searchNoResults:             return "search_no_results"
        case .messageSent:                 return "message_sent"
        case .offerMade:                   return "offer_made"
        case .negotiationHintShown:        return "negotiation_hint_shown"
        case .quickReplySent:              return "quick_reply_sent"
        case .offlineBannerShown:          return "offline_banner_shown"
        case .syncCompleted:               return "sync_completed"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .listingCardTapped(let id, let title):
            return ["listing_id": id, "title": title]
        case .feedPaginationLoaded(let page):
            return ["page": page]
        case .listingDetailViewed(let id):
            return ["listing_id": id]
        case .wishlistAdded(let id), .chatOpened(let id):
            return ["listing_id": id]
        case .aiPriceSuggestionRequested(let cat, let cond):
            return ["category": cat, "condition": cond]
        case .listingPublished(let id, let price, let cat):
            return ["listing_id": id, "price": price, "category": cat]
        case .searchPerformed(let q, let count):
            return ["query": q, "result_count": count]
        case .searchNoResults(let q):
            return ["query": q]
        case .messageSent(let chatId), .quickReplySent(let chatId):
            return ["chat_id": chatId]
        case .offerMade(let chatId, let amount):
            return ["chat_id": chatId, "amount": amount]
        case .negotiationHintShown(let chatId, let prob):
            return ["chat_id": chatId, "deal_probability": prob]
        case .syncCompleted(let count):
            return ["pending_count": count]
        default:
            return [:]
        }
    }
}

// MARK: - Analytics Service

protocol AnalyticsServiceProtocol {
    func log(_ event: AnalyticsEvent)
}

// Production: swap this for Firebase Analytics / Mixpanel / Amplitude
final class AnalyticsService: AnalyticsServiceProtocol {
    static let shared = AnalyticsService()
    private init() {}
    
    func log(_ event: AnalyticsEvent) {
        // In production: Analytics.logEvent(event.name, parameters: event.parameters)
        #if DEBUG
        let paramStr = event.parameters.isEmpty
            ? ""
            : " | \(event.parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", "))"
        print("📊 [\(event.name)]\(paramStr)")
        #endif
    }
}
