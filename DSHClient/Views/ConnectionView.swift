import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var dshService: DSHService
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("authToken") private var authToken: String = ""
    @AppStorage("savedConnections") private var savedConnectionsData: Data = Data()
    
    @State private var inputURL: String = ""
    @State private var inputToken: String = ""
    @State private var isConnecting: Bool = false
    @State private var errorMessage: String?
    @State private var savedConnections: [SavedConnection] = []
    
    struct SavedConnection: Codable, Identifiable {
        let id: UUID
        var name: String
        var url: String
        var token: String
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Logo
                VStack(spacing: 12) {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("DSH Client")
                        .font(.title.bold())
                    Text("连接到你的 DeepSeek Harness 实例")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // 快速连接
                VStack(spacing: 16) {
                    Text("快速连接")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("服务器地址 (如 http://192.168.1.100:57764)", text: $inputURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.URL)
                    
                    SecureField("认证 Token（可选）", text: $inputToken)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: connect) {
                        HStack {
                            if isConnecting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isConnecting ? "连接中..." : "连接")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(inputURL.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(inputURL.isEmpty || isConnecting)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // 已保存的连接
                if !savedConnections.isEmpty {
                    VStack(spacing: 12) {
                        Text("已保存的连接")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(savedConnections) { conn in
                            Button(action: { quickConnect(conn) }) {
                                HStack {
                                    Image(systemName: "server.rack")
                                        .foregroundColor(.blue)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(conn.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                        Text(conn.url)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                // 扫码连接
                VStack(spacing: 12) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("扫描 DSH 桌面端二维码")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("在 DSH 桌面端打开「更多 → 手机连接」生成二维码")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadSavedConnections()
            inputURL = serverURL
            inputToken = authToken
        }
    }
    
    private func connect() {
        isConnecting = true
        errorMessage = nil
        
        var url = inputURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !url.hasPrefix("http") {
            url = "http://" + url
        }
        
        dshService.connect(url: url, token: inputToken) { success, error in
            DispatchQueue.main.async {
                isConnecting = false
                if success {
                    serverURL = url
                    authToken = inputToken
                    saveConnection(name: extractHost(from: url), url: url, token: inputToken)
                } else {
                    errorMessage = error ?? "连接失败，请检查地址和网络"
                }
            }
        }
    }
    
    private func quickConnect(_ conn: SavedConnection) {
        inputURL = conn.url
        inputToken = conn.token
        connect()
    }
    
    private func extractHost(from url: String) -> String {
        if let host = URL(string: url)?.host {
            return host
        }
        return "DSH 实例"
    }
    
    private func saveConnection(name: String, url: String, token: String) {
        if let existing = savedConnections.firstIndex(where: { $0.url == url }) {
            savedConnections[existing] = SavedConnection(id: savedConnections[existing].id, name: name, url: url, token: token)
        } else {
            savedConnections.append(SavedConnection(id: UUID(), name: name, url: url, token: token))
        }
        if let data = try? JSONEncoder().encode(savedConnections) {
            savedConnectionsData = data
        }
    }
    
    private func loadSavedConnections() {
        if let saved = try? JSONDecoder().decode([SavedConnection].self, from: savedConnectionsData) {
            savedConnections = saved
        }
    }
}
