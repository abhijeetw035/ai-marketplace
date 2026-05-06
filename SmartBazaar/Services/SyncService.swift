import Foundation

protocol SyncServiceProtocol {
    func queueAction(_ action: @escaping () async throws -> Void)
    func sync() async
}

class MockSyncService: SyncServiceProtocol {
    private var actionQueue: [() async throws -> Void] = []
    
    func queueAction(_ action: @escaping () async throws -> Void) {
        actionQueue.append(action)
    }
    
    func sync() async {
        guard !actionQueue.isEmpty else { return }
        
        for action in actionQueue {
            do {
                try await action()
            } catch {
                print("Sync action failed: \(error)")
            }
        }
        actionQueue.removeAll()
    }
}
