import Foundation

struct MeshStats: Codable {
    let queriesToday: Int
    let blockedToday: Int
    let blockedPercent: Double
    let devicesOnline: Int
    let devicesTotal: Int
    let uptimeSeconds: Int
    let queriesOverTime: [HourlyData]
    let recentActivity: [ActivityItem]

    enum CodingKeys: String, CodingKey {
        case queriesToday = "queries_today"
        case blockedToday = "blocked_today"
        case blockedPercent = "blocked_percent"
        case devicesOnline = "devices_online"
        case devicesTotal = "devices_total"
        case uptimeSeconds = "uptime_seconds"
        case queriesOverTime = "queries_over_time"
        case recentActivity = "recent_activity"
    }

    var formattedUptime: String {
        let days = uptimeSeconds / 86400
        let hours = (uptimeSeconds % 86400) / 3600
        if days > 0 { return "\(days)d \(hours)h" }
        let mins = (uptimeSeconds % 3600) / 60
        return "\(hours)h \(mins)m"
    }
}

struct HourlyData: Codable, Identifiable {
    var id: String { hour }
    let hour: String
    let total: Int
    let blocked: Int
}

struct ActivityItem: Codable, Identifiable {
    var id: String { "\(domain)-\(time)" }
    let domain: String
    let status: String
    let time: String
    let device: String

    var isBlocked: Bool { status == "blocked" }
}
