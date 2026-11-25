import Foundation

struct ChatMessage: Identifiable, Codable {
    var id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    var isStreaming: Bool
    
    init(role: MessageRole, content: String, isStreaming: Bool = false) {
        self.id = UUID()
        self.role = role
        self.content = content
        self.timestamp = Date()
        self.isStreaming = isStreaming
    }
}

enum MessageRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .user: return "你"
        case .assistant: return "DSH"
        case .system: return "系统"
        }
    }
    
    var iconName: String {
        switch self {
        case .user: return "person.circle.fill"
        case .assistant: return "cpu.fill"
        case .system: return "gearshape.fill"
        }
    }
    
    var bubbleColor: Color {
        switch self {
        case .user: return .blue
        case .assistant: return Color(.systemGray5)
        case .system: return .orange
        }
    }
}

extension MessageRole {
    typealias Color = SwiftUI.Color
}
