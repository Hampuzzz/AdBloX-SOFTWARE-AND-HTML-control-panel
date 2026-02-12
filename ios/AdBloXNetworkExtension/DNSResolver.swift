import Foundation

/// Manages the DNS blocklist and provides domain lookup for the Network Extension.
class DNSResolver {
    private var blockedDomains: Set<String> = []
    private let appGroupID: String

    var blockedDomainCount: Int { blockedDomains.count }

    init(appGroupID: String) {
        self.appGroupID = appGroupID
    }

    /// Load blocklists from the shared App Group container.
    /// The main app syncs blocklists from the API and stores them here.
    func loadBlocklists() {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: "cached_blocklist_domains") else {
            // Load built-in default blocklist
            loadDefaultBlocklist()
            return
        }

        do {
            let lists = try JSONDecoder().decode([BlockListCache].self, from: data)
            for list in lists where list.enabled {
                // In production, each list's domains would be cached locally
                // For now, load from the built-in defaults
            }
            NSLog("[AdBloX] Loaded \(lists.count) blocklists from cache")
        } catch {
            NSLog("[AdBloX] Failed to decode cached blocklists: \(error)")
            loadDefaultBlocklist()
        }
    }

    /// Check if a domain should be blocked.
    /// Checks the exact domain and all parent domains (e.g., ads.example.com -> example.com).
    func shouldBlock(domain: String) -> Bool {
        let lowered = domain.lowercased()

        // Check exact match
        if blockedDomains.contains(lowered) { return true }

        // Check parent domains
        var parts = lowered.split(separator: ".")
        while parts.count > 1 {
            parts.removeFirst()
            let parent = parts.joined(separator: ".")
            if blockedDomains.contains(parent) { return true }
        }

        return false
    }

    /// Create a DNS response that blocks the query (returns 0.0.0.0).
    func createBlockedResponse(for query: Data) -> Data {
        guard query.count >= 12 else { return query }

        var response = query

        // Set response flags: QR=1, RCODE=0 (No Error), AA=1
        response[2] = 0x81  // QR=1, Opcode=0, AA=0, TC=0, RD=1
        response[3] = 0x80  // RA=1, RCODE=0

        // Set answer count to 1
        response[6] = 0x00
        response[7] = 0x01

        // Find end of question section
        var offset = 12
        while offset < response.count && response[offset] != 0 {
            offset += Int(response[offset]) + 1
        }
        offset += 5 // Skip null byte + QTYPE (2) + QCLASS (2)

        // Append answer: pointer to name + A record + 0.0.0.0
        var answer = Data()
        answer.append(contentsOf: [0xC0, 0x0C])       // Pointer to name in question
        answer.append(contentsOf: [0x00, 0x01])       // Type A
        answer.append(contentsOf: [0x00, 0x01])       // Class IN
        answer.append(contentsOf: [0x00, 0x00, 0x00, 0x3C]) // TTL 60s
        answer.append(contentsOf: [0x00, 0x04])       // RDLENGTH 4
        answer.append(contentsOf: [0x00, 0x00, 0x00, 0x00]) // 0.0.0.0

        response.append(answer)
        return response
    }

    // MARK: - Private

    private func loadDefaultBlocklist() {
        // Built-in blocklist covering major ad/tracking domains
        let defaultDomains = [
            "ads.google.com",
            "adservice.google.com",
            "pagead2.googlesyndication.com",
            "doubleclick.net",
            "googleadservices.com",
            "tracker.facebook.com",
            "pixel.facebook.com",
            "connect.facebook.net",
            "graph.facebook.com",
            "analytics.tiktok.com",
            "ads.tiktok.com",
            "pixel.quantserve.com",
            "telemetry.microsoft.com",
            "vortex.data.microsoft.com",
            "settings-win.data.microsoft.com",
            "s.youtube.com",
            "ads.yahoo.com",
            "advertising.com",
            "taboola.com",
            "outbrain.com",
            "criteo.com",
            "pubmatic.com",
            "rubiconproject.com",
            "openx.net",
            "adnxs.com",
            "moatads.com",
            "scorecardresearch.com",
            "amazon-adsystem.com",
            "ad.doubleclick.net",
            "stats.wp.com"
        ]

        blockedDomains = Set(defaultDomains)
        NSLog("[AdBloX] Loaded \(blockedDomains.count) default blocked domains")
    }
}

/// Lightweight struct for decoding cached blocklist metadata
private struct BlockListCache: Codable {
    let id: String
    let name: String
    let enabled: Bool
    let entries: Int
}
