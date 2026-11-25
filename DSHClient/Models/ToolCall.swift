import SwiftUI

struct ToolCall: Identifiable, Codable {
    let id: String
    let name: String
    let arguments: String
    var result: String?
    var status: ToolCallStatus
    
    init(id: String = UUID().uuidString, name: String, arguments: String) {
        self.id = id
        self.name = name
        self.arguments = arguments
        self.result = nil
        self.status = .running
    }
}

enum ToolCallStatus: String, Codable {
    case running = "running"
    case completed = "completed"
    case failed = "failed"
    
    var iconName: String {
        switch self {
        case .running: return "arrow.triangle.2.circlepath"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    var color: SwiftUI.Color {
        switch self {
        case .running: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }
}
