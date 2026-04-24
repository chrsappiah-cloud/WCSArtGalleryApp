import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GalleryView()
                .tabItem { Label("Gallery", systemImage: "rectangle.grid.2x2") }
            ShowcaseView()
                .tabItem { Label("Showcase", systemImage: "sparkles.tv") }
            UploadHubView()
                .tabItem { Label("Upload", systemImage: "square.and.arrow.up") }
            AIStudioView()
                .tabItem { Label("AI Studio", systemImage: "wand.and.stars") }
        }
    }
}
