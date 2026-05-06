import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    
    init(chatId: String = "defaultChatId") {
        _viewModel = StateObject(wrappedValue: ChatViewModel(chatId: chatId))
    }
    
    var body: some View {
        VStack {
            // AI Negotiation Assistant Banner
            if let hint = viewModel.negotiationHint {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Theme.accent)
                    Text(hint)
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                    Spacer()
                }
                .padding()
                .background(Theme.accent.opacity(0.1))
            }
            
            // Messages List
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        }
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message.text, isCurrentUser: viewModel.isCurrentUser(message))
                                .id(message.id)
                        }
                    }
                    .padding()
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
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
                
                TextField("Message...", text: $viewModel.inputText)
                    .padding(10)
                    .background(Theme.secondaryBackground)
                    .cornerRadius(20)
                    .onSubmit {
                        viewModel.sendMessage()
                    }
                
                Button(action: {
                    viewModel.sendMessage()
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
        .onAppear {
            if viewModel.messages.isEmpty {
                viewModel.fetchMessages()
            }
        }
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
