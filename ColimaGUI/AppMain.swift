import SwiftUI

@main
struct ColimaGUIApp: App {
    @StateObject private var manager = ColimaManager()
    
    var body: some Scene {
        MenuBarExtra {
            StatusView(manager: manager)
        } label: {
            HStack {
                Image(systemName: manager.status == .running ? "circle.fill" : "circle")
                    .foregroundColor(statusColor)
                Text("Colima")
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    private var statusColor: Color {
        switch manager.status {
        case .running: return .green
        case .stopped: return .gray
        case .transitioning: return .yellow
        case .error: return .red
        case .unknown: return .orange
        }
    }
}
