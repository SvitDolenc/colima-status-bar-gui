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
            
            if let profile = manager.currentProfile, manager.status == .running {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Profile: \(profile.name)")
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    Group {
                        Text("Arch: \(profile.arch)")
                        Text("CPUs: \(profile.cpus)")
                        Text("RAM: \(formatBytes(profile.memory))")
                        Text("Disk: \(formatBytes(profile.disk))")
                        Text("Runtime: \(profile.runtime)")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
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
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
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
