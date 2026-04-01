import Foundation
import Combine

enum ColimaStatus: String, Codable {
    case running = "Running"
    case stopped = "Stopped"
    case transitioning = "Transitioning"
    case unknown = "Unknown"
    case error = "Error"
}

struct ColimaProfile: Codable {
    let name: String
    let status: String
    let arch: String
    let cpus: Int
    let memory: Int64
    let disk: Int64
    let runtime: String
}

class ColimaManager: ObservableObject {
    @Published var status: ColimaStatus = .unknown
    @Published var isTransitioning: Bool = false
    @Published var lastError: String? = nil
    @Published var currentProfile: ColimaProfile? = nil
    
    private var timer: Timer?
    private let colimaPath: String
    
    init() {
        // Try to find colima binary in common paths
        let fileManager = FileManager.default
        let homeDir = ProcessInfo.processInfo.environment["HOME"] ?? ""
        let paths = [
            "/opt/homebrew/bin/colima",
            "/usr/local/bin/colima",
            "/usr/bin/colima",
            "\(homeDir)/.homebrew/bin/colima"
        ]
        self.colimaPath = paths.first(where: { fileManager.fileExists(atPath: $0) }) ?? "colima"
        
        startPolling()
    }
    
    func startPolling() {
        timer?.invalidate()
        fetchStatus()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.fetchStatus()
        }
    }
    
    func fetchStatus() {
        guard !isTransitioning else { return }
        
        Task {
            let result = await runCommand(args: ["list", "--json"])
            
            await MainActor.run {
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let outputString = String(data: data, encoding: .utf8) ?? ""
                        // Handle multiple JSON objects (one per line)
                        let lines = outputString.components(separatedBy: .newlines).filter { !$0.isEmpty }
                        
                        var foundStatus: ColimaStatus = .stopped
                        var foundProfile: ColimaProfile? = nil
                        
                        for line in lines {
                            if let lineData = line.data(using: .utf8),
                               let profile = try? decoder.decode(ColimaProfile.self, from: lineData),
                               profile.name == "default" {
                                foundStatus = ColimaStatus(rawValue: profile.status) ?? .unknown
                                foundProfile = profile
                                break
                            }
                        }
                        self.status = foundStatus
                        self.currentProfile = foundProfile
                        self.lastError = nil
                    }
                case .failure(let error):
                    self.status = .error
                    self.lastError = error.localizedDescription
                    self.currentProfile = nil
                }
            }
        }
    }
    
    private func fetchStatusLegacy() {
        Task {
            let result = await runCommand(args: ["status"])
            await MainActor.run {
                switch result {
                case .success(let data):
                    let output = String(data: data, encoding: .utf8) ?? ""
                    if output.contains("colima is running") {
                        self.status = .running
                    } else {
                        self.status = .stopped
                    }
                case .failure:
                    self.status = .stopped
                }
            }
        }
    }
    
    func startColima() {
        isTransitioning = true
        status = .transitioning
        Task {
            _ = await runCommand(args: ["start"])
            await MainActor.run {
                self.isTransitioning = false
                self.fetchStatus()
            }
        }
    }
    
    func stopColima() {
        isTransitioning = true
        status = .transitioning
        Task {
            _ = await runCommand(args: ["stop"])
            await MainActor.run {
                self.isTransitioning = false
                self.fetchStatus()
            }
        }
    }
    
    private func runCommand(args: [String]) async -> Result<Data, Error> {
        return await withCheckedContinuation { continuation in
            let process = Process()
            
            // Set environment to include common Homebrew paths
            var env = ProcessInfo.processInfo.environment
            let homebrewPaths = "/opt/homebrew/bin:/usr/local/bin"
            if let existingPath = env["PATH"] {
                env["PATH"] = "\(homebrewPaths):\(existingPath)"
            } else {
                env["PATH"] = homebrewPaths
            }
            process.environment = env
            
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            process.arguments = [colimaPath] + args
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                
                if process.terminationStatus == 0 || (args.contains("list") && process.terminationStatus != 127) {
                    continuation.resume(returning: .success(data))
                } else {
                    let error = String(data: data, encoding: .utf8) ?? "Unknown error"
                    continuation.resume(returning: .failure(NSError(domain: "ColimaError", code: Int(process.terminationStatus), userInfo: [NSLocalizedDescriptionKey: error])))
                }
            } catch {
                continuation.resume(returning: .failure(error))
            }
        }
    }
}
