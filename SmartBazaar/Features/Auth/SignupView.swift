import SwiftUI

struct SignupView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()
            
            Text("Create Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.accent)
            
            VStack(spacing: DesignSystem.Spacing.medium) {
                TextField("Full Name", text: $viewModel.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
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
                viewModel.signup()
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 4)
                    }
                    Text(viewModel.isLoading ? "Signing up..." : "Sign Up")
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
            
            Spacer()
        }
        .background(Theme.background)
    }
}

#Preview {
    SignupView(viewModel: AuthViewModel())
}
