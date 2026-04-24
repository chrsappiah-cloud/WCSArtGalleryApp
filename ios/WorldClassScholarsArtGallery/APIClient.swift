import Foundation

final class APIClient {
    static let shared = APIClient()

    private init() {}

    func fetchArtworks() async throws -> [Artwork] {
        let url = Config.apiBaseURL.appending(path: "artworks")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Artwork].self, from: data)
    }

    func buildPrompt(request: PromptRequest) async throws -> PromptResponse {
        var urlRequest = URLRequest(url: Config.apiBaseURL.appending(path: "ai/prompt"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        return try JSONDecoder().decode(PromptResponse.self, from: data)
    }

    func generateImage(request: PromptRequest) async throws -> URL? {
        var urlRequest = URLRequest(url: Config.apiBaseURL.appending(path: "ai/generate"))
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        let (data, _) = try await URLSession.shared.data(for: urlRequest)
        let value = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        if let imageURL = value?["image_url"] as? String {
            return URL(string: imageURL)
        }
        return nil
    }
}
