import Combine
import Foundation

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var artworks: [Artwork] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            artworks = try await APIClient.shared.fetchArtworks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
