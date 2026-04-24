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
        case id, title, description, medium, year
        case createdAt = "created_at"
        case artistName = "artist_name"
        case imageURL = "image_url"
        case thumbnailURL = "thumbnail_url"
        case sourceType = "source_type"
        case externalSource = "external_source"
        case promptUsed = "prompt_used"
    }

    /// Synthetic rows for live open-access previews (not from JSON decode).
    nonisolated init(
        id: Int,
        title: String,
        artistName: String,
        description: String?,
        medium: String?,
        year: String?,
        imageURL: String,
        thumbnailURL: String?,
        sourceType: String,
        externalSource: String?,
        promptUsed: String?,
        createdAt: String
    ) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.description = description
        self.medium = medium
        self.year = year
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.sourceType = sourceType
        self.externalSource = externalSource
        self.promptUsed = promptUsed
        self.createdAt = createdAt
    }
}

extension WCSBackendArtwork {
    nonisolated init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        artistName = try c.decode(String.self, forKey: .artistName)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        medium = try c.decodeIfPresent(String.self, forKey: .medium)
        year = try c.decodeIfPresent(String.self, forKey: .year)
        imageURL = try c.decode(String.self, forKey: .imageURL)
        thumbnailURL = try c.decodeIfPresent(String.self, forKey: .thumbnailURL)
        sourceType = try c.decode(String.self, forKey: .sourceType)
        externalSource = try c.decodeIfPresent(String.self, forKey: .externalSource)
        promptUsed = try c.decodeIfPresent(String.self, forKey: .promptUsed)
        createdAt = try c.decode(String.self, forKey: .createdAt)
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

    nonisolated func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(concept, forKey: .concept)
        try c.encode(style, forKey: .style)
        try c.encode(mood, forKey: .mood)
        try c.encode(palette, forKey: .palette)
        try c.encode(aspectRatio, forKey: .aspectRatio)
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
