import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
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
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button(action: {
                    // Login action
                }) {
                    Text("Log In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .cornerRadius(DesignSystem.CornerRadius.medium)
                }
                .padding(.horizontal)
                
                NavigationLink(destination: SignupView()) {
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
