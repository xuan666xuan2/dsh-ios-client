import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dshService: DSHService
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("authToken") private var authToken: String = ""
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            Group {
                if dshService.isConnected {
                    ChatView()
                } else {
                    ConnectionView()
                }
            }
            .navigationTitle("DSH Client")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
                if dshService.isConnected {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 8, height: 8)
                            Text("已连接")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }
}
