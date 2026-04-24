import Combine
import Foundation

enum GalleryBrowseCategory: String, CaseIterable, Sendable {
    case all
    case paintings
    case sculpture
    case photography
    case digitalArt
    case textileArt

    var displayTitle: String {
        switch self {
        case .all: "All"
        case .paintings: "Paintings"
        case .sculpture: "Sculpture"
        case .photography: "Photography"
        case .digitalArt: "Digital Art"
        case .textileArt: "Textile Art"
        }
    }

    fileprivate var matchKeywords: [String] {
        switch self {
        case .all: []
        case .paintings: ["paint", "oil", "canvas", "watercolor", "gouache", "tempera", "panel", "picture"]
        case .sculpture: ["sculpt", "marble", "bronze", "stone", "carv", "cast", "figur"]
        case .photography: ["photo", "print", "gelatin", "silver", "daguerre", "chromogenic", "lens"]
        case .digitalArt: ["digital", "video", "projection", "computer", "lcd", "screen"]
        case .textileArt: ["textile", "fabric", "tapestry", "weav", "kente", "silk", "embroider", "thread"]
        }
    }
}

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published private(set) var artworks: [Artwork] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var mainTabSelection: Int = 0
    @Published var browseCategory: GalleryBrowseCategory = .all

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

    var filteredForExplore: [Artwork] {
        guard browseCategory != .all else { return artworks }
        let keys = browseCategory.matchKeywords
        return artworks.filter { artwork in
            let haystack = "\(artwork.title) \(artwork.style) \(artwork.medium) \(artwork.description)"
                .lowercased()
            return keys.contains { haystack.contains($0) }
        }
    }

    func setBrowseCategory(_ category: GalleryBrowseCategory, jumpToExplore: Bool) {
        browseCategory = category
        if jumpToExplore {
            mainTabSelection = 1
        }
    }

    func toggleSaved(for artworkId: UUID) {
        artworks = artworks.map { piece in
            piece.id == artworkId ? piece.withSaved(!piece.isSaved) : piece
        }
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
