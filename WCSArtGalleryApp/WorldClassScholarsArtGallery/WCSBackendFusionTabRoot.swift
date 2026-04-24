import SwiftUI

/// Fusion-PDF tab stack, linked inside **WCSArtGalleryApp.xcodeproj + mocks** target.
struct WCSBackendFusionTabRoot: View {
    var body: some View {
        TabView {
            WCSBackendGalleryGridView()
                .tabItem { Label("Feed", systemImage: "square.grid.3x3.fill") }
            WCSFusionShowcaseView()
                .tabItem { Label("Rooms", systemImage: "sparkles.tv.fill") }
            WCSFusionUploadHubView()
                .tabItem { Label("Ingest", systemImage: "arrow.down.circle.fill") }
            WCSBackendAIStudioView()
                .tabItem { Label("Create", systemImage: "wand.and.stars") }
        }
        .tint(WCSStudioTheme.accent)
    }
}
