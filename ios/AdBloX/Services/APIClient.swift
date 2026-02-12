import Foundation

class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(baseURL: URL = URL(string: "https://mesh.adblox.se/api")!) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.httpAdditionalHeaders = ["Content-Type": "application/json"]
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    func getStats() async throws -> MeshStats {
        return try await get("/stats")
    }

    func getDevices() async throws -> DevicesResponse {
        return try await get("/devices")
    }

    func getBlocklists() async throws -> BlockListsResponse {
        return try await get("/blocklists")
    }

    func getQueryLog(page: Int = 1) async throws -> QueryLogResponse {
        return try await get("/querylog?page=\(page)")
    }

    func toggleBlocklist(id: String, enabled: Bool) async throws {
        let _: EmptyResponse = try await post("/blocklists/\(id)/toggle", body: ["enabled": enabled])
    }

    // MARK: - Private

    private func get<T: Decodable>(_ path: String) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addAuthHeaders(&request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    private func post<T: Decodable>(_ path: String, body: [String: Any]) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        addAuthHeaders(&request)

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try decoder.decode(T.self, from: data)
    }

    private func addAuthHeaders(_ request: inout URLRequest) {
        if let token = UserDefaults.standard.string(forKey: "mesh_token") {
            request.setValue(token, forHTTPHeaderField: "X-Mesh-Token")
        }
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.requestFailed
        }
    }
}

enum APIError: LocalizedError {
    case requestFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed: return "Request failed"
        case .decodingFailed: return "Failed to decode response"
        }
    }
}

private struct EmptyResponse: Decodable {}
