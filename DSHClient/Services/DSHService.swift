import Foundation
import SwiftUI

class DSHService: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var messages: [ChatMessage] = []
    @Published var isStreaming: Bool = false
    @Published var currentSession: ChatSession = ChatSession()
    @Published var sessions: [ChatSession] = []
    @Published var error: String?
    
    private var baseURL: String = ""
    private var authToken: String = ""
    private var streamTask: URLSessionDataTask?
    private var streamBuffer: String = ""
    
    // MARK: - 连接管理
    
    func connect(url: String, token: String, completion: @escaping (Bool, String?) -> Void) {
        baseURL = url.hasSuffix("/") ? String(url.dropLast()) : url
        authToken = token
        
        // 测试连接 - 尝试访问 DSH 的 /api/status 或根路径
        guard let testURL = URL(string: "\(baseURL)/api/status") ?? URL(string: baseURL) else {
            completion(false, "无效的服务器地址")
            return
        }
        
        var request = URLRequest(url: testURL)
        request.timeoutInterval = 10
        
        if !authToken.isEmpty {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, "连接失败: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 || httpResponse.statusCode == 401 {
                        // 401 说明服务器可达但需要认证
                        self?.isConnected = true
                        if httpResponse.statusCode == 401 && token.isEmpty {
                            completion(true, nil)
                        } else {
                            completion(true, nil)
                        }
                    } else {
                        completion(false, "服务器返回状态码: \(httpResponse.statusCode)")
                    }
                } else {
                    // 没有 HTTP 响应，可能是其他协议
                    self?.isConnected = true
                    completion(true, nil)
                }
            }
        }.resume()
    }
    
    func disconnect() {
        isConnected = false
        streamTask?.cancel()
        messages.removeAll()
        baseURL = ""
        authToken = ""
    }
    
    // MARK: - 会话管理
    
    func newSession() {
        if !currentSession.messages.isEmpty {
            sessions.insert(currentSession, at: 0)
        }
        currentSession = ChatSession()
        messages.removeAll()
    }
    
    // MARK: - 发送消息
    
    func send(message text: String) {
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        
        let assistantMessage = ChatMessage(role: .assistant, content: "", isStreaming: true)
        messages.append(assistantMessage)
        isStreaming = true
        
        // 通过 DSH API 发送消息
        sendToDSH(text: text, assistantMessageId: assistantMessage.id)
    }
    
    private func sendToDSH(text: String, assistantMessageId: UUID) {
        guard let url = URL(string: "\(baseURL)/api/chat/completions") else {
            updateAssistantMessage(id: assistantMessageId, content: "错误: 无效的服务器地址")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if !authToken.isEmpty {
            request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        
        // 构建消息历史
        var apiMessages: [[String: String]] = []
        for msg in messages where msg.id != assistantMessageId {
            apiMessages.append([
                "role": msg.role.rawValue,
                "content": msg.content
            ])
        }
        
        let body: [String: Any] = [
            "model": "default",
            "messages": apiMessages,
            "stream": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            updateAssistantMessage(id: assistantMessageId, content: "错误: 无法序列化请求")
            return
        }
        
        // SSE 流式请求
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.updateAssistantMessage(id: assistantMessageId, content: "错误: \(error.localizedDescription)")
                    self?.isStreaming = false
                    return
                }
                
                if let data = data, let text = String(data: data, encoding: .utf8) {
                    self?.processSSEResponse(text, assistantMessageId: assistantMessageId)
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    self?.updateAssistantMessage(id: assistantMessageId, content: "服务器错误: HTTP \(httpResponse.statusCode)")
                }
                
                self?.isStreaming = false
                if let idx = self?.messages.firstIndex(where: { $0.id == assistantMessageId }) {
                    self?.messages[idx].isStreaming = false
                }
            }
        }
        
        streamTask = task
        task.resume()
    }
    
    private func processSSEResponse(_ text: String, assistantMessageId: UUID) {
        var fullContent = ""
        let lines = text.components(separatedBy: "\n")
        
        for line in lines {
            if line.hasPrefix("data: ") {
                let jsonStr = String(line.dropFirst(6))
                if jsonStr == "[DONE]" { break }
                
                if let data = jsonStr.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let delta = choices.first?["delta"] as? [String: Any],
                   let content = delta["content"] as? String {
                    fullContent += content
                }
            }
        }
        
        if !fullContent.isEmpty {
            updateAssistantMessage(id: assistantMessageId, content: fullContent)
        }
    }
    
    private func updateAssistantMessage(id: UUID, content: String) {
        if let idx = messages.firstIndex(where: { $0.id == id }) {
            let streaming = messages[idx].isStreaming
            messages[idx] = ChatMessage(role: .assistant, content: content, isStreaming: streaming)
        }
    }
}
