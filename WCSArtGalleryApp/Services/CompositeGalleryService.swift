import Foundation

/// Merges your FastAPI gallery with **live** open-access imagery from The Met, Art Institute of Chicago, and Cleveland Museum of Art; then curated mocks if nothing loaded.
struct CompositeGalleryService: GalleryService {
    nonisolated init() {}

    func fetchArtworks() async throws -> [Artwork] {
        var backend: [Artwork] = []
        if let rows = try? await WCSBackendAPIClient.shared.fetchArtworks(), !rows.isEmpty {
            backend = rows.map { Artwork.fromBackend($0) }
        }

        let live = await OpenAccessMuseumAggregator.fetchArtworks(limitPerMuseum: 10)

        var merged: [Artwork] = []
        var seenImageURLs = Set<String>()
        func appendUnique(_ a: Artwork) {
            if let u = a.imageURL?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !u.isEmpty {
                guard seenImageURLs.insert(u).inserted else { return }
            }
            merged.append(a)
        }
        for a in backend { appendUnique(a) }
        for a in live { appendUnique(a) }

        if !merged.isEmpty {
            return merged
        }
        return try await MockGalleryService().fetchArtworks()
    }
}
