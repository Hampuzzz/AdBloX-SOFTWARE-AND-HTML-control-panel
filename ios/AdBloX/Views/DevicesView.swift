import SwiftUI

struct DevicesView: View {
    @State private var devices: [Device] = []
    @State private var isLoading = true
    @State private var showQRScanner = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(devices) { device in
                        NavigationLink(destination: DeviceDetailView(device: device)) {
                            DeviceRow(device: device)
                        }
                    }
                }
                .padding()
            }
            .background(Color.adbloxBackground)
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showQRScanner = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.adbloxPrimary)
                    }
                }
            }
            .sheet(isPresented: $showQRScanner) {
                QRScannerView()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .tint(.adbloxPrimary)
                }
            }
        }
        .task {
            do {
                let response = try await APIClient.shared.getDevices()
                devices = response.devices
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}

struct DeviceRow: View {
    let device: Device

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: device.osIcon)
                .font(.system(size: 20))
                .foregroundColor(.adbloxPrimary)
                .frame(width: 44, height: 44)
                .background(Color.adbloxPrimaryDim)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(device.hostname)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(device.ip)
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundColor(.adbloxTextMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(device.online ? Color.adbloxSuccess : Color.adbloxDanger)
                        .frame(width: 6, height: 6)
                    Text(device.online ? "Online" : "Offline")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(device.online ? .adbloxSuccess : .adbloxDanger)
                }

                if device.online {
                    Text("\(device.blockedToday) blocked")
                        .font(.caption2)
                        .foregroundColor(.adbloxTextMuted)
                }
            }
        }
        .padding()
        .background(Color.adbloxCardBg)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.adbloxBorder, lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct DeviceDetailView: View {
    let device: Device

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Device header
                VStack(spacing: 12) {
                    Image(systemName: device.osIcon)
                        .font(.system(size: 40))
                        .foregroundColor(.adbloxPrimary)
                        .frame(width: 80, height: 80)
                        .background(Color.adbloxPrimaryDim)
                        .cornerRadius(20)

                    Text(device.hostname)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Circle()
                            .fill(device.online ? Color.adbloxSuccess : Color.adbloxDanger)
                            .frame(width: 8, height: 8)
                        Text(device.online ? "Online" : "Offline")
                            .font(.subheadline)
                            .foregroundColor(device.online ? .adbloxSuccess : .adbloxDanger)
                    }
                }
                .padding()

                // Stats
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatCardView(title: "Queries", value: "\(device.queriesToday)", icon: "magnifyingglass", color: .adbloxPrimary)
                    StatCardView(title: "Blocked", value: "\(device.blockedToday)", icon: "shield.checkmark.fill", color: .adbloxDanger)
                }

                // Info rows
                VStack(spacing: 0) {
                    infoRow("IP Address", device.ip)
                    infoRow("OS", device.os.capitalized)
                    infoRow("Node ID", device.id)
                }
                .background(Color.adbloxCardBg)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.adbloxBorder, lineWidth: 1)
                )
            }
            .padding()
        }
        .background(Color.adbloxBackground)
        .navigationTitle(device.hostname)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.adbloxTextMuted)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontDesign(.monospaced)
                .foregroundColor(.adbloxText)
        }
        .padding()
    }
}
