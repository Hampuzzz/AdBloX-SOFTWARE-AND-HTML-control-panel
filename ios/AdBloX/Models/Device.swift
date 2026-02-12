import Foundation

struct Device: Identifiable, Codable {
    let id: String
    let hostname: String
    let ip: String
    let os: String
    let online: Bool
    let lastSeen: Date
    let queriesToday: Int
    let blockedToday: Int

    enum CodingKeys: String, CodingKey {
        case id, hostname, ip, os, online
        case lastSeen = "last_seen"
        case queriesToday = "queries_today"
        case blockedToday = "blocked_today"
    }

    var osIcon: String {
        switch os {
        case "macos": return "laptopcomputer"
        case "ios": return "iphone"
        case "windows": return "desktopcomputer"
        case "linux": return "server.rack"
        case "android": return "smartphone"
        default: return "desktopcomputer"
        }
    }
}

struct DevicesResponse: Codable {
    let devices: [Device]
}
