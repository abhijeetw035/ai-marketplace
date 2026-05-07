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
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(Theme.accent)
                        Text(hint)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Theme.primary)
                        Spacer()
                        if let prob = viewModel.dealProbability {
                            Text("\(prob)% Deal")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(prob > 70 ? Theme.success.opacity(0.2) : Theme.warning.opacity(0.2))
                                .foregroundColor(prob > 70 ? Theme.success : Theme.warning)
                                .cornerRadius(DesignSystem.CornerRadius.small)
                        }
                    }
                    
                    if !viewModel.quickReplies.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.quickReplies, id: \.self) { reply in
                                    Button(action: {
                                        viewModel.sendMessage(text: reply)
                                    }) {
                                        Text(reply)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Theme.background)
                                            .foregroundColor(Theme.accent)
                                            .cornerRadius(DesignSystem.CornerRadius.large)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                                                    .stroke(Theme.accent.opacity(0.5), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Theme.secondaryBackground)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Theme.border),
                    alignment: .bottom
                )
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
    NavigationStack {
        ChatView()
    }
}
