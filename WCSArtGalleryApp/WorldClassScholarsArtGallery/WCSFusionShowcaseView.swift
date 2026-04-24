import SwiftUI

/// Exhibition-style rooms with luminous panels.
struct WCSFusionShowcaseView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Showcase")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WCSStudioTheme.heroGradient)
                            .textCase(.uppercase)
                            .tracking(1.4)
                        Text("Curated rooms")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(WCSStudioTheme.textPrimary)
                        Text(
                            "Large imagery, restrained type, and editorial spacing — tuned for slow viewing."
                        )
                        .font(.subheadline)
                        .foregroundStyle(WCSStudioTheme.textMuted)
                    }
                    .padding(.horizontal, 4)

                    ForEach(0 ..< 3, id: \.self) { idx in
                        ZStack(alignment: .bottomLeading) {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            WCSStudioTheme.panelElevated,
                                            WCSStudioTheme.accent.opacity(0.18),
                                            WCSStudioTheme.accentSecondary.opacity(0.12),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                )
                                .frame(height: 240)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                        .stroke(WCSStudioTheme.stroke, lineWidth: 1),
                                )

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Room \(idx + 1)")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(WCSStudioTheme.textPrimary)
                                Text("Immersive digital exhibition")
                                    .font(.caption)
                                    .foregroundStyle(WCSStudioTheme.textMuted)
                            }
                            .padding(18)
                        }
                        .shadow(color: WCSStudioTheme.accent.opacity(0.12), radius: 20, y: 12)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .navigationTitle("Spaces")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(WCSStudioTheme.panel.opacity(0.35), for: .navigationBar)
        }
    }
}
