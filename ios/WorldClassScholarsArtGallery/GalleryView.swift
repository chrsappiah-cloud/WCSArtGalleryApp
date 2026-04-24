import SwiftUI

struct GalleryView: View {
    @StateObject private var vm = GalleryViewModel()
    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(vm.artworks) { art in
                        NavigationLink(value: art) {
                            VStack(alignment: .leading, spacing: 8) {
                                AsyncImage(url: URL(string: art.thumbnailURL ?? art.imageURL)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: {
                                    Rectangle().fill(Color.gray.opacity(0.15))
                                }
                                .frame(height: 220)
                                .clipped()
                                Text(art.title).font(.headline)
                                Text(art.artistName).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("World Class Scholars")
            .navigationDestination(for: Artwork.self) { art in
                ArtworkDetailView(artwork: art)
            }
            .task { await vm.load() }
        }
    }
}
