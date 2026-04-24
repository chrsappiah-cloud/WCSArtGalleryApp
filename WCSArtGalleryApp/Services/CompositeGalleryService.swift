import Foundation

/// Tries the FastAPI gallery first (open access / uploads / AI rows), then falls back to mock data.
struct CompositeGalleryService: GalleryService {
    func fetchArtworks() async throws -> [Artwork] {
        do {
            let remote = try await WCSBackendAPIClient.shared.fetchArtworks()
            if !remote.isEmpty {
                return remote.map { Artwork.fromBackend($0) }
            }
        } catch {
            // Network / server offline — use curated mock set.
        }
        return try await MockGalleryService().fetchArtworks()
    }
}
