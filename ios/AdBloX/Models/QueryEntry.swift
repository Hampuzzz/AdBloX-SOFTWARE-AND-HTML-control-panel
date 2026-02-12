import Foundation

struct QueryEntry: Identifiable, Codable {
    var id: String { "\(timestamp)-\(domain)" }
    let timestamp: Date
    let domain: String
    let type: String
    let status: String
    let device: String
    let list: String?

    var isBlocked: Bool { status == "blocked" }
}

struct QueryLogResponse: Codable {
    let total: Int
    let page: Int
    let perPage: Int
    let entries: [QueryEntry]

    enum CodingKeys: String, CodingKey {
        case total, page, entries
        case perPage = "per_page"
    }
}
