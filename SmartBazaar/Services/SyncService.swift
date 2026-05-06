import Foundation
import Combine

// MARK: - Pending Action Model

enum PendingActionType: String, Codable {
    case createListing
    case updateListing
    case saveWishlistItem
    case unsaveWishlistItem
    case sendMessage
}

struct PendingAction: Identifiable, Codable {
    let id: String
    let type: PendingActionType
    let payload: Data           // JSON-encoded payload
    let createdAt: Date
    var retryCount: Int
    
    init(type: PendingActionType, payload: Data) {
        self.id = UUID().uuidString
        self.type = type
        self.payload = payload
        self.createdAt = Date()
        self.retryCount = 0
    }
}

// MARK: - Pending Action Payloads

struct CreateListingPayload: Codable { let listing: Listing }
struct UpdateListingPayload: Codable { let listing: Listing }
struct WishlistPayload: Codable { let userId: String; let listingId: String }
struct SendMessagePayload: Codable { let chatId: String; let text: String; let offerAmount: Double? }

// MARK: - Sync Service Protocol

protocol SyncServiceProtocol: ObservableObject {
    var pendingCount: Int { get }
    func enqueue(type: PendingActionType, payload: some Encodable)
    func syncPendingActions() async
}

// MARK: - Production Sync Service

final class PersistentSyncService: SyncServiceProtocol, ObservableObject {
    
    @Published private(set) var pendingCount: Int = 0
    
    private let queueKey = "smartbazaar.pending_actions"
    private let maxRetries = 3
    private var queue: [PendingAction] = []
    
    private let listingService: ListingServiceProtocol
    
    init(listingService: ListingServiceProtocol? = nil) {
        self.listingService = listingService ?? FirebaseListingService()
        load()
    }
    
    // MARK: - Enqueue
    
    func enqueue(type: PendingActionType, payload: some Encodable) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        let action = PendingAction(type: type, payload: data)
        queue.append(action)
        pendingCount = queue.count
        persist()
    }
    
    // MARK: - Sync (runs after reconnect)
    
    func syncPendingActions() async {
        guard !queue.isEmpty else { return }
        
        var remaining: [PendingAction] = []
        
        for var action in queue {
            let success = await execute(action)
            if !success {
                action.retryCount += 1
                // Conflict resolution: discard after max retries, keep otherwise
                if action.retryCount < maxRetries {
                    remaining.append(action)
                } else {
                    print("SyncService: Discarding action \(action.type.rawValue) after \(maxRetries) retries.")
                }
            }
        }
        
        queue = remaining
        pendingCount = queue.count
        persist()
    }
    
    // MARK: - Execute individual action
    
    @discardableResult
    private func execute(_ action: PendingAction) async -> Bool {
        do {
            switch action.type {
            case .createListing:
                let payload = try JSONDecoder().decode(CreateListingPayload.self, from: action.payload)
                _ = try await listingService.createListing(listing: payload.listing)
                
            case .updateListing:
                let payload = try JSONDecoder().decode(UpdateListingPayload.self, from: action.payload)
                _ = try await listingService.updateListing(listing: payload.listing)
                
            case .saveWishlistItem, .unsaveWishlistItem, .sendMessage:
                // Handled by respective services — placeholder for extensibility
                break
            }
            return true
        } catch {
            print("SyncService: Action \(action.type.rawValue) failed — \(error)")
            return false
        }
    }
    
    // MARK: - Persistence (UserDefaults)
    
    private func persist() {
        guard let data = try? JSONEncoder().encode(queue) else { return }
        UserDefaults.standard.set(data, forKey: queueKey)
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: queueKey),
              let decoded = try? JSONDecoder().decode([PendingAction].self, from: data)
        else { return }
        queue = decoded
        pendingCount = queue.count
    }
}
