import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // AI Negotiation Assistant properties
    @Published var negotiationHint: String? = nil
    
    let chatId: String
    private let chatService: ChatServiceProtocol
    private let currentUserId = "currentUser123" // Mocked
    
    init(chatId: String, chatService: ChatServiceProtocol = MockChatService()) {
        self.chatId = chatId
        self.chatService = chatService
    }
    
    func fetchMessages() {
        isLoading = true
        Task {
            do {
                self.messages = try await chatService.fetchMessages(for: chatId)
                self.analyzeLatestMessageForNegotiation()
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let textToSend = inputText
        inputText = ""
        
        // Optimistic UI update
        let optimisticMsg = Message(id: UUID().uuidString, chatId: chatId, senderId: currentUserId, text: textToSend, mediaUrl: nil, timestamp: Date(), readStatus: false, offerAmount: nil)
        messages.append(optimisticMsg)
        
        Task {
            do {
                let sentMsg = try await chatService.sendMessage(chatId: chatId, text: textToSend, offerAmount: nil)
                if let index = messages.firstIndex(where: { $0.id == optimisticMsg.id }) {
                    messages[index] = sentMsg
                }
                negotiationHint = nil // Clear hint after sending
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func analyzeLatestMessageForNegotiation() {
        // Mock Phase 4: AI Negotiation Assistant logic
        if let lastMessage = messages.last, lastMessage.senderId != currentUserId {
            if lastMessage.text.contains("4000") || lastMessage.offerAmount != nil {
                self.negotiationHint = "AI: Try countering with ₹4,200. Buyer is likely to accept."
            }
        }
    }
    
    func isCurrentUser(_ message: Message) -> Bool {
        return message.senderId == currentUserId
    }
}
