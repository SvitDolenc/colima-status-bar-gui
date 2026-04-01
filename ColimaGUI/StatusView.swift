import SwiftUI

struct StatusView: View {
    @ObservedObject var manager: ColimaManager
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text("Status: \(manager.status.rawValue)")
                    .font(.headline)
            }
            .padding(.bottom, 5)
            
            if let error = manager.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 5)
            }
            
            Divider()
            
            Button(action: {
                manager.startColima()
            }) {
                Label("Start Colima", systemImage: "play.fill")
            }
            .disabled(manager.status == .running || manager.isTransitioning)
            
            Button(action: {
                manager.stopColima()
            }) {
                Label("Stop Colima", systemImage: "stop.fill")
            }
            .disabled(manager.status == .stopped || manager.isTransitioning)
            
            Divider()
            
            Button("Refresh Status") {
                manager.fetchStatus()
            }
            
            Button("Quit Colima GUI") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 200)
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
