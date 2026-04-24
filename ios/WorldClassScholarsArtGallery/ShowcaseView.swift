import SwiftUI

struct ShowcaseView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Exhibitions")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(
                            "A showcase-led experience inspired by premium gallery viewing rooms, with large imagery, restrained typography, and editorial spacing."
                        )
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    ForEach(0..<3, id: \.self) { idx in
                        ZStack(alignment: .bottomLeading) {
                            Rectangle()
                                .fill(Color.black.opacity(0.08))
                                .frame(height: 260)
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Curated Room \(idx + 1)")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("Immersive digital exhibition layout")
                            }
                            .padding()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Showcase")
        }
    }
}
