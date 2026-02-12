import Foundation
import NetworkExtension

/// Manages the VPN tunnel to the AdBloX device — works like Tailscale.
///
/// Flow:
/// 1. User taps Connect → VPN tunnel established to AdBloX device
/// 2. All traffic (or just DNS) routes through the tunnel
/// 3. AdBloX device's dashboard becomes accessible at its local IP
/// 4. DNS queries go through AdBloX = ads blocked on this iPhone
///
/// The tunnel uses NETunnelProviderManager which creates a packet tunnel
/// to the AdBloX device. The device IP (e.g. 100.64.0.1) is the gateway
/// that serves both the dashboard and DNS filtering.
class VPNManager: ObservableObject {
    @Published var state: VPNState = .disconnected
    @Published var deviceIP: String = ""
    @Published var deviceName: String = ""
    @Published var connectedSince: Date?
    @Published var bytesIn: UInt64 = 0
    @Published var bytesOut: UInt64 = 0
    @Published var nodes: [MeshNode] = []
    @Published var isFirstLaunch: Bool

    /// The URL to load when connected — this is your AdBloX device's dashboard
    var dashboardURL: URL? {
        guard state == .connected, !deviceIP.isEmpty else { return nil }
        return URL(string: "http://\(deviceIP)")
    }

    private var tunnelManager: NETunnelProviderManager?
    private var statusObserver: Any?
    private var trafficTimer: Timer?

    enum VPNState: Equatable {
        case disconnected
        case connecting
        case connected
        case disconnecting
        case error(String)

