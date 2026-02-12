import SwiftUI

/// Shows mesh nodes — like Tailscale's device list.
/// When connected, shows your AdBloX device + any other peers on the mesh.
struct NodesView: View {
    @EnvironmentObject var vpn: VPNManager

    var body: some View {
        NavigationView {
            ZStack {
                Color.adbloxBg.ignoresSafeArea()

                if vpn.state.isActive {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // This device (iPhone)
                            NodeRow(
                                name: UIDevice.current.name,
                                ip: "This device",
                                osIcon: "iphone",
                                isOnline: true,
                                isThisDevice: true,
                                isExitNode: false
                            )

                            // Mesh nodes
                            ForEach(vpn.nodes) { node in
                                NodeRow(
                                    name: node.name,
                                    ip: node.ip,
                                    osIcon: node.osIcon,
                                    isOnline: node.isOnline,
                                    isThisDevice: false,
                                    isExitNode: node.isExitNode
                                )
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "network")
                            .font(.system(size: 48))
                            .foregroundColor(.adbloxMuted)
                        Text("Not Connected")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Text("Connect to see mesh nodes.")
                            .font(.subheadline)
                            .foregroundColor(.adbloxMuted)
                    }
                }
            }
            .navigationTitle("Nodes")
        }
    }
}

struct NodeRow: View {
    let name: String
    let ip: String
    let osIcon: String
    let isOnline: Bool
    let isThisDevice: Bool
    let isExitNode: Bool

    var body: some View {
        HStack(spacing: 14) {
            // OS icon
            Image(systemName: osIcon)
                .font(.system(size: 20))
                .foregroundColor(.adbloxCyan)
                .frame(width: 44, height: 44)
                .background(Color.adbloxCyanDim)
                .cornerRadius(10)

            // Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if isThisDevice {
                        Text("YOU")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.adbloxCyan)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.adbloxCyanDim)
                            .cornerRadius(4)
                    }

                    if isExitNode {
                        Text("EXIT NODE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.adbloxGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.adbloxGreen.opacity(0.15))
                            .cornerRadius(4)
                    }
                }

                Text(ip)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.adbloxMuted)
            }

            Spacer()

            // Status
            Circle()
                .fill(isOnline ? Color.adbloxGreen : Color.adbloxRed)
                .frame(width: 8, height: 8)
                .shadow(color: (isOnline ? Color.adbloxGreen : Color.adbloxRed).opacity(0.5), radius: 3)
        }
        .padding()
        .background(Color.adbloxCard)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.adbloxBorder, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}
