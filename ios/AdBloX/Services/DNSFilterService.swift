import Foundation
import NetworkExtension

/// Manages the DNS filtering Network Extension and blocklist sync.
class DNSFilterService: ObservableObject {
    @Published var isActive: Bool = false
    @Published var blockedCount: Int = 0
    @Published var lastSync: Date?

    private let appGroupID = "group.se.adblox.mesh"
    private let blocklistCacheKey = "cached_blocklist_domains"

    init() {
        loadState()
    }

    // MARK: - Public

    func activate() {
        let config = NEDNSSettingsManager.shared()
        let dnsSettings = NEDNSOverHTTPSSettings(servers: ["1.1.1.1", "8.8.8.8"])
        dnsSettings.serverURL = URL(string: "https://dns.adblox.se/dns-query")
        config.dnsSettings = dnsSettings
        config.localizedDescription = "AdBloX DNS Filter"

        config.saveToPreferences { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[AdBloX] DNS config error: \(error)")
                    self?.isActive = false
                } else {
                    self?.isActive = true
                    self?.syncBlocklists()
                }
            }
        }
    }

    func deactivate() {
        let config = NEDNSSettingsManager.shared()
        config.removeFromPreferences { [weak self] _ in
            DispatchQueue.main.async {
                self?.isActive = false
            }
        }
    }

    func syncBlocklists() {
        Task {
            do {
                let lists = try await APIClient.shared.getBlocklists()
                let enabledLists = lists.lists.filter { $0.enabled }

                // Store blocklist metadata in shared App Group for the Network Extension
                if let defaults = UserDefaults(suiteName: appGroupID) {
                    let listData = try JSONEncoder().encode(enabledLists)
                    defaults.set(listData, forKey: blocklistCacheKey)
                    defaults.set(Date(), forKey: "last_blocklist_sync")
                }

                await MainActor.run {
                    self.lastSync = Date()
                }
            } catch {
                print("[AdBloX] Blocklist sync failed: \(error)")
            }
        }
    }

    // MARK: - Private

    private func loadState() {
        if let defaults = UserDefaults(suiteName: appGroupID) {
            lastSync = defaults.object(forKey: "last_blocklist_sync") as? Date
            blockedCount = defaults.integer(forKey: "total_blocked_count")
        }
    }
}
