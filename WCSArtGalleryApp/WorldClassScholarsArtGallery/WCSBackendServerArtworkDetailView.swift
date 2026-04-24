import SwiftUI

struct WCSBackendServerArtworkDetailView: View {
    let artwork: WCSBackendArtwork

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: artwork.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 280, maxHeight: 440)
                            .clipped()
                    default:
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(WCSStudioTheme.panelElevated)
                            .frame(height: 280)
                            .overlay { ProgressView().tint(WCSStudioTheme.accent) }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(WCSStudioTheme.stroke, lineWidth: 1),
                )
                .shadow(color: WCSStudioTheme.accent.opacity(0.15), radius: 22, y: 12)

                Text(artwork.title)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(WCSStudioTheme.textPrimary)
                Text(artwork.artistName)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(WCSStudioTheme.heroGradient)

                if let description = artwork.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(WCSStudioTheme.textMuted)
                }
                if let prompt = artwork.promptUsed {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Prompt trace")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WCSStudioTheme.textMuted)
                            .textCase(.uppercase)
                        Text(prompt)
                            .font(.footnote)
                            .foregroundStyle(WCSStudioTheme.textPrimary.opacity(0.9))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(WCSStudioTheme.panelElevated.opacity(0.9))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(WCSStudioTheme.stroke, lineWidth: 1),
                            ),
                    )
                }
            }
            .padding(18)
        }
        .navigationTitle("Artwork")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(WCSStudioTheme.panel.opacity(0.4), for: .navigationBar)
    }
}