        var label: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting..."
            case .connected: return "Connected"
            case .disconnecting: return "Disconnecting..."
            case .error(let msg): return "Error: \(msg)"
            }
        }

        var isActive: Bool {
            if case .connected = self { return true }
            return false
        }
    }

    init() {
        isFirstLaunch = !UserDefaults.standard.bool(forKey: "has_configured")
        loadSavedDevice()
        loadTunnelProfile()
    }

    deinit {
        if let observer = statusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        trafficTimer?.invalidate()
    }

    // MARK: - Connect / Disconnect

    func connect() {
        guard !deviceIP.isEmpty else {
            state = .error("No device configured")
            return
        }

        if tunnelManager == nil {
            installTunnelProfile {
                self.startTunnel()
            }
        } else {
            startTunnel()
        }
    }

    func disconnect() {
        state = .disconnecting
        tunnelManager?.connection.stopVPNTunnel()
    }

    func toggle() {
        if state.isActive {
            disconnect()
        } else {
            connect()
        }
    }

    // MARK: - Device Configuration

    /// Configure which AdBloX device to connect to.
    /// Called from QR scanner or manual IP entry.
    func configureDevice(ip: String, name: String) {
        deviceIP = ip
        deviceName = name.isEmpty ? "AdBloX Device" : name
        UserDefaults.standard.set(ip, forKey: "adblox_device_ip")
        UserDefaults.standard.set(deviceName, forKey: "adblox_device_name")
        UserDefaults.standard.set(true, forKey: "has_configured")
        isFirstLaunch = false

        // Update tunnel config with new IP
        updateTunnelConfiguration()
    }

    /// Parse a QR code or enrollment URL.
    /// Format: adblox://connect?ip=100.64.0.1&name=MyAdBloX&key=authkey123
    /// Or just an IP address: 100.64.0.1
    func parseEnrollment(_ input: String) -> (ip: String, name: String, key: String)? {
        // Plain IP address
        if input.matches(of: /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/).count > 0 {
            return (ip: input, name: "AdBloX Device", key: "")
        }

        // adblox:// URL scheme
        guard let components = URLComponents(string: input) else { return nil }

        let items = components.queryItems ?? []
        let ip = items.first(where: { $0.name == "ip" })?.value ?? ""
        let name = items.first(where: { $0.name == "name" })?.value ?? "AdBloX Device"
        let key = items.first(where: { $0.name == "key" })?.value ?? ""

        guard !ip.isEmpty else { return nil }
        return (ip: ip, name: name, key: key)
    }

    // MARK: - Private — Tunnel Management

    private func loadSavedDevice() {
        deviceIP = UserDefaults.standard.string(forKey: "adblox_device_ip") ?? ""
        deviceName = UserDefaults.standard.string(forKey: "adblox_device_name") ?? ""
    }

    private func loadTunnelProfile() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("[AdBloX] Load profiles error: \(error)")
                    return
                }

                self.tunnelManager = managers?.first(where: {
                    $0.localizedDescription == "AdBloX MESH"
                })

                if let manager = self.tunnelManager {
                    self.observeStatus(of: manager)
                    self.syncState(from: manager.connection.status)
                }
            }
        }
    }

    private func installTunnelProfile(then: @escaping () -> Void) {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "AdBloX MESH"

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "se.adblox.mesh.tunnel"
        proto.serverAddress = deviceIP
        proto.providerConfiguration = [
            "deviceIP": deviceIP,
            "deviceName": deviceName,
            "authKey": UserDefaults.standard.string(forKey: "adblox_auth_key") ?? ""
        ]

        manager.protocolConfiguration = proto
        manager.isEnabled = true

        // Route DNS through the tunnel
        let dns = NEDNSSettings(servers: [deviceIP])
        dns.matchDomains = [""]  // All DNS goes through tunnel
        // DNS settings are configured in the tunnel provider itself

        manager.saveToPreferences { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.state = .error(error.localizedDescription)
                    return
                }

                // Must reload after first save
                manager.loadFromPreferences { _ in
                    DispatchQueue.main.async {
                        self?.tunnelManager = manager
                        self?.observeStatus(of: manager)
                        then()
                    }
                }
            }
        }
    }

    private func startTunnel() {
        guard let manager = tunnelManager else { return }
        state = .connecting

        do {
            try manager.connection.startVPNTunnel(options: [
                "deviceIP": NSString(string: deviceIP)
            ])
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func updateTunnelConfiguration() {
        guard let manager = tunnelManager,
              let proto = manager.protocolConfiguration as? NETunnelProviderProtocol else { return }

        proto.serverAddress = deviceIP
        proto.providerConfiguration?["deviceIP"] = deviceIP
        proto.providerConfiguration?["deviceName"] = deviceName

        manager.saveToPreferences { error in
            if let error = error {
                print("[AdBloX] Config update error: \(error)")
            }
        }
    }

    // MARK: - Private — Status Observation

    private func observeStatus(of manager: NETunnelProviderManager) {
        statusObserver = NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: manager.connection,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.syncState(from: manager.connection.status)
        }
    }

    private func syncState(from status: NEVPNStatus) {
        switch status {
        case .connected:
            state = .connected
            connectedSince = Date()
            startTrafficMonitor()
            loadMeshNodes()

        case .connecting, .reasserting:
            state = .connecting

        case .disconnecting:
            state = .disconnecting

        case .disconnected:
            state = .disconnected
            connectedSince = nil
            trafficTimer?.invalidate()
            nodes = []

        case .invalid:
            state = .disconnected
            tunnelManager = nil

        @unknown default:
            break
        }
    }

    // MARK: - Private — Traffic & Nodes

    private func startTrafficMonitor() {
        trafficTimer?.invalidate()
        trafficTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            // In production, read from the tunnel provider via IPC
            // For now, simulate traffic counters
            self?.bytesIn += UInt64.random(in: 500...5000)
            self?.bytesOut += UInt64.random(in: 200...2000)
        }
    }

    private func loadMeshNodes() {
        // Populated from the tunnel provider or AdBloX API
        // Shows which devices are on the mesh
        nodes = [
            MeshNode(
                name: deviceName.isEmpty ? "AdBloX Device" : deviceName,
                ip: deviceIP,
                isExitNode: true,
                isOnline: true,
                os: "linux"
            )
        ]
    }
}

// MARK: - Supporting Types

struct MeshNode: Identifiable {
    let id = UUID()
    let name: String
    let ip: String
    let isExitNode: Bool
    let isOnline: Bool
    let os: String

    var osIcon: String {
        switch os {
        case "linux": return "server.rack"
        case "macos": return "laptopcomputer"
        case "ios": return "iphone"
        case "windows": return "desktopcomputer"
        default: return "desktopcomputer"
        }
    }
}
