import Foundation

struct ChatSession: Identifiable, Codable {
    let id: String
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, title: String = "新对话") {
        self.id = id
        self.title = title
        self.messages = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct SessionList: Codable {
    var sessions: [ChatSession] = []
}
