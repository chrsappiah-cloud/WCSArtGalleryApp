import Foundation

/// Parallel fetches from major museums’ **public, keyless** open-access APIs (Met, Art Institute of Chicago, Cleveland Museum of Art).
/// Images are live IIIF / CDN URLs suitable for `AsyncImage`.
enum OpenAccessMuseumAggregator: Sendable {
    nonisolated private static let metSearch = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/search")!
    nonisolated private static let metObject = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/objects")!
    nonisolated private static let articSearch = URL(string: "https://api.artic.edu/api/v1/artworks/search")!
    nonisolated private static let clevelandSearch = URL(string: "https://openaccess-api.clevelandart.org/api/artworks/")!

    nonisolated private static let session: URLSession = {
        let c = URLSessionConfiguration.ephemeral
        c.timeoutIntervalForRequest = 22
        c.timeoutIntervalForResource = 35
        return URLSession(configuration: c)
    }()

    /// Rows for the main gallery `Artwork` model.
    nonisolated static func fetchArtworks(limitPerMuseum: Int) async -> [Artwork] {
        let seeds = await fetchSeeds(limitPerMuseum: limitPerMuseum)
        return seeds.map { $0.toArtwork() }
    }

    /// Rows for the Studio **Feed** (`WCSBackendArtwork`) when the API is empty or offline.
    nonisolated static func fetchBackendRows(limitPerMuseum: Int) async -> [WCSBackendArtwork] {
        let seeds = await fetchSeeds(limitPerMuseum: limitPerMuseum)
        return seeds.enumerated().map { idx, s in s.toWCSBackendArtwork(syntheticIndex: idx) }
    }

    nonisolated private static func fetchSeeds(limitPerMuseum: Int) async -> [MuseumArtSeed] {
        let cap = min(24, max(4, limitPerMuseum))
        async let met = fetchMet(cap)
        async let artic = fetchArtic(cap)
        async let cleve = fetchCleveland(cap)
        let m = await met
        let a = await artic
        let c = await cleve
        var combined = m + a + c
        var seen = Set<String>()
        combined.removeAll { seed in
            let key = seed.imageURL.lowercased()
            if seen.contains(key) { return true }
            seen.insert(key)
            return false
        }
        return combined
    }

    // MARK: - Met

    private nonisolated static func fetchMet(_ limit: Int) async -> [MuseumArtSeed] {
        let terms = ["masterpiece", "portrait", "landscape", "textile", "sculpture"]
        let q = terms.randomElement() ?? "painting"
        guard var c = URLComponents(url: metSearch, resolvingAgainstBaseURL: false) else { return [] }
        c.queryItems = [
            URLQueryItem(name: "hasImages", value: "true"),
            URLQueryItem(name: "q", value: q),
        ]
        guard let url = c.url else { return [] }
        guard let (data, _) = try? await session.data(from: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let ids = root["objectIDs"] as? [Int]
        else { return [] }

        var out: [MuseumArtSeed] = []
        for oid in ids.prefix(limit) {
            guard let oURL = URL(string: "\(metObject.absoluteString)/\(oid)"),
                  let (od, _) = try? await session.data(from: oURL),
                  let obj = try? JSONSerialization.jsonObject(with: od) as? [String: Any]
            else { continue }
            let image = (obj["primaryImage"] as? String) ?? (obj["primaryImageSmall"] as? String)
            guard let image, !image.isEmpty else { continue }
            let title = (obj["title"] as? String).map { String($0.prefix(512)) } ?? "Untitled"
            let artist = (obj["artistDisplayName"] as? String).map { String($0.prefix(512)) } ?? "The Met"
            let date = obj["objectDate"] as? String
            let medium = obj["medium"] as? String
            let culture = obj["culture"] as? String
            let desc = [date, culture].compactMap { $0 }.joined(separator: " · ")
            let thumb = (obj["primaryImageSmall"] as? String) ?? image
            out.append(
                MuseumArtSeed(
                    museum: "The Met",
                    remoteId: "met-\(oid)",
                    title: title,
                    artist: artist,
                    description: desc.isEmpty ? "The Metropolitan Museum of Art — Open Access" : desc,
                    medium: medium.map { String($0.prefix(255)) },
                    year: date.map { String($0.prefix(64)) },
                    imageURL: image,
                    thumbnailURL: thumb,
                    externalURL: oURL.absoluteString
                )
            )
        }
        return out
    }

    // MARK: - Art Institute of Chicago

    private nonisolated static func fetchArtic(_ limit: Int) async -> [MuseumArtSeed] {
        let queries = ["impressionism", "renaissance", "modern", "still life", "figure"]
        let q = queries.randomElement() ?? "painting"
        guard var c = URLComponents(url: articSearch, resolvingAgainstBaseURL: false) else { return [] }
        c.queryItems = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "fields", value: "id,title,artist_display,image_id,date_display,medium_display"),
        ]
        guard let url = c.url,
              let (data, _) = try? await session.data(from: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rows = root["data"] as? [[String: Any]]
        else { return [] }

        var out: [MuseumArtSeed] = []
        for row in rows {
            guard let id = row["id"] as? Int,
                  let imageId = row["image_id"] as? String,
                  !imageId.isEmpty
            else { continue }
            let iiif = "https://www.artic.edu/iiif/2/\(imageId)/full/!800,800/0/default.jpg"
            let thumb = "https://www.artic.edu/iiif/2/\(imageId)/full/!200,200/0/default.jpg"
            let title = (row["title"] as? String).map { String($0.prefix(512)) } ?? "Untitled"
            let artist = (row["artist_display"] as? String).map { String($0.prefix(512)) } ?? "Art Institute of Chicago"
            let year = row["date_display"] as? String
            let medium = row["medium_display"] as? String
            out.append(
                MuseumArtSeed(
                    museum: "Art Institute of Chicago",
                    remoteId: "artic-\(id)",
                    title: title,
                    artist: artist,
                    description: "Art Institute of Chicago — open collection",
                    medium: medium.map { String($0.prefix(255)) },
                    year: year.map { String($0.prefix(64)) },
                    imageURL: iiif,
                    thumbnailURL: thumb,
                    externalURL: "https://www.artic.edu/artworks/\(id)"
                )
            )
        }
        return out
    }

