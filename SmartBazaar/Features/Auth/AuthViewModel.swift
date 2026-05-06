import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = MockAuthService()) {
        self.authService = authService
        self.isAuthenticated = authService.isAuthenticated
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await authService.login(email: email, password: password)
                self.isAuthenticated = true
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func signup() {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill all fields."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await authService.signup(name: name, email: email, password: password)
                self.isAuthenticated = true
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func logout() {
        do {
            try authService.logout()
            self.isAuthenticated = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
