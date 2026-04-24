import SwiftUI

/// FastAPI-backed gallery grid with studio-style tiles.
struct WCSBackendGalleryGridView: View {
    @StateObject private var vm = WCSBackendGalleryViewModel()
    private let columns = [GridItem(.adaptive(minimum: 158), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(vm.artworks) { art in
                        NavigationLink(value: art) {
                            VStack(alignment: .leading, spacing: 10) {
                                AsyncImage(url: URL(string: art.thumbnailURL ?? art.imageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(WCSStudioTheme.panel)
                                            .overlay {
                                                ProgressView()
                                                    .tint(WCSStudioTheme.accent)
                                            }
                                    }
                                }
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(WCSStudioTheme.stroke, lineWidth: 1),
                                )

                                Text(art.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(WCSStudioTheme.textPrimary)
                                    .lineLimit(2)
                                Text(art.artistName)
                                    .font(.caption)
                                    .foregroundStyle(WCSStudioTheme.textMuted)
                            }
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(WCSStudioTheme.panelElevated.opacity(0.88))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        WCSStudioTheme.accent.opacity(0.25),
                                                        WCSStudioTheme.stroke,
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1,
                                            ),
                                    ),
                            )
                            .shadow(color: WCSStudioTheme.accent.opacity(0.1), radius: 14, y: 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Imagine")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.35), for: .navigationBar)
            .navigationDestination(for: WCSBackendArtwork.self) { art in
                WCSBackendServerArtworkDetailView(artwork: art)
            }
            .task { await vm.load() }
        }
    }
}
