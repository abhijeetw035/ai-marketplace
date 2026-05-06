import Foundation
import SwiftUI
import Combine

@MainActor
class FeedViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String? = nil
    @Published var pendingSyncCount: Int = 0
    
    private var currentPage: Int = 1
    private var hasMorePages: Bool = true
    
    private let listingService: ListingServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let syncService: PersistentSyncService
    private let network = NetworkMonitor.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(
        listingService: ListingServiceProtocol? = nil,
        cacheService: CacheServiceProtocol? = nil
    ) {
        self.listingService = listingService ?? FirebaseListingService()
        self.cacheService = cacheService ?? FileSystemCacheService()
        self.syncService = PersistentSyncService(listingService: listingService)
        
        loadCachedFeed()
        observeNetwork()
        
        syncService.$pendingCount
            .receive(on: RunLoop.main)
            .assign(to: \.pendingSyncCount, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Network observation
    
    private func observeNetwork() {
        network.$isConnected
            .removeDuplicates()
            .sink { [weak self] isOnline in
                guard let self else { return }
                if isOnline {
                    Task { await self.onReconnect() }
                }
            }
            .store(in: &cancellables)
    }
    
    private func onReconnect() async {
        // Flush queued actions first, then refresh feed
        await syncService.syncPendingActions()
        fetchListings()
    }
    
    // MARK: - Cache
    
    private func loadCachedFeed() {
        if let cached = try? cacheService.getCachedFeed(), !cached.isEmpty {
            self.listings = cached
        }
    }
    
    // MARK: - Fetch
    
    func fetchListings() {
        guard network.isConnected else {
            // Offline — serve cached content silently
            loadCachedFeed()
            return
        }
        
        isLoading = listings.isEmpty  // Only show spinner on cold start
        errorMessage = nil
        currentPage = 1
        hasMorePages = true
        
        Task {
            do {
                let fetched = try await listingService.fetchFeed(page: currentPage)
                self.listings = fetched
                try? cacheService.saveFeed(listings: fetched)
                self.hasMorePages = fetched.count == 20
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func loadMoreListings() {
        guard !isLoadingMore, hasMorePages, network.isConnected else { return }
        isLoadingMore = true
        currentPage += 1
        
        Task {
            do {
                let more = try await listingService.fetchFeed(page: currentPage)
                self.listings.append(contentsOf: more)
                self.hasMorePages = more.count == 20
                self.isLoadingMore = false
            } catch {
                self.isLoadingMore = false
            }
        }
    }
    
    // MARK: - Offline queuing helpers (used by other ViewModels)
    
    func queueCreateListing(_ listing: Listing) {
        syncService.enqueue(type: .createListing, payload: CreateListingPayload(listing: listing))
    }
    
    func queueUpdateListing(_ listing: Listing) {
        syncService.enqueue(type: .updateListing, payload: UpdateListingPayload(listing: listing))
    }
}

