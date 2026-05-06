import Foundation
import Combine

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    
    func login(email: String, password: String) async throws -> User
    func signup(name: String, email: String, password: String) async throws -> User
    func logout() throws
}

class MockAuthService: AuthServiceProtocol {
    @Published var currentUser: User?
    var isAuthenticated: Bool { currentUser != nil }
    
    func login(email: String, password: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let mockUser = User(id: UUID().uuidString, name: "Test User", avatar: nil, rating: 4.5, createdAt: Date(), verificationStatus: true)
        self.currentUser = mockUser
        return mockUser
    }
    
    func signup(name: String, email: String, password: String) async throws -> User {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        let mockUser = User(id: UUID().uuidString, name: name, avatar: nil, rating: 5.0, createdAt: Date(), verificationStatus: false)
        self.currentUser = mockUser
        return mockUser
    }
    
    func logout() throws {
        self.currentUser = nil
    }
}
