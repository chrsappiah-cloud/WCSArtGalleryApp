import Combine
import SwiftUI

struct GalleryHomeView: View {
    @ObservedObject var viewModel: GalleryViewModel

    private let categories = [
        "Paintings",
        "Sculpture",
        "Photography",
        "Digital Art",
        "Textile Art",
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Imagine")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WCSStudioTheme.heroGradient)
                            .textCase(.uppercase)
                            .tracking(1.6)
                        Text("WCS Art Gallery")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(WCSStudioTheme.heroGradient)
                        Text("Curated surfaces, open collections, and AI-assisted creation — in one flow.")
                            .font(.subheadline)
                            .foregroundStyle(WCSStudioTheme.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if viewModel.isLoading {
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(WCSStudioTheme.accent)
                            Text("Syncing collection…")
                                .font(.subheadline)
                                .foregroundStyle(WCSStudioTheme.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(Color(red: 1, green: 0.45, blue: 0.5))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(WCSStudioTheme.panelElevated.opacity(0.9))
                            )
                    } else {
                        featuredSection
                    }

                    categoriesSection
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 28)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.4), for: .navigationBar)
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

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Featured")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(WCSStudioTheme.textPrimary)
                Spacer()
                Image(systemName: "sparkles")
                    .foregroundStyle(WCSStudioTheme.heroGradient)
            }

            ForEach(viewModel.featuredArtworks) { artwork in
                NavigationLink {
                    ArtworkDetailView(artwork: artwork)
                } label: {
                    HStack(alignment: .center, spacing: 14) {
                        thumbnail(artwork)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(artwork.title)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(WCSStudioTheme.textPrimary)
                                .multilineTextAlignment(.leading)
                            Text("\(artwork.artist) · \(artwork.style)")
                                .font(.subheadline)
                                .foregroundStyle(WCSStudioTheme.textMuted)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WCSStudioTheme.textMuted.opacity(0.6))
                    }
                    .wcsGlassCard()
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func thumbnail(_ artwork: Artwork) -> some View {
        Group {
            if let urlStr = artwork.imageURL, let u = URL(string: urlStr) {
                AsyncImage(url: u) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(WCSStudioTheme.panel)
                            .overlay {
                                ProgressView()
                                    .tint(WCSStudioTheme.accentSecondary)
                            }
                    }
                }
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(WCSStudioTheme.stroke, lineWidth: 1)
                )
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                WCSStudioTheme.accent.opacity(0.35),
                                WCSStudioTheme.accentSecondary.opacity(0.2),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .overlay {
                        Image(systemName: "photo.stack")
                            .font(.title2)
                            .foregroundStyle(WCSStudioTheme.textPrimary.opacity(0.85))
                    }
            }
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Modes")
                .font(.title3.weight(.semibold))
                .foregroundStyle(WCSStudioTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 12)], spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    Text(category)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(WCSStudioTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(WCSStudioTheme.panelElevated.opacity(0.75))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(WCSStudioTheme.stroke, lineWidth: 1)
                                )
                        )
                }
            }
        }
    }
}
