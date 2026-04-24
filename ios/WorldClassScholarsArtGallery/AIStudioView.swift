import SwiftUI

struct AIStudioView: View {
    @StateObject private var vm = AIStudioViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Concept") {
                    TextField("Concept", text: $vm.concept, axis: .vertical)
                    TextField("Style", text: $vm.style)
                    TextField("Mood", text: $vm.mood)
                    TextField("Palette", text: $vm.palette)
                }
                Section("Prompt") {
                    Button("Build Prompt") {
                        Task { await vm.buildPrompt() }
                    }
                    if !vm.generatedPrompt.isEmpty {
                        Text(vm.generatedPrompt).font(.footnote)
                    }
                }
                Section("Generate") {
                    Button("Generate Artwork") {
                        Task { await vm.generate() }
                    }
                    if let url = vm.generatedImageURL {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
            }
            .navigationTitle("AI Studio")
        }
    }
}
