import SwiftUI

/// Settings: VPN configuration, device info, about.
struct SettingsView: View {
    @EnvironmentObject var vpn: VPNManager
    @State private var showSetup = false
    @State private var showResetConfirm = false

    var body: some View {
        NavigationView {
            List {
                // Connection
                Section {
                    // VPN status
                    HStack {
                        settingIcon("bolt.fill", color: .adbloxCyan)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("VPN Tunnel")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text(vpn.state.label)
                                .font(.caption)
                                .foregroundColor(vpn.state.isActive ? .adbloxGreen : .adbloxMuted)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { vpn.state.isActive },
                            set: { $0 ? vpn.connect() : vpn.disconnect() }
                        ))
                        .tint(.adbloxCyan)
                        .labelsHidden()
                    }
                } header: {
                    Text("Connection")
                }

                // Device
                Section {
                    if !vpn.deviceIP.isEmpty {
                        HStack {
                            settingIcon("server.rack", color: .adbloxCyan)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(vpn.deviceName.isEmpty ? "AdBloX Device" : vpn.deviceName)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text(vpn.deviceIP)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.adbloxMuted)
                            }
                            Spacer()
                            Button("Change") { showSetup = true }
                                .font(.caption)
                                .foregroundColor(.adbloxCyan)
                        }
                    } else {
                        Button(action: { showSetup = true }) {
                            HStack {
                                settingIcon("plus.circle.fill", color: .adbloxCyan)
                                Text("Set Up Device")
                                    .font(.subheadline)
                                    .foregroundColor(.adbloxCyan)
                            }
                        }
                    }

                    // DNS routing info
                    HStack {
                        settingIcon("shield.checkmark.fill", color: .adbloxGreen)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DNS Filtering")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("All DNS queries route through your AdBloX device when connected")
                                .font(.caption)
                                .foregroundColor(.adbloxMuted)
                        }
                    }
                } header: {
                    Text("AdBloX Device")
                }

                // Network info (when connected)
                if vpn.state.isActive {
                    Section {
                        infoRow("Device IP", vpn.deviceIP, "globe")
                        infoRow("Mesh Nodes", "\(vpn.nodes.count + 1)", "network")
                        if let since = vpn.connectedSince {
                            HStack {
                                settingIcon("clock.fill", color: .adbloxOrange)
                                Text("Connected")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(since, style: .relative)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.adbloxMuted)
                            }
                        }
                    } header: {
                        Text("Network")
                    }
                }

                // AltStore info
                Section {
                    HStack {
                        settingIcon("arrow.triangle.2.circlepath", color: .adbloxOrange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("AltStore Refresh")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("Keep AltServer running to auto-refresh every 7 days")
                                .font(.caption)
                                .foregroundColor(.adbloxMuted)
                        }
                    }
                } header: {
                    Text("Distribution")
                }

                // About
                Section {
                    infoRow("Version", "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0") Pro", "info.circle")
                    infoRow("Build", "2026.02.12", "hammer")
                    infoRow("Platform", "iOS \(UIDevice.current.systemVersion)", "iphone")
                } header: {
                    Text("About")
                }

                // Danger zone
                Section {
                    Button(action: { showResetConfirm = true }) {
                        HStack {
                            settingIcon("trash.fill", color: .adbloxRed)
                            Text("Reset Configuration")
                                .font(.subheadline)
                                .foregroundColor(.adbloxRed)
                        }
                    }
                } header: {
                    Text("Advanced")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.adbloxBg)
            .navigationTitle("Settings")
            .sheet(isPresented: $showSetup) {
                DeviceSetupView()
            }
            .alert("Reset Configuration?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    vpn.disconnect()
                    UserDefaults.standard.removeObject(forKey: "adblox_device_ip")
                    UserDefaults.standard.removeObject(forKey: "adblox_device_name")
                    UserDefaults.standard.removeObject(forKey: "adblox_auth_key")
                    UserDefaults.standard.removeObject(forKey: "has_configured")
                    vpn.configureDevice(ip: "", name: "")
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will remove the configured device and disconnect the VPN.")
            }
        }
    }

    // MARK: - Helpers

    private func settingIcon(_ name: String, color: Color) -> some View {
        Image(systemName: name)
            .font(.system(size: 14))
            .foregroundColor(color)
            .frame(width: 28, height: 28)
            .background(color.opacity(0.15))
            .cornerRadius(6)
    }

    private func infoRow(_ label: String, _ value: String, _ icon: String) -> some View {
        HStack {
            settingIcon(icon, color: .adbloxCyan)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.adbloxMuted)
        }
    }
}
