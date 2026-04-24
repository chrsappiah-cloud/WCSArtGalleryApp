import Combine
import SwiftUI

struct ExploreView: View {
    @ObservedObject var viewModel: GalleryViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(viewModel.artworks) { artwork in
                        NavigationLink {
                            ArtworkDetailView(artwork: artwork)
                        } label: {
                            HStack(alignment: .center, spacing: 14) {
                                exploreThumb(artwork)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(artwork.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(WCSStudioTheme.textPrimary)
                                    Text("\(artwork.artist) · \(artwork.medium)")
                                        .font(.subheadline)
                                        .foregroundStyle(WCSStudioTheme.textMuted)
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        }
                    }
                } header: {
                    Text("Library")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(WCSStudioTheme.textMuted)
                        .textCase(.uppercase)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .listRowBackground(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(WCSStudioTheme.panelElevated.opacity(0.55))
                    .padding(.vertical, 3)
            )
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.35), for: .navigationBar)
            .refreshable {
                await viewModel.loadArtworks()
            }
            .task {
                if viewModel.artworks.isEmpty {
                    await viewModel.loadArtworks()
                }
            }
        }
    }

    @ViewBuilder
    private func exploreThumb(_ artwork: Artwork) -> some View {
        if let urlStr = artwork.imageURL, let u = URL(string: urlStr) {
            AsyncImage(url: u) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(WCSStudioTheme.panel)
                }
            }
            .frame(width: 54, height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(WCSStudioTheme.stroke, lineWidth: 1)
            )
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(WCSStudioTheme.accent.opacity(0.22))
                .frame(width: 54, height: 54)
                .overlay {
                    Image(systemName: "square.grid.2x2")
                        .foregroundStyle(WCSStudioTheme.textPrimary.opacity(0.7))
                }
        }
    }
}
