import SwiftUI

struct WishlistView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: "heart.slash")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                    .padding(.bottom, DesignSystem.Spacing.small)
                Text("No saved items yet")
                    .font(.headline)
                Text("Items you favorite will appear here.")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)
                Spacer()
            }
            .navigationTitle("Wishlist")
            .background(Theme.secondaryBackground)
        }
    }
}

#Preview {
    WishlistView()
}
