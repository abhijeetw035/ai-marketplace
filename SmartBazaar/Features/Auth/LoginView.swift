import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: DesignSystem.Spacing.large) {
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.small) {
                    Text("SmartBazaar")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.accent)
                    
                    Text("The AI-Powered Marketplace")
                        .font(.subheadline)
                        .foregroundColor(Theme.secondaryText)
                }
                
                VStack(spacing: DesignSystem.Spacing.medium) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(Theme.error)
                        .font(.caption)
                }
                
                Button(action: {
                    viewModel.login()
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 4)
                        }
                        Text(viewModel.isLoading ? "Logging in..." : "Log In")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Theme.accent)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)
                
                NavigationLink(destination: SignupView(viewModel: viewModel)) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(Theme.accent)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .background(Theme.background)
        }
    }
}

#Preview {
    LoginView()
}
