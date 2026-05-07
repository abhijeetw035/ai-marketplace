import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.large) {
                Spacer()
                
                VStack(spacing: DesignSystem.Spacing.small) {
                    Image(systemName: "bag.fill.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.accent)
                        .padding(.bottom, DesignSystem.Spacing.small)
                    
                    Text("SmartBazaar")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundColor(Theme.primary)
                    
                    Text("The AI-Powered Marketplace")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(Theme.secondaryText)
                }
                .appearAnimation()
                
                VStack(spacing: DesignSystem.Spacing.medium) {
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
                        SecureField("Enter your password", text: $viewModel.password)
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
                
                VStack(spacing: DesignSystem.Spacing.medium) {
                    Button(action: {
                        viewModel.login()
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Log In")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(viewModel.isLoading)
                    
                    NavigationLink(destination: SignupView(viewModel: viewModel)) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(Theme.secondaryText)
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(Theme.accent)
                        }
                        .font(DesignSystem.Typography.body)
                    }
                }
                .padding(.horizontal)
                .appearAnimation(delay: 0.2)
                
                Spacer()
            }
            .background(Theme.background)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
