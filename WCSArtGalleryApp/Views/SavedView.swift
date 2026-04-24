import Combine
import SwiftUI

struct SavedView: View {
    @ObservedObject var viewModel: GalleryViewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedArtworks.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing saved yet", systemImage: "bookmark")
                            .foregroundStyle(WCSStudioTheme.heroGradient)
                    } description: {
                        Text("Tap the bookmark on pieces you love — they will land here.")
                            .foregroundStyle(WCSStudioTheme.textMuted)
                    }
                    .padding(.top, 40)
                } else {
                    List {
                        ForEach(viewModel.savedArtworks) { artwork in
                            NavigationLink {
                                ArtworkDetailView(artwork: artwork)
                            } label: {
                                HStack(spacing: 12) {
                                    savedThumb(artwork)
                                    Text(artwork.title)
                                        .font(.headline.weight(.medium))
                                        .foregroundStyle(WCSStudioTheme.textPrimary)
                                }
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(WCSStudioTheme.panelElevated.opacity(0.55))
                            .padding(.vertical, 3)
                    )
                }
            }
            .navigationTitle("Saved")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.35), for: .navigationBar)
            .refreshable {
                await viewModel.loadArtworks()
            }
        }
    }

    @ViewBuilder
    private func savedThumb(_ artwork: Artwork) -> some View {
        if let urlStr = artwork.imageURL, let u = URL(string: urlStr) {
            AsyncImage(url: u) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(WCSStudioTheme.panel)
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(WCSStudioTheme.accentSecondary.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundStyle(WCSStudioTheme.accentSecondary)
                }
        }
    }
}
