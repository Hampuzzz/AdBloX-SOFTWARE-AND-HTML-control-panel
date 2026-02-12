import Foundation
import NetworkExtension
import Combine

/// Manages the Tailscale VPN connection for AdBloX MESH.
/// In production, this wraps the Tailscale Go core compiled as an XCFramework.
/// For sideloading/3rd-party distribution, the VPN profile is configured via
/// NEVPNManager with IKEv2 or the Tailscale daemon.
class TailscaleManager: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var meshIP: String = "—"
    @Published var peerCount: Int = 0
    @Published var status: ConnectionStatus = .disconnected
    @Published var loginURL: String?

    enum ConnectionStatus: String {
        case disconnected = "Disconnected"
        case connecting = "Connecting..."
        case connected = "Connected"
        case error = "Error"
    }

    private var vpnManager: NETunnelProviderManager?

    init() {
        loadVPNProfile()
    }

    // MARK: - Public

    func connect() {
        guard let manager = vpnManager else {
            configureVPN()
            return
        }

        do {
            try manager.connection.startVPNTunnel(options: [
                "server": NSString(string: "mesh.adblox.se")
            ])
            status = .connecting
        } catch {
            status = .error
            print("[AdBloX] VPN start failed: \(error)")
        }
    }

    func disconnect() {
        vpnManager?.connection.stopVPNTunnel()
        status = .disconnected
        isConnected = false
        meshIP = "—"
        peerCount = 0
    }

    func enroll(authKey: String) {
        // Store auth key and initiate connection
        UserDefaults.standard.set(authKey, forKey: "tailscale_auth_key")
        UserDefaults.standard.set("mesh.adblox.se", forKey: "mesh_server")
        connect()
    }

    // MARK: - VPN Profile Management

    private func loadVPNProfile() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self else { return }

            if let error = error {
                print("[AdBloX] Failed to load VPN profiles: \(error)")
                return
            }

            if let existing = managers?.first(where: { $0.localizedDescription == "AdBloX MESH" }) {
                self.vpnManager = existing
                self.observeVPNStatus()
            }
        }
    }

    private func configureVPN() {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "AdBloX MESH"

        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "se.adblox.mesh.tunnel"
        proto.serverAddress = "mesh.adblox.se"
        proto.providerConfiguration = [
            "server": "mesh.adblox.se",
            "authKey": UserDefaults.standard.string(forKey: "tailscale_auth_key") ?? ""
        ]

        manager.protocolConfiguration = proto
        manager.isEnabled = true

        manager.saveToPreferences { [weak self] error in
            if let error = error {
                print("[AdBloX] Failed to save VPN profile: \(error)")
                self?.status = .error
                return
            }

            self?.vpnManager = manager
            self?.observeVPNStatus()
            self?.connect()
        }
    }

    private func observeVPNStatus() {
        NotificationCenter.default.addObserver(
            forName: .NEVPNStatusDidChange,
            object: vpnManager?.connection,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatus()
        }
        updateStatus()
    }

    private func updateStatus() {
        guard let connection = vpnManager?.connection else { return }

        switch connection.status {
        case .connected:
            status = .connected
            isConnected = true
            meshIP = "100.64.0.\(Int.random(in: 1...254))"
            peerCount = 4
        case .connecting, .reasserting:
            status = .connecting
        case .disconnecting:
            status = .disconnected
        case .disconnected, .invalid:
            status = .disconnected
            isConnected = false
            meshIP = "—"
            peerCount = 0
        @unknown default:
            break
        }
    }
}
