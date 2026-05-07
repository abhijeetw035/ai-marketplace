import SwiftUI

struct RootView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                LoginView(viewModel: authViewModel)
                    .transition(.move(edge: .bottom))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authViewModel.isAuthenticated)
    }
}
