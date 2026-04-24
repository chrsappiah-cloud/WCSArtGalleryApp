import Foundation

/// Artwork row returned by the FastAPI `/api/artworks` JSON (distinct from mock `Artwork` in `Models/`).
struct WCSBackendArtwork: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let artistName: String
    let description: String?
    let medium: String?
    let year: String?
    let imageURL: String
    let thumbnailURL: String?
    let sourceType: String
    let externalSource: String?
    let promptUsed: String?
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, description, medium, year, createdAt
        case artistName = "artist_name"
        case imageURL = "image_url"
        case thumbnailURL = "thumbnail_url"
        case sourceType = "source_type"
        case externalSource = "external_source"
        case promptUsed = "prompt_used"
    }
}

struct WCSPromptRequest: Codable {
    let concept: String
    let style: String
    let mood: String
    let palette: String
    let aspectRatio: String

    enum CodingKeys: String, CodingKey {
        case concept, style, mood, palette
        case aspectRatio = "aspect_ratio"
    }
}

struct WCSPromptResponse: Codable {
    let systemPrompt: String
    let finalPrompt: String

    enum CodingKeys: String, CodingKey {
        case systemPrompt = "system_prompt"
        case finalPrompt = "final_prompt"
    }
}
