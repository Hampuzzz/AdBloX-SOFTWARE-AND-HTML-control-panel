import NetworkExtension

/// Packet Tunnel Provider that creates a VPN tunnel to the AdBloX device
/// and intercepts DNS queries to block domains matching the AdBloX blocklists.
///
/// This runs as a separate process via the Network Extension framework.
/// Data is shared with the main app through an App Group container.
class PacketTunnelProvider: NEPacketTunnelProvider {

    private var dnsResolver: DNSResolver!
    private let appGroupID = "group.se.adblox.mesh"

    override func startTunnel(options: [String: Any]?, completionHandler: @escaping (Error?) -> Void) {
        // Initialize DNS resolver with cached blocklists from App Group
        dnsResolver = DNSResolver(appGroupID: appGroupID)
        dnsResolver.loadBlocklists()

        // Read device IP from App Group or tunnel options
        let defaults = UserDefaults(suiteName: appGroupID)
        let deviceIP = options?["deviceIP"] as? String
            ?? defaults?.string(forKey: "device_ip")
            ?? "100.64.0.1"

        NSLog("[AdBloX] Starting tunnel to \(deviceIP) with \(dnsResolver.blockedDomainCount) blocked domains")

        // Configure tunnel network settings
        let tunnelSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: deviceIP)

        // DNS settings — route DNS through AdBloX device
        let dnsSettings = NEDNSSettings(servers: [deviceIP])
        dnsSettings.matchDomains = [""]  // Match all domains
        tunnelSettings.dnsSettings = dnsSettings

        // IPv4 settings — route traffic through tunnel
        let ipv4 = NEIPv4Settings(addresses: ["10.0.0.2"], subnetMasks: ["255.255.255.0"])
        ipv4.includedRoutes = [NEIPv4Route.default()]
        // Exclude the device IP itself from the tunnel to avoid routing loops
        let deviceRoute = NEIPv4Route(destinationAddress: deviceIP, subnetMask: "255.255.255.255")
        ipv4.excludedRoutes = [deviceRoute]
        tunnelSettings.ipv4Settings = ipv4

        // Apply settings
        setTunnelNetworkSettings(tunnelSettings) { error in
            if let error = error {
                NSLog("[AdBloX] Failed to set tunnel settings: \(error)")
                completionHandler(error)
                return
            }

            NSLog("[AdBloX] Tunnel started successfully")
            completionHandler(nil)

            // Start reading packets from the tunnel
            self.readPackets()
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        NSLog("[AdBloX] Tunnel stopped: \(reason)")
        completionHandler()
    }

    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Handle messages from the main app (e.g., stats requests)
        if let message = String(data: messageData, encoding: .utf8) {
            NSLog("[AdBloX] App message: \(message)")

            if message == "stats" {
                let defaults = UserDefaults(suiteName: appGroupID)
                let blocked = defaults?.integer(forKey: "total_blocked_count") ?? 0
                let response = "\(blocked)".data(using: .utf8)
                completionHandler?(response)
                return
            }
        }
        completionHandler?(nil)
    }

    // MARK: - Packet Handling

    private func readPackets() {
        packetFlow.readPackets { [weak self] packets, protocols in
            guard let self = self else { return }

            for (index, packet) in packets.enumerated() {
                self.handlePacket(packet, protocolNumber: protocols[index])
            }

            // Continue reading
            self.readPackets()
        }
    }

    private func handlePacket(_ packet: Data, protocolNumber: NSNumber) {
        // Check if this is a DNS packet (UDP port 53)
        if isDNSPacket(packet) {
            if let domain = extractDomainFromDNSPayload(packet),
               dnsResolver.shouldBlock(domain: domain) {
                // Drop the packet (blocked domain) and increment counter
                incrementBlockedCount()
                NSLog("[AdBloX] Blocked: \(domain)")
                return
            }
        }

        // Forward non-blocked packets back through the tunnel
        packetFlow.writePackets([packet], withProtocols: [protocolNumber])
    }

    private func isDNSPacket(_ packet: Data) -> Bool {
        // Minimal check: IPv4 (protocol byte at offset 9 == 17 for UDP)
        // and destination port 53
        guard packet.count > 28 else { return false }

        // Check IP version (4)
        let version = (packet[0] >> 4) & 0x0F
        guard version == 4 else { return false }

        // Check protocol is UDP (17)
        let proto = packet[9]
        guard proto == 17 else { return false }

        // IP header length
        let ihl = Int(packet[0] & 0x0F) * 4

        // Check destination port (2 bytes after UDP header start)
        guard packet.count > ihl + 3 else { return false }
        let dstPort = (UInt16(packet[ihl + 2]) << 8) | UInt16(packet[ihl + 3])

        return dstPort == 53
    }

    private func extractDomainFromDNSPayload(_ packet: Data) -> String? {
        // Find DNS payload: skip IP header + 8 bytes UDP header
        let ihl = Int(packet[0] & 0x0F) * 4
        let dnsOffset = ihl + 8

        // DNS header is 12 bytes, QNAME starts at offset 12
        let qnameStart = dnsOffset + 12
        guard packet.count > qnameStart else { return nil }

        var domain = ""
        var offset = qnameStart

        while offset < packet.count {
            let length = Int(packet[offset])
            if length == 0 { break }
            offset += 1

            guard offset + length <= packet.count else { return nil }

            let label = String(data: packet[offset..<(offset + length)], encoding: .utf8) ?? ""
            domain += (domain.isEmpty ? "" : ".") + label
            offset += length
        }

        return domain.isEmpty ? nil : domain.lowercased()
    }

    private func incrementBlockedCount() {
        if let defaults = UserDefaults(suiteName: appGroupID) {
            let count = defaults.integer(forKey: "total_blocked_count") + 1
            defaults.set(count, forKey: "total_blocked_count")
        }
    }
}
