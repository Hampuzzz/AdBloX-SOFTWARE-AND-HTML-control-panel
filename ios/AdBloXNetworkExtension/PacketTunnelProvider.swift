import NetworkExtension

/// DNS Proxy Provider that intercepts DNS queries and blocks domains
/// matching the AdBloX blocklists.
///
/// This runs as a separate process via the Network Extension framework.
/// Data is shared with the main app through an App Group container.
class PacketTunnelProvider: NEPacketTunnelProvider {

    private var dnsResolver: DNSResolver!
    private let appGroupID = "group.se.adblox.mesh"

    override func startProxy(options: [String: Any]?, completionHandler: @escaping (Error?) -> Void) {
        // Initialize DNS resolver with cached blocklists from App Group
        dnsResolver = DNSResolver(appGroupID: appGroupID)
        dnsResolver.loadBlocklists()

        NSLog("[AdBloX] DNS Proxy started with \(dnsResolver.blockedDomainCount) blocked domains")
        completionHandler(nil)
    }

    override func stopProxy(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        NSLog("[AdBloX] DNS Proxy stopped: \(reason)")
        completionHandler()
    }

    override func handleNewFlow(_ flow: NEAppProxyFlow) -> Bool {
        guard let udpFlow = flow as? NEAppProxyUDPFlow else {
            return false
        }

        // Handle DNS UDP flows (port 53)
        handleDNSFlow(udpFlow)
        return true
    }

    private func handleDNSFlow(_ flow: NEAppProxyUDPFlow) {
        flow.open(withLocalEndpoint: nil) { [weak self] error in
            if let error = error {
                NSLog("[AdBloX] Flow open error: \(error)")
                return
            }
            self?.readDNSQuery(from: flow)
        }
    }

    private func readDNSQuery(from flow: NEAppProxyUDPFlow) {
        flow.readDatagrams { [weak self] datagrams, endpoints, error in
            guard let self = self,
                  let datagrams = datagrams,
                  let endpoints = endpoints,
                  error == nil else {
                return
            }

            for (index, datagram) in datagrams.enumerated() {
                let domain = self.extractDomain(from: datagram)

                if let domain = domain, self.dnsResolver.shouldBlock(domain: domain) {
                    // Return blocked response (NXDOMAIN or 0.0.0.0)
                    let blockedResponse = self.dnsResolver.createBlockedResponse(for: datagram)
                    flow.writeDatagrams([blockedResponse], sentBy: [endpoints[index]]) { _ in }

                    self.incrementBlockedCount()
                    NSLog("[AdBloX] Blocked: \(domain)")
                } else {
                    // Forward to upstream DNS
                    self.forwardToUpstream(datagram: datagram, flow: flow, endpoint: endpoints[index])
                }
            }

            // Continue reading
            self.readDNSQuery(from: flow)
        }
    }

    private func extractDomain(from packet: Data) -> String? {
        // DNS packet parsing: skip 12-byte header, read QNAME
        guard packet.count > 12 else { return nil }

        var domain = ""
        var offset = 12

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

    private func forwardToUpstream(datagram: Data, flow: NEAppProxyUDPFlow, endpoint: NWEndpoint) {
        // In production, forward via Tailscale tunnel to upstream DNS
        // For now, forward directly to configured upstream
        flow.writeDatagrams([datagram], sentBy: [endpoint]) { _ in }
    }

    private func incrementBlockedCount() {
        if let defaults = UserDefaults(suiteName: appGroupID) {
            let count = defaults.integer(forKey: "total_blocked_count") + 1
            defaults.set(count, forKey: "total_blocked_count")
        }
    }
}
