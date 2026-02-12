import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var tailscale: TailscaleManager
    @EnvironmentObject var dnsFilter: DNSFilterService
    @State private var stats: MeshStats?
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Connection status banner
                    HStack {
                        Circle()
                            .fill(tailscale.isConnected ? Color.adbloxSuccess : Color.adbloxDanger)
                            .frame(width: 10, height: 10)
                            .shadow(color: tailscale.isConnected ? Color.adbloxSuccess.opacity(0.5) : Color.adbloxDanger.opacity(0.5), radius: 4)
                        Text(tailscale.status.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.adbloxTextMuted)
                        Spacer()
                        if tailscale.isConnected {
                            Text(tailscale.meshIP)
                                .font(.caption)
                                .fontDesign(.monospaced)
                                .foregroundColor(.adbloxTextMuted)
                        }
                    }
                    .padding()
                    .background(Color.adbloxCardBg)
                    .cornerRadius(12)

                    // Stat cards
                    if let stats = stats {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCardView(
                                title: "Queries",
                                value: formatNumber(stats.queriesToday),
                                icon: "magnifyingglass",
                                color: .adbloxPrimary
                            )
                            StatCardView(
                                title: "Blocked",
                                value: formatNumber(stats.blockedToday),
                                subtitle: "\(String(format: "%.1f", stats.blockedPercent))%",
                                icon: "shield.checkmark.fill",
                                color: .adbloxDanger
                            )
                            StatCardView(
                                title: "Devices",
                                value: "\(stats.devicesOnline)/\(stats.devicesTotal)",
                                icon: "laptopcomputer.and.iphone",
                                color: .adbloxSuccess
                            )
                            StatCardView(
                                title: "Uptime",
                                value: stats.formattedUptime,
                                icon: "clock.fill",
                                color: .adbloxWarning
                            )
                        }

                        // Recent activity
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Activity")
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(stats.recentActivity) { item in
                                HStack {
                                    Circle()
                                        .fill(item.isBlocked ? Color.adbloxDanger : Color.adbloxSuccess)
                                        .frame(width: 8, height: 8)

                                    Text(item.domain)
                                        .font(.caption)
                                        .fontDesign(.monospaced)
                                        .foregroundColor(.adbloxText)
                                        .lineLimit(1)

                                    Spacer()

                                    Text(item.device)
                                        .font(.caption2)
                                        .foregroundColor(.adbloxTextMuted)

                                    Text(item.time)
                                        .font(.caption2)
                                        .foregroundColor(.adbloxTextMuted)
                                }
                            }
                        }
                        .padding()
                        .background(Color.adbloxCardBg)
                        .cornerRadius(12)
                    } else if isLoading {
                        ProgressView()
                            .tint(.adbloxPrimary)
                            .padding(40)
                    }
                }
                .padding()
            }
            .background(Color.adbloxBackground)
            .navigationTitle("AdBloX MESH")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkmark.fill")
                            .foregroundColor(.adbloxPrimary)
                        Text("AdBloX MESH")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .task {
            await loadStats()
        }
    }

    private func loadStats() async {
        do {
            stats = try await APIClient.shared.getStats()
            isLoading = false
        } catch {
            isLoading = false
            print("[AdBloX] Failed to load stats: \(error)")
        }
    }

    private func formatNumber(_ num: Int) -> String {
        if num >= 1_000_000 { return String(format: "%.1fM", Double(num) / 1_000_000) }
        if num >= 1000 { return String(format: "%.1fK", Double(num) / 1000) }
        return "\(num)"
    }
}
