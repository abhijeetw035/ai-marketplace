import SwiftUI

struct SignupView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.large) {
            Spacer()
            
            VStack(spacing: DesignSystem.Spacing.small) {
                Text("Create Account")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(Theme.primary)
                
                Text("Join our community today")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(Theme.secondaryText)
            }
            .appearAnimation()
            
            VStack(spacing: DesignSystem.Spacing.medium) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                    Text("Full Name")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(Theme.secondaryText)
                    TextField("Enter your name", text: $viewModel.name)
                        .padding()
                        .background(Theme.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                    Text("Email")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(Theme.secondaryText)
                    TextField("Enter your email", text: $viewModel.email)
                        .padding()
                        .background(Theme.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                    Text("Password")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(Theme.secondaryText)
                    SecureField("Create a password", text: $viewModel.password)
                        .padding()
                        .background(Theme.secondaryBackground)
                        .cornerRadius(DesignSystem.CornerRadius.small)
                }
            }
            .padding(.horizontal)
            .appearAnimation(delay: 0.1)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(Theme.error)
                    .font(DesignSystem.Typography.caption)
                    .padding(.horizontal)
            }
            
            Button(action: {
                viewModel.signup()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            .appearAnimation(delay: 0.2)
            
            Spacer()
        }
        .background(Theme.background)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SignupView(viewModel: AuthViewModel())
}
