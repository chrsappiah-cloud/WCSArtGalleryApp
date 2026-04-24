import Foundation

final class WCSBackendAPIClient {
    static let shared = WCSBackendAPIClient()

    private init() {}

    /// FastAPI may return `detail` as a string (HTTPException) or a list (validation errors).
    private static func flattenFastAPIDetail(_ value: Any?) -> String? {
        if let s = value as? String { return s }
        if let arr = value as? [[String: Any]] {
            return arr.compactMap { row in
                if let msg = row["msg"] as? String { return msg }
                if let loc = row["loc"] as? [Any] {
                    return "\(loc): \(row["msg"] as? String ?? "")"
                }
                return nil
            }.joined(separator: "; ")
        }
        return nil
    }

    struct APIError: LocalizedError {
        let message: String
        var errorDescription: String? { message }
    }

    private func require2xx(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200 ... 299).contains(http.statusCode) else {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = Self.flattenFastAPIDetail(obj["detail"]),
               !detail.isEmpty
            {
                throw APIError(message: detail)
            }
            throw APIError(message: "Server error (\(http.statusCode)).")
        }
    }

    func fetchArtworks() async throws -> [WCSBackendArtwork] {
        let url = WCSBackendAPIConfig.apiBaseURL.appending(path: "artworks")
        let (data, response) = try await URLSession.shared.data(from: url)
        try require2xx(response, data: data)
        return try JSONDecoder().decode([WCSBackendArtwork].self, from: data)
    }

    func buildPrompt(request: WCSPromptRequest) async throws -> WCSPromptResponse {
        var urlRequest = URLRequest(url: WCSBackendAPIConfig.apiBaseURL.appending(path: "ai/prompt"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        try require2xx(response, data: data)
        return try JSONDecoder().decode(WCSPromptResponse.self, from: data)
    }

    func generateImage(request: WCSPromptRequest) async throws -> URL? {
        var urlRequest = URLRequest(url: WCSBackendAPIConfig.apiBaseURL.appending(path: "ai/generate"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        try require2xx(response, data: data)
        let value = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let imageURL = value?["image_url"] as? String {
            return URL(string: Artwork.resolvedImageURL(imageURL))
        }
        throw APIError(message: "Image generation returned no `image_url`.")
    }

    /// Pulls open-access Met highlights into the shared database (`POST /api/import/open-access-met-sample`).
    func importMetOpenAccessSample(limit: Int = 6) async throws -> Int {
        let base = WCSBackendAPIConfig.apiBaseURL.appending(path: "import/open-access-met-sample")
        var parts = URLComponents(url: base, resolvingAgainstBaseURL: false)!
        parts.queryItems = [URLQueryItem(name: "limit", value: String(limit))]
        guard let url = parts.url else { throw URLError(.badURL) }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        try require2xx(response, data: data)
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return (obj?["imported"] as? Int) ?? 0
    }
}
