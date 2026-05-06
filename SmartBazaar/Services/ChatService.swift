import Foundation

protocol ChatServiceProtocol {
    func fetchMessages(for chatId: String) async throws -> [Message]
    func sendMessage(chatId: String, text: String, offerAmount: Double?) async throws -> Message
}

class MockChatService: ChatServiceProtocol {
    func fetchMessages(for chatId: String) async throws -> [Message] {
        try await Task.sleep(nanoseconds: 800_000_000)
        return [
            Message(id: "1", chatId: chatId, senderId: "buyer1", text: "Is this still available?", mediaUrl: nil, timestamp: Date().addingTimeInterval(-3600), readStatus: true, offerAmount: nil),
            Message(id: "2", chatId: chatId, senderId: "currentUser123", text: "Yes, it is!", mediaUrl: nil, timestamp: Date().addingTimeInterval(-3500), readStatus: true, offerAmount: nil),
            Message(id: "3", chatId: chatId, senderId: "buyer1", text: "Would you take ₹4000?", mediaUrl: nil, timestamp: Date().addingTimeInterval(-100), readStatus: true, offerAmount: 4000.0)
        ]
    }
    
    func sendMessage(chatId: String, text: String, offerAmount: Double? = nil) async throws -> Message {
        try await Task.sleep(nanoseconds: 500_000_000)
        return Message(id: UUID().uuidString, chatId: chatId, senderId: "currentUser123", text: text, mediaUrl: nil, timestamp: Date(), readStatus: false, offerAmount: offerAmount)
    }
}
