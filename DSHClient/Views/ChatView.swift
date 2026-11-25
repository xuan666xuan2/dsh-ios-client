import SwiftUI

struct ChatView: View {
    @EnvironmentObject var dshService: DSHService
    @State private var inputText: String = ""
    @State private var showSidebar = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 消息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dshService.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if dshService.isStreaming {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("思考中...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("streaming-indicator")
                        }
                    }
                    .padding()
                }
                .onChange(of: dshService.messages.count) { _ in
                    if let last = dshService.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: dshService.messages.last?.content) { _ in
                    if let last = dshService.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            // 输入区域
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 8) {
                    // 新建对话按钮
                    Button(action: { dshService.newSession() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // 文本输入
                    ZStack(alignment: .topLeading) {
                        if inputText.isEmpty {
                            Text("输入消息...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        TextEditor(text: $inputText)
                            .frame(minHeight: 40, maxHeight: 120)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .opacity(inputText.isEmpty ? 0.5 : 1)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    
                    // 发送按钮
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || dshService.isStreaming)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        dshService.send(message: text)
    }
}
