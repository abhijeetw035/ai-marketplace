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

import FirebaseFirestore

class FirebaseChatService: ChatServiceProtocol {
    private let db = Firestore.firestore()
    
    func fetchMessages(for chatId: String) async throws -> [Message] {
        let snapshot = try await db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .getDocuments()
            
        return snapshot.documents.compactMap { doc -> Message? in
            try? doc.data(as: Message.self)
        }
    }
    
    func sendMessage(chatId: String, text: String, offerAmount: Double?) async throws -> Message {
        let newMessage = Message(
            id: UUID().uuidString,
            chatId: chatId,
            senderId: "currentUser123", // Should come from AuthService
            text: text,
            mediaUrl: nil,
            timestamp: Date(),
            readStatus: false,
            offerAmount: offerAmount
        )
        
        let docRef = db.collection("chats").document(chatId).collection("messages").document(newMessage.id)
        try docRef.setData(from: newMessage)
        
        // Update the last message on the chat document
        try await db.collection("chats").document(chatId).setData([
            "lastMessage": text,
            "updatedAt": Timestamp(date: Date())
        ], merge: true)
        
        return newMessage
    }
}
