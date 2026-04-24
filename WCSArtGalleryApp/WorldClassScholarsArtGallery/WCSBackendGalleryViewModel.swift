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
        do {
            artworks = try await WCSBackendAPIClient.shared.fetchArtworks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
