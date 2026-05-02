import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                            .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                        
                        VStack(alignment: .leading) {
                            Text("User Name")
                                .font(.headline)
                            Text("View and edit profile")
                                .font(.subheadline)
                                .foregroundColor(Theme.accent)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.small)
                }
                
                Section(header: Text("Account")) {
                    Label("My Listings", systemImage: "list.bullet")
                    Label("Messages", systemImage: "message")
                }
                
                Section(header: Text("Settings")) {
                    Label("Preferences", systemImage: "gear")
                    Label("Help & Support", systemImage: "questionmark.circle")
                    Label("Log Out", systemImage: "arrow.right.square")
                        .foregroundColor(Theme.error)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView()
}
