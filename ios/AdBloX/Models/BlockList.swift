import Foundation

struct BlockList: Identifiable, Codable {
    let id: String
    let name: String
    let description: String?
    let url: String
    let entries: Int
    var enabled: Bool
    let updated: Date

    var formattedEntries: String {
        if entries >= 1000 {
            return String(format: "%.1fK", Double(entries) / 1000)
        }
        return "\(entries)"
    }
}

struct BlockListsResponse: Codable {
    let lists: [BlockList]
}
