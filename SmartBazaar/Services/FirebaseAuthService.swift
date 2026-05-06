import Foundation
import Combine
import FirebaseAuth

class FirebaseAuthService: AuthServiceProtocol, ObservableObject {
    @Published var currentUser: User?
    
    var isAuthenticated: Bool {
        Auth.auth().currentUser != nil
    }
    
    init() {
        _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                self?.currentUser = User(
                    id: user.uid,
                    name: user.displayName ?? "User",
                    avatar: user.photoURL?.absoluteString,
                    rating: 5.0,
                    createdAt: Date(),
                    verificationStatus: true
                )
            } else {
                self?.currentUser = nil
            }
        }
    }
    
    func login(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return User(
            id: result.user.uid,
            name: result.user.displayName ?? "User",
            avatar: result.user.photoURL?.absoluteString,
            rating: 5.0,
            createdAt: Date(),
            verificationStatus: true
        )
    }
    
    func signup(name: String, email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        
        return User(
            id: result.user.uid,
            name: name,
            avatar: nil,
            rating: 5.0,
            createdAt: Date(),
            verificationStatus: true
        )
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
}
