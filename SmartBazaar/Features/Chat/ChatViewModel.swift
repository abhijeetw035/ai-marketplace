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
    @Published var dealProbability: Int? = nil
    @Published var quickReplies: [String] = []
    
    let chatId: String
    let itemPrice: Double // Needed for analysis
    
    private let chatService: ChatServiceProtocol
    private let aiService: AIServiceProtocol
    private let currentUserId = "currentUser123" // Mocked
    
    init(chatId: String, itemPrice: Double = 5000.0, chatService: ChatServiceProtocol? = nil, aiService: AIServiceProtocol? = nil) {
        self.chatId = chatId
        self.itemPrice = itemPrice
        self.chatService = chatService ?? FirebaseChatService()
        self.aiService = aiService ?? MockAIService()
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
    
    func sendMessage(text: String? = nil) {
        let textToSend = text ?? inputText
        guard !textToSend.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        if text == nil {
            inputText = ""
        }
        
        // Optimistic UI update
        let optimisticMsg = Message(id: UUID().uuidString, chatId: chatId, senderId: currentUserId, text: textToSend, mediaUrl: nil, timestamp: Date(), readStatus: false, offerAmount: nil)
        messages.append(optimisticMsg)
        
        // Clear UI hints immediately
        negotiationHint = nil
        dealProbability = nil
        quickReplies = []
        
        Task {
            do {
                let sentMsg = try await chatService.sendMessage(chatId: chatId, text: textToSend, offerAmount: nil)
                if let index = messages.firstIndex(where: { $0.id == optimisticMsg.id }) {
                    messages[index] = sentMsg
                }
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func analyzeLatestMessageForNegotiation() {
        guard let lastMessage = messages.last, lastMessage.senderId != currentUserId else { return }
        
        Task {
            do {
                let analysis = try await aiService.analyzeNegotiation(message: lastMessage.text, currentPrice: itemPrice, isSeller: true)
                
                if analysis.isOffer {
                    self.negotiationHint = analysis.suggestionText
                    self.dealProbability = analysis.dealProbability
                    self.quickReplies = analysis.quickReplies
                }
            } catch {
                print("Failed to analyze negotiation: \(error)")
            }
        }
    }
    
    func isCurrentUser(_ message: Message) -> Bool {
        return message.senderId == currentUserId
    }
}
