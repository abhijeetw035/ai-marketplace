import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(0..<5) { index in
                        FeedItemCard()
                    }
                }
                .padding()
            }
            .navigationTitle("Marketplace")
            .background(Theme.secondaryBackground)
        }
    }
}

struct FeedItemCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 200)
                .cornerRadius(DesignSystem.CornerRadius.medium)
                .overlay(
                    Text("Image Placeholder")
                        .foregroundColor(.gray)
                )
            
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.tiny) {
                Text("Item Title")
                    .font(.headline)
                
                Text("₹4,500")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.accent)
                
                HStack {
                    Text("Trust Score: 92/100")
                        .font(.caption)
                        .foregroundColor(Theme.success)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Theme.success.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.small)
                    Spacer()
                    Text("Just now")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.tiny)
        }
        .padding(.bottom, DesignSystem.Spacing.medium)
    }
}

#Preview {
    FeedView()
}
