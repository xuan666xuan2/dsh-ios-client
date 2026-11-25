import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    @State private var showToolCalls = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.role == .user {
                Spacer(minLength: 40)
            }
            
            if message.role != .user {
                Image(systemName: message.role.iconName)
                    .font(.title3)
                    .foregroundColor(message.role == .assistant ? .blue : .orange)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                // 消息气泡
                VStack(alignment: .leading, spacing: 6) {
                    if message.role == .user {
                        Text(message.content)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(18)
                    } else {
                        // Assistant 消息支持 Markdown 风格
                        Text(message.content)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(18)
                            .textSelection(.enabled)
                    }
                }
                
                // 流式指示器
                if message.isStreaming {
                    HStack(spacing: 2) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(Color.secondary)
                                .frame(width: 4, height: 4)
                                .opacity(0.5)
                        }
                    }
                }
                
                // 时间戳
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if message.role == .user {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            
            if message.role != .user {
                Spacer(minLength: 40)
            }
        }
    }
}
