import SwiftUI

struct ArtworkDetailView: View {
    let artwork: Artwork

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AsyncImage(url: URL(string: artwork.imageURL)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.15)).frame(height: 320)
                }
                Text(artwork.title).font(.largeTitle).fontWeight(.semibold)
                Text(artwork.artistName).font(.title3).foregroundStyle(.secondary)
                if let description = artwork.description, !description.isEmpty {
                    Text(description)
                }
                if let prompt = artwork.promptUsed {
                    GroupBox("AI Prompt") {
                        Text(prompt).font(.footnote)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Artwork")
        .navigationBarTitleDisplayMode(.inline)
    }
}
