import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dshService: DSHService
    @Environment(\.dismiss) private var dismiss
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("authToken") private var authToken: String = ""
    @AppStorage("fontSize") private var fontSize: Double = 16
    @AppStorage("sendWithEnter") private var sendWithEnter: Bool = true
    
    var body: some View {
        NavigationStack {
            Form {
                // 连接信息
                Section("连接设置") {
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("服务器地址")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(serverURL.isEmpty ? "未设置" : serverURL)
                                .font(.subheadline)
                        }
                    }
                    
                    HStack {
                        Image(systemName: dshService.isConnected ? "wifi" : "wifi.slash")
                            .foregroundColor(dshService.isConnected ? .green : .red)
                        VStack(alignment: .leading) {
                            Text("连接状态")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(dshService.isConnected ? "已连接" : "未连接")
                                .font(.subheadline)
                        }
                    }
                    
                    if dshService.isConnected {
                        Button(role: .destructive) {
                            dshService.disconnect()
                        } label: {
                            Label("断开连接", systemImage: "xmark.circle")
                        }
                    }
                }
                
                // 显示设置
                Section("显示设置") {
                    VStack(alignment: .leading) {
                        Text("消息字体大小: \(Int(fontSize))pt")
                        Slider(value: $fontSize, in: 12...24, step: 1)
                    }
                }
                
                // 关于
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("构建")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                    Link(destination: URL(string: "https://github.com/xuan666xuan2/dsh-ios-client")!) {
                        HStack {
                            Text("源代码")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