    // MARK: - Cleveland Museum of Art

    private nonisolated static func fetchCleveland(_ limit: Int) async -> [MuseumArtSeed] {
        let terms = ["landscape", "portrait", "bronze", "tapestry", "ceramic"]
        let q = terms.randomElement() ?? "painting"
        guard var c = URLComponents(url: clevelandSearch, resolvingAgainstBaseURL: false) else { return [] }
        c.queryItems = [
            URLQueryItem(name: "has_image", value: "1"),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "q", value: q),
        ]
        guard let url = c.url,
              let (data, _) = try? await session.data(from: url),
              let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rows = root["data"] as? [[String: Any]]
        else { return [] }

        var out: [MuseumArtSeed] = []
        for row in rows {
            guard let id = row["id"] as? Int else { continue }
            let images = row["images"] as? [String: Any]
            let web = images?["web"] as? [String: Any]
            let image = (web?["url"] as? String) ?? (images?["print"] as? [String: Any])?["url"] as? String
            guard let image, !image.isEmpty else { continue }
            let title = (row["title"] as? String).map { String($0.prefix(512)) } ?? "Untitled"
            let creators = row["creators"] as? String
            let artist = creators.map { String($0.prefix(512)) } ?? "Cleveland Museum of Art"
            let creation = row["creation_date"] as? String
            let technique = row["technique"] as? String
            out.append(
                MuseumArtSeed(
                    museum: "Cleveland Museum of Art",
                    remoteId: "cma-\(id)",
                    title: title,
                    artist: artist,
                    description: "Cleveland Museum of Art — Open Access",
                    medium: technique.map { String($0.prefix(255)) },
                    year: creation.map { String($0.prefix(64)) },
                    imageURL: image,
                    thumbnailURL: image,
                    externalURL: "https://www.clevelandart.org/art/\(row["accession_number"] as? String ?? "\(id)")"
                )
            )
        }
        return out
    }
}

// MARK: - Seeds

private struct MuseumArtSeed: Sendable {
    let museum: String
    let remoteId: String
    let title: String
    let artist: String
    let description: String
    let medium: String?
    let year: String?
    let imageURL: String
    let thumbnailURL: String
    let externalURL: String

    nonisolated func toArtwork() -> Artwork {
        let id = Self.stableUUID(museum: museum, remoteId: remoteId)
        return Artwork(
            id: id,
            title: title,
            artist: artist,
            style: museum,
            year: year ?? "",
            medium: medium ?? "",
            description: description,
            isFeatured: true,
            isSaved: false,
            imageURL: imageURL
        )
    }

    nonisolated func toWCSBackendArtwork(syntheticIndex: Int) -> WCSBackendArtwork {
        let id = -9_000_000 - syntheticIndex
        let now = ISO8601DateFormatter().string(from: Date())
        return WCSBackendArtwork(
            id: id,
            title: title,
            artistName: "\(artist) · \(museum)",
            description: description,
            medium: medium,
            year: year,
            imageURL: imageURL,
            thumbnailURL: thumbnailURL,
            sourceType: "external_api",
            externalSource: externalURL,
            promptUsed: nil,
            createdAt: now
        )
    }

    nonisolated private static func stableUUID(museum: String, remoteId: String) -> UUID {
        let combined = "\(museum)|\(remoteId)"
        var hash: UInt64 = 14_695_981_039_346_656_037
        for b in combined.utf8 {
            hash = hash &* 31 &+ UInt64(b)
        }
        let suffix = hash & 0xFFFFFFFFFFFF
        let hex = String(format: "%012llx", suffix)
        return UUID(uuidString: "00000000-0000-4000-b000-\(hex)") ?? UUID()
    }
}
