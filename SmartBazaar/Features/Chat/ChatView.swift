import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    
    var body: some View {
        VStack {
            // AI Negotiation Assistant Banner
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Theme.accent)
                Text("AI: Try countering with ₹4,200. Buyer is likely to accept.")
                    .font(.caption)
                    .foregroundColor(Theme.accent)
                Spacer()
            }
            .padding()
            .background(Theme.accent.opacity(0.1))
            
            // Messages List
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    ChatBubble(message: "Is this still available?", isCurrentUser: false)
                    ChatBubble(message: "Yes, it is!", isCurrentUser: true)
                    ChatBubble(message: "Would you take 4000?", isCurrentUser: false)
                }
                .padding()
            }
            
            // Input Area
            HStack {
                Button(action: {
                    // Add media
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                TextField("Message...", text: $messageText)
                    .padding(10)
                    .background(Theme.secondaryBackground)
                    .cornerRadius(20)
                
                Button(action: {
                    // Send message
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundColor(Theme.accent)
                }
            }
            .padding()
            .background(Theme.background)
        }
        .navigationTitle("John Doe")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChatBubble: View {
    let message: String
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            Text(message)
                .padding(12)
                .background(isCurrentUser ? Theme.accent : Theme.secondaryBackground)
                .foregroundColor(isCurrentUser ? .white : Theme.primary)
                .cornerRadius(16)
            
            if !isCurrentUser { Spacer() }
        }
    }
}

#Preview {
    NavigationView {
        ChatView()
    }
}
