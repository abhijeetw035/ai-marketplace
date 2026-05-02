import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            CreateListingView()
                .tabItem {
                    Label("Sell", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            WishlistView()
                .tabItem {
                    Label("Saved", systemImage: "heart")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(4)
        }
        .tint(Theme.accent)
    }
}

#Preview {
    MainTabView()
}
