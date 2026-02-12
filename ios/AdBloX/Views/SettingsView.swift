import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var tailscale: TailscaleManager
    @EnvironmentObject var dnsFilter: DNSFilterService

    var body: some View {
        NavigationView {
            List {
                // VPN Connection
                Section {
                    HStack {
                        Image(systemName: "network")
                            .foregroundColor(.adbloxPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("VPN Connection")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text(tailscale.status.rawValue)
                                .font(.caption)
                                .foregroundColor(tailscale.isConnected ? .adbloxSuccess : .adbloxTextMuted)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { tailscale.isConnected },
                            set: { $0 ? tailscale.connect() : tailscale.disconnect() }
                        ))
                        .tint(.adbloxPrimary)
                        .labelsHidden()
                    }

                    HStack {
                        Image(systemName: "shield.checkmark.fill")
                            .foregroundColor(.adbloxPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("DNS Filtering")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text(dnsFilter.isActive ? "Active" : "Inactive")
                                .font(.caption)
                                .foregroundColor(dnsFilter.isActive ? .adbloxSuccess : .adbloxTextMuted)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { dnsFilter.isActive },
                            set: { $0 ? dnsFilter.activate() : dnsFilter.deactivate() }
                        ))
                        .tint(.adbloxPrimary)
                        .labelsHidden()
                    }
                } header: {
                    Text("Protection")
                }

                // Mesh Info
                Section {
                    infoRow("Mesh IP", tailscale.meshIP, "globe")
                    infoRow("Peers", "\(tailscale.peerCount) devices", "laptopcomputer.and.iphone")
                    infoRow("Server", "mesh.adblox.se", "server.rack")
                } header: {
                    Text("Mesh Network")
                }

                // Blocklist sync
                Section {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.adbloxPrimary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sync Blocklists")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            if let lastSync = dnsFilter.lastSync {
                                Text("Last sync: \(lastSync, style: .relative) ago")
                                    .font(.caption)
                                    .foregroundColor(.adbloxTextMuted)
                            }
                        }
                        Spacer()
                        Button("Sync") {
                            dnsFilter.syncBlocklists()
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.adbloxPrimary)
                    }
                } header: {
                    Text("Data")
                }

                // About
                Section {
                    infoRow("Version", "1.8.2 Pro", "info.circle")
                    infoRow("Build", "2026.02", "hammer")

                    Link(destination: URL(string: "https://adblox.se")!) {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.adbloxPrimary)
                            Text("adblox.se")
                                .font(.subheadline)
                                .foregroundColor(.adbloxPrimary)
                        }
                    }
                } header: {
                    Text("About")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.adbloxBackground)
            .navigationTitle("Settings")
        }
    }

    private func infoRow(_ label: String, _ value: String, _ icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.adbloxPrimary)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundColor(.adbloxTextMuted)
        }
    }
}
