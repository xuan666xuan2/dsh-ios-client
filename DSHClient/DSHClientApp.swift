import SwiftUI

@main
struct DSHClientApp: App {
    @StateObject private var dshService = DSHService()
    @AppStorage("serverURL") private var serverURL: String = ""
    @AppStorage("authToken") private var authToken: String = ""
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dshService)
        }
    }
}
