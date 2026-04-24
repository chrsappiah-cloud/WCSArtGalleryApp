import Foundation

final class WCSBackendAPIClient {
    static let shared = WCSBackendAPIClient()

    private init() {}

    func fetchArtworks() async throws -> [WCSBackendArtwork] {
        let url = WCSBackendAPIConfig.apiBaseURL.appending(path: "artworks")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([WCSBackendArtwork].self, from: data)
    }

    func buildPrompt(request: WCSPromptRequest) async throws -> WCSPromptResponse {
        var urlRequest = URLRequest(url: WCSBackendAPIConfig.apiBaseURL.appending(path: "ai/prompt"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(WCSPromptResponse.self, from: data)
    }

    func generateImage(request: WCSPromptRequest) async throws -> URL? {
        var urlRequest = URLRequest(url: WCSBackendAPIConfig.apiBaseURL.appending(path: "ai/generate"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let value = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let imageURL = value?["image_url"] as? String {
            return URL(string: Artwork.resolvedImageURL(imageURL))
        }
        return nil
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
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return (obj?["imported"] as? Int) ?? 0
    }
}
