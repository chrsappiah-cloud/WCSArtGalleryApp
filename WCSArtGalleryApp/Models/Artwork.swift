import Foundation

struct Artwork: Identifiable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let style: String
    let year: String
    let medium: String
    let description: String
    let isFeatured: Bool
    let isSaved: Bool
    /// Remote or `/media/...` URL when loaded from the FastAPI backend / open access.
    let imageURL: String?

    nonisolated init(
        id: UUID,
        title: String,
        artist: String,
        style: String,
        year: String,
        medium: String,
        description: String,
        isFeatured: Bool,
        isSaved: Bool,
        imageURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.style = style
        self.year = year
        self.medium = medium
        self.description = description
        self.isFeatured = isFeatured
        self.isSaved = isSaved
        self.imageURL = imageURL
    }
}

extension Artwork {
    /// Maps API / database rows into the gallery `Artwork` model used by Home / Explore / Saved.
    static func fromBackend(_ row: WCSBackendArtwork) -> Artwork {
        let suffix = UInt64(bitPattern: Int64(row.id)) & 0xFFFFFFFFFFFF
        let hex = String(format: "%012llx", suffix)
        let stableId = UUID(uuidString: "00000000-0000-4000-8000-\(hex)") ?? UUID()
        let featured = row.sourceType == "external_api" || row.sourceType == "ai_generated"
        return Artwork(
            id: stableId,
            title: row.title,
            artist: row.artistName,
            style: row.sourceType.replacingOccurrences(of: "_", with: " ").capitalized,
            year: row.year ?? "",
            medium: row.medium ?? "",
            description: row.description ?? "",
            isFeatured: featured,
            isSaved: false,
            imageURL: Self.resolvedImageURL(row.imageURL)
        )
    }

    /// Turns `/media/...` paths into full URLs using the API host (not the `/api` prefix).
    static func resolvedImageURL(_ raw: String) -> String {
        if raw.hasPrefix("http://") || raw.hasPrefix("https://") {
            return raw
        }
        if raw.hasPrefix("/") {
            let origin = WCSBackendAPIConfig.apiOrigin.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return "\(origin)\(raw)"
        }
        return raw
    }

    nonisolated func withSaved(_ saved: Bool) -> Artwork {
        Artwork(
            id: id,
            title: title,
            artist: artist,
            style: style,
            year: year,
            medium: medium,
            description: description,
            isFeatured: isFeatured,
            isSaved: saved,
            imageURL: imageURL
        )
    }
}
