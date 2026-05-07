import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Profile Header
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Circle()
                            .fill(Theme.tertiaryBackground)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.secondaryText)
                            )
                        
                        VStack(spacing: DesignSystem.Spacing.tiny) {
                            Text(viewModel.userName)
                                .font(DesignSystem.Typography.title)
                                .foregroundColor(Theme.primary)
                            
                            Text("Verified Member")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(Theme.accent)
                                .padding(.horizontal, DesignSystem.Spacing.small)
                                .padding(.vertical, 4)
                                .background(Theme.accent.opacity(0.1))
                                .cornerRadius(DesignSystem.CornerRadius.pill)
                        }
                    }
                    .padding(.top)
                    .appearAnimation()
                    
                    // Stats Section
                    HStack(spacing: 0) {
                        ProfileStatItem(title: "My Listings", value: "\(viewModel.listingsCount)")
                        Divider().frame(height: 30)
                        ProfileStatItem(title: "Wishlist", value: "\(viewModel.wishlistCount)")
                        Divider().frame(height: 30)
                        ProfileStatItem(title: "Rating", value: viewModel.rating)
                    }
                    .padding()
                    .background(Theme.background)
                    .cornerRadius(DesignSystem.CornerRadius.medium)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    .appearAnimation(delay: 0.1)
                    
                    // Menu Sections
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        ProfileMenuSection(title: "Account") {
                            ProfileMenuItem(icon: "list.bullet", title: "My Listings")
                            ProfileMenuItem(icon: "message", title: "Messages")
                            ProfileMenuItem(icon: "bell", title: "Notifications")
                        }
                        
                        ProfileMenuSection(title: "Settings") {
                            ProfileMenuItem(icon: "gear", title: "Preferences")
                            ProfileMenuItem(icon: "shield", title: "Security")
                            ProfileMenuItem(icon: "questionmark.circle", title: "Help & Support")
                        }
                        
                        Button(action: {
                            viewModel.logout()
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Log Out")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                            .foregroundColor(Theme.error)
                            .padding()
                            .background(Theme.error.opacity(0.1))
                            .cornerRadius(DesignSystem.CornerRadius.medium)
                        }
                        .padding(.top, DesignSystem.Spacing.small)
                    }
                    .padding(.horizontal)
                    .appearAnimation(delay: 0.2)
                }
                .padding(.bottom, DesignSystem.Spacing.extraLarge)
            }
            .background(Theme.secondaryBackground)
            .navigationTitle("Profile")
            .onAppear {
                viewModel.loadProfileData()
            }
        }
    }
}

struct ProfileStatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(Theme.primary)
            Text(title)
                .font(DesignSystem.Typography.micro)
                .foregroundColor(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileMenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(title)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(Theme.secondaryText)
                .padding(.leading, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Theme.background)
            .cornerRadius(DesignSystem.CornerRadius.medium)
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: icon)
                    .foregroundColor(Theme.accent)
                    .frame(width: 24)
                
                Text(title)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(Theme.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.secondaryText)
                    .opacity(0.5)
            }
            .padding()
        }
        Divider().padding(.leading, 50)
    }
}

#Preview {
    ProfileView()
}
