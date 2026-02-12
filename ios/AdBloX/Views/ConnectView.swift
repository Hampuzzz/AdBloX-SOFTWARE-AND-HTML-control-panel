import SwiftUI

/// Main screen — like Tailscale's connect screen.
/// Big power button in the center. Tap to connect to your AdBloX device.
/// Shows connection status, device info, and traffic stats.
struct ConnectView: View {
    @EnvironmentObject var vpn: VPNManager
    @State private var showSetup = false
    @State private var pulseAnimation = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.adbloxBg.ignoresSafeArea()

                // Background glow when connected
                if vpn.state.isActive {
                    RadialGradient(
                        colors: [Color.adbloxCyan.opacity(0.08), .clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 300
                    )
                    .ignoresSafeArea()
                }

                VStack(spacing: 0) {
                    Spacer()

                    // Status label
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(statusColor)
                                .frame(width: 8, height: 8)
                                .shadow(color: statusColor.opacity(0.6), radius: 4)
                            Text(vpn.state.label)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(statusColor)
                        }

                        if vpn.state.isActive, !vpn.deviceName.isEmpty {
                            Text(vpn.deviceName)
                                .font(.caption)
                                .foregroundColor(.adbloxMuted)
                        }
                    }

                    Spacer().frame(height: 40)

                    // Big power button
                    Button(action: {
                        if vpn.isFirstLaunch && vpn.deviceIP.isEmpty {
                            showSetup = true
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                vpn.toggle()
                            }
                        }
                    }) {
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(
                                    vpn.state.isActive ? Color.adbloxCyan : Color.adbloxBorder,
                                    lineWidth: 3
                                )
                                .frame(width: 180, height: 180)
                                .shadow(color: vpn.state.isActive ? Color.adbloxCyan.opacity(0.3) : .clear, radius: 20)

                            // Pulse ring (when connecting)
                            if case .connecting = vpn.state {
                                Circle()
                                    .stroke(Color.adbloxCyan.opacity(0.3), lineWidth: 2)
                                    .frame(width: 180, height: 180)
                                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                                    .opacity(pulseAnimation ? 0 : 0.5)
                                    .animation(
                                        .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                                        value: pulseAnimation
                                    )
                            }

                            // Inner fill
                            Circle()
                                .fill(
                                    vpn.state.isActive
                                        ? Color.adbloxCyan.opacity(0.1)
                                        : Color.adbloxCard
                                )
                                .frame(width: 170, height: 170)

                            // Power icon
                            Image(systemName: "power")
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(
                                    vpn.state.isActive ? .adbloxCyan : .adbloxMuted
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .onChange(of: vpn.state, perform: { newState in
                        if case .connecting = newState {
                            pulseAnimation = true
                        } else {
                            pulseAnimation = false
                        }
                    })

                    Spacer().frame(height: 40)

                    // Connection info
                    if vpn.state.isActive {
                        connectedInfo
                    } else if !vpn.deviceIP.isEmpty {
                        deviceInfo
                    } else {
                        setupPrompt
                    }

                    Spacer()

                    // Bottom: shield logo + version
                    VStack(spacing: 4) {
                        Image(systemName: "shield.checkmark.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.adbloxCyan.opacity(0.4))
                        Text("AdBloX MESH v1.8.2")
                            .font(.caption2)
                            .foregroundColor(.adbloxMuted.opacity(0.5))
                    }
                    .padding(.bottom, 8)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkmark.fill")
                            .foregroundColor(.adbloxCyan)
                        Text("AdBloX")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSetup = true }) {
                        Image(systemName: vpn.deviceIP.isEmpty ? "plus.circle.fill" : "qrcode.viewfinder")
                            .foregroundColor(.adbloxCyan)
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                DeviceSetupView()
            }
        }
    }

    // MARK: - Subviews

    private var connectedInfo: some View {
        VStack(spacing: 16) {
            // Device IP
            HStack {
                Image(systemName: "arrow.triangle.branch")
                    .foregroundColor(.adbloxCyan)
                    .font(.system(size: 14))
                Text(vpn.deviceIP)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(.adbloxText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.adbloxCard)
            .cornerRadius(10)

            // Traffic stats
            HStack(spacing: 32) {
                VStack(spacing: 2) {
                    Text(formatBytes(vpn.bytesIn))
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(.adbloxGreen)
                    Text("IN")
                        .font(.caption2)
                        .foregroundColor(.adbloxMuted)
                }
                VStack(spacing: 2) {
                    Text(formatBytes(vpn.bytesOut))
                        .font(.system(.subheadline, design: .monospaced))
                        .fontWeight(.semibold)
                        .foregroundColor(.adbloxCyan)
                    Text("OUT")
                        .font(.caption2)
                        .foregroundColor(.adbloxMuted)
                }
                if let since = vpn.connectedSince {
                    VStack(spacing: 2) {
                        Text(since, style: .timer)
                            .font(.system(.subheadline, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(.adbloxOrange)
                        Text("UPTIME")
                            .font(.caption2)
                            .foregroundColor(.adbloxMuted)
                    }
                }
            }

            // "Open Dashboard" hint
            Text("Dashboard available in the Dashboard tab")
                .font(.caption)
                .foregroundColor(.adbloxMuted)
                .padding(.top, 4)
        }
    }

    private var deviceInfo: some View {
        VStack(spacing: 8) {
            Text("Ready to connect")
                .font(.subheadline)
                .foregroundColor(.adbloxText)
            HStack(spacing: 4) {
                Image(systemName: "server.rack")
                    .font(.caption)
                    .foregroundColor(.adbloxCyan)
                Text(vpn.deviceName.isEmpty ? vpn.deviceIP : vpn.deviceName)
                    .font(.caption)
                    .foregroundColor(.adbloxMuted)
            }
        }
    }

    private var setupPrompt: some View {
        VStack(spacing: 12) {
            Text("No device configured")
                .font(.subheadline)
                .foregroundColor(.adbloxText)
            Text("Scan the QR code from your AdBloX device\nor enter its IP address to get started")
                .font(.caption)
                .foregroundColor(.adbloxMuted)
                .multilineTextAlignment(.center)

            Button(action: { showSetup = true }) {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Set Up Device")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.adbloxCyan)
                .cornerRadius(10)
            }
        }
    }

    // MARK: - Helpers

    private var statusColor: Color {
        switch vpn.state {
        case .connected: return .adbloxGreen
        case .connecting, .disconnecting: return .adbloxOrange
        case .error: return .adbloxRed
        case .disconnected: return .adbloxMuted
        }
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        if bytes >= 1_073_741_824 {
            return String(format: "%.1f GB", Double(bytes) / 1_073_741_824)
        }
        if bytes >= 1_048_576 {
            return String(format: "%.1f MB", Double(bytes) / 1_048_576)
        }
        if bytes >= 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024)
        }
        return "\(bytes) B"
    }
}
