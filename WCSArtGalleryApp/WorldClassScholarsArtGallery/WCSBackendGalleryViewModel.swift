import Combine
import Foundation

@MainActor
final class WCSBackendGalleryViewModel: ObservableObject {
    @Published var artworks: [WCSBackendArtwork] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        var merged: [WCSBackendArtwork] = []
        if let api = try? await WCSBackendAPIClient.shared.fetchArtworks() {
            merged = api
        }

        let live = await OpenAccessMuseumAggregator.fetchBackendRows(limitPerMuseum: 10)
        var seen = Set(merged.map { $0.imageURL.lowercased() })
        for row in live {
            let key = row.imageURL.lowercased()
            if seen.insert(key).inserted {
                merged.append(row)
            }
        }

        artworks = merged
        if merged.isEmpty {
            errorMessage = "No rows yet. Start FastAPI or check the network — live museum previews could not load."
        }
    }
}
