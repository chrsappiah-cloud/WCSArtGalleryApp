import Combine
import Foundation

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published private(set) var artworks: [Artwork] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let service: GalleryService

    init(service: GalleryService = CompositeGalleryService()) {
        self.service = service
    }

    var featuredArtworks: [Artwork] {
        artworks.filter(\.isFeatured)
    }

    var savedArtworks: [Artwork] {
        artworks.filter(\.isSaved)
    }

    func loadArtworks() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            artworks = try await service.fetchArtworks()
        } catch {
            errorMessage = "Unable to load artworks right now. Please try again."
        }
    }

    /// Adds CloudKit-backed rows that are not already in the in-memory list (same `Artwork.id`).
    func mergeArtworksFromCloudKit(_ imported: [Artwork]) {
        let existing = Set(artworks.map(\.id))
        let additions = imported.filter { !existing.contains($0.id) }
        guard !additions.isEmpty else { return }
        artworks = additions + artworks
    }
}
