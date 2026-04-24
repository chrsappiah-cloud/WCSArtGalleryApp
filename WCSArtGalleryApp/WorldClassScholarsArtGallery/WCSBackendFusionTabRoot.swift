import SwiftUI

/// Studio hub: single chrome rail (no nested `TabView`) so the main tab bar stays the only system tab strip.
enum WCSStudioInnerPane: Int, CaseIterable, Identifiable {
    case feed, rooms, ingest, create

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .feed: "Feed"
        case .rooms: "Rooms"
        case .ingest: "Ingest"
        case .create: "Create"
        }
    }

    var systemImage: String {
        switch self {
        case .feed: "square.grid.3x3.fill"
        case .rooms: "sparkles.tv.fill"
        case .ingest: "arrow.down.circle.fill"
        case .create: "wand.and.stars"
        }
    }
}

struct WCSBackendFusionTabRoot: View {
    @State private var pane: WCSStudioInnerPane = .feed

    var body: some View {
        VStack(spacing: 0) {
            studioPicker
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(
                    WCSStudioTheme.onyx.opacity(0.94)
                        .overlay(
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            WCSStudioTheme.champagne.opacity(0.14),
                                            Color.clear,
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom,
                                    ),
                                ),
                        ),
                )

            Group {
                switch pane {
                case .feed:
                    WCSBackendGalleryGridView()
                case .rooms:
                    WCSFusionShowcaseView()
                case .ingest:
                    WCSFusionUploadHubView()
                case .create:
                    WCSBackendAIStudioView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(WCSStudioTheme.void.ignoresSafeArea())
    }

    private var studioPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(WCSStudioInnerPane.allCases) { p in
                    Button {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.84)) {
                            pane = p
                        }
                    } label: {
                        VStack(spacing: 5) {
                            Image(systemName: p.systemImage)
                                .font(.system(size: 17, weight: .semibold))
                            Text(p.title)
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundStyle(pane == p ? WCSStudioTheme.textPrimary : WCSStudioTheme.textMuted)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(pane == p ? WCSStudioTheme.panelElevated.opacity(0.96) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(
                                            pane == p
                                                ? LinearGradient(
                                                    colors: [
                                                        WCSStudioTheme.champagne.opacity(0.55),
                                                        WCSStudioTheme.accent.opacity(0.4),
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing,
                                                )
                                                : LinearGradient(
                                                    colors: [WCSStudioTheme.stroke.opacity(0.45)],
                                                    startPoint: .top,
                                                    endPoint: .bottom,
                                                ),
                                            lineWidth: pane == p ? 1.15 : 0.85,
                                        ),
                                ),
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }
}
