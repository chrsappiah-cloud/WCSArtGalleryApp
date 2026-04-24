import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                hero

                VStack(alignment: .leading, spacing: 8) {
                    Text(artwork.title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(WCSStudioTheme.textPrimary)
                    Text(artwork.artist)
                        .font(.title3.weight(.medium))
                        .foregroundStyle(WCSStudioTheme.heroGradient)
                }

                VStack(spacing: 12) {
                    metaRow("Style", artwork.style)
                    metaRow("Year", artwork.year)
                    metaRow("Medium", artwork.medium)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(WCSStudioTheme.panelElevated.opacity(0.85))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(WCSStudioTheme.stroke, lineWidth: 1)
                        )
                )

                Text(artwork.description)
                    .font(.body)
                    .foregroundStyle(WCSStudioTheme.textMuted)
                    .lineSpacing(4)
            }
            .padding(18)
        }
        .navigationTitle("Artwork")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(WCSStudioTheme.panel.opacity(0.4), for: .navigationBar)
    }

    @ViewBuilder
    private var hero: some View {
        if let urlStr = artwork.imageURL, let u = URL(string: urlStr) {
            AsyncImage(url: u) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 280, maxHeight: 420)
                        .clipped()
                default:
                    placeholderHero(showProgress: true)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                WCSStudioTheme.accent.opacity(0.5),
                                WCSStudioTheme.accentSecondary.opacity(0.35),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2,
                    ),
            )
            .shadow(color: WCSStudioTheme.accent.opacity(0.2), radius: 24, y: 14)
        } else {
            placeholderHero(showProgress: false)
        }
    }

    private func placeholderHero(showProgress: Bool) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(WCSStudioTheme.panelElevated)
            .frame(height: 260)
            .overlay {
                if showProgress {
                    ProgressView()
                        .tint(WCSStudioTheme.accent)
                } else {
                    Image(systemName: "photo.artframe")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(WCSStudioTheme.heroGradient)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(WCSStudioTheme.stroke, lineWidth: 1),
            )
    }

    private func metaRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(WCSStudioTheme.textMuted)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(WCSStudioTheme.textPrimary)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    NavigationStack {
        ArtworkDetailView(
            artwork: Artwork(
                id: UUID(),
                title: "Golden Kente Reverie",
                artist: "Ama Nkrumah",
                style: "Contemporary Textile",
                year: "2026",
                medium: "Acrylic on Canvas",
                description: "Sample detail preview for an artwork card.",
                isFeatured: true,
                isSaved: false,
                imageURL: nil
            )
        )
    }
    .preferredColorScheme(.dark)
}
